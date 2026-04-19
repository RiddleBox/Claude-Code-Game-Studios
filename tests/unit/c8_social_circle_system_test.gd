# tests/unit/c8_social_circle_system_test.gd
# C8社交圈系统单元测试
# 验证角色轮换、活跃角色等功能

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
var c8_module: Node = null

func _ready() -> void:
	print("========================================")
	print("C8社交圈系统单元测试开始")
	print("========================================")

	# 设置测试用例
	_setup_test_cases()

	# 运行测试
	_run_all_tests()

	# 输出报告
	_print_test_report()

	print("========================================")
	print("C8单元测试完成")
	print("========================================")

func _setup_test_cases() -> void:
	# 基本功能测试
	test_cases.append(TestCase.new(
		"C8-001",
		"C8模块加载和初始化"
	))

	test_cases.append(TestCase.new(
		"C8-002",
		"获取当前活跃角色"
	))

	test_cases.append(TestCase.new(
		"C8-003",
		"获取所有角色列表"
	))

	test_cases.append(TestCase.new(
		"C8-004",
		"获取角色信息"
	))

func _run_all_tests() -> void:
	# 第一步：加载C8模块
	if not _load_c8_module():
		print("错误: 无法加载C8模块，测试终止")
		_mark_all_as_failed("C8模块加载失败")
		return

	# 运行各个测试用例
	_test_module_loading()
	_test_get_active_character()
	_test_get_all_characters()
	_test_get_character_info()

func _load_c8_module() -> bool:
	# 实例化C8模块
	var module_class = load("res://src/gameplay/c8_social_circle_system/c8_social_circle_system.gd")
	if not module_class:
		print("错误: 无法加载C8模块类")
		return false

	c8_module = module_class.new()
	if not c8_module:
		print("错误: 无法实例化C8模块")
		return false

	# 初始化模块
	var init_success = c8_module.initialize({})
	if not init_success:
		print("警告: C8模块初始化失败")
		return false

	print("C8模块加载成功")
	return true

func _test_module_loading() -> void:
	var test = test_cases[0]

	if c8_module:
		test.set_result(TestResult.PASS, "C8模块加载成功")
	else:
		test.set_result(TestResult.FAIL, "C8模块未加载")

func _test_get_active_character() -> void:
	var test = test_cases[1]

	if not c8_module:
		test.set_result(TestResult.FAIL, "C8模块未加载")
		return

	var active = c8_module.get_active_character()

	if active != "":
		test.set_result(TestResult.PASS, "获取活跃角色成功: " + active)
	else:
		test.set_result(TestResult.FAIL, "获取活跃角色失败，返回空字符串")

func _test_get_all_characters() -> void:
	var test = test_cases[2]

	if not c8_module:
		test.set_result(TestResult.FAIL, "C8模块未加载")
		return

	var all = c8_module.get_all_characters()

	if all is Dictionary:
		test.set_result(TestResult.PASS, "获取所有角色成功，数量: " + str(all.size()))
	else:
		test.set_result(TestResult.FAIL, "获取所有角色失败，返回类型错误")

func _test_get_character_info() -> void:
	var test = test_cases[3]

	if not c8_module:
		test.set_result(TestResult.FAIL, "C8模块未加载")
		return

	var info = c8_module.get_character_info("aria")

	if info is Dictionary and info.size() > 0:
		test.set_result(TestResult.PASS, "获取角色信息成功")
	else:
		test.set_result(TestResult.FAIL, "获取角色信息失败")

func _print_test_report() -> void:
	print("\n" + "=".repeat(50))
	print("C8社交圈系统单元测试报告")
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
