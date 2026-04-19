extends GutTest

# C1 角色动画系统单元测试

var c1_system: C1CharacterAnimationSystem

func before_each():
	c1_system = C1CharacterAnimationSystem.new()
	add_child_autofree(c1_system)

func after_each():
	if c1_system and is_instance_valid(c1_system):
		c1_system.queue_free()

func test_module_metadata():
	assert_eq(c1_system.module_id, "c1_character_animation_system", "模块ID应为c1_character_animation_system")
	assert_eq(c1_system.module_name, "角色动画系统", "模块名称应为角色动画系统")
	assert_eq(c1_system.module_version, "1.0.0", "版本应为1.0.0")
	assert_eq(c1_system.category, "gameplay", "类别应为gameplay")

func test_dependencies():
	assert_true(c1_system.dependencies.has("f2_state_machine"), "应依赖f2_state_machine")
	assert_eq(c1_system.dependencies.size(), 1, "应只有1个必需依赖")

func test_composition_mode_enum():
	assert_eq(C1CharacterAnimationSystem.CompositionMode.INSIDE, 0, "INSIDE模式应为0")
	assert_eq(C1CharacterAnimationSystem.CompositionMode.LEANING_OUT, 1, "LEANING_OUT模式应为1")

func test_animation_state_enum():
	assert_eq(C1CharacterAnimationSystem.AnimationState.IDLE, 0, "IDLE状态应为0")
	assert_eq(C1CharacterAnimationSystem.AnimationState.THINKING, 1, "THINKING状态应为1")
	assert_eq(C1CharacterAnimationSystem.AnimationState.WORKING, 2, "WORKING状态应为2")
	assert_eq(C1CharacterAnimationSystem.AnimationState.PLAYING, 3, "PLAYING状态应为3")
	assert_eq(C1CharacterAnimationSystem.AnimationState.SLEEPING, 4, "SLEEPING状态应为4")

func test_constants():
	assert_eq(C1CharacterAnimationSystem.DEFAULT_TRANSITION_DURATION, 0.3, "默认过渡时间应为0.3秒")
	assert_eq(C1CharacterAnimationSystem.DEFAULT_BLEND_TIME, 0.2, "默认混合时间应为0.2秒")

func test_signals():
	assert_has_signal(c1_system, "animation_changed", "应有animation_changed信号")
	assert_has_signal(c1_system, "composition_mode_changed", "应有composition_mode_changed信号")
	assert_has_signal(c1_system, "animation_completed", "应有animation_completed信号")

func test_initial_state():
	assert_eq(c1_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_false(c1_system._is_animating, "初始时不应在播放动画")
