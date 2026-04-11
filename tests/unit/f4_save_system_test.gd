# tests/unit/f4_save_system_test.gd
# F4存档系统单元测试
# 验证基本save/load功能

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
var f4_module: Node = null

func _ready() -> void:
	print("========================================")
	print("F4存档系统单元测试开始")
	print("========================================")

	# 设置测试用例
	_setup_test_cases()

	# 运行测试
	_run_all_tests()

	# 输出报告
	_print_test_report()

	print("========================================")
	print("F4单元测试完成")
	print("========================================")

func _setup_test_cases() -> void:
	# 基本功能测试
	test_cases.append(TestCase.new(
		"F4-001",
		"F4模块加载和初始化"
	))

	test_cases.append(TestCase.new(
		"F4-002",
		"保存单个键值 - 整数"
	))

	test_cases.append(TestCase.new(
		"F4-003",
		"读取存在的键值"
	))

	test_cases.append(TestCase.new(
		"F4-004",
		"读取不存在的键值返回默认值"
	))

	test_cases.append(TestCase.new(
		"F4-005",
		"批量保存多个键值"
	))

	test_cases.append(TestCase.new(
		"F4-006",
		"删除键值"
	))

	test_cases.append(TestCase.new(
		"F4-007",
		"获取存档统计信息"
	))

	test_cases.append(TestCase.new(
		"F4-008",
		"多次保存负载一致性"
	))

func _run_all_tests() -> void:
	# 第一步：加载F4模块
	if not _load_f4_module():
		print("错误: 无法加载F4模块，测试终止")
		_mark_all_as_failed("F4模块加载失败")
		return

	# 运行各个测试用例
	_test_module_loading()
	_test_save_single_int()
	_test_load_existing()
	_test_load_nonexistent()
	_test_save_batch()
	_test_delete_key()
	_test_get_stats()
	_test_multiple_save_load()

func _load_f4_module() -> bool:
	# 实例化F4模块
	var module_class = load("res://src/core/f4_save_system/f4_save_system.gd")
	if not module_class:
		print("错误: 无法加载F4模块类")
		return false

	f4_module = module_class.new()
	if not f4_module:
		print("错误: 无法实例化F4模块")
		return false

	# 初始化模块
	var init_success = f4_module.initialize({})
	if not init_success:
		print("警告: F4模块初始化失败")
		return false

	print("F4模块加载成功")
	return true

func _test_module_loading() -> void:
	var test = test_cases[0]

	if f4_module:
		test.set_result(TestResult.PASS, "F4模块加载成功")
	else:
		test.set_result(TestResult.FAIL, "F4模块未加载")

func _test_save_single_int() -> void:
	var test = test_cases[1]

	if not f4_module:
		test.set_result(TestResult.FAIL, "F4模块未加载")
		return

	# 保存整数值
	var success = f4_module.save("test.int_key", 42)
	if success:
		test.set_result(TestResult.PASS, "整数保存成功: 42")
	else:
		test.set_result(TestResult.FAIL, "整数保存失败")

func _test_load_existing() -> void:
	var test = test_cases[2]

	if not f4_module:
		test.set_result(TestResult.FAIL, "F4模块未加载")
		return

	# 读取之前保存的值
	var value = f4_module.load("test.int_key", -1)
	if value == 42:
		test.set_result(TestResult.PASS, "整数读取成功: " + str(value))
	else:
		test.set_result(TestResult.FAIL, "整数读取失败，得到: " + str(value))

func _test_load_nonexistent() -> void:
	var test = test_cases[3]

	if not f4_module:
		test.set_result(TestResult.FAIL, "F4模块未加载")
		return

	# 读取不存在的键
	var value = f4_module.load("test.nonexistent", 99)
	if value == 99:
		test.set_result(TestResult.PASS, "默认值返回成功: " + str(value))
	else:
		test.set_result(TestResult.FAIL, "默认值返回失败，得到: " + str(value))

func _test_save_batch() -> void:
	var test = test_cases[4]

	if not f4_module:
		test.set_result(TestResult.FAIL, "F4模块未加载")
		return

	# 批量保存
	var batch_data = {
		"batch.key1": "value1",
		"batch.key2": 3.14,
		"batch.key3": true
	}

	var success = f4_module.save_batch(batch_data)
	if success:
		test.set_result(TestResult.PASS, "批量保存成功: " + str(batch_data.size()) + " 个键值")
	else:
		test.set_result(TestResult.FAIL, "批量保存失败")

func _test_delete_key() -> void:
	var test = test_cases[5]

	if not f4_module:
		test.set_result(TestResult.FAIL, "F4模块未加载")
		return

	# 保存一个键用于删除测试
	f4_module.save("test.delete_key", "to_be_deleted")

	# 删除键
	var success = f4_module.delete("test.delete_key")
	if success:
		# 验证键已被删除
		var value = f4_module.load("test.delete_key", null)
		if value == null:
			test.set_result(TestResult.PASS, "键删除成功")
		else:
			test.set_result(TestResult.FAIL, "键删除后仍然存在，得到: " + str(value))
	else:
		test.set_result(TestResult.FAIL, "删除操作失败")

func _test_get_stats() -> void:
	var test = test_cases[6]

	if not f4_module:
		test.set_result(TestResult.FAIL, "F4模块未加载")
		return

	# 获取统计信息
	var stats = f4_module.get_stats()

	if stats.has("total_keys"):
		test.set_result(TestResult.PASS, "统计信息获取成功，总键值: " + str(stats["total_keys"]))
	else:
		test.set_result(TestResult.FAIL, "统计信息缺少必要字段")

func _test_multiple_save_load() -> void:
	var test = test_cases[7]

	if not f4_module:
		test.set_result(TestResult.FAIL, "F4模块未加载")
		return

	# 测试多次保存和加载的一致性
	var test_key = "test.multi_key"
	var test_value = {"nested": true, "count": 7}

	# 第一次保存
	var save1 = f4_module.save(test_key, test_value)
	if not save1:
		test.set_result(TestResult.FAIL, "第一次保存失败")
		return

	# 第一次加载
	var load1 = f4_module.load(test_key, {})
	if load1 is Dictionary and load1.get("count") == 7:
		# 第二次保存（更新值）
		var updated_value = {"nested": false, "count": 12}
		var save2 = f4_module.save(test_key, updated_value)
		if not save2:
			test.set_result(TestResult.FAIL, "第二次保存失败")
			return

		# 第二次加载
		var load2 = f4_module.load(test_key, {})
		if load2 is Dictionary and load2.get("count") == 12:
			test.set_result(TestResult.PASS, "多次保存负载一致性验证成功")
		else:
			test.set_result(TestResult.FAIL, "第二次加载失败，得到: " + str(load2))
	else:
		test.set_result(TestResult.FAIL, "第一次加载失败，得到: " + str(load1))

func _print_test_report() -> void:
	print("\n" + "=".repeat(50))
	print("F4存档系统单元测试报告")
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

# 清理测试数据（可选）
func _exit_tree() -> void:
	if f4_module:
		# 清理测试创建的键
		var keys_to_delete = [
			"test.int_key",
			"batch.key1", "batch.key2", "batch.key3",
			"test.delete_key",
			"test.multi_key"
		]

		for key in keys_to_delete:
			f4_module.delete(key)

		print("测试数据已清理")