extends GutTest

# F6 角色上下文管理器单元测试

var f6_manager: Node

func before_each():
	var F6Class = load("res://src/foundation/f6_character_context_manager/f6_character_context_manager.gd")
	f6_manager = F6Class.new()
	add_child_autofree(f6_manager)

func after_each():
	if f6_manager and is_instance_valid(f6_manager):
		f6_manager.queue_free()

func test_constants():
	var F6Class = load("res://src/foundation/f6_character_context_manager/f6_character_context_manager.gd")
	assert_eq(F6Class.RECENT_EXCHANGES, 10, "近期对话保留轮数应为10")
	assert_eq(F6Class.MAX_CONTEXT_TOKENS, 4000, "最大上下文Token数应为4000")
	assert_eq(F6Class.AVG_TOKENS_PER_CHAR, 0.4, "平均每字符Token数应为0.4")

func test_module_info():
	var info = f6_manager.get_module_info()
	assert_eq(info["id"], "f6_character_context_manager", "模块ID应为f6_character_context_manager")
	assert_eq(info["name"], "角色上下文管理器", "模块名称应为角色上下文管理器")
	assert_eq(info["version"], "1.0.0", "版本应为1.0.0")
	assert_true(info["dependencies"] is Array, "dependencies应为数组")
	assert_true(info["optional_dependencies"] is Array, "optional_dependencies应为数组")

func test_module_properties():
	assert_eq(f6_manager.module_id, "", "module_id初始应为空字符串")
	assert_true(f6_manager.dependencies is Array, "dependencies应为数组")
	assert_true(f6_manager.optional_dependencies is Array, "optional_dependencies应为数组")

func test_build_context_structure():
	# 测试build_context返回的数据结构
	var context = f6_manager.build_context("测试输入", "aria")
	assert_true(context.has("system_prompt"), "上下文应包含system_prompt")
	assert_true(context.has("messages"), "上下文应包含messages")
	assert_true(context.has("current_input"), "上下文应包含current_input")
	assert_true(context.has("metadata"), "上下文应包含metadata")
	assert_eq(context["current_input"], "测试输入", "current_input应为传入的用户输入")

func test_build_context_metadata():
	var context = f6_manager.build_context("测试输入")
	assert_true(context["metadata"].has("personality_tags"), "metadata应包含personality_tags")
	assert_true(context["metadata"].has("context_tokens"), "metadata应包含context_tokens")
	assert_true(context["metadata"]["personality_tags"] is Array, "personality_tags应为数组")

func test_shutdown():
	# 测试shutdown不会崩溃
	f6_manager.shutdown()
	assert_true(true, "shutdown应正常执行")
