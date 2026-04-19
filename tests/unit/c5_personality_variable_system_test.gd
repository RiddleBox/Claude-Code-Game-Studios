extends GutTest

# C5 性格变量系统单元测试

var c5_system: C5PersonalityVariableSystem

func before_each():
	c5_system = C5PersonalityVariableSystem.new()
	add_child_autofree(c5_system)

func after_each():
	if c5_system and is_instance_valid(c5_system):
		c5_system.queue_free()

func test_module_metadata():
	assert_eq(c5_system.module_id, "c5_personality_variable_system", "模块ID应为c5_personality_variable_system")
	assert_eq(c5_system.module_name, "性格变量系统", "模块名称应为性格变量系统")
	assert_eq(c5_system.category, "gameplay", "类别应为gameplay")
	assert_eq(c5_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(c5_system.dependencies.has("f4_save_system"), "应依赖f4_save_system")
	assert_eq(c5_system.dependencies.size(), 1, "应只有1个必需依赖")

func test_constants():
	assert_eq(C5PersonalityVariableSystem.MAX_SHIFT_PER_CALL, 0.05, "单次shift最大delta应为0.05")
	assert_eq(C5PersonalityVariableSystem.SAVE_KEY_PERSONALITY, "c5.personality", "性格存档键应为c5.personality")
	assert_eq(C5PersonalityVariableSystem.AXES_CONFIG_PATH, "res://data/config/personality_axes.json", "轴配置路径应正确")

func test_signals():
	assert_has_signal(c5_system, "personality_shifted", "应有personality_shifted信号")

func test_initial_state():
	assert_eq(c5_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_true(c5_system._personality is Dictionary, "性格状态应为字典")
	assert_true(c5_system._axes_meta is Array, "轴元数据应为数组")

func test_default_axes_meta():
	assert_eq(c5_system._default_axes_meta.size(), 4, "默认应有4个性格轴")

	var axis_ids = []
	for axis in c5_system._default_axes_meta:
		axis_ids.append(axis["id"])

	assert_true(axis_ids.has("curiosity"), "应有curiosity轴")
	assert_true(axis_ids.has("warmth"), "应有warmth轴")
	assert_true(axis_ids.has("boldness"), "应有boldness轴")
	assert_true(axis_ids.has("melancholy"), "应有melancholy轴")

func test_default_axes_structure():
	for axis in c5_system._default_axes_meta:
		assert_true(axis.has("id"), "轴应有id字段")
		assert_true(axis.has("low_label"), "轴应有low_label字段")
		assert_true(axis.has("high_label"), "轴应有high_label字段")
		assert_true(axis.has("default"), "轴应有default字段")
		assert_true(axis.has("display_name"), "轴应有display_name字段")
		assert_eq(axis["default"], 0.5, "默认值应为0.5")
