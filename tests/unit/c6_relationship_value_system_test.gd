# tests/unit/c6_relationship_value_system_test.gd
# C6关系值系统单元测试
# 验证关系值计算、等级变化等功能

extends Node

# 测试结果枚举
enum TestResult {
	PASS,
	FAIL,
	SKIP
}

# 测试用例类
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
var c6_module: Node = null

func _ready() -> void:
	print("========================================")
	print("C6关系值系统单元测试开始")
	print("========================================")

	# 设置测试用例
	_setup_test_cases()

	# 运行测试
	_run_all_tests()

	# 输出报告
	_print_test_report()

	print("========================================")
	print("C6单元测试完成")
	print("========================================")

func _setup_test_cases() -> void:
	# 基本功能测试
	test_cases.append(TestCase.new(
		"C6-001",
		"C6模块加载和初始化"
	))

	test_cases.append(TestCase.new(
		"C6-002",
		"获取初始关系值为0"
	))

	test_cases.append(TestCase.new(
		"C6-003",
		"修改关系值增加"
	))

	test_cases.append(TestCase.new(
		"C6-004",
		"修改关系值减少"
	))

	test_cases.append(TestCase.new(
		"C6-005",
		"关系值不超过最大值100"
	))

	test_cases.append(TestCase.new(
		"C6-006",
		"关系值不低于最小值-100"
	))

	test_cases.append(TestCase.new(
		"C6-007",
		"获取初始关系等级为1（认识）"
	))

	test_cases.append(TestCase.new(
		"C6-008",
		"关系值达到20时等级为2（熟悉）"
	))

	test_cases.append(TestCase.new(
		"C6-009",
		"关系值达到50时等级为3（亲密）"
	))

	test_cases.append(TestCase.new(
		"C6-010",
		"关系值达到80时等级为4（挚友）"
	))

func _run_all_tests() -> void:
	# 第一步：加载C6模块
	if not _load_c6_module():
		print("错误: 无法加载C6模块，测试终止")
		_mark_all_as_failed("C6模块加载失败")
		return

	# 运行各个测试用例
	_test_module_loading()
	_test_initial_relationship()
	_test_modify_increase()
	_test_modify_decrease()
	_test_max_value()
	_test_min_value()
	_test_initial_tier()
	_test_tier_2()
	_test_tier_3()
	_test_tier_4()

func _load_c6_module() -> bool:
	# 实例化C6模块
	var module_class = load("res://src/gameplay/c6_relationship_value_system/c6_relationship_value_system.gd")
	if not module_class:
		print("错误: 无法加载C6模块类")
		return false

	c6_module = module_class.new()
	if not c6_module:
		print("错误: 无法实例化C6模块")
		return false

	# 初始化模块
	var init_success = c6_module.initialize({})
	if not init_success:
		print("警告: C6模块初始化失败")
		return false

	print("C6模块加载成功")
	return true

func _test_module_loading() -> void:
	var test = test_cases[0]

	if c6_module:
		test.set_result(TestResult.PASS, "C6模块加载成功")
	else:
		test.set_result(TestResult.FAIL, "C6模块未加载")

func _test_initial_relationship() -> void:
	var test = test_cases[1]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	var value = c6_module.get_relationship_value("test_char")
	if value == 0.0:
		test.set_result(TestResult.PASS, "初始关系值为0")
	else:
		test.set_result(TestResult.FAIL, "初始关系值错误，得到: " + str(value))

func _test_modify_increase() -> void:
	var test = test_cases[2]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", 0.0)
	c6_module.modify_relationship("test_char", 10.0)
	var value = c6_module.get_relationship_value("test_char")

	if value == 10.0:
		test.set_result(TestResult.PASS, "关系值增加成功: 0 + 10 = 10")
	else:
		test.set_result(TestResult.FAIL, "关系值增加失败，得到: " + str(value))

func _test_modify_decrease() -> void:
	var test = test_cases[3]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", 10.0)
	c6_module.modify_relationship("test_char", -5.0)
	var value = c6_module.get_relationship_value("test_char")

	if value == 5.0:
		test.set_result(TestResult.PASS, "关系值减少成功: 10 - 5 = 5")
	else:
		test.set_result(TestResult.FAIL, "关系值减少失败，得到: " + str(value))

func _test_max_value() -> void:
	var test = test_cases[4]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", 95.0)
	c6_module.modify_relationship("test_char", 10.0)
	var value = c6_module.get_relationship_value("test_char")

	if value == 100.0:
		test.set_result(TestResult.PASS, "关系值正确限制在最大值100")
	else:
		test.set_result(TestResult.FAIL, "关系值限制失败，得到: " + str(value))

func _test_min_value() -> void:
	var test = test_cases[5]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", -95.0)
	c6_module.modify_relationship("test_char", -10.0)
	var value = c6_module.get_relationship_value("test_char")

	if value == -100.0:
		test.set_result(TestResult.PASS, "关系值正确限制在最小值-100")
	else:
		test.set_result(TestResult.FAIL, "关系值限制失败，得到: " + str(value))

func _test_initial_tier() -> void:
	var test = test_cases[6]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", 0.0)
	var tier = c6_module.get_relationship_tier("test_char")

	if tier == 1:
		test.set_result(TestResult.PASS, "初始关系等级为1（认识）")
	else:
		test.set_result(TestResult.FAIL, "初始关系等级错误，得到: " + str(tier))

func _test_tier_2() -> void:
	var test = test_cases[7]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", 20.0)
	var tier = c6_module.get_relationship_tier("test_char")

	if tier == 2:
		test.set_result(TestResult.PASS, "关系值20时等级为2（熟悉）")
	else:
		test.set_result(TestResult.FAIL, "关系等级错误，得到: " + str(tier))

func _test_tier_3() -> void:
	var test = test_cases[8]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", 50.0)
	var tier = c6_module.get_relationship_tier("test_char")

	if tier == 3:
		test.set_result(TestResult.PASS, "关系值50时等级为3（亲密）")
	else:
		test.set_result(TestResult.FAIL, "关系等级错误，得到: " + str(tier))

func _test_tier_4() -> void:
	var test = test_cases[9]

	if not c6_module:
		test.set_result(TestResult.FAIL, "C6模块未加载")
		return

	c6_module.set_relationship_value("test_char", 80.0)
	var tier = c6_module.get_relationship_tier("test_char")

	if tier == 4:
		test.set_result(TestResult.PASS, "关系值80时等级为4（挚友）")
	else:
		test.set_result(TestResult.FAIL, "关系等级错误，得到: " + str(tier))

func _print_test_report() -> void:
	print("\n" + "=".repeat(50))
	print("C6关系值系统单元测试报告")
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
