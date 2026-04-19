extends GutTest

# C2 外出返回循环单元测试

var c2_system: C2OutingReturnCycle

func before_each():
	c2_system = C2OutingReturnCycle.new()
	add_child_autofree(c2_system)

func after_each():
	if c2_system and is_instance_valid(c2_system):
		c2_system.queue_free()

func test_module_metadata():
	assert_eq(c2_system.module_id, "c2_outing_return_cycle", "模块ID应为c2_outing_return_cycle")
	assert_eq(c2_system.category, "gameplay", "类别应为gameplay")
	assert_eq(c2_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(c2_system.dependencies.has("f2_state_machine"), "应依赖f2_state_machine")
	assert_true(c2_system.dependencies.has("f3_time_system"), "应依赖f3_time_system")
	assert_true(c2_system.dependencies.has("f4_save_system"), "应依赖f4_save_system")

func test_constants():
	assert_eq(C2OutingReturnCycle.MIN_OUTING_INTERVAL, 20.0, "最小外出间隔应为20分钟")
	assert_eq(C2OutingReturnCycle.OUTING_PROBABILITY_PER_TICK, 0.05, "每次tick出发概率应为5%")
	assert_eq(C2OutingReturnCycle.DEFAULT_COOLDOWN_MINUTES, 5.0, "默认冷却时间应为5分钟")
	assert_eq(C2OutingReturnCycle.MIN_OUTING_DURATION, 10.0, "最短外出时长应为10分钟")
	assert_eq(C2OutingReturnCycle.MAX_OUTING_DURATION, 30.0, "最长外出时长应为30分钟")

func test_signals():
	assert_has_signal(c2_system, "departure_triggered", "应有departure_triggered信号")
	assert_has_signal(c2_system, "departure_accepted", "应有departure_accepted信号")
	assert_has_signal(c2_system, "departure_declined", "应有departure_declined信号")
	assert_has_signal(c2_system, "return_triggered", "应有return_triggered信号")
	assert_has_signal(c2_system, "state_changed", "应有state_changed信号")

func test_initial_state():
	assert_eq(c2_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_eq(c2_system._current_state, "home", "初始位置应为home")
	assert_false(c2_system._is_outing_active, "初始时不应在外出")
	assert_false(c2_system._is_returning, "初始时不应在返回")
