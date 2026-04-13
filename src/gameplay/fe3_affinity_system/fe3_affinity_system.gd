# gameplay/fe3_affinity_system/fe3_affinity_system.gd
# Fe3好感度系统 — 管理用户与角色的好感度等级、分数变化、成长体系
# 实现 IModule 接口，支持模块化架构

class_name Fe3AffinitySystem
extends Node

## IModule 接口实现
var module_id: String = "fe3_affinity_system"
var module_name: String = "好感度系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f4_save_system"]  # 依赖存档系统
var optional_dependencies: Array[String] = ["fe2_memory_system", "fe1_dialogue_system"]
var config_path: String = "res://data/config/fe3_affinity_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================
# 好感度等级枚举
enum AffinityLevel {
	STRANGER = 0,    # 陌生（0~99分）
	FAMILIAR = 1,    # 熟悉（100~299分）
	FOND = 2,        # 好感（300~599分）
	LIKE = 3,        # 喜欢（600~999分）
	INTIMATE = 4     # 亲密（1000分以上）
}

# 各等级分数范围
const LEVEL_RANGES = [
	[0, 99],     # 陌生
	[100, 299],  # 熟悉
	[300, 599],  # 好感
	[600, 999],  # 喜欢
	[1000, 999999] # 亲密
]

# 等级名称
const LEVEL_NAMES = [
	"陌生",
	"熟悉",
	"好感",
	"喜欢",
	"亲密"
]

# 默认初始好感度分数
const DEFAULT_INITIAL_SCORE = 50

# 每日自然衰减分数（连续7天不互动开始衰减）
const DAILY_DECAY_AMOUNT = 5
# 衰减触发天数（连续N天不互动开始衰减）
const DECAY_TRIGGER_DAYS = 7

# 常见互动行为分值配置
const ACTION_SCORES = {
	"mouse_click": 1,          # 点击角色
	"mouse_hover": 0.5,        # 鼠标悬停
	"daily_checkin": 5,        # 每日签到
	"feed_food": 10,           # 投喂食物
	"play_game": 15,           # 一起玩游戏
	"complete_task": 20,       # 完成互动任务
	"special_event": 50,       # 特殊节日/纪念日事件
	"negative_interaction": -10 # 负面互动
}

## ==================== 信号 ====================
signal affinity_changed(old_score: float, new_score: float, delta: float)  # 好感度分数变化
signal level_up(new_level: int, new_level_name: String)  # 好感度升级
signal level_down(new_level: int, new_level_name: String)  # 好感度降级

## ==================== 私有变量 ====================
var _f4_save: Node = null  # 存档系统引用
var _fe2_memory: Node = null  # 记忆系统引用
var _current_score: float = DEFAULT_INITIAL_SCORE  # 当前好感度分数
var _current_level: int = AffinityLevel.STRANGER  # 当前好感度等级
var _last_interaction_time: int = 0  # 上次互动时间戳
var _last_decay_check_time: int = 0  # 上次衰减检查时间戳
var _total_interaction_count: int = 0  # 总互动次数

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[FE3] 初始化好感度系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[FE3] 无法获取App节点")
		return false

	_f4_save = app.get_module("f4_save_system")
	if not _f4_save:
		push_error("[FE3] 无法获取存档系统模块")
		return false

	# 可选依赖：记忆系统
	_fe2_memory = app.get_module("fe2_memory_system")
	if not _fe2_memory:
		print("[FE3] 记忆系统未找到，将跳过记忆记录功能")

	# 从存档加载好感度数据
	_load_from_save()

	# 计算当前等级
	_update_level()

	status = IModule.ModuleStatus.INITIALIZED
	print("[FE3] 好感度系统初始化完成，当前等级: %s (%d 分)" % [LEVEL_NAMES[_current_level], _current_score])
	return true

## IModule.start() 实现
func start() -> bool:
	print("[FE3] 启动好感度系统...")
	status = IModule.ModuleStatus.STARTING

	# 注册存档回调，退出时自动保存好感度数据
	if _f4_save:
		if not _f4_save.is_connected("before_save", _on_before_save): _f4_save.connect("before_save", _on_before_save)

	# 检查离线期间的好感度衰减
	_check_offline_decay()

	status = IModule.ModuleStatus.RUNNING
	print("[FE3] 好感度系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[FE3] 停止 fe3_affinity_system...")
	status = IModule.ModuleStatus.STOPPING

	# 保存好感度数据
	_save_to_save()

	status = IModule.ModuleStatus.STOPPED
	print("[FE3] fe3_affinity_system 已停止")

## IModule.get_module_info() 实现
func get_module_info() -> Dictionary:
	return {
		"id": module_id,
		"name": module_name,
		"version": module_version,
		"category": category,
		"priority": priority,
		"status": status,
		"dependencies": dependencies,
		"optional_dependencies": optional_dependencies,
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共API ====================
## 增加好感度
## @param amount: 增加的分数
## @param reason: 增加原因（会记录到记忆系统）
## @param record_memory: 是否记录到记忆系统
func add_affinity(amount: float, reason: String = "", record_memory: bool = true) -> float:
	if amount <= 0:
		return _current_score

	var old_score = _current_score
	var new_score = clamp(_current_score + amount, 0, 999999)
	var delta = new_score - old_score

	if delta > 0:
		_current_score = new_score
		_last_interaction_time = Time.get_unix_time_from_system()
		_total_interaction_count += 1

		# 触发分数变化事件
		affinity_changed.emit(old_score, new_score, delta)
		print("[FE3] 好感度增加 %.1f，当前: %.1f 分，原因: %s" % [delta, _current_score, reason])

		# 记录到记忆系统
		if record_memory and _fe2_memory:
			_fe2_memory.add_memory(
				reason,
				Fe2MemorySystem.MemoryType.DAILY_INTERACTION,
				["affinity_increase", "interaction"],
				2
			)

		# 检查是否升级
		_update_level()

	return _current_score

## 减少好感度
## @param amount: 减少的分数
## @param reason: 减少原因
## @param record_memory: 是否记录到记忆系统
func reduce_affinity(amount: float, reason: String = "", record_memory: bool = true) -> float:
	if amount <= 0:
		return _current_score

	var old_score = _current_score
	var new_score = clamp(_current_score - amount, 0, 999999)
	var delta = old_score - new_score

	if delta > 0:
		_current_score = new_score
		_last_interaction_time = Time.get_unix_time_from_system()

		# 触发分数变化事件
		affinity_changed.emit(old_score, new_score, -delta)
		print("[FE3] 好感度减少 %.1f，当前: %.1f 分，原因: %s" % [delta, _current_score, reason])

		# 记录到记忆系统
		if record_memory and _fe2_memory:
			_fe2_memory.add_memory(
				reason,
				Fe2MemorySystem.MemoryType.DAILY_INTERACTION,
				["affinity_decrease", "negative_interaction"],
				2
			)

		# 检查是否降级
		_update_level()

	return _current_score

## 记录互动行为（根据行为类型自动增减对应分数）
## @param action_type: 行为类型，对应ACTION_SCORES的key
## @param custom_amount: 自定义分数，不传则使用默认配置
func record_interaction(action_type: String, custom_amount: Variant = null) -> float:
	if not ACTION_SCORES.has(action_type) and custom_amount == null:
		push_warning("[FE3] 未知互动行为类型: %s" % action_type)
		return _current_score

	var amount = custom_amount if custom_amount != null else ACTION_SCORES[action_type]
	var reason = "互动行为: %s" % action_type

	if amount > 0:
		return add_affinity(amount, reason)
	elif amount < 0:
		return reduce_affinity(-amount, reason)
	else:
		return _current_score

## 获取当前好感度分数
func get_current_score() -> float:
	return _current_score

## 获取当前好感度等级
func get_current_level() -> int:
	return _current_level

## 获取当前等级名称
func get_current_level_name() -> String:
	return LEVEL_NAMES[_current_level]

## 获取指定等级的名称
func get_level_name(level: int) -> String:
	if level >= 0 and level < LEVEL_NAMES.size():
		return LEVEL_NAMES[level]
	return ""

## 获取当前等级的进度百分比（0~100）
func get_level_progress() -> float:
	var range_min = LEVEL_RANGES[_current_level][0]
	var range_max = LEVEL_RANGES[_current_level][1]

	if _current_level == AffinityLevel.INTIMATE:
		# 最高级进度按100%计算
		return 100.0

	var progress = ((_current_score - range_min) / (range_max - range_min)) * 100
	return clamp(progress, 0, 100)

## 获取升级到下一级还需要的分数
func get_next_level_required_score() -> float:
	if _current_level == AffinityLevel.INTIMATE:
		# 已经是最高级，不需要再升级
		return 0

	var range_max = LEVEL_RANGES[_current_level][1]
	return max(0, range_max - _current_score + 1)

## 获取总互动次数
func get_total_interaction_count() -> int:
	return _total_interaction_count

## ==================== 私有方法 ====================
## 更新好感度等级（检查是否升级/降级）
func _update_level() -> void:
	var old_level = _current_level

	# 根据分数计算新等级
	for i in range(LEVEL_RANGES.size()):
		var min_score = LEVEL_RANGES[i][0]
		var max_score = LEVEL_RANGES[i][1]
		if _current_score >= min_score and _current_score <= max_score:
			_current_level = i
			break

	# 等级变化触发事件
	if _current_level > old_level:
		level_up.emit(_current_level, LEVEL_NAMES[_current_level])
		print("[FE3] 好感度升级！当前等级: %s" % LEVEL_NAMES[_current_level])

		# 记录到记忆系统
		if _fe2_memory:
			_fe2_memory.add_memory(
				"好感度升级到%s" % LEVEL_NAMES[_current_level],
				Fe2MemorySystem.MemoryType.SPECIAL_EVENT,
				["affinity_level_up", "milestone"],
				8
			)
	elif _current_level < old_level:
		level_down.emit(_current_level, LEVEL_NAMES[_current_level])
		print("[FE3] 好感度降级！当前等级: %s" % LEVEL_NAMES[_current_level])

		# 记录到记忆系统
		if _fe2_memory:
			_fe2_memory.add_memory(
				"好感度降级到%s" % LEVEL_NAMES[_current_level],
				Fe2MemorySystem.MemoryType.SPECIAL_EVENT,
				["affinity_level_down", "event"],
				5
			)

## 检查离线期间的好感度衰减
func _check_offline_decay() -> void:
	var total_decay = 0.0  # 提前声明变量，避免作用域问题
	if _last_interaction_time == 0:
		# 首次启动，没有互动记录
		_last_interaction_time = Time.get_unix_time_from_system()
		return

	var now = Time.get_unix_time_from_system()
	var days_since_last_interaction = (now - _last_interaction_time) / 86400  # 转成天数

	if days_since_last_interaction >= DECAY_TRIGGER_DAYS:
		# 超过7天没互动，开始衰减
		var decay_days = int(floor(days_since_last_interaction - DECAY_TRIGGER_DAYS + 1))
		total_decay = decay_days * DAILY_DECAY_AMOUNT

		if total_decay > 0:
			reduce_affinity(
				total_decay,
				"离线 %.1f 天未互动，好感度自然衰减" % days_since_last_interaction,
				true
			)

	_last_decay_check_time = now
	print("[FE3] 离线衰减检查完成，距离上次互动 %.1f 天，衰减了 %.1f 分" % [days_since_last_interaction, min(total_decay, _current_score)])

## 从存档加载好感度数据
func _load_from_save() -> void:
	if not _f4_save:
		return

	# 读取存档数据
	_current_score = _f4_save.load("affinity_system.current_score", DEFAULT_INITIAL_SCORE)
	_last_interaction_time = _f4_save.load("affinity_system.last_interaction_time", 0)
	_last_decay_check_time = _f4_save.load("affinity_system.last_decay_check_time", 0)
	_total_interaction_count = _f4_save.load("affinity_system.total_interaction_count", 0)

	# 分数范围检查
	_current_score = clamp(_current_score, 0, 999999)

## 保存好感度数据到存档
func _save_to_save() -> void:
	if not _f4_save:
		return

	_f4_save.save("affinity_system.current_score", _current_score)
	_f4_save.save("affinity_system.current_level", _current_level)
	_f4_save.save("affinity_system.last_interaction_time", _last_interaction_time)
	_f4_save.save("affinity_system.last_decay_check_time", _last_decay_check_time)
	_f4_save.save("affinity_system.total_interaction_count", _total_interaction_count)
	print("[FE3] 好感度数据已保存到存档")

## 存档前回调
func _on_before_save() -> void:
	_save_to_save()
