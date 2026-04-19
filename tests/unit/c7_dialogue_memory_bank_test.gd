# tests/unit/c7_dialogue_memory_bank_test.gd
# C7对话记忆库单元测试
# 验证对话记录、摘要等功能

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
var c7_module: Node = null

func _ready() -> void:
	print("========================================")
	print("C7对话记忆库单元测试开始")
	print("========================================")

	# 设置测试用例
	_setup_test_cases()

	# 运行测试
	_run_all_tests()

	# 输出报告
	_print_test_report()

	print("========================================")
	print("C7单元测试完成")
	print("========================================")

func _setup_test_cases() -> void:
	# 基本功能测试
	test_cases.append(TestCase.new(
		"C7-001",
		"C7模块加载和初始化"
	))

	test_cases.append(TestCase.new(
		"C7-002",
		"记录对话交换"
	))

	test_cases.append(TestCase.new(
		"C7-003",
		"获取近期对话"
	))

	test_cases.append(TestCase.new(
		"C7-004",
		"多条对话记录"
	))

	test_cases.append(TestCase.new(
		"C7-005",
		"获取所有对话（调试）"
	))

func _run_all_tests() -> void:
	# 第一步：加载C7模块
	if not _load_c7_module():
		print("错误: 无法加载C7模块，测试终止")
		_mark_all_as_failed("C7模块加载失败")
		return

	# 运行各个测试用例
	_test_module_loading()
	_test_record_exchange()
	_test_get_recent_exchanges()
	_test_multiple_records()
	_test_get_all_exchanges()

func _load_c7_module() -> bool:
	# 实例化C7模块
	var module_class = load("res://src/gameplay/c7_dialogue_memory_bank/c7_dialogue_memory_bank.gd")
	if not module_class:
		print("错误: 无法加载C7模块类")
		return false

	c7_module = module_class.new()
	if not c7_module:
		print("错误: 无法实例化C7模块")
		return false

	# 初始化模块
	var init_success = c7_module.initialize({})
	if not init_success:
		print("警告: C7模块初始化失败")
		return false

	print("C7模块加载成功")
	return true

func _test_module_loading() -> void:
	var test = test_cases[0]

	if c7_module:
		test.set_result(TestResult.PASS, "C7模块加载成功")
	else:
		test.set_result(TestResult.FAIL, "C7模块未加载")

func _test_record_exchange() -> void:
	var test = test_cases[1]

	if not c7_module:
		test.set_result(TestResult.FAIL, "C7模块未加载")
		return

	var exchange_id = c7_module.record_exchange(
		"你好",
		"你好！很高兴见到你。",
		"aria",
		["friendly"]
	)

	if exchange_id != "":
		test.set_result(TestResult.PASS, "对话记录成功，ID: " + exchange_id)
	else:
		test.set_result(TestResult.FAIL, "对话记录失败，返回空ID")

func _test_get_recent_exchanges() -> void:
	var test = test_cases[2]

	if not c7_module:
		test.set_result(TestResult.FAIL, "C7模块未加载")
		return

	# 先记录一条对话
	c7_module.record_exchange(
		"测试问题",
		"测试回答",
		"aria",
		[]
	)

	var recent = c7_module.get_recent_exchanges("aria", 1)

	if recent.size() == 1:
		test.set_result(TestResult.PASS, "获取近期对话成功，数量: " + str(recent.size()))
	else:
		test.set_result(TestResult.FAIL, "获取近期对话失败，期望1条，得到: " + str(recent.size()))

func _test_multiple_records() -> void:
	var test = test_cases[3]

	if not c7_module:
		test.set_result(TestResult.FAIL, "C7模块未加载")
		return

	# 记录多条对话
	for i in range(3):
		c7_module.record_exchange(
			"问题" + str(i),
			"回答" + str(i),
			"aria",
			[]
		)

	var recent = c7_module.get_recent_exchanges("aria", 3)

	if recent.size() >= 3:
		test.set_result(TestResult.PASS, "多条对话记录成功，获取到: " + str(recent.size()) + "条")
	else:
		test.set_result(TestResult.FAIL, "多条对话记录失败，期望至少3条，得到: " + str(recent.size()))

func _test_get_all_exchanges() -> void:
	var test = test_cases[4]

	if not c7_module:
		test.set_result(TestResult.FAIL, "C7模块未加载")
		return

	var all = c7_module.get_all_exchanges()

	if all is Dictionary:
		test.set_result(TestResult.PASS, "获取所有对话成功，总数: " + str(all.size()))
	else:
		test.set_result(TestResult.FAIL, "获取所有对话失败，返回类型错误")

func _print_test_report() -> void:
	print("\n" + "=".repeat(50))
	print("C7对话记忆库单元测试报告")
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
