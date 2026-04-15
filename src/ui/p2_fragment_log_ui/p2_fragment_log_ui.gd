# ui/p2_fragment_log_ui/p2_fragment_log_ui.gd
# P2 — 碎片日志 UI（Fragment Log UI）
# 玩家回顾碎片的界面
# 实现 IModule 接口，支持模块化架构

class_name P2FragmentLogUI
extends Node

## IModule 接口实现
var module_id: String = "p2_fragment_log_ui"
var module_name: String = "碎片日志UI"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["ui_framework"]
var optional_dependencies: Array[String] = ["c3_fragment_system", "fe3_affinity_system"]
var config_path: String = "res://data/config/p2_fragment_log_ui.json"
var category: String = "ui"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 信号 ====================

## 碎片被选中时触发
signal fragment_selected(fragment_id: String)

## ==================== 私有变量 ====================

## UI框架引用
var _ui_framework: Node = null

## C3碎片系统引用（可选）
var _c3_fragments: Node = null

## Fe3好感度系统引用（可选）
var _fe3_affinity: Node = null

## 当前筛选类型
var _current_filter: String = "all"

## 当前排序方式
var _current_sort: String = "newest"

## UI是否可见
var _is_visible: bool = false

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[P2] 初始化碎片日志UI...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[P2] 无法获取 App 节点")
		return false

	_ui_framework = app.get_module("ui_framework")
	if not _ui_framework:
		push_error("[P2] 无法获取 UI框架模块")
		return false

	# 获取可选依赖
	_c3_fragments = app.get_module("c3_fragment_system")
	_fe3_affinity = app.get_module("fe3_affinity_system")

	status = IModule.ModuleStatus.INITIALIZED
	print("[P2] 碎片日志UI初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[P2] 启动碎片日志UI...")
	status = IModule.ModuleStatus.STARTING

	status = IModule.ModuleStatus.RUNNING
	print("[P2] 碎片日志UI启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[P2] 停止碎片日志UI...")
	status = IModule.ModuleStatus.STOPPING

	status = IModule.ModuleStatus.STOPPED
	print("[P2] 碎片日志UI已停止")

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
		"is_visible": _is_visible,
		"current_filter": _current_filter,
		"current_sort": _current_sort
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共 API ====================

## 显示碎片日志
func show() -> void:
	_is_visible = true
	print("[P2] 显示碎片日志")
	_refresh_fragment_list()

## 隐藏碎片日志
func hide() -> void:
	_is_visible = false
	print("[P2] 隐藏碎片日志")

## 切换显示状态
func toggle() -> void:
	if _is_visible:
		hide()
	else:
		show()

## 设置筛选类型
func set_filter(filter_type: String) -> void:
	_current_filter = filter_type
	print("[P2] 设置筛选: %s" % filter_type)
	if _is_visible:
		_refresh_fragment_list()

## 设置排序方式
func set_sort(sort_type: String) -> void:
	_current_sort = sort_type
	print("[P2] 设置排序: %s" % sort_type)
	if _is_visible:
		_refresh_fragment_list()

## 标记碎片为已读
func mark_fragment_read(fragment_id: String) -> void:
	if _c3_fragments and _c3_fragments.has_method("mark_read"):
		_c3_fragments.mark_read(fragment_id)
		if _is_visible:
			_refresh_fragment_list()

## 获取当前显示的碎片列表
func get_current_fragments() -> Array:
	if not _c3_fragments or not _c3_fragments.has_method("get_all"):
		return []

	var fragments: Array
	match _current_filter:
		"all":
			fragments = _c3_fragments.get_all()
		"unread":
			fragments = _c3_fragments.get_unread()
		"dialogue":
			fragments = _c3_fragments.get_by_type("dialogue")
		"scene":
			fragments = _c3_fragments.get_by_type("scene")
		"object":
			fragments = _c3_fragments.get_by_type("object")
		"emotion":
			fragments = _c3_fragments.get_by_type("emotion")
		_:
			fragments = _c3_fragments.get_all()

	# 排序已在get_*方法中处理
	return fragments

## ==================== 私有方法 ====================

## 刷新碎片列表
func _refresh_fragment_list() -> void:
	var fragments = get_current_fragments()
	print("[P2] 刷新碎片列表，共 %d 条" % fragments.size())

## 获取性格展示标签
func _get_personality_display_label() -> String:
	var app = get_parent()
	if not app:
		return "平静"

	var c5_personality = app.get_module("c5_personality_variable_system")
	if c5_personality and c5_personality.has_method("get_display_label"):
		return c5_personality.get_display_label()

	return "平静"
