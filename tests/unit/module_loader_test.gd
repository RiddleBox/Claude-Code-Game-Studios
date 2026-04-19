extends GutTest

# ModuleLoader 单元测试

var loader: ModuleLoader

func before_each():
	loader = ModuleLoader.new()
	add_child_autofree(loader)
	# 等待_ready()执行
	await get_tree().process_frame

func after_each():
	if loader and is_instance_valid(loader):
		loader.shutdown_all_modules()

func test_loader_initialization():
	assert_not_null(loader, "ModuleLoader应成功创建")
	assert_not_null(loader._dependency_graph, "依赖图应已初始化")

func test_register_module_success():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")

	var result = loader.register_module(
		"test_f2",
		test_module_class,
		{},
		[],
		[],
		50
	)

	assert_true(result, "模块注册应成功")
	assert_true(loader._modules.has("test_f2"), "模块应存在于注册表中")
	assert_eq(loader._module_priorities["test_f2"], 50, "优先级应正确设置")

func test_register_duplicate_module_fails():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")

	loader.register_module("test_f2", test_module_class, {}, [], [], 50)
	var result = loader.register_module("test_f2", test_module_class, {}, [], [], 50)

	assert_false(result, "重复注册应失败")

func test_register_module_instance_success():
	var instance = Node.new()
	instance.set_script(load("res://src/core/f2_state_machine/f2_state_machine.gd"))

	var result = loader.register_module_instance(
		"test_instance",
		instance,
		{},
		[],
		[],
		60
	)

	assert_true(result, "模块实例注册应成功")
	assert_eq(instance.module_id, "test_instance", "模块ID应正确设置")
	assert_true(loader._modules.has("test_instance"), "模块实例应存在于注册表中")

func test_get_module():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {}, [], [], 50)

	var module = loader.get_module("test_f2")

	assert_not_null(module, "应能获取已注册的模块")
	assert_eq(module.module_id, "test_f2", "模块ID应匹配")

func test_get_nonexistent_module_returns_null():
	var module = loader.get_module("nonexistent")

	assert_null(module, "不存在的模块应返回null")

func test_initialize_single_module():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {}, [], [], 50)

	var result = loader.initialize_all_modules()

	assert_true(result, "初始化应成功")
	assert_true(loader._module_status["test_f2"]["initialized"], "模块应标记为已初始化")
	assert_eq(loader._module_status["test_f2"]["status"], IModule.ModuleStatus.INITIALIZED, "状态应为INITIALIZED")

func test_initialize_with_dependencies():
	var f2_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	var f3_class = load("res://src/core/f3_time_system/f3_time_system.gd")

	# F3依赖F2
	loader.register_module("test_f2", f2_class, {}, [], [], 50)
	loader.register_module("test_f3", f3_class, {}, ["test_f2"], [], 40)

	var result = loader.initialize_all_modules()

	assert_true(result, "带依赖的初始化应成功")
	assert_true(loader._module_status["test_f2"]["initialized"], "依赖模块应先初始化")
	assert_true(loader._module_status["test_f3"]["initialized"], "依赖方模块应后初始化")

func test_initialize_missing_dependency_fails():
	var f3_class = load("res://src/core/f3_time_system/f3_time_system.gd")

	# F3依赖不存在的模块
	loader.register_module("test_f3", f3_class, {}, ["nonexistent"], [], 40)

	var result = loader.initialize_all_modules()

	assert_false(result, "缺少依赖时初始化应失败")

func test_start_all_modules():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {}, [], [], 50)
	loader.initialize_all_modules()

	var result = loader.start_all_modules()

	assert_true(result, "启动应成功")
	assert_true(loader._module_status["test_f2"]["started"], "模块应标记为已启动")
	assert_eq(loader._module_status["test_f2"]["status"], IModule.ModuleStatus.RUNNING, "状态应为RUNNING")

func test_stop_all_modules():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {}, [], [], 50)
	loader.initialize_all_modules()
	loader.start_all_modules()

	loader.stop_all_modules()

	assert_false(loader._module_status["test_f2"]["started"], "模块应标记为未启动")
	assert_eq(loader._module_status["test_f2"]["status"], IModule.ModuleStatus.STOPPED, "状态应为STOPPED")

func test_is_module_ready():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {}, [], [], 50)

	assert_false(loader.is_module_ready("test_f2"), "未初始化的模块应不就绪")

	loader.initialize_all_modules()
	assert_false(loader.is_module_ready("test_f2"), "已初始化但未启动的模块应不就绪")

	loader.start_all_modules()
	assert_true(loader.is_module_ready("test_f2"), "已启动的模块应就绪")

func test_get_module_status():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {}, [], [], 50)

	var status = loader.get_module_status("test_f2")

	assert_not_null(status, "应返回状态字典")
	assert_true(status.has("status"), "应包含status字段")
	assert_true(status.has("initialized"), "应包含initialized字段")
	assert_true(status.has("started"), "应包含started字段")

func test_get_all_module_status():
	var f2_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	var f3_class = load("res://src/core/f3_time_system/f3_time_system.gd")

	loader.register_module("test_f2", f2_class, {}, [], [], 50)
	loader.register_module("test_f3", f3_class, {}, [], [], 40)

	var all_status = loader.get_all_module_status()

	assert_eq(all_status.size(), 2, "应返回所有模块状态")
	assert_true(all_status.has("test_f2"), "应包含test_f2状态")
	assert_true(all_status.has("test_f3"), "应包含test_f3状态")

func test_reload_module():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {"key": "old_value"}, [], [], 50)
	loader.initialize_all_modules()
	loader.start_all_modules()

	var result = loader.reload_module("test_f2", {"key": "new_value"})

	assert_true(result, "重新加载应成功")
	assert_eq(loader._module_configs["test_f2"]["key"], "new_value", "配置应已更新")
	assert_true(loader.is_module_ready("test_f2"), "重新加载后模块应就绪")

func test_shutdown_all_modules():
	var test_module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	loader.register_module("test_f2", test_module_class, {}, [], [], 50)
	loader.initialize_all_modules()
	loader.start_all_modules()

	loader.shutdown_all_modules()

	assert_eq(loader._modules.size(), 0, "所有模块应已清理")
	assert_eq(loader._module_configs.size(), 0, "所有配置应已清理")
	assert_eq(loader._module_status.size(), 0, "所有状态应已清理")

func test_module_priority_affects_startup_order():
	var f2_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	var f3_class = load("res://src/core/f3_time_system/f3_time_system.gd")

	# 注册时F3优先级更高
	loader.register_module("test_f2", f2_class, {}, [], [], 50)
	loader.register_module("test_f3", f3_class, {}, [], [], 100)

	var init_order = loader._dependency_graph.get_startup_order(loader._module_priorities)

	# 高优先级应先初始化
	var f3_index = init_order.find("test_f3")
	var f2_index = init_order.find("test_f2")
	assert_lt(f3_index, f2_index, "高优先级模块应先初始化")
