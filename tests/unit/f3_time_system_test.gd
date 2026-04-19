extends GutTest

# F3 时间系统单元测试

var f3_system: F3TimeSystem

func before_each():
	f3_system = F3TimeSystem.new()
	add_child_autofree(f3_system)

func after_each():
	if f3_system and is_instance_valid(f3_system):
		f3_system.shutdown()

func test_module_metadata():
	assert_eq(f3_system.module_id, "f3_time_system", "模块ID应为f3_time_system")
	assert_eq(f3_system.module_name, "时间/节奏系统", "模块名称应为时间/节奏系统")
	assert_eq(f3_system.category, "core", "模块类别应为core")
	assert_eq(f3_system.priority, "high", "模块优先级应为high")

func test_initialize():
	var result = f3_system.initialize({})

	assert_true(result, "初始化应成功")
	assert_eq(f3_system.status, IModule.ModuleStatus.INITIALIZED, "状态应为INITIALIZED")

func test_start():
	f3_system.initialize({})
	var result = f3_system.start()

	assert_true(result, "启动应成功")
	assert_eq(f3_system.status, IModule.ModuleStatus.RUNNING, "状态应为RUNNING")

func test_stop():
	f3_system.initialize({})
	f3_system.start()
	f3_system.stop()

	assert_eq(f3_system.status, IModule.ModuleStatus.STOPPED, "状态应为STOPPED")

func test_tick_signal():
	f3_system.initialize({})
	f3_system.start()

	watch_signals(f3_system)

	# 等待一小段时间让tick可能触发
	await wait_seconds(0.1)

	# 注意：由于tick间隔是60秒，在单元测试中可能不会触发
	# 这里只验证信号存在
	assert_has_signal(f3_system, "tick", "应有tick信号")

func test_catching_up_completed_signal():
	f3_system.initialize({})

	assert_has_signal(f3_system, "catching_up_completed", "应有catching_up_completed信号")

func test_constants():
	assert_eq(F3TimeSystem.MAX_OFFLINE_MINUTES, 1440.0, "离线时长上限应为1440分钟")
	assert_eq(F3TimeSystem.OFFLINE_TICK_BATCH_SIZE, 60.0, "离线补算批次应为60分钟")
	assert_eq(F3TimeSystem.ONLINE_TICK_INTERVAL, 60.0, "在线tick间隔应为60秒")

func test_time_system_mode_enum():
	assert_eq(F3TimeSystem.TimeSystemMode.CATCHING_UP, 0, "CATCHING_UP枚举值应为0")
	assert_eq(F3TimeSystem.TimeSystemMode.RUNNING, 1, "RUNNING枚举值应为1")

func test_reload_config():
	f3_system.initialize({})
	var result = f3_system.reload_config({})

	assert_true(result, "重新加载配置应成功")

func test_shutdown_cleanup():
	f3_system.initialize({})
	f3_system.start()
	f3_system.shutdown()

	assert_eq(f3_system.status, IModule.ModuleStatus.SHUTDOWN, "状态应为SHUTDOWN")
