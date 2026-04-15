extends Node

## Sprint 5 集成测试
## 测试P2 Alpha层的6个系统：C6, F5, F6, C7, C8, Fe4

var _test_results: Array[Dictionary] = []
var _app: Node = null

func _ready() -> void:
	print("\n========================================")
	print("Sprint 5 Integration Test")
	print("========================================\n")

	# 获取App实例
	_app = get_node("/root/App")
	if not _app:
		print("[ERROR] Cannot find App node")
		return

	# 延迟运行测试，等待模块加载
	call_deferred("_run_tests_deferred")

func _run_tests_deferred() -> void:
	# 运行测试
	_run_all_tests()

	# 输出结果
	_print_results()

func _run_all_tests() -> void:
	print("Running Sprint 5 Integration Tests...\n")

	# F5 Aria接口层测试
	_test_f5_module_loaded()
	_test_f5_connection_state()
	_test_f5_degraded_mode()

	# C6 关系值系统测试
	_test_c6_module_loaded()
	_test_c6_relationship_calculation()

	# F6 角色上下文管理器测试
	_test_f6_module_loaded()
	_test_f6_context_building()

	# C7 对话记忆库测试
	_test_c7_module_loaded()
	_test_c7_memory_storage()

	# C8 社交圈系统测试
	_test_c8_module_loaded()
	_test_c8_character_rotation()

	# Fe4 共鸣成长系统测试
	_test_fe4_module_loaded()
	_test_fe4_resonance_growth()

#region F5 Aria接口层测试

func _test_f5_module_loaded() -> void:
	var test_name := "F5模块加载测试"
	var f5 = _app.get_module("f5_aria_interface")

	if f5:
		_add_result(test_name, true, "F5模块已加载")
	else:
		_add_result(test_name, false, "F5模块未找到")

func _test_f5_connection_state() -> void:
	var test_name := "F5连接状态测试"
	var f5 = _app.get_module("f5_aria_interface")

	if not f5:
		_add_result(test_name, false, "F5模块未找到")
		return

	if f5.has_method("get_connection_state"):
		var state = f5.get_connection_state()
		# 初始状态应该是DISCONNECTED（因为没有配置API Key）
		if state == 0:  # ConnectionState.DISCONNECTED
			_add_result(test_name, true, "初始连接状态正确: DISCONNECTED")
		else:
			_add_result(test_name, false, "初始连接状态错误: " + str(state))
	else:
		_add_result(test_name, false, "F5模块缺少get_connection_state方法")

func _test_f5_degraded_mode() -> void:
	var test_name := "F5降级模式测试"
	var f5 = _app.get_module("f5_aria_interface")

	if not f5:
		_add_result(test_name, false, "F5模块未找到")
		return

	if f5.has_method("send_llm_request") and f5.has_signal("llm_stream_chunk"):
		# 在DISCONNECTED状态下，F5应该有降级模式配置
		# 这里只测试接口存在性，不测试异步响应
		_add_result(test_name, true, "F5模块具备降级模式接口")
	else:
		_add_result(test_name, false, "F5模块缺少必要的降级模式接口")

#endregion

#region C6 关系值系统测试

func _test_c6_module_loaded() -> void:
	var test_name := "C6模块加载测试"
	var c6 = _app.get_module("c6_relationship_value_system")

	if c6:
		_add_result(test_name, true, "C6模块已加载")
	else:
		_add_result(test_name, false, "C6模块未找到")

func _test_c6_relationship_calculation() -> void:
	var test_name := "C6关系值计算测试"
	var c6 = _app.get_module("c6_relationship_value_system")

	if not c6:
		_add_result(test_name, false, "C6模块未找到")
		return

	if c6.has_method("modify_relationship") and c6.has_method("get_relationship_value") and c6.has_method("get_relationship_tier"):
		# 测试关系值修改
		c6.modify_relationship("aria", 25.0)
		var value = c6.get_relationship_value("aria")
		var tier = c6.get_relationship_tier("aria")

		if abs(value - 25.0) < 0.1 and tier == 2:
			_add_result(test_name, true, "关系值计算正确: value=%.1f, tier=%d" % [value, tier])
		else:
			_add_result(test_name, false, "关系值计算错误: value=%.1f, tier=%d" % [value, tier])
	else:
		_add_result(test_name, false, "C6模块缺少必要方法")

#endregion

#region F6 角色上下文管理器测试

func _test_f6_module_loaded() -> void:
	var test_name := "F6模块加载测试"
	var f6 = _app.get_module("f6_character_context_manager")

	if f6:
		_add_result(test_name, true, "F6模块已加载")
	else:
		_add_result(test_name, false, "F6模块未找到")

func _test_f6_context_building() -> void:
	var test_name := "F6上下文构建测试"
	var f6 = _app.get_module("f6_character_context_manager")

	if not f6:
		_add_result(test_name, false, "F6模块未找到")
		return

	if f6.has_method("build_context"):
		var context = f6.build_context("测试消息", "aria")

		if context.has("system_prompt") and context.has("messages") and context.has("current_input"):
			var has_system = false
			for msg in context.messages:
				if msg.role == "system":
					has_system = true
					break

			if has_system and not context.system_prompt.is_empty():
				_add_result(test_name, true, "上下文构建成功，包含system prompt和messages")
			else:
				_add_result(test_name, false, "上下文结构不完整")
		else:
			_add_result(test_name, false, "上下文缺少必要字段")
	else:
		_add_result(test_name, false, "F6模块缺少build_context方法")

#endregion

#region C7 对话记忆库测试

func _test_c7_module_loaded() -> void:
	var test_name := "C7模块加载测试"
	var c7 = _app.get_module("c7_dialogue_memory_bank")

	if c7:
		_add_result(test_name, true, "C7模块已加载")
	else:
		_add_result(test_name, false, "C7模块未找到")

func _test_c7_memory_storage() -> void:
	var test_name := "C7记忆存储测试"
	var c7 = _app.get_module("c7_dialogue_memory_bank")

	if not c7:
		_add_result(test_name, false, "C7模块未找到")
		return

	if c7.has_method("record_exchange") and c7.has_method("get_recent_exchanges"):
		# 记录测试对话
		var exchange_id = c7.record_exchange("测试输入", "测试回应", "aria")
		var recent = c7.get_recent_exchanges("aria", 1)

		if not exchange_id.is_empty() and recent.size() > 0:
			_add_result(test_name, true, "对话记录存储成功，ID: " + exchange_id)
		else:
			_add_result(test_name, false, "对话记录存储失败")
	else:
		_add_result(test_name, false, "C7模块缺少必要方法")

#endregion

#region C8 社交圈系统测试

func _test_c8_module_loaded() -> void:
	var test_name := "C8模块加载测试"
	var c8 = _app.get_module("c8_social_circle_system")

	if c8:
		_add_result(test_name, true, "C8模块已加载")
	else:
		_add_result(test_name, false, "C8模块未找到")

func _test_c8_character_rotation() -> void:
	var test_name := "C8角色轮换测试"
	var c8 = _app.get_module("c8_social_circle_system")

	if not c8:
		_add_result(test_name, false, "C8模块未找到")
		return

	if c8.has_method("get_active_character") and c8.has_method("get_all_characters"):
		_add_result(test_name, true, "C8模块具备角色轮换接口")
	else:
		_add_result(test_name, false, "C8模块缺少必要方法")

#endregion

#region Fe4 共鸣成长系统测试

func _test_fe4_module_loaded() -> void:
	var test_name := "Fe4模块加载测试"
	var fe4 = _app.get_module("fe4_resonance_growth_system")

	if fe4:
		_add_result(test_name, true, "Fe4模块已加载")
	else:
		_add_result(test_name, false, "Fe4模块未找到")

func _test_fe4_resonance_growth() -> void:
	var test_name := "Fe4共鸣成长测试"
	var fe4 = _app.get_module("fe4_resonance_growth_system")

	if not fe4:
		_add_result(test_name, false, "Fe4模块未找到")
		return

	if fe4.has_method("get_resonance_value") and fe4.has_method("modify_resonance"):
		var initial_value = fe4.get_resonance_value("aria")
		fe4.modify_resonance("aria", 10.0)
		var new_value = fe4.get_resonance_value("aria")

		if abs(new_value - (initial_value + 10.0)) < 0.1:
			_add_result(test_name, true, "共鸣度计算正确: %.1f -> %.1f" % [initial_value, new_value])
		else:
			_add_result(test_name, false, "共鸣度计算错误: %.1f -> %.1f" % [initial_value, new_value])
	else:
		_add_result(test_name, false, "Fe4模块缺少必要方法")

#endregion

#region 测试结果管理

func _add_result(test_name: String, passed: bool, message: String = "") -> void:
	_test_results.append({
		"name": test_name,
		"passed": passed,
		"message": message
	})

	var status := "[PASS]" if passed else "[FAIL]"
	print(status + " | " + test_name)
	if not message.is_empty():
		print("       " + message)

func _print_results() -> void:
	print("\n========================================")
	print("Test Results Summary")
	print("========================================")

	var passed_count := 0
	var failed_count := 0

	for result in _test_results:
		if result.passed:
			passed_count += 1
		else:
			failed_count += 1

	var total := _test_results.size()
	print("Total: %d | Passed: %d | Failed: %d" % [total, passed_count, failed_count])

	if failed_count > 0:
		print("\nFailed Tests:")
		for result in _test_results:
			if not result.passed:
				print("  - " + result.name)
				if not result.message.is_empty():
					print("    " + result.message)

	print("\n========================================\n")

#endregion
