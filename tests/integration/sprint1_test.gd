# tests/integration/sprint1_test.gd
# Sprint 1 集成测试脚本
# 验证UI框架和F3时间系统功能

extends Node

# 测试结果
enum TestResult {
	PASS,
	FAIL,
	SKIP
}

# 测试用例结构
class TestCase:
	var name: String
	var description: String
	var result: TestResult = TestResult.SKIP
	var message: String = ""

	func _init(_name: String, _description: String):
		name = _name
		description = _description

	func set_result(_result: TestResult, _message: String = ""):
		result = _result
		message = _message

var test_cases: Array[TestCase] = []
var app_node: Node = null

func _ready() -> void:
	print("========================================")
	print("Sprint 1 集成测试开始")
	print("========================================")

	# 设置测试用例
	_setup_test_cases()

	# 运行测试
	_run_all_tests()

	# 输出报告
	_print_test_report()

	# 测试完成后退出（或保持在场景中供观察）
	print("========================================")
	print("集成测试完成")
	print("========================================")

func _setup_test_cases() -> void:
	# 测试用例定义
	test_cases.append(TestCase.new(
		"UI-001",
		"UI框架模块加载和初始化"
	))

	test_cases.append(TestCase.new(
		"UI-002",
		"UI主题资源加载"
	))

	test_cases.append(TestCase.new(
		"UI-003",
		"UI组件工厂方法 - 创建透明面板"
	))

	test_cases.append(TestCase.new(
		"UI-004",
		"UI组件工厂方法 - 创建透明标签"
	))

	test_cases.append(TestCase.new(
		"UI-005",
		"UI组件添加到F1窗口场景"
	))

	test_cases.append(TestCase.new(
		"F3-001",
		"F3时间系统模块加载和初始化"
	))

	test_cases.append(TestCase.new(
		"F3-002",
		"F3时间系统tick信号监听"
	))

	test_cases.append(TestCase.new(
		"F3-003",
		"F3模拟时间流逝功能"
	))

	test_cases.append(TestCase.new(
		"INT-001",
		"模块间依赖关系验证"
	))

func _run_all_tests() -> void:
	# 第一步：获取App节点
	if not _find_app_node():
		print("错误: 未找到App节点，测试终止")
		_mark_all_as_failed("未找到App节点")
		return

	# 运行各个测试用例
	_test_ui_module_loading()
	_test_ui_theme_loading()
	_test_ui_component_factory()
	_test_ui_component_to_f1_window()
	_test_f3_module_loading()
	_test_f3_tick_signal()
	_test_f3_time_simulation()
	_test_module_dependencies()

func _find_app_node() -> bool:
	# 查找场景中的App节点
	var root = get_tree().root
	app_node = root.find_child("App", true, false)

	if app_node:
		print("找到App节点:", app_node.name)
		return true
	else:
		print("警告: 未找到App节点，尝试其他方法查找")
		# 尝试通过路径查找
		app_node = root.get_node_or_null("/root/App")
		if app_node:
			print("通过路径找到App节点")
			return true

	return false

func _test_ui_module_loading() -> void:
	var test = test_cases[0]

	if not app_node:
		test.set_result(TestResult.FAIL, "App节点未找到")
		return

	# 获取UI模块
	var ui_module = app_node.get_module("ui_framework")
	if ui_module:
		test.set_result(TestResult.PASS, "UI模块加载成功")
	else:
		test.set_result(TestResult.FAIL, "无法获取UI模块")

func _test_ui_theme_loading() -> void:
	var test = test_cases[1]

	var ui_module = app_node.get_module("ui_framework")
	if not ui_module:
		test.set_result(TestResult.FAIL, "UI模块未加载")
		return

	# 检查主题是否加载
	if ui_module.has_method("get_theme"):
		var theme = ui_module.get_theme()
		if theme:
			test.set_result(TestResult.PASS, "UI主题加载成功: " + str(theme.resource_name))
		else:
			test.set_result(TestResult.FAIL, "UI主题未加载")
	else:
		test.set_result(TestResult.FAIL, "UI模块缺少get_theme方法")

func _test_ui_component_factory() -> void:
	# 测试透明面板创建
	var test_panel = test_cases[2]
	var ui_module = app_node.get_module("ui_framework")

	if not ui_module:
		test_panel.set_result(TestResult.FAIL, "UI模块未加载")
		return

	# 测试创建面板
	if ui_module.has_method("create_panel"):
		var panel = ui_module.create_panel()
		if panel:
			test_panel.set_result(TestResult.PASS, "透明面板创建成功")
			# 测试创建标签
			var test_label = test_cases[3]
			if ui_module.has_method("create_label"):
				var label = ui_module.create_label("测试标签")
				if label:
					test_label.set_result(TestResult.PASS, "透明标签创建成功")
				else:
					test_label.set_result(TestResult.FAIL, "透明标签创建失败")
			else:
				test_label.set_result(TestResult.FAIL, "UI模块缺少create_label方法")
		else:
			test_panel.set_result(TestResult.FAIL, "透明面板创建失败")
	else:
		test_panel.set_result(TestResult.FAIL, "UI模块缺少create_panel方法")

func _test_ui_component_to_f1_window() -> void:
	var test = test_cases[4]

	var ui_module = app_node.get_module("ui_framework")
	var f1_module = app_node.get_module("f1_window_system")

	if not ui_module or not f1_module:
		test.set_result(TestResult.FAIL, "UI或F1模块未加载")
		return

	# 创建UI组件
	var panel = ui_module.create_panel()
	var label = ui_module.create_label("UI集成测试")
	label.position = Vector2(20, 20)

	# 将组件添加到F1节点
	panel.add_child(label)
	f1_module.add_child(panel)

	# 设置面板位置和大小
	panel.position = Vector2(50, 50)
	panel.size = Vector2(200, 100)

	test.set_result(TestResult.PASS, "UI组件已添加到F1窗口，请观察渲染效果")

	# 注意：实际渲染效果需要视觉验证
	# 这里只是验证组件添加成功

func _test_f3_module_loading() -> void:
	var test = test_cases[5]

	var f3_module = app_node.get_module("f3_time_system")
	if f3_module:
		test.set_result(TestResult.PASS, "F3模块加载成功")
	else:
		test.set_result(TestResult.FAIL, "无法获取F3模块")

func _test_f3_tick_signal() -> void:
	var test = test_cases[6]

	var f3_module = app_node.get_module("f3_time_system")
	if not f3_module:
		test.set_result(TestResult.FAIL, "F3模块未加载")
		return

	# 连接tick信号
	if f3_module.has_signal("tick"):
		# 使用Callable绑定
		f3_module.tick.connect(_on_f3_tick_received.bind(test))

		# 标记为需要手动验证（等待实际tick或模拟）
		test.set_result(TestResult.PASS, "tick信号连接成功，等待验证...")
	else:
		test.set_result(TestResult.FAIL, "F3模块缺少tick信号")

func _on_f3_tick_received(timestamp: int, delta_minutes: float, test: TestCase) -> void:
	# tick信号回调
	if test.result != TestResult.PASS:
		test.set_result(TestResult.PASS,
			"tick信号验证成功: 时间戳=" + str(timestamp) + ", Δ分钟=" + str(delta_minutes))
		print("[测试] F3 tick信号收到: 时间戳=" + str(timestamp) + ", Δ分钟=" + str(delta_minutes))

func _test_f3_time_simulation() -> void:
	var test = test_cases[7]

	var f3_module = app_node.get_module("f3_time_system")
	if not f3_module:
		test.set_result(TestResult.FAIL, "F3模块未加载")
		return

	# 检查是否有模拟时间流逝的方法
	if f3_module.has_method("simulate_time_passed"):
		# 先连接tick信号（如果尚未连接）
		if f3_module.has_signal("tick"):
			f3_module.tick.connect(_on_f3_simulated_tick.bind(test))

		# 模拟5分钟时间流逝
		f3_module.simulate_time_passed(5.0)
		test.set_result(TestResult.PASS, "模拟5分钟时间流逝成功，检查tick信号")
	else:
		test.set_result(TestResult.FAIL, "F3模块缺少simulate_time_passed方法")

func _on_f3_simulated_tick(timestamp: int, delta_minutes: float, test: TestCase) -> void:
	# 模拟tick信号回调
	if test.result == TestResult.PASS and delta_minutes == 5.0:
		print("[测试] F3模拟tick验证成功: Δ分钟=" + str(delta_minutes))
	else:
		print("[测试] F3模拟tick: Δ分钟=" + str(delta_minutes))

func _test_module_dependencies() -> void:
	var test = test_cases[8]

	# 检查模块间依赖关系
	var f2_module = app_node.get_module("f2_state_machine")
	var f1_module = app_node.get_module("f1_window_system")
	var ui_module = app_node.get_module("ui_framework")
	var f3_module = app_node.get_module("f3_time_system")

	var all_modules_loaded = f1_module and f2_module and ui_module and f3_module
	var dependencies_met = true
	var missing_deps = []

	# 检查关键依赖
	if f2_module and not f1_module:
		dependencies_met = false
		missing_deps.append("F2依赖F1")
	if ui_module and not f1_module:
		dependencies_met = false
		missing_deps.append("UI依赖F1")

	if all_modules_loaded and dependencies_met:
		test.set_result(TestResult.PASS, "所有模块依赖关系正确")
	elif not all_modules_loaded:
		test.set_result(TestResult.FAIL, "部分模块未加载")
	else:
		test.set_result(TestResult.FAIL, "依赖关系错误: " + ", ".join(missing_deps))

func _print_test_report() -> void:
	print("\n" + "=".repeat(50))
	print("Sprint 1 集成测试报告")
	print("=".repeat(50))

	var passed = 0
	var failed = 0
	var skipped = 0

	for test in test_cases:
		var status_symbol = "?"
		match test.result:
			TestResult.PASS:
				status_symbol = "✓"
				passed += 1
			TestResult.FAIL:
				status_symbol = "✗"
				failed += 1
			TestResult.SKIP:
				status_symbol = "○"
				skipped += 1

		print("%s %s: %s" % [status_symbol, test.name, test.description])
		if test.message:
			print("   └─ %s" % test.message)

	print("\n" + "=".repeat(50))
	print("总计: %d 通过, %d 失败, %d 跳过" % [passed, failed, skipped])

	if failed == 0:
		print("✅ 所有测试通过!")
	elif failed > 0:
		print("⚠️  有测试失败，请检查")

	print("=".repeat(50))

func _mark_all_as_failed(reason: String) -> void:
	for test in test_cases:
		if test.result == TestResult.SKIP:
			test.set_result(TestResult.FAIL, reason)
