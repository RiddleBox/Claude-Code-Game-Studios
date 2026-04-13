# tests/integration/sprint3_integration_test.gd
# Sprint3集成测试 - 测试Fe1/Fe2/Fe3/Fe5/P1功能模块
# 独立测试场景，在启动后自动运行

class_name Sprint3IntegrationTest
extends Node

## 测试统计
var _tests_passed: int = 0
var _tests_failed: int = 0
var _tests_skipped: int = 0

## 测试结果
var _test_results: Array = []

## App引用
var _app: Node = null

## 启动时运行
func _ready() -> void:
	print("========================================")
	print("Sprint 3 集成测试开始")
	print("========================================")

	# 获取App节点
	_app = get_node_or_null("/root/App")
	if not _app:
		print("[Test] 错误: 无法找到App节点")
		return

	# 延迟运行测试（等待所有模块初始化完成）



	_run_all_tests()

## 运行所有测试
func _run_all_tests() -> void:
	print("[Test] 开始运行Sprint3集成测试...")

	# 测试1: Fe1对话系统
	_run_test("FE1-001", "Fe1对话系统模块加载和初始化", _test_fe1_module)

	# 测试2: Fe1对话显示
	_run_test("FE1-002", "Fe1对话显示功能", _test_fe1_show_dialogue)

	# 测试3: Fe2记忆系统
	_run_test("FE2-001", "Fe2记忆系统模块加载和初始化", _test_fe2_module)

	# 测试4: Fe2添加记忆
	_run_test("FE2-002", "Fe2记忆添加功能", _test_fe2_add_memory)

	# 测试5: Fe3好感度系统
	_run_test("FE3-001", "Fe3好感度系统模块加载和初始化", _test_fe3_module)

	# 测试6: Fe3好感度增加
	_run_test("FE3-002", "Fe3好感度增加功能", _test_fe3_add_affinity)

	# 测试7: Fe5音频系统
	_run_test("FE5-001", "Fe5音频系统模块加载和初始化", _test_fe5_module)

	# 测试8: P1主UI系统
	_run_test("P1-001", "P1主UI系统模块加载和初始化", _test_p1_module)

	# 打印测试报告
	_print_test_report()

## 运行单个测试
func _run_test(test_id: String, test_name: String, test_func: Callable) -> void:
	print("\n[Test] 运行 %s: %s" % [test_id, test_name])

	var success = false
	var error_msg = ""

	success = test_func.call()

	if success:
		_tests_passed += 1
		_test_results.append({"id": test_id, "name": test_name, "passed": true})
		print("✓ %s: 通过" % test_id)
	else:
		_tests_failed += 1
		_test_results.append({"id": test_id, "name": test_name, "passed": false, "error": error_msg})
		print("✗ %s: 失败" % test_id)
		if not error_msg.is_empty():
			print("   └─ %s" % error_msg)

## 打印测试报告
func _print_test_report() -> void:
	print("
==================================================")
	print("Sprint 3 集成测试报告")
	print("==================================================")

	for result in _test_results:
		if result.passed:
			print("✓ %s: %s" % [result.id, result.name])
		else:
			print("✗ %s: %s" % [result.id, result.name])
			if result.has("error") and not result.error.is_empty():
				print("   └─ %s" % result.error)

	print("\n总计: %d 通过, %d 失败, %d 跳过" % [_tests_passed, _tests_failed, _tests_skipped])

	if _tests_failed > 0:
		print("⚠️  有测试失败，请检查")
	else:
		print("✓ 所有测试通过！")

	print("==================================================")

## ========== 测试用例 ==========

## 测试Fe1对话系统模块
func _test_fe1_module() -> bool:
	if not _app or not _app.has_method("get_module"):
		return false

	var fe1 = _app.get_module("fe1_dialogue_system")
	if not fe1:
		return false

	return fe1.has_method("show_dialogue") and fe1.has_method("trigger_event_dialogue")

## 测试Fe1对话显示
func _test_fe1_show_dialogue() -> bool:
	var fe1 = _app.get_module("fe1_dialogue_system")
	if not fe1:
		return false

	# 测试显示普通对话
	var result = fe1.show_dialogue("测试对话", 0, 1.0, 0)
	if not result:
		return false

	return true

## 测试Fe2记忆系统模块
func _test_fe2_module() -> bool:
	var fe2 = _app.get_module("fe2_memory_system")
	if not fe2:
		return false

	return fe2.has_method("add_memory") and fe2.has_method("query_memories")

## 测试Fe2添加记忆
func _test_fe2_add_memory() -> bool:
	var fe2 = _app.get_module("fe2_memory_system")
	if not fe2:
		return false

	# 添加测试记忆
	var memory_id = fe2.add_memory("测试记忆内容", 0, ["test"], 5)
	if memory_id.is_empty():
		return false

	# 查询记忆
	var memories = fe2.query_memories(-1, ["test"])
	return memories.size() > 0

## 测试Fe3好感度系统模块
func _test_fe3_module() -> bool:
	var fe3 = _app.get_module("fe3_affinity_system")
	if not fe3:
		return false

	return (fe3.has_method("add_affinity") and fe3.has_method("get_current_score")
		and fe3.has_method("get_current_level"))

## 测试Fe3好感度增加
func _test_fe3_add_affinity() -> bool:
	var fe3 = _app.get_module("fe3_affinity_system")
	if not fe3:
		return false

	var old_score = fe3.get_current_score()
	var new_score = fe3.add_affinity(10.0, "测试互动")

	return new_score > old_score

## 测试Fe5音频系统模块
func _test_fe5_module() -> bool:
	var fe5 = _app.get_module("fe5_audio_system")
	if not fe5:
		return false

	return (fe5.has_method("play_sfx") and fe5.has_method("set_sfx_volume")
		and fe5.has_method("set_muted"))

## 测试P1主UI系统模块
func _test_p1_module() -> bool:
	var p1 = _app.get_module("p1_main_ui")
	if not p1:
		return false

	return (p1.has_method("show_ui") and p1.has_method("open_panel")
		and p1.has_method("close_panel"))
