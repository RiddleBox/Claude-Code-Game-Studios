# ui/p1_main_ui/p1_main_ui.gd
# P1主UI系统 - 桌面交互界面，展示和管理所有系统功能
# 实现IModule接口，支持模块化架构

class_name P1MainUI
extends Node

## IModule接口实现
var module_id: String = "p1_main_ui"
var module_name: String = "主UI系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["ui_framework"]
var optional_dependencies: Array[String] = ["fe3_affinity_system", "fe2_memory_system", "fe5_audio_system"]
var config_path: String = "res://data/config/p1_main_ui.json"
var category: String = "ui"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## UI面板枚举
enum PanelType {
	NONE = 0,
	MAIN = 1,
	SETTINGS = 2,
	MEMORY = 3,
	AFFINITY = 4
}

## ==================== 信号 ====================

signal panel_opened(panel_type: int)
signal panel_closed(panel_type: int)
signal settings_changed(settings: Dictionary)

## ==================== 私有变量 ====================

## UI框架引用
var _ui_module: Node = null
## 好感度系统引用
var _fe3_affinity: Node = null
## 记忆系统引用
var _fe2_memory: Node = null
## 音频系统引用
var _fe5_audio: Node = null
## F1窗口系统引用
var _f1_window: Node = null
## 当前打开的面板
var _current_panel: int = PanelType.NONE
## UI容器节点
var _ui_container: Control = null
## 主UI面板
var _main_panel: Control = null
## 设置面板
var _settings_panel: Control = null
## 记忆面板
var _memory_panel: Control = null
## 好感度面板
var _affinity_panel: Control = null
## UI是否可见
var _ui_visible: bool = false

## ==================== IModule接口方法 ====================

## IModule.initialize()实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[P1] 初始化主UI系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[P1] 无法获取App节点")
		return false

	_ui_module = app.get_module("ui_framework")
	if not _ui_module:
		push_error("[P1] 无法获取UI框架模块")
		return false

	# 获取可选依赖模块
	_fe3_affinity = app.get_module("fe3_affinity_system")
	_fe2_memory = app.get_module("fe2_memory_system")
	_fe5_audio = app.get_module("fe5_audio_system")
	_f1_window = app.get_module("f1_window_system")

	# 创建UI容器
	_create_ui_container()

	status = IModule.ModuleStatus.INITIALIZED
	print("[P1] 主UI系统初始化完成")
	return true

## IModule.start()实现
func start() -> bool:
	print("[P1] 启动主UI系统...")
	status = IModule.ModuleStatus.STARTING

	# 监听各系统事件
	_connect_system_events()

	# 初始隐藏UI（通过快捷键显示）
	_hide_ui()

	status = IModule.ModuleStatus.RUNNING
	print("[P1] 主UI系统启动完成")
	return true

## IModule.stop()实现
func stop() -> void:
	print("[P1] 停止主UI系统...")
	status = IModule.ModuleStatus.STOPPING

	# 隐藏所有面板
	_hide_ui()

	status = IModule.ModuleStatus.STOPPED
	print("[P1] 主UI系统已停止")

## IModule.get_module_info()实现
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
		"current_panel": _current_panel,
		"ui_visible": _ui_visible
	}

## IModule.is_healthy()实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error()实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共API ====================

## 显示主UI
func show_ui() -> void:
	if _ui_visible:
		return

	_ui_visible = true
	if _ui_container:
		_ui_container.visible = true

	print("[P1] UI已显示")

## 隐藏主UI
func hide_ui() -> void:
	_hide_ui()

## 切换UI显示/隐藏
func toggle_ui() -> bool:
	if _ui_visible:
		_hide_ui()
		return false
	else:
		show_ui()
		return true

## 打开指定面板
func open_panel(panel_type: int) -> void:
	if _current_panel == panel_type:
		return

	# 关闭当前面板
	_close_current_panel()

	# 打开新面板
	_current_panel = panel_type
	_open_panel_by_type(panel_type)

	panel_opened.emit(panel_type)

## 关闭当前面板
func close_panel() -> void:
	_close_current_panel()

## 获取UI可见状态
func is_ui_visible() -> bool:
	return _ui_visible

## 获取当前打开的面板
func get_current_panel() -> int:
	return _current_panel

## ==================== 私有方法 ====================

## 创建UI容器
func _create_ui_container() -> void:
	if not _ui_module:
		return

	# 创建UI容器
	_ui_container = Control.new()
	_ui_container.name = "P1MainUIContainer"
	_ui_container.anchors_preset = Control.PRESET_FULL_RECT

	# 添加到F1窗口
	if _f1_window and _f1_window.has_method("add_child"):
		_f1_window.add_child(_ui_container)
		print("[P1] UI容器已添加到F1窗口")
	else:
		add_child(_ui_container)
		print("[P1] UI容器已添加到App节点")

	# 创建各面板
	_create_main_panel()
	_create_settings_panel()
	_create_memory_panel()
	_create_affinity_panel()

## 创建主面板
func _create_main_panel() -> void:
	if not _ui_module:
		return

	_main_panel = Control.new()
	_main_panel.name = "MainPanel"
	_main_panel.size = Vector2(300, 400)
	_main_panel.position = Vector2(20, 20)

	# TODO: 使用UI框架添加主面板内容

	_main_panel.visible = false
	_ui_container.add_child(_main_panel)

## 创建设置面板
func _create_settings_panel() -> void:
	if not _ui_module:
		return

	_settings_panel = Control.new()
	_settings_panel.name = "SettingsPanel"
	_settings_panel.size = Vector2(350, 500)
	_settings_panel.position = Vector2(20, 20)

	# TODO: 使用UI框架添加设置面板内容
	# - 音效音量滑块
	# - 语音音量滑块
	# - 静音开关
	# - 其他系统设置

	_settings_panel.visible = false
	_ui_container.add_child(_settings_panel)

## 创建记忆面板
func _create_memory_panel() -> void:
	if not _ui_module:
		return

	_memory_panel = Control.new()
	_memory_panel.name = "MemoryPanel"
	_memory_panel.size = Vector2(400, 500)
	_memory_panel.position = Vector2(20, 20)

	# TODO: 使用UI框架添加记忆面板内容
	# - 记忆列表
	# - 筛选/搜索功能
	# - 记忆详情查看

	_memory_panel.visible = false
	_ui_container.add_child(_memory_panel)

## 创建好感度面板
func _create_affinity_panel() -> void:
	if not _ui_module:
		return

	_affinity_panel = Control.new()
	_affinity_panel.name = "AffinityPanel"
	_affinity_panel.size = Vector2(300, 400)
	_affinity_panel.position = Vector2(20, 20)

	# TODO: 使用UI框架添加好感度面板内容
	# - 当前等级显示
	# - 等级进度条
	# - 升级所需分数
	# - 等级说明

	_affinity_panel.visible = false
	_ui_container.add_child(_affinity_panel)

## 连接各系统事件
func _connect_system_events() -> void:
	if _fe3_affinity:
		if _fe3_affinity.has_signal("level_up"):
			if not _fe3_affinity.level_up.is_connected(_on_affinity_level_up): _fe3_affinity.level_up.connect(_on_affinity_level_up)
		if _fe3_affinity.has_signal("level_down"):
			if not _fe3_affinity.level_down.is_connected(_on_affinity_level_down): _fe3_affinity.level_down.connect(_on_affinity_level_down)

	if _fe2_memory:
		if _fe2_memory.has_signal("memory_unlocked"):
			if not _fe2_memory.memory_unlocked.is_connected(_on_memory_unlocked): _fe2_memory.memory_unlocked.connect(_on_memory_unlocked)

	if _fe5_audio:
		if _fe5_audio.has_signal("volume_changed"):
			if not _fe5_audio.volume_changed.is_connected(_on_volume_changed): _fe5_audio.volume_changed.connect(_on_volume_changed)

## 根据类型打开面板
func _open_panel_by_type(panel_type: int) -> void:
	match panel_type:
		PanelType.MAIN:
			if _main_panel:
				_main_panel.visible = true
		PanelType.SETTINGS:
			if _settings_panel:
				_settings_panel.visible = true
		PanelType.MEMORY:
			if _memory_panel:
				_memory_panel.visible = true
				_refresh_memory_panel()
		PanelType.AFFINITY:
			if _affinity_panel:
				_affinity_panel.visible = true
				_refresh_affinity_panel()

## 关闭当前面板
func _close_current_panel() -> void:
	if _current_panel == PanelType.NONE:
		return

	match _current_panel:
		PanelType.MAIN:
			if _main_panel:
				_main_panel.visible = false
		PanelType.SETTINGS:
			if _settings_panel:
				_settings_panel.visible = false
		PanelType.MEMORY:
			if _memory_panel:
				_memory_panel.visible = false
		PanelType.AFFINITY:
			if _affinity_panel:
				_affinity_panel.visible = false

	var old_panel = _current_panel
	_current_panel = PanelType.NONE
	panel_closed.emit(old_panel)

## 隐藏UI
func _hide_ui() -> void:
	_ui_visible = false
	if _ui_container:
		_ui_container.visible = false

	_close_current_panel()
	print("[P1] UI已隐藏")

## 刷新好感度面板
func _refresh_affinity_panel() -> void:
	if not _fe3_affinity or not _affinity_panel:
		return

	# TODO: 更新好感度面板显示的内容
	# - 当前等级
	# - 当前分数
	# - 进度条
	# - 升级所需分数

	print("[P1] 刷新好感度面板")

## 刷新记忆面板
func _refresh_memory_panel() -> void:
	if not _fe2_memory or not _memory_panel:
		return

	# TODO: 更新记忆列表
	# - 查询最近的记忆
	# - 显示记忆列表

	print("[P1] 刷新记忆面板")

## 好感度升级事件回调
func _on_affinity_level_up(_new_level: int, new_level_name: String) -> void:
	print("[P1] 好感度升级: %s" % new_level_name)

## 好感度降级事件回调
func _on_affinity_level_down(_new_level: int, new_level_name: String) -> void:
	print("[P1] 好感度降级: %s" % new_level_name)

## 记忆解锁事件回调
func _on_memory_unlocked(memory_id: String) -> void:
	print("[P1] 记忆解锁: %s" % memory_id)

## 音量变化事件回调
func _on_volume_changed(sfx_volume: float, voice_volume: float) -> void:
	print("[P1] 音量变化: 音效=%.2f, 语音=%.2f" % [sfx_volume, voice_volume])
