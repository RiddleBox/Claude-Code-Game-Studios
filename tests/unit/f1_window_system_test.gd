extends GutTest

# F1 窗口系统单元测试

var f1_system: F1WindowSystem

func before_each():
	f1_system = F1WindowSystem.new()
	add_child_autofree(f1_system)

func after_each():
	if f1_system and is_instance_valid(f1_system):
		f1_system.shutdown()

func test_module_metadata():
	assert_eq(f1_system.module_id, "f1_window_system", "模块ID应为f1_window_system")
	assert_eq(f1_system.module_name, "桌面窗口系统", "模块名称应为桌面窗口系统")
	assert_eq(f1_system.category, "core", "模块类别应为core")
	assert_eq(f1_system.priority, "critical", "模块优先级应为critical")

func test_initialize():
	var config = {"window": {"transparent": true}}
	var result = f1_system.initialize(config)

	assert_true(result, "初始化应成功")
	assert_eq(f1_system.status, IModule.ModuleStatus.INITIALIZED, "状态应为INITIALIZED")

func test_start():
	f1_system.initialize({})
	var result = f1_system.start()

	assert_true(result, "启动应成功")
	assert_eq(f1_system.status, IModule.ModuleStatus.RUNNING, "状态应为RUNNING")

func test_stop():
	f1_system.initialize({})
	f1_system.start()
	f1_system.stop()

	assert_eq(f1_system.status, IModule.ModuleStatus.STOPPED, "状态应为STOPPED")
	assert_false(f1_system.is_dragging, "停止后不应处于拖拽状态")

func test_get_window_position():
	f1_system.initialize({})
	var pos = f1_system.get_window_position()

	assert_not_null(pos, "应返回窗口位置")
	assert_true(pos is Vector2, "窗口位置应为Vector2类型")

func test_get_window_size():
	f1_system.initialize({})
	var size = f1_system.get_window_size()

	assert_not_null(size, "应返回窗口大小")
	assert_true(size is Vector2, "窗口大小应为Vector2类型")
	assert_gt(size.x, 0, "窗口宽度应大于0")
	assert_gt(size.y, 0, "窗口高度应大于0")

func test_is_desktop_mode():
	f1_system.initialize({})
	var is_desktop = f1_system.is_desktop_mode()

	assert_true(is_desktop is bool, "应返回布尔值")

func test_is_mouse_in_window():
	f1_system.initialize({})
	var is_in = f1_system.is_mouse_in_window()

	assert_true(is_in is bool, "应返回布尔值")

func test_health_check():
	f1_system.initialize({})
	var health = f1_system.health_check()

	assert_not_null(health, "应返回健康检查结果")
	assert_true(health.has("healthy"), "应包含healthy字段")
	assert_true(health.has("issues"), "应包含issues字段")
	assert_true(health.has("window_position"), "应包含window_position字段")
	assert_true(health.has("window_size"), "应包含window_size字段")

func test_reload_config():
	f1_system.initialize({"window": {"transparent": true}})
	var new_config = {"window": {"always_on_top": false}}
	var result = f1_system.reload_config(new_config)

	assert_true(result, "重新加载配置应成功")
