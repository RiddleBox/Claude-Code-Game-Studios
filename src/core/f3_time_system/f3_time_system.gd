# core/f3_time_system/f3_time_system.gd
# F3 时间/节奏系统模块化版本
# 实现IModule接口，支持模块化架构
# 简化版：F4存档系统依赖标记为TODO，使用内存临时存储

class_name F3TimeSystem
extends Node

## IModule接口实现
var module_id: String = "f3_time_system"
var module_name: String = "时间/节奏系统"
var module_version: String = "1.0.0"
# TODO: 依赖F4存档系统，目前标记为可选依赖，允许降级运行
var dependencies: Array[String] = []  # 原设计依赖F4，简化版为空
var optional_dependencies: Array[String] = ["f4_save_system"]
var config_path: String = "res://data/config/f3_time_system.json"
var category: String = "core"
var priority: String = "high"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 离线时长上限（分钟）— 调优参数
const MAX_OFFLINE_MINUTES: float = 1440.0  # 24小时
## 离线补算批次大小（分钟）— 调优参数
const OFFLINE_TICK_BATCH_SIZE: float = 60.0  # 60分钟/批
## 在线tick间隔（秒）
const ONLINE_TICK_INTERVAL: float = 60.0  # 60秒 = 1分钟

## ==================== 系统状态 ====================

enum TimeSystemMode {
	CATCHING_UP,  # 补算离线进度
	RUNNING       # 正常运行
}

## 公共信号 (与GDD一致)
signal tick(current_timestamp: int, delta_minutes: float)
signal catching_up_completed(total_offline_minutes: float)

## 私有变量
var _mode: TimeSystemMode = TimeSystemMode.CATCHING_UP
var _timer: Timer = null
var _last_online_timestamp: int = 0  # TODO: 临时内存存储，应通过F4读写
var _total_minutes_played: float = 0.0
var _total_minutes_elapsed: float = 0.0
var _is_catching_up: bool = false
var _f4_module: Node = null  # F4存档系统模块引用

## ==================== IModule接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[F3] 初始化时间/节奏系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 应用配置
	# TODO: 从config加载参数值（如MAX_OFFLINE_MINUTES等）

	# 获取当前时间戳
	var current_timestamp: int = Time.get_unix_time_from_system()

	# 尝试从F4存档系统读取last_online_timestamp
	var loaded_timestamp = _load_last_timestamp_from_f4()
	if loaded_timestamp > 0:
		_last_online_timestamp = loaded_timestamp
		print("[F3] 从F4加载时间戳: %d" % _last_online_timestamp)
	else:
		# F4不可用或返回0，使用当前时间戳
		_last_online_timestamp = current_timestamp
		print("[F3] 警告：F4存档系统不可用或返回0，使用内存临时存储时间戳")

	# 计算离线时长
	var offline_minutes: float = _calculate_offline_minutes(current_timestamp)
	print("[F3] 离线时长计算: %0.1f 分钟" % offline_minutes)

	# 设置补算模式
	if offline_minutes > 0:
		_mode = TimeSystemMode.CATCHING_UP
		_is_catching_up = true
		print("[F3] 进入补算模式，离线时长: %0.1f 分钟" % offline_minutes)
	else:
		_mode = TimeSystemMode.RUNNING
		_is_catching_up = false
		print("[F3] 无离线时长，直接进入运行模式")

	# 创建计时器节点
	_timer = Timer.new()
	_timer.name = "TickTimer"
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)

	status = IModule.ModuleStatus.INITIALIZED
	print("[F3] 时间/节奏系统初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[F3] 启动时间/节奏系统...")
	status = IModule.ModuleStatus.STARTING

	# 开始补算离线进度（如果需要）
	if _mode == TimeSystemMode.CATCHING_UP:
		_start_catching_up()
	else:
		_start_normal_running()

	status = IModule.ModuleStatus.RUNNING
	print("[F3] 时间/节奏系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[F3] 停止时间/节奏系统...")
	status = IModule.ModuleStatus.STOPPING

	if _timer and _timer.is_inside_tree():
		_timer.stop()
		_timer.queue_free()
		_timer = null

	# 保存当前时间戳到F4存档系统
	var current_timestamp: int = Time.get_unix_time_from_system()
	var save_success = _save_last_timestamp_to_f4()
	if save_success:
		print("[F3] 时间戳已保存到F4: %d" % current_timestamp)
	else:
		print("[F3] 警告: 时间戳保存到F4失败")
## IModule.shutdown() 实现
	func shutdown() -> void:
	print("[F3] 关闭时间/节奏系统...")

	# 清理资源
	if _timer:
		_timer.queue_free()
		_timer = null

	# 重置状态
	_last_online_timestamp = 0
	_total_minutes_played = 0.0
	_total_minutes_elapsed = 0.0
	_is_catching_up = false

	status = IModule.ModuleStatus.SHUTDOWN
	print("[F3] 时间/节奏系统已关闭")

## IModule.reload_config() 实现
func reload_config(new_config: Dictionary = {}) -> bool:
	print("[F3] 重新加载配置")
	# TODO: 实现配置热重载
	return true

## IModule.handle_error() 实现
func handle_error(error: Dictionary) -> bool:
	last_error = error
	status = IModule.ModuleStatus.ERROR
	push_error("[F3] 模块错误: %s" % error.get("message", "Unknown error"))
	return false

## IModule.health_check() 实现
func health_check() -> Dictionary:
	var issues: Array[String] = []

	if status != IModule.ModuleStatus.RUNNING:
		issues.append("模块未运行")

	if not _timer:
		issues.append("计时器未初始化")

	# TODO: 检查F4存档系统连接状态（简化版跳过）

	return {
		"healthy": issues.is_empty() and status == IModule.ModuleStatus.RUNNING,
		"issues": issues
	}


## ==================== F4存档集成辅助方法 ====================

## 获取F4存档系统模块引用
func _get_f4_module() -> Node:
	if _f4_module:
		return _f4_module

	# 通过App节点查找F4模块
	var app = get_node_or_null("/root/App")
	if app and app.has_method("get_module"):
		_f4_module = app.get_module("f4_save_system")
		if _f4_module:
			print("[F3] F4存档系统模块引用获取成功")
		else:
			print("[F3] 警告: F4存档系统模块未找到")

	return _f4_module

## 从F4加载最后在线时间戳
func _load_last_timestamp_from_f4() -> int:
	var f4 = _get_f4_module()
	if not f4:
		print("[F3] F4存档系统不可用，使用内存存储")
		return 0

	# 使用F4的load API
	if f4.has_method("load"):
		var loaded = f4.load("f3.last_online_timestamp", 0)
		if loaded is int:
			print("[F3] 从F4加载时间戳: %d" % loaded)
			return loaded
		else:
			print("[F3] 警告: 从F4加载的时间戳类型错误")

	return 0

## 保存最后在线时间戳到F4
func _save_last_timestamp_to_f4() -> bool:
	var f4 = _get_f4_module()
	if not f4:
		print("[F3] F4存档系统不可用，跳过保存")
		return false

	# 使用F4的save API
	if f4.has_method("save"):
		var success = f4.save("f3.last_online_timestamp", _last_online_timestamp)
		if success:
			print("[F3] 时间戳保存到F4: %d" % _last_online_timestamp)
		else:
			print("[F3] 警告: 时间戳保存到F4失败")
		return success

	return false

## ==================== 核心时间逻辑 ====================

## 计算离线时长（分钟）
func _calculate_offline_minutes(current_timestamp: int) -> float:
	# 边界情况：系统时钟被调回
	if current_timestamp <= _last_online_timestamp:
		print("[F3] 系统时钟被调回，不计算离线时长")
		return 0.0

	var seconds_diff: float = float(current_timestamp - _last_online_timestamp)
	var minutes_diff: float = seconds_diff / 60.0

	# 应用上限
	if minutes_diff > MAX_OFFLINE_MINUTES:
		print("[F3] 离线时长超过上限 %0.1f 分钟，截断" % MAX_OFFLINE_MINUTES)
		minutes_diff = MAX_OFFLINE_MINUTES

	return minutes_diff

## 开始补算离线进度
	func _start_catching_up() -> void:
	print("[F3] 开始补算离线进度...")

	var current_timestamp: int = Time.get_unix_time_from_system()
	var offline_minutes: float = _calculate_offline_minutes(current_timestamp)

	if offline_minutes <= 0:
		print("[F3] 无离线时长需要补算，直接进入运行模式")
		_mode = TimeSystemMode.RUNNING
		_start_normal_running()
		return

	# 计算批次数量
	var batch_count: int = ceil(offline_minutes / OFFLINE_TICK_BATCH_SIZE)
	print("[F3] 离线补算: %0.1f 分钟，分 %d 批，每批 %0.1f 分钟" % [
		offline_minutes, batch_count, OFFLINE_TICK_BATCH_SIZE
	])

	# 立即补算所有批次（简化版：同步处理）
	# TODO: 考虑异步分批处理以避免帧率卡顿
	for batch_index in range(batch_count):
		var remaining_minutes: float = offline_minutes - (batch_index * OFFLINE_TICK_BATCH_SIZE)
		var batch_minutes: float = min(OFFLINE_TICK_BATCH_SIZE, remaining_minutes)

		# 发出补算tick
		var batch_timestamp: int = _last_online_timestamp + int((batch_index * OFFLINE_TICK_BATCH_SIZE * 60) + (batch_minutes * 60) / 2)
		_emit_tick(batch_timestamp, batch_minutes)

		# 更新累计时间
		_total_minutes_elapsed += batch_minutes
		# 注意：补算期间不计入在线时长

		print("[F3] 补算批次 %d/%d: %0.1f 分钟" % [batch_index + 1, batch_count, batch_minutes])

	# 更新最后在线时间戳（补算完成后）
	_last_online_timestamp = current_timestamp

	# 补算完成，切换到运行模式
	_mode = TimeSystemMode.RUNNING
	_is_catching_up = false

	# 广播补算完成信号
	catching_up_completed.emit(offline_minutes)
	print("[F3] 离线补算完成，总计 %0.1f 分钟" % offline_minutes)

	# 开始正常运行
	_start_normal_running()

## 开始正常运行（每分钟tick）
	func _start_normal_running() -> void:
	print("[F3] 开始正常运行（每分钟tick）")

	if not _timer:
		push_error("[F3] 计时器未初始化，无法启动正常运行")
		return

	# 设置计时器
	_timer.wait_time = ONLINE_TICK_INTERVAL
	_timer.one_shot = false
	_timer.start()

	print("[F3] 计时器启动，间隔 %0.1f 秒" % ONLINE_TICK_INTERVAL)

## 计时器超时回调
func _on_timer_timeout() -> void:
	var current_timestamp: int = Time.get_unix_time_from_system()

	# 发出正常tick（1分钟）
	_emit_tick(current_timestamp, 1.0)

	# 更新累计时间
	_total_minutes_played += 1.0
	_total_minutes_elapsed += 1.0

	# 更新最后在线时间戳
	_last_online_timestamp = current_timestamp

## 发出tick信号（统一入口）
func _emit_tick(timestamp: int, delta_minutes: float) -> void:
	tick.emit(timestamp, delta_minutes)
	#print("[F3] Tick: 时间戳 %d, Δ%0.1f 分钟" % [timestamp, delta_minutes])

## ==================== 公共查询接口 ====================

## 获取当前Unix时间戳
func get_current_timestamp() -> int:
	return Time.get_unix_time_from_system()

## 获取游戏总在线分钟数（不含离线）
func get_total_minutes_played() -> float:
	return _total_minutes_played

## 获取游戏总流逝分钟数（含离线）
func get_total_minutes_elapsed() -> float:
	return _total_minutes_elapsed

## 获取系统当前模式
func get_mode() -> TimeSystemMode:
	return _mode

## 检查是否在补算离线进度
func is_catching_up() -> bool:
	return _is_catching_up

## ==================== 调试工具 ====================

## 模拟时间流逝（用于测试）
func simulate_time_passed(minutes: float) -> void:
	print("[F3] 模拟时间流逝: %0.1f 分钟" % minutes)

	var current_timestamp: int = Time.get_unix_time_from_system()
	var simulated_timestamp: int = current_timestamp + int(minutes * 60)

	# 直接发出tick（跳过计时器）
	_emit_tick(simulated_timestamp, minutes)

	# 更新累计时间
	if _mode == TimeSystemMode.RUNNING:
		_total_minutes_played += minutes
	_total_minutes_elapsed += minutes

	# 更新最后在线时间戳
	_last_online_timestamp = simulated_timestamp

## 重置系统状态（用于测试）
func reset_for_testing() -> void:
	print("[F3] 重置系统状态（测试模式）")

	if _timer and _timer.is_inside_tree():
		_timer.stop()

	_last_online_timestamp = Time.get_unix_time_from_system()
	_total_minutes_played = 0.0
	_total_minutes_elapsed = 0.0
	_is_catching_up = false
	_mode = TimeSystemMode.RUNNING

	print("[F3] 系统已重置，当前时间戳: %d" % _last_online_timestamp)
