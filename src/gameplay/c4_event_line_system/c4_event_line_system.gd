# gameplay/c4_event_line_system/c4_event_line_system.gd
# C4 — 事件线系统（Event Line System）
# 游戏叙事内容的结构层
# 实现 IModule 接口，支持模块化架构

class_name C4EventLineSystem
extends Node

## IModule 接口实现
var module_id: String = "c4_event_line_system"
var module_name: String = "事件线系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f4_save_system", "f3_time_system"]
var optional_dependencies: Array[String] = ["c3_fragment_system", "c5_personality_variable_system"]
var config_path: String = "res://data/config/c4_event_line_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 分支事件触发概率
const BRANCH_TRIGGER_CHANCE: float = 0.40

## 分支事件最短触发间隔（分钟）
const BRANCH_COOLDOWN_MINUTES: int = 60

## 滚动窗口大小，防止分支事件短期重复
const BRANCH_REPEAT_WINDOW: int = 5

## 存档键名
const SAVE_KEY_MAIN_PROGRESS: String = "c4.main_line_progress"
const SAVE_KEY_BRANCH_COOLDOWN: String = "c4.branch_cooldown"
const SAVE_KEY_USED_BRANCHES: String = "c4.used_branch_events"

## 数据文件路径
const MAIN_LINE_PATH: String = "res://data/config/main_line.json"
const BRANCH_EVENTS_PATH: String = "res://data/config/branch_events.json"
const GENERAL_FRAGMENTS_PATH: String = "res://data/config/general_fragments.json"

## ==================== 信号 ====================

## 主干事件节点触发时
signal main_line_node_triggered(node_id: String, variant_id: String)

## 分支事件触发时
signal branch_event_triggered(event_id: String, variant_id: String)

## ==================== 私有变量 ====================

## F4 存档系统引用
var _f4_save: Node = null

## F3 时间系统引用
var _f3_time: Node = null

## C3 碎片系统引用（可选）
var _c3_fragments: Node = null

## C5 性格变量系统引用（可选）
var _c5_personality: Node = null

## 主干事件线数据
var _main_line: Dictionary = {}

## 分支事件数据
var _branch_events: Array = []

## 通用碎片池
var _general_fragments: Array = []

## 主干事件线进度
var _main_line_progress: Dictionary = {
	"current_node_index": 0,
	"completed": false
}

## 上次分支事件触发的时间戳
var _branch_cooldown: int = 0

## 已触发过的分支事件ID（滚动窗口）
var _used_branch_events: Array = []

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[C4] 初始化事件线系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[C4] 无法获取 App 节点")
		return false

	_f4_save = app.get_module("f4_save_system")
	if not _f4_save:
		push_error("[C4] 无法获取 F4 存档系统模块")
		return false

	_f3_time = app.get_module("f3_time_system")
	if not _f3_time:
		push_error("[C4] 无法获取 F3 时间系统模块")
		return false

	# 获取可选依赖
	_c3_fragments = app.get_module("c3_fragment_system")
	_c5_personality = app.get_module("c5_personality_variable_system")

	# 1. 加载数据文件
	_load_data_files()

	# 2. 从 F4 加载进度
	_load_from_save()

	status = IModule.ModuleStatus.INITIALIZED
	print("[C4] 事件线系统初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[C4] 启动事件线系统...")
	status = IModule.ModuleStatus.STARTING

	status = IModule.ModuleStatus.RUNNING
	print("[C4] 事件线系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[C4] 停止事件线系统...")
	status = IModule.ModuleStatus.STOPPING

	# 保存到 F4
	_save_to_save()

	status = IModule.ModuleStatus.STOPPED
	print("[C4] 事件线系统已停止")

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
		"main_line_progress": _main_line_progress.duplicate(),
		"branch_events_available": _branch_events.size(),
		"general_fragments_available": _general_fragments.size()
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共 API ====================

## 获取外出内容（C2调用此接口）
func get_outing_content() -> Array:
	print("[C4] 获取外出内容...")

	# 1. 检查主干事件
	var main_result = _try_main_line()
	if not main_result.is_empty():
		print("[C4] 触发主干事件")
		_save_to_save()
		return main_result

	# 2. 检查分支事件
	var branch_result = _try_branch_event()
	if not branch_result.is_empty():
		print("[C4] 触发分支事件")
		_save_to_save()
		return branch_result

	# 3. 通用池保底
	var general_result = _get_general_fragment()
	print("[C4] 使用通用碎片")
	_save_to_save()
	return general_result

## ==================== 私有方法 ====================

## 加载数据文件
func _load_data_files() -> void:
	# 加载主干事件线
	if FileAccess.file_exists(MAIN_LINE_PATH):
		var file = FileAccess.open(MAIN_LINE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_DICTIONARY:
				_main_line = parsed.duplicate()
				print("[C4] 加载主干事件线: %d 个节点" % _main_line.get("nodes", []).size())
			else:
				push_warning("[C4] 主干事件线格式错误")
	else:
		push_warning("[C4] 主干事件线文件缺失")

	# 加载分支事件
	if FileAccess.file_exists(BRANCH_EVENTS_PATH):
		var file = FileAccess.open(BRANCH_EVENTS_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_ARRAY:
				_branch_events = parsed.duplicate()
				print("[C4] 加载分支事件: %d 个" % _branch_events.size())
			else:
				push_warning("[C4] 分支事件格式错误")
	else:
		push_warning("[C4] 分支事件文件缺失")

	# 加载通用碎片池
	if FileAccess.file_exists(GENERAL_FRAGMENTS_PATH):
		var file = FileAccess.open(GENERAL_FRAGMENTS_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_ARRAY:
				_general_fragments = parsed.duplicate()
				print("[C4] 加载通用碎片: %d 条" % _general_fragments.size())
			else:
				push_warning("[C4] 通用碎片格式错误")
	else:
		push_warning("[C4] 通用碎片文件缺失")
		# 添加保底通用碎片
		_general_fragments = [
			{
				"content_id": "general_fallback_001",
				"type": "dialogue",
				"text": "它今天没说什么特别的，只是安静地待着。",
				"emotion_tag": "peaceful",
				"personality_weights": {}
			}
		]

## 尝试触发主干事件
func _try_main_line() -> Array:
	if _main_line_progress.completed:
		return []

	var nodes = _main_line.get("nodes", [])
	if nodes.is_empty():
		return []

	var current_index = _main_line_progress.current_node_index
	if current_index >= nodes.size():
		_main_line_progress.completed = true
		return []

	var node = nodes[current_index]
	if not _check_main_line_conditions(node):
		return []

	# 条件满足，选择变体
	var variants = node.get("variants", [])
	if variants.is_empty():
		return []

	var best_variant = _select_best_variant(variants)
	if not best_variant:
		return []

	# 推进进度
	_main_line_progress.current_node_index += 1
	if _main_line_progress.current_node_index >= nodes.size():
		_main_line_progress.completed = true

	main_line_node_triggered.emit(
		node.get("node_id", ""),
		best_variant.get("variant_id", "")
	)

	return best_variant.get("fragments", [])

## 检查主干事件解锁条件
func _check_main_line_conditions(node: Dictionary) -> bool:
	var conditions = node.get("unlock_conditions", {})
	var min_fragments = conditions.get("min_fragments", 0)
	var min_minutes = conditions.get("min_online_minutes", 0)

	# 检查碎片数
	if _c3_fragments and _c3_fragments.has_method("get_all"):
		var fragment_count = _c3_fragments.get_all().size()
		if fragment_count < min_fragments:
			return false
	elif min_fragments > 0:
		# C3不可用时，碎片条件视为不满足
		return false

	# 检查在线时长
	if _f3_time and _f3_time.has_method("get_total_online_minutes"):
		var minutes = _f3_time.get_total_online_minutes()
		if minutes < min_minutes:
			return false
	elif min_minutes > 0:
		# F3不可用时，时间条件视为不满足
		return false

	return true

## 尝试触发分支事件
func _try_branch_event() -> Array:
	if _branch_events.is_empty():
		return []

	# 检查冷却
	var now = Time.get_unix_time_from_system()
	var cooldown_seconds = BRANCH_COOLDOWN_MINUTES * 60
	if now - _branch_cooldown < cooldown_seconds:
		return []

	# 检查概率
	if randf() > BRANCH_TRIGGER_CHANCE:
		return []

	# 过滤已用事件
	var candidates = []
	for event in _branch_events:
		var event_id = event.get("event_id", "")
		if not _used_branch_events.has(event_id):
			candidates.append(event)

	if candidates.is_empty():
		return []

	# 选择最佳分支事件
	var best_event = _select_best_event(candidates)
	if not best_event:
		return []

	# 选择最佳变体
	var variants = best_event.get("variants", [])
	if variants.is_empty():
		return []

	var best_variant = _select_best_variant(variants)
	if not best_variant:
		return []

	# 更新状态
	_branch_cooldown = now
	var event_id = best_event.get("event_id", "")
	_used_branch_events.append(event_id)

	# 维护滚动窗口
	while _used_branch_events.size() > BRANCH_REPEAT_WINDOW:
		_used_branch_events.pop_front()

	branch_event_triggered.emit(event_id, best_variant.get("variant_id", ""))

	return best_variant.get("fragments", [])

## 从通用池获取碎片
func _get_general_fragment() -> Array:
	if _general_fragments.is_empty():
		return []

	# 用C5选择最佳通用碎片
	var best_fragment = _select_best_general_fragment()
	if not best_fragment:
		return [_general_fragments[0].duplicate()]

	return [best_fragment.duplicate()]

## 选择最佳变体
func _select_best_variant(variants: Array) -> Dictionary:
	if variants.is_empty():
		return {}

	if not _c5_personality or not _c5_personality.has_method("score_content"):
		# C5不可用时，返回第一个变体
		return variants[0]

	var best_score = -1.0
	var best_variant = {}

	for variant in variants:
		var weights = variant.get("personality_weights", {})
		var score = _c5_personality.score_content(weights)
		if score > best_score:
			best_score = score
			best_variant = variant

	return best_variant

## 选择最佳分支事件
func _select_best_event(events: Array) -> Dictionary:
	if events.is_empty():
		return {}

	if not _c5_personality or not _c5_personality.has_method("score_content"):
		# C5不可用时，返回第一个事件
		return events[0]

	var best_score = -1.0
	var best_event = {}

	for event in events:
		var weights = event.get("personality_weights", {})
		var score = _c5_personality.score_content(weights)
		# 乘以触发权重
		score *= event.get("trigger_weight", 1.0)
		if score > best_score:
			best_score = score
			best_event = event

	return best_event

## 选择最佳通用碎片
func _select_best_general_fragment() -> Dictionary:
	if _general_fragments.is_empty():
		return {}

	if not _c5_personality or not _c5_personality.has_method("score_content"):
		# C5不可用时，随机选择
		return _general_fragments[randi() % _general_fragments.size()]

	var best_score = -1.0
	var best_fragment = {}

	for fragment in _general_fragments:
		var weights = fragment.get("personality_weights", {})
		var score = _c5_personality.score_content(weights)
		if score > best_score:
			best_score = score
			best_fragment = fragment

	return best_fragment

## 从 F4 加载数据
func _load_from_save() -> void:
	if not _f4_save:
		return

	var saved_progress = _f4_save.load(SAVE_KEY_MAIN_PROGRESS, {})
	if typeof(saved_progress) == TYPE_DICTIONARY:
		_main_line_progress = saved_progress.duplicate()

	_branch_cooldown = _f4_save.load(SAVE_KEY_BRANCH_COOLDOWN, 0)

	var saved_branches = _f4_save.load(SAVE_KEY_USED_BRANCHES, [])
	if typeof(saved_branches) == TYPE_ARRAY:
		_used_branch_events = saved_branches.duplicate()

	print("[C4] 从存档加载了进度状态")

## 保存到 F4
func _save_to_save() -> void:
	if not _f4_save:
		return

	_f4_save.save(SAVE_KEY_MAIN_PROGRESS, _main_line_progress.duplicate())
	_f4_save.save(SAVE_KEY_BRANCH_COOLDOWN, _branch_cooldown)
	_f4_save.save(SAVE_KEY_USED_BRANCHES, _used_branch_events.duplicate())
