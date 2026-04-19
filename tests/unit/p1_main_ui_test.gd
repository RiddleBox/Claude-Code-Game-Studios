extends GutTest

# P1 主UI系统单元测试

var p1_ui: P1MainUI

func before_each():
	p1_ui = P1MainUI.new()
	add_child_autofree(p1_ui)

func after_each():
	if p1_ui and is_instance_valid(p1_ui):
		p1_ui.queue_free()

func test_module_metadata():
	assert_eq(p1_ui.module_id, "p1_main_ui", "模块ID应为p1_main_ui")
	assert_eq(p1_ui.module_name, "主UI系统", "模块名称应为主UI系统")
	assert_eq(p1_ui.category, "ui", "类别应为ui")
	assert_eq(p1_ui.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(p1_ui.dependencies.has("ui_framework"), "应依赖ui_framework")
	assert_true(p1_ui.optional_dependencies.has("fe3_affinity_system"), "应有可选依赖fe3_affinity_system")
	assert_true(p1_ui.optional_dependencies.has("fe2_memory_system"), "应有可选依赖fe2_memory_system")
	assert_true(p1_ui.optional_dependencies.has("fe5_audio_system"), "应有可选依赖fe5_audio_system")

func test_panel_type_enum():
	assert_eq(P1MainUI.PanelType.NONE, 0, "NONE应为0")
	assert_eq(P1MainUI.PanelType.MAIN, 1, "MAIN应为1")
	assert_eq(P1MainUI.PanelType.SETTINGS, 2, "SETTINGS应为2")
	assert_eq(P1MainUI.PanelType.MEMORY, 3, "MEMORY应为3")
	assert_eq(P1MainUI.PanelType.AFFINITY, 4, "AFFINITY应为4")

func test_signals():
	assert_has_signal(p1_ui, "panel_opened", "应有panel_opened信号")
	assert_has_signal(p1_ui, "panel_closed", "应有panel_closed信号")
	assert_has_signal(p1_ui, "settings_changed", "应有settings_changed信号")

func test_initial_state():
	assert_eq(p1_ui.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_eq(p1_ui._current_panel, P1MainUI.PanelType.NONE, "初始时无面板打开")
	assert_false(p1_ui._ui_visible, "初始时UI应不可见")
