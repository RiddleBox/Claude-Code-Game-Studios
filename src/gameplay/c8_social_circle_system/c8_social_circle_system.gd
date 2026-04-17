extends Node

## C8 社交圈系统
## 负责管理多个角色的轮换和离线状态模拟

# ModuleLoader required properties
var module_id: String = ""
var dependencies: Array[String] = []
var optional_dependencies: Array[String] = []

#region 信号定义

## 角色轮换时触发
signal character_rotated(new_character_id: String, old_character_id: String)

## 离线事件发生时触发
signal offline_event_occurred(character_id: String, event_type: String, event_data: Dictionary)

#endregion

#region 常量定义

## 角色轮换间隔（秒）
const ROTATION_INTERVAL := 3600.0  # 1小时

## 最大角色数
const MAX_CHARACTERS := 5

#endregion

#region 私有变量

## 角色列表
var _characters: Dictionary = {}

## 当前活跃角色
var _active_character_id: String = "aria"

## 轮换计时器
var _rotation_timer: Timer = null

## 依赖的模块
var _f4_save_system: Node = null
var _f3_time_system: Node = null

#endregion

#region IModule接口实现

func get_module_info() -> Dictionary:
	return {
		"id": "c8_social_circle_system",
		"name": "社交圈系统",
		"version": "1.0.0",
		"dependencies": ["f4_save_system"],
		"optional_dependencies": ["f3_time_system"]
	}

func initialize(_config: Dictionary = {}) -> bool:
	print("[C8] Initializing Social Circle System...")

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[C8] Cannot get App node")
		return false

	_f4_save_system = app.get_module("f4_save_system")
	if not _f4_save_system:
		push_error("[C8] Required dependency f4_save_system not found")
		return false

	_f3_time_system = app.get_module("f3_time_system")
	_load_from_save()

	# 创建轮换计时器
	_rotation_timer = Timer.new()
	_rotation_timer.wait_time = ROTATION_INTERVAL
	_rotation_timer.timeout.connect(_on_rotation_timer_timeout)
	add_child(_rotation_timer)

	print("[C8] Social Circle System initialized")
	return true

func start() -> bool:
	print("[C8] Starting Social Circle System...")
	return true

func shutdown() -> void:
	print("[C8] Shutting down Social Circle System...")

	# 保存数据
	_save_to_save()

	# 清理
	_characters.clear()

	print("[C8] Social Circle System shut down")

#endregion

#region 公共API

## 获取当前活跃角色
func get_active_character() -> String:
	return _active_character_id

## 设置活跃角色
func set_active_character(character_id: String) -> bool:
	if not _characters.has(character_id):
		return false

	var old_character_id := _active_character_id
	_active_character_id = character_id

	if old_character_id != _active_character_id:
		character_rotated.emit(_active_character_id, old_character_id)

	_save_to_save()
	return true

## 获取所有角色列表
func get_all_characters() -> Dictionary:
	return _characters.duplicate()

## 获取角色信息
func get_character_info(character_id: String) -> Dictionary:
	return _characters.get(character_id, {}).duplicate()

## 触发离线事件（模拟）
func trigger_offline_event(character_id: String, event_type: String, event_data: Dictionary = {}) -> bool:
	if not _characters.has(character_id):
		return false

	offline_event_occurred.emit(character_id, event_type, event_data)
	return true

#endregion

#region 私有方法

## 初始化角色列表
func _init_characters() -> void:
	_characters = {
		"aria": {
			"id": "aria",
			"name": "Aria",
			"description": "窗语世界的主要角色",
			"is_available": true,
			"last_interaction": 0
		}
	}

	if _active_character_id.is_empty() or not _characters.has(_active_character_id):
		_active_character_id = "aria"

## 轮换计时器回调
func _on_rotation_timer_timeout() -> void:
	# 简化实现：暂不自动轮换
	pass

## 从存档加载
func _load_from_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("get_data"):
		return

	var saved_characters = _f4_save_system.get_data("c8.characters")
	if saved_characters is Dictionary and not saved_characters.is_empty():
		_characters = saved_characters.duplicate()

	var saved_active = _f4_save_system.get_data("c8.active_character")
	if saved_active is String and _characters.has(saved_active):
		_active_character_id = saved_active

	print("[C8] Loaded %d characters from save" % _characters.size())

## 保存到存档
func _save_to_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("set_data"):
		return

	_f4_save_system.set_data("c8.characters", _characters.duplicate())
	_f4_save_system.set_data("c8.active_character", _active_character_id)

#endregion
