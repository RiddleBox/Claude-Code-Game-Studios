# ui/p3_settings_ui/p3_settings_ui.gd
# P3 — 设置 UI（Settings UI）
# 游戏设置面板
# 实现 IModule 接口，支持模块化架构

class_name P3SettingsUI
extends Node

## IModule 接口实现
var module_id: String = "p3_settings_ui"
var module_name: String = "设置UI"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["ui_framework"]
var optional_dependencies: Array[String] = ["f1_window_system", "fe5_audio_system"]
var config_path: String = "res://data/config/p3_settings_ui.json"
var category: String = "ui"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 信号 ====================

## 设置改变时触发
signal settings_changed(setting_cat: String, setting_key: String, setting_value: Variant)

## ==================== 私有变量 ====================

## UI框架引用
var _ui_framework: Node = null

## F1窗口系统引用（可选）
var _f1_window: Node = null

## Fe5音频系统引用（可选）
var _fe5_audio: Node = null

## 设置面板是否可见
var _is_visible: bool = false

## 设置数据
var _settings: Dictionary = {
	"audio": {
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 1.0
	},
	"window": {
		"click_through": true,
		"always_on_top": true,
		"show_tray_icon": true
	},
	"gameplay": {
		"auto_save": true,
		"show_unread_hint": true
	}
}

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[P3] 初始化设置UI...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[P3] 无法获取 App 节点")
		return false

	_ui_framework = app.get_module("ui_framework")
	if not _ui_framework:
		push_error("[P3] 无法获取 UI框架模块")
		return false

	# 获取可选依赖
	_f1_window = app.get_module("f1_window_system")
	_fe5_audio = app.get_module("fe5_audio_system")

	# 从存档加载设置
	_load_settings()

	status = IModule.ModuleStatus.INITIALIZED
	print("[P3] 设置UI初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[P3] 启动设置UI...")
	status = IModule.ModuleStatus.STARTING

	status = IModule.ModuleStatus.RUNNING
	print("[P3] 设置UI启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[P3] 停止设置UI...")
	status = IModule.ModuleStatus.STOPPING

	# 保存设置
	_save_settings()

	status = IModule.ModuleStatus.STOPPED
	print("[P3] 设置UI已停止")

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
		"settings": _settings.duplicate()
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共 API ====================

## 显示设置面板
func show() -> void:
	_is_visible = true
	print("[P3] 显示设置面板")

## 隐藏设置面板
func hide() -> void:
	_is_visible = false
	print("[P3] 隐藏设置面板")
	_save_settings()

## 切换显示状态
func toggle() -> void:
	if _is_visible:
		hide()
	else:
		show()

## 获取设置值
func get_setting(setting_cat: String, setting_key: String, default_value: Variant = null) -> Variant:
	if not _settings.has(setting_cat):
		return default_value
	var cat_settings = _settings[setting_cat]
	if not cat_settings.has(setting_key):
		return default_value
	return cat_settings[setting_key]

## 设置设置值
func set_setting(setting_cat: String, setting_key: String, setting_value: Variant) -> void:
	if not _settings.has(setting_cat):
		_settings[setting_cat] = {}
	_settings[setting_cat][setting_key] = setting_value

	print("[P3] 设置变更: %s.%s = %s" % [setting_cat, setting_key, str(setting_value)])

	# 应用设置
	_apply_setting(setting_cat, setting_key, setting_value)

	settings_changed.emit(setting_cat, setting_key, setting_value)

## 重置所有设置
func reset_all() -> void:
	print("[P3] 重置所有设置")
	_settings = {
		"audio": {
			"master_volume": 1.0,
			"sfx_volume": 1.0,
			"music_volume": 1.0
		},
		"window": {
			"click_through": true,
			"always_on_top": true,
			"show_tray_icon": true
		},
		"gameplay": {
			"auto_save": true,
			"show_unread_hint": true
		}
	}

	# 应用所有设置
	for setting_cat in _settings:
		for setting_key in _settings[setting_cat]:
			_apply_setting(setting_cat, setting_key, _settings[setting_cat][setting_key])

## 获取所有设置
func get_all_settings() -> Dictionary:
	return _settings.duplicate()

## ==================== 私有方法 ====================

## 应用设置到对应系统
func _apply_setting(setting_cat: String, setting_key: String, setting_value: Variant) -> void:
	match setting_cat:
		"audio":
			if _fe5_audio:
				match setting_key:
					"master_volume":
						if _fe5_audio.has_method("set_master_volume"):
							_fe5_audio.set_master_volume(setting_value)
					"sfx_volume":
						if _fe5_audio.has_method("set_sfx_volume"):
							_fe5_audio.set_sfx_volume(setting_value)
					"music_volume":
						if _fe5_audio.has_method("set_music_volume"):
							_fe5_audio.set_music_volume(setting_value)
		"window":
			if _f1_window:
				match setting_key:
					"click_through":
						if _f1_window.has_method("set_click_through"):
							_f1_window.set_click_through(setting_value)
					"always_on_top":
						if _f1_window.has_method("set_always_on_top"):
							_f1_window.set_always_on_top(setting_value)
					"show_tray_icon":
						if _f1_window.has_method("set_tray_icon_visible"):
							_f1_window.set_tray_icon_visible(setting_value)

## 从存档加载设置
func _load_settings() -> void:
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		return

	var f4_save = app.get_module("f4_save_system")
	if not f4_save:
		return

	var saved_settings = f4_save.load("p3.settings", {})
	if typeof(saved_settings) == TYPE_DICTIONARY:
		# 合并设置，保留默认值
		for setting_cat in saved_settings:
			if not _settings.has(setting_cat):
				_settings[setting_cat] = {}
			for setting_key in saved_settings[setting_cat]:
				_settings[setting_cat][setting_key] = saved_settings[setting_cat][setting_key]

	print("[P3] 从存档加载了设置")

## 保存设置到存档
func _save_settings() -> void:
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		return

	var f4_save = app.get_module("f4_save_system")
	if not f4_save:
		return

	f4_save.save("p3.settings", _settings.duplicate())
	print("[P3] 设置已保存")
