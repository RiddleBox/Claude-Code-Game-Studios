# gameplay/fe6_notification_system/fe6_notification_system.gd
# Fe6 — 通知/提醒系统（Notification System）
# 「通知是留痕，不是打断」
# 实现 IModule 接口，支持模块化架构

class_name Fe6NotificationSystem
extends Node

## IModule 接口实现
var module_id: String = "fe6_notification_system"
var module_name: String = "通知提醒系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f1_window_system"]
var optional_dependencies: Array[String] = ["c2_outing_return_cycle", "c4_event_line_system", "c5_personality_variable_system", "fe2_memory_system", "fe1_dialogue_system"]
var config_path: String = "res://data/config/fe6_notification_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 强度阈值
const SUBTLE_THRESHOLD: float = 0.3
const EXPRESSIVE_THRESHOLD: float = 0.7

## 存档键名
const SAVE_KEY_DND_MODE: String = "fe6.dnd_mode"

## ==================== 枚举 ====================

## 通知优先级
enum NotificationPriority {
	LOW,      # 低优先级
	NORMAL,   # 普通优先级
	HIGH,     # 高优先级
	URGENT    # 紧急优先级
}

## 托盘状态
enum TrayState {
	NORMAL,     # 正常状态
	NOTICE,     # 有通知
	ATTENTION   # 需要注意
}

## ==================== 信号 ====================

## 通知显示时触发
signal notification_shown(notification_id: String, priority: int)

## 通知消除时触发
signal notification_dismissed(notification_id: String)

## 纸条未读时触发
signal note_unread_on_return()

## ==================== 私有变量 ====================

## F1 窗口系统引用
var _f1_window: Node = null

## C2 外出-归来循环引用（可选）
var _c2_outing: Node = null

## C4 事件线系统引用（可选）
var _c4_events: Node = null

## C5 性格变量系统引用（可选）
var _c5_personality: Node = null

## Fe1 对话系统引用（可选）
var _fe1_dialogue: Node = null

## Fe2 记忆系统引用（可选）
var _fe2_memory: Node = null

## 通知队列：[{id, text, priority, timestamp}]
var _notification_queue: Array = []

## 勿扰模式
var _dnd_mode: bool = false

## 当前通知强度（外出时锁定）
var _current_intensity: float = 0.5

## 纸条显示状态
var _note_visible: bool = false

## 纸条是否被注意到
var _note_acknowledged: bool = false

## 泄漏内容提示状态
var _leak_hint_visible: bool = false

## 托盘当前状态
var _tray_state: int = TrayState.NORMAL

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[Fe6] 初始化通知提醒系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[Fe6] 无法获取 App 节点")
		return false

	_f1_window = app.get_module("f1_window_system")
	if not _f1_window:
		push_error("[Fe6] 无法获取 F1 窗口系统模块")
		return false

	# 获取可选依赖
	_c2_outing = app.get_module("c2_outing_return_cycle")
	_c4_events = app.get_module("c4_event_line_system")
	_c5_personality = app.get_module("c5_personality_variable_system")
	_fe1_dialogue = app.get_module("fe1_dialogue_system")
	_fe2_memory = app.get_module("fe2_memory_system")

	# 从 F4 加载设置
	_load_from_save()

	# 订阅信号
	_subscribe_signals()

	status = IModule.ModuleStatus.INITIALIZED
	print("[Fe6] 通知提醒系统初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[Fe6] 启动通知提醒系统...")
	status = IModule.ModuleStatus.STARTING

	status = IModule.ModuleStatus.RUNNING
	print("[Fe6] 通知提醒系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[Fe6] 停止通知提醒系统...")
	status = IModule.ModuleStatus.STOPPING

	# 保存设置
	_save_to_save()

	status = IModule.ModuleStatus.STOPPED
	print("[Fe6] 通知提醒系统已停止")

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
		"dnd_mode": _dnd_mode,
		"notification_count": _notification_queue.size(),
		"note_visible": _note_visible,
		"leak_hint_visible": _leak_hint_visible
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共 API ====================

## 显示通知
func show_notification(text: String, notif_priority: int = NotificationPriority.NORMAL) -> String:
	if _dnd_mode and notif_priority < NotificationPriority.HIGH:
		print("[Fe6] 勿扰模式，忽略低优先级通知")
		return ""

	var notification_id = "notif_" + str(Time.get_ticks_msec())
	var notif_data = {
		"id": notification_id,
		"text": text,
		"priority": notif_priority,
		"timestamp": Time.get_ticks_msec()
	}

	_notification_queue.append(notif_data)
	_notification_queue.sort_custom(func(a, b): return a.priority > b.priority)

	notification_shown.emit(notification_id, priority)
	print("[Fe6] 显示通知: %s (priority: %d)" % [text, priority])

	# 更新托盘状态
	_update_tray_state()

	return notification_id

## 消除通知
func dismiss_notification(notification_id: String) -> void:
	var index = -1
	for i in range(_notification_queue.size()):
		if _notification_queue[i].id == notification_id:
			index = i
			break

	if index >= 0:
		_notification_queue.remove_at(index)
		notification_dismissed.emit(notification_id)
		print("[Fe6] 通知已消除: %s" % notification_id)
		_update_tray_state()

## 获取所有通知
func get_all_notifications() -> Array:
	return _notification_queue.duplicate()

## 设置勿扰模式
func set_dnd_mode(enabled: bool) -> void:
	_dnd_mode = enabled
	_save_to_save()
	print("[Fe6] 勿扰模式: %s" % str(enabled))

## 获取勿扰模式
func get_dnd_mode() -> bool:
	return _dnd_mode

## 玩家注意到纸条
func acknowledge_note() -> void:
	_note_acknowledged = true
	print("[Fe6] 纸条已被注意到")

## ==================== 私有方法 ====================

## 订阅信号
func _subscribe_signals() -> void:
	# 订阅 C2 外出信号
	if _c2_outing:
		if _c2_outing.has_signal("character_departed"):
			_c2_outing.character_departed.connect(_on_character_departed)
			print("[Fe6] 已订阅 C2 character_departed 信号")
		if _c2_outing.has_signal("character_returned"):
			_c2_outing.character_returned.connect(_on_character_returned)
			print("[Fe6] 已订阅 C2 character_returned 信号")

	# 订阅 Fe2 泄漏内容信号
	if _fe2_memory:
		if _fe2_memory.has_signal("leak_content_available"):
			_fe2_memory.leak_content_available.connect(_on_leak_content_available)
			print("[Fe6] 已订阅 Fe2 leak_content_available 信号")

	# 订阅 Fe1 归来提示确认信号
	if _fe1_dialogue:
		if _fe1_dialogue.has_signal("return_hint_acknowledged"):
			_fe1_dialogue.return_hint_acknowledged.connect(_on_return_hint_acknowledged)
			print("[Fe6] 已订阅 Fe1 return_hint_acknowledged 信号")

## 获取通知强度
func _get_notification_intensity() -> float:
	if _c5_personality and _c5_personality.has_method("get_axis"):
		# 根据性格计算强度：温暖+胆量决定表现性
		var warmth = _c5_personality.get_axis("warmth")
		var boldness = _c5_personality.get_axis("boldness")
		return (warmth + boldness) / 2.0
	return 0.5

## 更新托盘状态
func _update_tray_state() -> void:
	var new_state = TrayState.NORMAL

	# 检查高优先级通知
	for notif in _notification_queue:
		if notif.priority >= NotificationPriority.HIGH:
			new_state = TrayState.ATTENTION
			break
		elif notif.priority >= NotificationPriority.NORMAL:
			new_state = TrayState.NOTICE

	# 检查泄漏内容提示
	if _leak_hint_visible and _current_intensity >= EXPRESSIVE_THRESHOLD:
		new_state = TrayState.ATTENTION

	if new_state != _tray_state:
		_tray_state = new_state
		print("[Fe6] 托盘状态更新: %d" % _tray_state)

## C2 外出信号回调
func _on_character_departed() -> void:
	print("[Fe6] 收到外出事件")

	# 锁定当前强度
	_current_intensity = clamp(_get_notification_intensity(), 0.0, 1.0)

	# 显示纸条
	_note_visible = true
	_note_acknowledged = false

	# 获取外出留言
	var note_text = "出去逛逛，待会回来"
	if _c4_events and _c4_events.has_method("get_departure_note"):
		var custom_note = _c4_events.get_departure_note()
		if not custom_note.is_empty():
			note_text = custom_note

	print("[Fe6] 显示外出纸条: %s (intensity: %.2f)" % [note_text, _current_intensity])

## C2 归来信号回调
func _on_character_returned() -> void:
	print("[Fe6] 收到归来事件")

	# 移除纸条
	_note_visible = false

	# 检查纸条是否未读
	if not _note_acknowledged:
		note_unread_on_return.emit()
		print("[Fe6] 纸条未被注意到")

	# 强度≥0.3时更新托盘状态
	if _current_intensity >= SUBTLE_THRESHOLD:
		_tray_state = TrayState.NOTICE
		_update_tray_state()
		print("[Fe6] 归来触发托盘通知")

## Fe2 泄漏内容信号回调
func _on_leak_content_available() -> void:
	print("[Fe6] 收到泄漏内容更新")

	# 显示泄漏内容提示
	_leak_hint_visible = true
	_update_tray_state()

## Fe1 归来提示确认信号回调
func _on_return_hint_acknowledged() -> void:
	print("[Fe6] 归来提示已确认")

	# 恢复托盘状态
	_tray_state = TrayState.NORMAL
	_update_tray_state()

## 从 F4 加载数据
func _load_from_save() -> void:
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		return

	var f4_save = app.get_module("f4_save_system")
	if not f4_save:
		return

	_dnd_mode = f4_save.load(SAVE_KEY_DND_MODE, false)
	print("[Fe6] 从存档加载了勿扰模式: %s" % str(_dnd_mode))

## 保存到 F4
func _save_to_save() -> void:
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		return

	var f4_save = app.get_module("f4_save_system")
	if not f4_save:
		return

	f4_save.save(SAVE_KEY_DND_MODE, _dnd_mode)
