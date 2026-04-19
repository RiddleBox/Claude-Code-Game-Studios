extends GutTest

# C4 事件线系统单元测试

var c4_system: C4EventLineSystem

func before_each():
	c4_system = C4EventLineSystem.new()
	add_child_autofree(c4_system)

func after_each():
	if c4_system and is_instance_valid(c4_system):
		c4_system.queue_free()

func test_module_metadata():
	assert_eq(c4_system.module_id, "c4_event_line_system", "模块ID应为c4_event_line_system")
	assert_eq(c4_system.module_name, "事件线系统", "模块名称应为事件线系统")
	assert_eq(c4_system.category, "gameplay", "类别应为gameplay")
	assert_eq(c4_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(c4_system.dependencies.has("f4_save_system"), "应依赖f4_save_system")
	assert_true(c4_system.dependencies.has("f3_time_system"), "应依赖f3_time_system")
	assert_true(c4_system.optional_dependencies.has("c3_fragment_system"), "应有可选依赖c3_fragment_system")
	assert_true(c4_system.optional_dependencies.has("c5_personality_variable_system"), "应有可选依赖c5_personality_variable_system")

func test_constants():
	assert_eq(C4EventLineSystem.BRANCH_TRIGGER_CHANCE, 0.40, "分支触发概率应为0.40")
	assert_eq(C4EventLineSystem.BRANCH_COOLDOWN_MINUTES, 60, "分支冷却时间应为60分钟")
	assert_eq(C4EventLineSystem.BRANCH_REPEAT_WINDOW, 5, "分支重复窗口应为5")
	assert_eq(C4EventLineSystem.SAVE_KEY_MAIN_PROGRESS, "c4.main_line_progress", "主线进度存档键应为c4.main_line_progress")
	assert_eq(C4EventLineSystem.SAVE_KEY_BRANCH_COOLDOWN, "c4.branch_cooldown", "分支冷却存档键应为c4.branch_cooldown")
	assert_eq(C4EventLineSystem.SAVE_KEY_USED_BRANCHES, "c4.used_branch_events", "已用分支存档键应为c4.used_branch_events")

func test_signals():
	assert_has_signal(c4_system, "main_line_node_triggered", "应有main_line_node_triggered信号")
	assert_has_signal(c4_system, "branch_event_triggered", "应有branch_event_triggered信号")

func test_initial_state():
	assert_eq(c4_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_true(c4_system._main_line is Dictionary, "主线数据应为字典")
	assert_true(c4_system._branch_events is Array, "分支事件应为数组")
	assert_true(c4_system._general_fragments is Array, "通用碎片应为数组")
	assert_eq(c4_system._main_line_progress["current_node_index"], 0, "主线进度初始应为0")
	assert_false(c4_system._main_line_progress["completed"], "主线初始应未完成")
	assert_eq(c4_system._branch_cooldown, 0, "分支冷却初始应为0")
