extends GutTest

# F2 状态机单元测试

var f2_system: F2StateMachine

func before_each():
	f2_system = F2StateMachine.new()
	add_child_autofree(f2_system)

func after_each():
	if f2_system and is_instance_valid(f2_system):
		f2_system.shutdown()

func test_module_metadata():
	assert_eq(f2_system.module_id, "f2_state_machine", "模块ID应为f2_state_machine")
	assert_eq(f2_system.module_name, "角色状态机", "模块名称应为角色状态机")
	assert_eq(f2_system.category, "core", "模块类别应为core")
	assert_eq(f2_system.priority, "high", "模块优先级应为high")
	assert_has(f2_system.dependencies, "f1_window_system", "应依赖f1_window_system")

func test_initialize():
	var result = f2_system.initialize({})

	assert_true(result, "初始化应成功")
	assert_eq(f2_system.status, IModule.ModuleStatus.INITIALIZED, "状态应为INITIALIZED")
	assert_eq(f2_system.current_state, F2StateMachine.CharacterState.IDLE, "初始状态应为IDLE")

func test_start():
	f2_system.initialize({})
	var result = f2_system.start()

	assert_true(result, "启动应成功")
	assert_eq(f2_system.status, IModule.ModuleStatus.RUNNING, "状态应为RUNNING")

func test_stop():
	f2_system.initialize({})
	f2_system.start()
	f2_system.stop()

	assert_eq(f2_system.status, IModule.ModuleStatus.STOPPED, "状态应为STOPPED")

func test_state_transition_idle_to_attentive():
	f2_system.initialize({})
	f2_system.start()

	var result = f2_system.request_state_change(F2StateMachine.CharacterState.ATTENTIVE, "test")

	assert_true(result, "从IDLE到ATTENTIVE的转换应成功")
	assert_eq(f2_system.current_state, F2StateMachine.CharacterState.ATTENTIVE, "当前状态应为ATTENTIVE")

func test_state_transition_to_interacting():
	f2_system.initialize({})
	f2_system.start()

	var result = f2_system.request_state_change(F2StateMachine.CharacterState.INTERACTING, "test")

	assert_true(result, "转换到INTERACTING应成功")
	assert_eq(f2_system.current_state, F2StateMachine.CharacterState.INTERACTING, "当前状态应为INTERACTING")

func test_state_transition_to_talking():
	f2_system.initialize({})
	f2_system.start()

	var result = f2_system.request_state_change(F2StateMachine.CharacterState.TALKING, "test")

	assert_true(result, "转换到TALKING应成功")
	assert_eq(f2_system.current_state, F2StateMachine.CharacterState.TALKING, "当前状态应为TALKING")

func test_is_available_for():
	f2_system.initialize({})
	f2_system.start()

	var available = f2_system.is_available_for(F2StateMachine.CharacterState.ATTENTIVE)

	assert_true(available is bool, "应返回布尔值")

func test_request_departure():
	f2_system.initialize({})
	f2_system.start()

	# 请求外出不应崩溃
	f2_system.request_departure()
	assert_true(true, "请求外出应正常执行")

func test_state_changed_signal():
	f2_system.initialize({})
	f2_system.start()

	watch_signals(f2_system)
	f2_system.request_state_change(F2StateMachine.CharacterState.ATTENTIVE, "test")

	assert_signal_emitted(f2_system, "state_changed", "应发出state_changed信号")

func test_pending_departure_flag():
	f2_system.initialize({})
	f2_system.start()

	assert_false(f2_system.pending_departure, "初始时pending_departure应为false")

func test_reload_config():
	f2_system.initialize({})
	var result = f2_system.reload_config({})

	assert_true(result, "重新加载配置应成功")
