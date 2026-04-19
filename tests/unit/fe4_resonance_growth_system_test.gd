# tests/unit/fe4_resonance_growth_system_test.gd
# FE4共鸣成长系统单元测试
# 验证共鸣度计算、等级变化、成就等功能

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
var fe4_module: Node = null

func _ready() -> void:
	print("========================================")
	print("FE4共鸣成长系统单元测试开始")
	print("========================================")

	# 设置测试用例
	_setup_test_cases()

	# 运行测试
	_run_all_tests()

	# 输出报告
	_print_test_report()

	print("========================================")
	print("FE4单元测试完成")
	print("========================================")

func _setup_test_cases() -> void:
	# 基本功能测试
	test_cases.append(TestCase.new(
		"FE4-001",
		"FE4模块加载和初始化"
	))

	test_cases.append(TestCase.new(
		"FE4-002",
		"获取初始共鸣度为0"
	))

	test_cases.append(TestCase.new(
		"FE4-003",
		"修改共鸣度增加"
	))

	test_cases.append(TestCase.new(
		"FE4-004",
		"共鸣度不超过最大值150"
	))

	test_cases.append(TestCase.new(
		"FE4-005",
		"共鸣度不低于最小值0"
	))

	test_cases.append(TestCase.new(
		"FE4-006",
		"获取初始共鸣等级为0（初识）"
	))

	test_cases.append(TestCase.new(
		"FE4-007",
		"共鸣度达到10时等级为1（熟悉）"
	))

	test_cases.append(TestCase.new(
		"FE4-008",
		"共鸣度达到30时等级为2（默契）"
	))

	test_cases.append(TestCase.new(
		"FE4-009",
		"共鸣度达到60时等级为3（知音）"
	))

	test_cases.append(TestCase.new(
		"FE4-010",
		"共鸣度达到100时等级为4（灵魂伴侣）"
	))

func _run_all_tests() -> void:
	# 第一步：加载FE4模块
	if not _load_fe4_module():
		print("错误: 无法加载FE4模块，测试终止")
		_mark_all_as_failed("FE4模块加载失败")
		return

	# 运行各个测试用例
	_test_module_loading()
	_test_initial_resonance()
	_test_modify_increase()
	_test_max_value()
	_test_min_value()
	_test_initial_tier()
	_test_tier_1()
	_test_tier_2()
	_test_tier_3()
	_test_tier_4()

func _load_fe4_module() -> bool:
	# 实例化FE4模块
	var module_class = load("res://src/gameplay/fe4_resonance_growth_system/fe4_resonance_growth_system.gd")
	if not module_class:
		print("错误: 无法加载FE4模块类")
		return false

	fe4_module = module_class.new()
	if not fe4_module:
		print("错误: 无法实例化FE4模块")
		return false

	# 初始化模块
	var init_success = fe4_module.initialize({})
	if not init_success:
		print("警告: FE4模块初始化失败")
		return false

	print("FE4模块加载成功")
	return true

func _test_module_loading() -> void:
	var test = test_cases[0]

	if fe4_module:
		test.set_result(TestResult.PASS, "FE4模块加载成功")
	else:
		test.set_result(TestResult.FAIL, "FE4模块未加载")

func _test_initial_resonance() -> void:
	var test = test_cases[1]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	var value = fe4_module.get_resonance_value("test_char")
	if value == 0.0:
		test.set_result(TestResult.PASS, "初始共鸣度为0")
	else:
		test.set_result(TestResult.FAIL, "初始共鸣度错误，得到: " + str(value))

func _test_modify_increase() -> void:
	var test = test_cases[2]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 0.0)
	fe4_module.modify_resonance("test_char", 15.0)
	var value = fe4_module.get_resonance_value("test_char")

	if value == 15.0:
		test.set_result(TestResult.PASS, "共鸣度增加成功: 0 + 15 = 15")
	else:
		test.set_result(TestResult.FAIL, "共鸣度增加失败，得到: " + str(value))

func _test_max_value() -> void:
	var test = test_cases[3]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 145.0)
	fe4_module.modify_resonance("test_char", 10.0)
	var value = fe4_module.get_resonance_value("test_char")

	if value == 150.0:
		test.set_result(TestResult.PASS, "共鸣度正确限制在最大值150")
	else:
		test.set_result(TestResult.FAIL, "共鸣度限制失败，得到: " + str(value))

func _test_min_value() -> void:
	var test = test_cases[4]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 5.0)
	fe4_module.modify_resonance("test_char", -10.0)
	var value = fe4_module.get_resonance_value("test_char")

	if value == 0.0:
		test.set_result(TestResult.PASS, "共鸣度正确限制在最小值0")
	else:
		test.set_result(TestResult.FAIL, "共鸣度限制失败，得到: " + str(value))

func _test_initial_tier() -> void:
	var test = test_cases[5]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 0.0)
	var tier = fe4_module.get_resonance_tier("test_char")

	if tier == 0:
		test.set_result(TestResult.PASS, "初始共鸣等级为0（初识）")
	else:
		test.set_result(TestResult.FAIL, "初始共鸣等级错误，得到: " + str(tier))

func _test_tier_1() -> void:
	var test = test_cases[6]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 10.0)
	var tier = fe4_module.get_resonance_tier("test_char")

	if tier == 1:
		test.set_result(TestResult.PASS, "共鸣度10时等级为1（熟悉）")
	else:
		test.set_result(TestResult.FAIL, "共鸣等级错误，得到: " + str(tier))

func _test_tier_2() -> void:
	var test = test_cases[7]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 30.0)
	var tier = fe4_module.get_resonance_tier("test_char")

	if tier == 2:
		test.set_result(TestResult.PASS, "共鸣度30时等级为2（默契）")
	else:
		test.set_result(TestResult.FAIL, "共鸣等级错误，得到: " + str(tier))

func _test_tier_3() -> void:
	var test = test_cases[8]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 60.0)
	var tier = fe4_module.get_resonance_tier("test_char")

	if tier == 3:
		test.set_result(TestResult.PASS, "共鸣度60时等级为3（知音）")
	else:
		test.set_result(TestResult.FAIL, "共鸣等级错误，得到: " + str(tier))

func _test_tier_4() -> void:
	var test = test_cases[9]

	if not fe4_module:
		test.set_result(TestResult.FAIL, "FE4模块未加载")
		return

	fe4_module.set_resonance_value("test_char", 100.0)
	var tier = fe4_module.get_resonance_tier("test_char")

	if tier == 4:
		test.set_result(TestResult.PASS, "共鸣度100时等级为4（灵魂伴侣）")
	else:
		test.set_result(TestResult.FAIL, "共鸣等级错误，得到: " + str(tier))

func _print_test_report() -> void:
	print("\n" + "=".repeat(50))
	print("FE4共鸣成长系统单元测试报告")
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
