extends GutTest

# P2 碎片日志UI单元测试

var p2_ui: P2FragmentLogUI

func before_each():
	p2_ui = P2FragmentLogUI.new()
	add_child_autofree(p2_ui)

func after_each():
	if p2_ui and is_instance_valid(p2_ui):
		p2_ui.queue_free()

func test_module_metadata():
	assert_eq(p2_ui.module_id, "p2_fragment_log_ui", "模块ID应为p2_fragment_log_ui")
	assert_eq(p2_ui.module_name, "碎片日志UI", "模块名称应为碎片日志UI")
	assert_eq(p2_ui.category, "ui", "类别应为ui")
	assert_eq(p2_ui.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(p2_ui.dependencies.has("ui_framework"), "应依赖ui_framework")
	assert_true(p2_ui.optional_dependencies.has("c3_fragment_system"), "应有可选依赖c3_fragment_system")
	assert_true(p2_ui.optional_dependencies.has("fe3_affinity_system"), "应有可选依赖fe3_affinity_system")

func test_signals():
	assert_has_signal(p2_ui, "fragment_selected", "应有fragment_selected信号")

func test_initial_state():
	assert_eq(p2_ui.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_eq(p2_ui._current_filter, "all", "初始筛选应为all")
	assert_eq(p2_ui._current_sort, "newest", "初始排序应为newest")
	assert_false(p2_ui._is_visible, "初始时UI应不可见")
