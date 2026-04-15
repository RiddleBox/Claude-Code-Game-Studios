# tests/integration/sprint4_integration_test.gd
# Sprint4集成测试 - 测试C3/C4/C5/Fe6/P2/P3垂直切片系统
# 独立测试场景，在启动后自动运行

class_name Sprint4IntegrationTest
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
	print("Sprint 4 集成测试开始")
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
	print("[Test] 开始运行Sprint4集成测试...")

	# 测试1: C3碎片系统模块加载
	_run_test("C3-001", "C3碎片系统模块加载和初始化", _test_c3_module)

	# 测试2: C3碎片入库
	_run_test("C3-002", "C3碎片接收和存储功能", _test_c3_receive_fragments)

	# 测试3: C3碎片查询
	_run_test("C3-003", "C3碎片查询和筛选功能", _test_c3_query_fragments)

	# 测试4: C5性格变量系统模块加载
	_run_test("C5-001", "C5性格变量系统模块加载和初始化", _test_c5_module)

	# 测试5: C5性格读取
	_run_test("C5-002", "C5性格变量读取功能", _test_c5_get_personality)

	# 测试6: C5性格变化
	_run_test("C5-003", "C5性格变化和持久化功能", _test_c5_shift_personality)

	# 测试7: C5内容评分
	_run_test("C5-004", "C5内容评分功能", _test_c5_score_content)

	# 测试8: C4事件线系统模块加载
	_run_test("C4-001", "C4事件线系统模块加载和初始化", _test_c4_module)

	# 测试9: Fe6通知提醒系统模块加载
	_run_test("FE6-001", "Fe6通知提醒系统模块加载和初始化", _test_fe6_module)

	# 测试10: Fe6通知显示
	_run_test("FE6-002", "Fe6通知显示和消除功能", _test_fe6_show_notification)

	# 测试11: Fe6勿扰模式
	_run_test("FE6-003", "Fe6勿扰模式功能", _test_fe6_dnd_mode)

	# 测试12: P2碎片日志UI模块加载
	_run_test("P2-001", "P2碎片日志UI模块加载和初始化", _test_p2_module)

	# 测试13: P2碎片筛选
	_run_test("P2-002", "P2碎片筛选和排序功能", _test_p2_filter_fragments)

	# 测试14: P3设置UI模块加载
	_run_test("P3-001", "P3设置UI模块加载和初始化", _test_p3_module)

	# 测试15: P3设置读写
	_run_test("P3-002", "P3设置读写和应用功能", _test_p3_settings)

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
	print("\n==================================================")
	print("Sprint 4 集成测试报告")
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

## 测试C3碎片系统模块
func _test_c3_module() -> bool:
	if not _app or not _app.has_method("get_module"):
		return false

	var c3 = _app.get_module("c3_fragment_system")
	if not c3:
		return false

	return (c3.has_method("get_all") and c3.has_method("receive_fragments")
		and c3.has_method("mark_read") and c3.has_method("get_unread"))

## 测试C3碎片接收和存储
func _test_c3_receive_fragments() -> bool:
	var c3 = _app.get_module("c3_fragment_system")
	if not c3:
		return false

	# 创建测试碎片
	var test_payloads = [
		{
			"content_id": "test_001",
			"type": "dialogue",
			"text": "测试对话内容",
			"emotion_tag": "peaceful"
		}
	]

	# 接收碎片
	var received_ids = c3.receive_fragments(test_payloads, "test_outing_001")
	if received_ids.is_empty():
		return false

	# 验证碎片已存储
	var all_fragments = c3.get_all()
	return all_fragments.size() > 0

## 测试C3碎片查询和筛选
func _test_c3_query_fragments() -> bool:
	var c3 = _app.get_module("c3_fragment_system")
	if not c3:
		return false

	# 测试get_all
	var all_fragments = c3.get_all()
	if all_fragments.is_empty():
		return false

	# 测试get_unread
	var unread = c3.get_unread()
	if unread.is_empty():
		return false

	# 测试get_by_type
	var dialogues = c3.get_by_type("dialogue")
	# 测试get_latest
	var latest = c3.get_latest(1)

	return latest.size() == 1

## 测试C5性格变量系统模块
func _test_c5_module() -> bool:
	var c5 = _app.get_module("c5_personality_variable_system")
	if not c5:
		return false

	return (c5.has_method("get_axis") and c5.has_method("get_all")
		and c5.has_method("shift") and c5.has_method("score_content")
		and c5.has_method("get_display_label"))

## 测试C5性格变量读取
func _test_c5_get_personality() -> bool:
	var c5 = _app.get_module("c5_personality_variable_system")
	if not c5:
		return false

	# 测试单轴读取
	var curiosity = c5.get_axis("curiosity")
	# 测试全轴读取
	var all = c5.get_all()
	# 测试显示标签
	var label = c5.get_display_label()

	return all.size() > 0 and not label.is_empty()

## 测试C5性格变化和持久化
func _test_c5_shift_personality() -> bool:
	var c5 = _app.get_module("c5_personality_variable_system")
	if not c5:
		return false

	var old_val = c5.get_axis("curiosity")
	c5.shift("curiosity", 0.01)
	var new_val = c5.get_axis("curiosity")

	# 验证值已变化
	return new_val > old_val

## 测试C5内容评分
func _test_c5_score_content() -> bool:
	var c5 = _app.get_module("c5_personality_variable_system")
	if not c5:
		return false

	# 测试评分
	var weights = {"curiosity": 0.8, "warmth": 0.5}
	var score = c5.score_content(weights)

	# 评分应为非负数
	return score >= 0.0

## 测试C4事件线系统模块
func _test_c4_module() -> bool:
	var c4 = _app.get_module("c4_event_line_system")
	if not c4:
		return false

	return c4.has_method("get_outing_content")

## 测试Fe6通知提醒系统模块
func _test_fe6_module() -> bool:
	var fe6 = _app.get_module("fe6_notification_system")
	if not fe6:
		return false

	return (fe6.has_method("show_notification") and fe6.has_method("dismiss_notification")
		and fe6.has_method("set_dnd_mode") and fe6.has_method("get_dnd_mode"))

## 测试Fe6通知显示和消除
func _test_fe6_show_notification() -> bool:
	var fe6 = _app.get_module("fe6_notification_system")
	if not fe6:
		return false

	# 显示通知
	var notif_id = fe6.show_notification("测试通知", 1)
	if notif_id.is_empty():
		return false

	# 获取所有通知
	var all_notifs = fe6.get_all_notifications()
	if all_notifs.is_empty():
		return false

	# 消除通知
	fe6.dismiss_notification(notif_id)

	return true

## 测试Fe6勿扰模式
func _test_fe6_dnd_mode() -> bool:
	var fe6 = _app.get_module("fe6_notification_system")
	if not fe6:
		return false

	# 设置勿扰模式
	fe6.set_dnd_mode(true)
	if not fe6.get_dnd_mode():
		return false

	# 关闭勿扰模式
	fe6.set_dnd_mode(false)
	if fe6.get_dnd_mode():
		return false

	return true

## 测试P2碎片日志UI模块
func _test_p2_module() -> bool:
	var p2 = _app.get_module("p2_fragment_log_ui")
	if not p2:
		return false

	return (p2.has_method("show") and p2.has_method("hide")
		and p2.has_method("set_filter") and p2.has_method("set_sort"))

## 测试P2碎片筛选和排序
func _test_p2_filter_fragments() -> bool:
	var p2 = _app.get_module("p2_fragment_log_ui")
	if not p2:
		return false

	# 设置筛选
	p2.set_filter("unread")
	p2.set_sort("newest")

	# 获取当前碎片
	var fragments = p2.get_current_fragments()

	return true  # 只要不崩溃就通过

## 测试P3设置UI模块
func _test_p3_module() -> bool:
	var p3 = _app.get_module("p3_settings_ui")
	if not p3:
		return false

	return (p3.has_method("show") and p3.has_method("hide")
		and p3.has_method("get_setting") and p3.has_method("set_setting")
		and p3.has_method("reset_all"))

## 测试P3设置读写和应用
func _test_p3_settings() -> bool:
	var p3 = _app.get_module("p3_settings_ui")
	if not p3:
		return false

	# 读取默认设置
	var master_volume = p3.get_setting("audio", "master_volume", 0.5)

	# 修改设置
	p3.set_setting("audio", "master_volume", 0.8)

	# 验证修改
	var new_volume = p3.get_setting("audio", "master_volume", 0.5)
	if new_volume != 0.8:
		return false

	# 重置设置
	p3.reset_all()

	# 验证重置
	var reset_volume = p3.get_setting("audio", "master_volume", 0.5)

	return reset_volume == 1.0
