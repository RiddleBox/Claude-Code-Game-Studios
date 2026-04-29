# gameplay/c2_outing_return_cycle/c2_outing_return_cycle.gd
# C2OutingReturnCycle — TODO: 填写模块描述
# 实现 IModule 接口，支持模块化架构

class_name C2OutingReturnCycle
extends Node

## IModule 接口实现
var module_id: String = "c2_outing_return_cycle"
var module_name: String = "c2_outing_return_cycle"  # TODO: 改为中文名
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f2_state_machine", "f3_time_system", "f4_save_system", "c3_fragment_system"]  # 依赖F2状态机、F3时间系统、F4存档系统、C3碎片系统
var optional_dependencies: Array[String] = []
var config_path: String = "res://data/config/c2_outing_return_cycle.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

const MIN_OUTING_INTERVAL: float = 0.5  # 最小外出间隔（分钟）- 测试用
const OUTING_PROBABILITY_PER_TICK: float = 0.3  # 每次tick出发概率（30%）- 测试用
const DEFAULT_COOLDOWN_MINUTES: float = 0.2  # 默认冷却时间（分钟）- 测试用
const MIN_OUTING_DURATION: float = 0.3  # 最短外出时长（分钟）- 测试用
const MAX_OUTING_DURATION: float = 1.0  # 最长外出时长（分钟）- 测试用

## ==================== 信号 ====================

signal departure_triggered(reason: String)  # 外出触发信号
signal departure_accepted()  # 外出被接受（F2状态机允许）
signal departure_declined(reason: String)  # 外出被拒绝
signal return_triggered()  # 返回触发信号
signal state_changed(new_state: String)  # 状态变化信号

## ==================== 私有变量 ====================

var _f1_module: Node = null  # F1窗口系统模块引用
var _f2_module: Node = null  # F2状态机模块引用
var _f3_module: Node = null  # F3时间系统模块引用
var _f4_module: Node = null  # F4存档系统模块引用
var _c3_module: Node = null  # C3碎片系统模块引用
var _current_state: String = "home"  # 当前状态：home, away, returning
var _last_departure_timestamp: int = 0  # 上次出发时间戳
var _cooldown_remaining: float = 0.0  # 冷却剩余时间（分钟）
var _is_outing_active: bool = false  # 是否正在外出
var _outing_duration: float = 0.0  # 本次外出持续时间（分钟）
var _target_outing_duration: float = 0.0  # 本次外出目标时长（分钟）
var _is_returning: bool = false  # 是否正在归来状态

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[C2] 初始化 c2_outing_return_cycle...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取模块引用
	if not _connect_to_modules():
		push_error("[C2] 无法连接到依赖模块")
		return false

	# 加载存档状态
	_load_saved_state()

	# 订阅F3 tick信号
	_connect_to_f3_tick()

	status = IModule.ModuleStatus.INITIALIZED
	print("[C2] c2_outing_return_cycle 初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[C2] 启动 c2_outing_return_cycle...")
	status = IModule.ModuleStatus.STARTING

	# TODO: 实现启动逻辑

	status = IModule.ModuleStatus.RUNNING
	print("[C2] c2_outing_return_cycle 启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[C2] 停止 c2_outing_return_cycle...")
	status = IModule.ModuleStatus.STOPPING

	# TODO: 实现停止逻辑（释放资源、保存状态等）

	status = IModule.ModuleStatus.STOPPED
	print("[C2] c2_outing_return_cycle 已停止")

## IModule.shutdown() 实现
func shutdown() -> void:
	print("[C2] 关闭 c2_outing_return_cycle...")

	# TODO: 清理资源

	status = IModule.ModuleStatus.SHUTDOWN
	print("[C2] c2_outing_return_cycle 已关闭")

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

## ==================== 私有方法 ====================

func _connect_to_modules() -> bool:
	if _f1_module == null:
		_f1_module = get_parent().get_module("f1_window_system")
		if not _f1_module:
			push_warning("[C2] 无法获取F1模块引用（可选）")

	if _f2_module == null:
		_f2_module = get_parent().get_module("f2_state_machine")
		if not _f2_module:
			push_error("[C2] 无法获取F2模块引用")
			return false

	if _f3_module == null:
		_f3_module = get_parent().get_module("f3_time_system")
		if not _f3_module:
			push_error("[C2] 无法获取F3模块引用")
			return false

	if _f4_module == null:
		_f4_module = get_parent().get_module("f4_save_system")
		if not _f4_module:
			push_error("[C2] 无法获取F4模块引用")
			return false

	if _c3_module == null:
		_c3_module = get_parent().get_module("c3_fragment_system")
		if not _c3_module:
			push_error("[C2] 无法获取C3模块引用")
			return false

	print("[C2] 已连接到依赖模块")
	return true

func _load_saved_state() -> void:
	if not _f4_module or not _f4_module.has_method("load"):
		push_warning("[C2] F4模块不可用，使用默认状态")
		_last_departure_timestamp = 0
		_cooldown_remaining = 0.0
		_is_outing_active = false
		return

	var saved_timestamp = _f4_module.load("c2.last_departure_timestamp", 0)
	var saved_is_outing = _f4_module.load("c2.is_outing_active", false)
	var saved_target_duration = _f4_module.load("c2.target_outing_duration", 0.0)

	if saved_timestamp is int and saved_timestamp > 0:
		_last_departure_timestamp = saved_timestamp
		var current_time = Time.get_unix_time_from_system()
		var offline_minutes = float(current_time - saved_timestamp) / 60.0

		if saved_is_outing:
			# 上次退出时正在外出，计算离线期间的状态
			_target_outing_duration = saved_target_duration
			if offline_minutes >= _target_outing_duration:
				# 离线期间已经完成外出，现在已经回家
				_is_outing_active = false
				_cooldown_remaining = max(0.0, DEFAULT_COOLDOWN_MINUTES - (offline_minutes - _target_outing_duration))
				print("[C2] 离线模拟: 上次外出已完成，离线时长: %.1f 分钟，冷却剩余: %.1f 分钟" % [offline_minutes, _cooldown_remaining])
			else:
				# 还在外出中，继续计时
				_is_outing_active = true
				_outing_duration = offline_minutes
				print("[C2] 离线模拟: 仍在外出中，已外出: %.1f 分钟，剩余预计: %.1f 分钟" % [_outing_duration, _target_outing_duration - _outing_duration])
		else:
			# 上次退出时在家，计算冷却剩余
			_cooldown_remaining = max(0.0, DEFAULT_COOLDOWN_MINUTES - offline_minutes)
			print("[C2] 加载存档状态: 上次出发时间戳 = %d, 离线时长: %.1f 分钟, 冷却剩余 = %.1f 分钟" % [saved_timestamp, offline_minutes, _cooldown_remaining])
	else:
		print("[C2] 首次运行，无存档状态")

func _connect_to_f3_tick() -> void:
	if _f3_module and _f3_module.has_signal("tick"):
		_f3_module.tick.connect(_on_f3_tick)
		print("[C2] 已订阅F3 tick信号")
	else:
		push_warning("[C2] F3模块缺少tick信号，无法连接")

func _on_f3_tick(_timestamp: int, delta_minutes: float) -> void:
	# 更新冷却时间
	if _cooldown_remaining > 0:
		_cooldown_remaining = max(0.0, _cooldown_remaining - delta_minutes)

	# 如果不在外出状态，则检查是否触发新的外出
	if not _is_outing_active:
		if _check_departure_trigger(delta_minutes):
			_trigger_departure()
	else:
		# 正在外出状态，累计外出时长
		_outing_duration += delta_minutes
		# 检查是否到了归来时间
		if _outing_duration >= _target_outing_duration:
			_trigger_return()

func _check_departure_trigger(delta_minutes: float) -> bool:
	if _cooldown_remaining > 0:
		return false

	if _current_state == "home":
		var probability = OUTING_PROBABILITY_PER_TICK * delta_minutes
		var roll = randf()
		return roll < probability

	return false

func _trigger_departure() -> void:
	_last_departure_timestamp = Time.get_unix_time_from_system()
	_is_outing_active = true
	_is_returning = false
	_current_state = "away"
	_outing_duration = 0.0
	# 生成随机外出时长
	_target_outing_duration = randf_range(MIN_OUTING_DURATION, MAX_OUTING_DURATION)

	# 保存状态到F4
	if _f4_module and _f4_module.has_method("save"):
		_f4_module.save("c2.last_departure_timestamp", _last_departure_timestamp)
		_f4_module.save("c2.is_outing_active", _is_outing_active)
		_f4_module.save("c2.target_outing_duration", _target_outing_duration)

	# 设置F1外出状态（背景变暗）
	if _f1_module and _f1_module.has_method("set_away_state"):
		_f1_module.set_away_state(true)

	print("[C2] 外出触发！开始外出状态，预计时长: %.1f 分钟" % _target_outing_duration)
	departure_triggered.emit("normal_departure")

	# 尝试通过F2状态机
	if _f2_module and _f2_module.has_method("request_departure"):
		_f2_module.request_departure()
		# 连接F2的反馈信号
		_f2_module.departure_accepted.connect(_on_departure_accepted)
		_f2_module.departure_declined.connect(_on_departure_declined)
	else:
		push_warning("[C2] 无法通过F2请求状态变化")
func _trigger_return() -> void:
	_is_returning = true
	_current_state = "returning"

	print("[C2] 外出结束，开始归来！本次外出时长: %.1f 分钟" % _outing_duration)
	return_triggered.emit()

	# 从C3碎片池获取碎片
	_collect_fragments_from_outing()

	# 恢复F1正常状态（取消背景变暗）
	if _f1_module and _f1_module.has_method("set_away_state"):
		_f1_module.set_away_state(false)

	# 请求F2切换到归来状态
	if _f2_module and _f2_module.has_method("request_return"):
		_f2_module.request_return()

	# 延迟1秒后切换到home状态（模拟归来动画）
	await get_tree().create_timer(1.0).timeout
	_on_return_complete()

## 从外出中收集碎片
func _collect_fragments_from_outing() -> void:
	if not _c3_module:
		push_warning("[C2] C3模块不可用，无法收集碎片")
		return

	# 获取当前游戏时间（如果F3可用）
	var current_hour = -1
	if _f3_module and _f3_module.has_method("get_current_hour"):
		current_hour = _f3_module.get_current_hour()

	# 获取当前亲密度（暂时使用0，后续接入Fe3）
	var current_affinity = 0

	# 从碎片池随机选择1-3个碎片
	var fragment_count = randi_range(1, 3)
	var selected_fragments = _c3_module.pick_random_fragments(fragment_count, current_affinity, current_hour)

	if selected_fragments.is_empty():
		print("[C2] 本次外出未获得碎片")
		return

	# 添加碎片到玩家库
	var added_count = 0
	for frag_id in selected_fragments:
		if _c3_module.add_fragment(frag_id):
			added_count += 1

	print("[C2] 本次外出获得 %d 个碎片: %s" % [added_count, selected_fragments])

func _on_return_complete() -> void:
	_is_outing_active = false
	_is_returning = false
	_current_state = "home"
	_outing_duration = 0.0
	_cooldown_remaining = DEFAULT_COOLDOWN_MINUTES

	# 保存状态到F4
	if _f4_module and _f4_module.has_method("save"):
		_f4_module.save("c2.is_outing_active", _is_outing_active)

	print("[C2] 归来完成，进入冷却状态，冷却时长: %.1f 分钟" % _cooldown_remaining)
	state_changed.emit("home")

func _on_departure_accepted() -> void:
	print("[C2] F2接受外出请求，外出生效")
	departure_accepted.emit()

func _on_departure_declined() -> void:
	print("[C2] F2拒绝外出请求，取消本次外出")
	_is_outing_active = false
	_current_state = "home"

	# 恢复F1正常状态
	if _f1_module and _f1_module.has_method("set_away_state"):
		_f1_module.set_away_state(false)

	departure_declined.emit("F2状态不允许")
