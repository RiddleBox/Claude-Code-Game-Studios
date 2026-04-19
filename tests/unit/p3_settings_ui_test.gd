extends GutTest

# P3 设置UI单元测试

var p3_ui: P3SettingsUI

func before_each():
	p3_ui = P3SettingsUI.new()
	add_child_autofree(p3_ui)

func after_each():
	if p3_ui and is_instance_valid(p3_ui):
		p3_ui.queue_free()

func test_module_metadata():
	assert_eq(p3_ui.module_id, "p3_settings_ui", "模块ID应为p3_settings_ui")
	assert_eq(p3_ui.module_name, "设置UI", "模块名称应为设置UI")
	assert_eq(p3_ui.category, "ui", "类别应为ui")
	assert_eq(p3_ui.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(p3_ui.dependencies.has("ui_framework"), "应依赖ui_framework")
	assert_true(p3_ui.optional_dependencies.has("f1_window_system"), "应有可选依赖f1_window_system")
	assert_true(p3_ui.optional_dependencies.has("fe5_audio_system"), "应有可选依赖fe5_audio_system")

func test_signals():
	assert_has_signal(p3_ui, "settings_changed", "应有settings_changed信号")

func test_initial_state():
	assert_eq(p3_ui.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_false(p3_ui._is_visible, "初始时UI应不可见")
	assert_true(p3_ui._settings is Dictionary, "设置应为字典")

func test_default_settings_structure():
	assert_true(p3_ui._settings.has("audio"), "应有audio设置分类")
	assert_true(p3_ui._settings.has("window"), "应有window设置分类")
	assert_true(p3_ui._settings.has("gameplay"), "应有gameplay设置分类")

func test_default_audio_settings():
	assert_eq(p3_ui._settings["audio"]["master_volume"], 1.0, "默认主音量应为1.0")
	assert_eq(p3_ui._settings["audio"]["sfx_volume"], 1.0, "默认音效音量应为1.0")
	assert_eq(p3_ui._settings["audio"]["music_volume"], 1.0, "默认音乐音量应为1.0")

func test_default_window_settings():
	assert_true(p3_ui._settings["window"]["click_through"], "默认应启用点击穿透")
	assert_true(p3_ui._settings["window"]["always_on_top"], "默认应启用置顶")
	assert_true(p3_ui._settings["window"]["show_tray_icon"], "默认应显示托盘图标")

func test_default_gameplay_settings():
	assert_true(p3_ui._settings["gameplay"]["auto_save"], "默认应启用自动保存")
	assert_true(p3_ui._settings["gameplay"]["show_unread_hint"], "默认应显示未读提示")
