extends GutTest

# C3 碎片系统单元测试

var c3_system: C3FragmentSystem

func before_each():
	c3_system = C3FragmentSystem.new()
	add_child_autofree(c3_system)

func after_each():
	if c3_system and is_instance_valid(c3_system):
		c3_system.queue_free()

func test_module_metadata():
	assert_eq(c3_system.module_id, "c3_fragment_system", "模块ID应为c3_fragment_system")
	assert_eq(c3_system.module_name, "碎片系统", "模块名称应为碎片系统")
	assert_eq(c3_system.category, "gameplay", "类别应为gameplay")
	assert_eq(c3_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(c3_system.dependencies.has("f4_save_system"), "应依赖f4_save_system")
	assert_true(c3_system.dependencies.has("f3_time_system"), "应依赖f3_time_system")
	assert_true(c3_system.optional_dependencies.has("c2_outing_return_cycle"), "应有可选依赖c2_outing_return_cycle")

func test_fragment_type_enum():
	assert_eq(C3FragmentSystem.FragmentType.DIALOGUE, 0, "DIALOGUE类型应为0")
	assert_eq(C3FragmentSystem.FragmentType.SCENE, 1, "SCENE类型应为1")
	assert_eq(C3FragmentSystem.FragmentType.OBJECT, 2, "OBJECT类型应为2")
	assert_eq(C3FragmentSystem.FragmentType.EMOTION, 3, "EMOTION类型应为3")

func test_constants():
	assert_eq(C3FragmentSystem.SAVE_KEY_FRAGMENTS, "c3.fragments", "碎片存档键应为c3.fragments")
	assert_eq(C3FragmentSystem.SAVE_KEY_COUNTER, "c3.fragment_counter", "计数器存档键应为c3.fragment_counter")

func test_signals():
	assert_has_signal(c3_system, "fragments_received", "应有fragments_received信号")

func test_initial_state():
	assert_eq(c3_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_eq(c3_system._fragment_counter, 0, "碎片计数器初始应为0")
	assert_true(c3_system._fragments is Dictionary, "碎片存储应为字典")
	assert_eq(c3_system._fragments.size(), 0, "初始时碎片存储应为空")
