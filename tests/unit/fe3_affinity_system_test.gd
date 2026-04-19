extends GutTest

# FE3 好感度系统单元测试

var fe3_system: Fe3AffinitySystem

func before_each():
	fe3_system = Fe3AffinitySystem.new()
	add_child_autofree(fe3_system)

func after_each():
	if fe3_system and is_instance_valid(fe3_system):
		fe3_system.queue_free()

func test_module_metadata():
	assert_eq(fe3_system.module_id, "fe3_affinity_system", "模块ID应为fe3_affinity_system")
	assert_eq(fe3_system.module_name, "好感度系统", "模块名称应为好感度系统")
	assert_eq(fe3_system.category, "gameplay", "类别应为gameplay")
	assert_eq(fe3_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(fe3_system.dependencies.has("f4_save_system"), "应依赖f4_save_system")
	assert_true(fe3_system.optional_dependencies.has("fe2_memory_system"), "应有可选依赖fe2_memory_system")
	assert_true(fe3_system.optional_dependencies.has("fe1_dialogue_system"), "应有可选依赖fe1_dialogue_system")

func test_affinity_levels():
	assert_eq(Fe3AffinitySystem.AffinityLevel.STRANGER, 0, "陌生等级应为0")
	assert_eq(Fe3AffinitySystem.AffinityLevel.FAMILIAR, 1, "熟悉等级应为1")
	assert_eq(Fe3AffinitySystem.AffinityLevel.FOND, 2, "好感等级应为2")
	assert_eq(Fe3AffinitySystem.AffinityLevel.LIKE, 3, "喜欢等级应为3")
	assert_eq(Fe3AffinitySystem.AffinityLevel.INTIMATE, 4, "亲密等级应为4")

func test_level_ranges():
	assert_eq(Fe3AffinitySystem.LEVEL_RANGES.size(), 5, "应有5个等级范围")
	assert_eq(Fe3AffinitySystem.LEVEL_RANGES[0], [0, 99], "陌生范围应为0-99")
	assert_eq(Fe3AffinitySystem.LEVEL_RANGES[1], [100, 299], "熟悉范围应为100-299")
	assert_eq(Fe3AffinitySystem.LEVEL_RANGES[2], [300, 599], "好感范围应为300-599")
	assert_eq(Fe3AffinitySystem.LEVEL_RANGES[3], [600, 999], "喜欢范围应为600-999")
	assert_eq(Fe3AffinitySystem.LEVEL_RANGES[4], [1000, 999999], "亲密范围应为1000-999999")

func test_level_names():
	assert_eq(Fe3AffinitySystem.LEVEL_NAMES.size(), 5, "应有5个等级名称")
	assert_eq(Fe3AffinitySystem.LEVEL_NAMES[0], "陌生", "等级0名称应为陌生")
	assert_eq(Fe3AffinitySystem.LEVEL_NAMES[1], "熟悉", "等级1名称应为熟悉")
	assert_eq(Fe3AffinitySystem.LEVEL_NAMES[2], "好感", "等级2名称应为好感")
	assert_eq(Fe3AffinitySystem.LEVEL_NAMES[3], "喜欢", "等级3名称应为喜欢")
	assert_eq(Fe3AffinitySystem.LEVEL_NAMES[4], "亲密", "等级4名称应为亲密")

func test_constants():
	assert_eq(Fe3AffinitySystem.DEFAULT_INITIAL_SCORE, 50, "默认初始分数应为50")
	assert_eq(Fe3AffinitySystem.DAILY_DECAY_AMOUNT, 5, "每日衰减量应为5")
	assert_eq(Fe3AffinitySystem.DECAY_TRIGGER_DAYS, 7, "衰减触发天数应为7")

func test_action_scores():
	assert_eq(Fe3AffinitySystem.ACTION_SCORES["mouse_click"], 1, "点击分数应为1")
	assert_eq(Fe3AffinitySystem.ACTION_SCORES["daily_checkin"], 5, "签到分数应为5")
	assert_eq(Fe3AffinitySystem.ACTION_SCORES["feed_food"], 10, "投喂分数应为10")
	assert_eq(Fe3AffinitySystem.ACTION_SCORES["special_event"], 50, "特殊事件分数应为50")
	assert_eq(Fe3AffinitySystem.ACTION_SCORES["negative_interaction"], -10, "负面互动分数应为-10")

func test_signals():
	assert_has_signal(fe3_system, "affinity_changed", "应有affinity_changed信号")
	assert_has_signal(fe3_system, "level_up", "应有level_up信号")
	assert_has_signal(fe3_system, "level_down", "应有level_down信号")

func test_initial_state():
	assert_eq(fe3_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_eq(fe3_system._current_score, Fe3AffinitySystem.DEFAULT_INITIAL_SCORE, "初始分数应为默认值")
	assert_eq(fe3_system._current_level, Fe3AffinitySystem.AffinityLevel.STRANGER, "初始等级应为陌生")
	assert_eq(fe3_system._last_interaction_time, 0, "上次互动时间初始应为0")
	assert_eq(fe3_system._total_interaction_count, 0, "总互动次数初始应为0")
