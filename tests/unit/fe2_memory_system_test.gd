extends GutTest

# FE2 记忆系统单元测试

var fe2_system: Fe2MemorySystem

func before_each():
	fe2_system = Fe2MemorySystem.new()
	add_child_autofree(fe2_system)

func after_each():
	if fe2_system and is_instance_valid(fe2_system):
		fe2_system.queue_free()

func test_module_metadata():
	assert_eq(fe2_system.module_id, "fe2_memory_system", "模块ID应为fe2_memory_system")
	assert_eq(fe2_system.module_name, "记忆系统", "模块名称应为记忆系统")
	assert_eq(fe2_system.category, "gameplay", "类别应为gameplay")
	assert_eq(fe2_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(fe2_system.dependencies.has("f4_save_system"), "应依赖f4_save_system")
	assert_true(fe2_system.optional_dependencies.has("fe3_affinity_system"), "应有可选依赖fe3_affinity_system")

func test_memory_types():
	assert_eq(Fe2MemorySystem.MemoryType.DAILY_INTERACTION, 0, "日常互动类型应为0")
	assert_eq(Fe2MemorySystem.MemoryType.SPECIAL_EVENT, 1, "特殊事件类型应为1")
	assert_eq(Fe2MemorySystem.MemoryType.MEMORY_FRAGMENT, 2, "回忆碎片类型应为2")
	assert_eq(Fe2MemorySystem.MemoryType.USER_PREFERENCE, 3, "用户偏好类型应为3")
	assert_eq(Fe2MemorySystem.MemoryType.SHARED_EXPERIENCE, 4, "共同经历类型应为4")

func test_constants():
	assert_eq(Fe2MemorySystem.MAX_MEMORIES, 1000, "最大记忆数量应为1000")

func test_signals():
	assert_has_signal(fe2_system, "memory_added", "应有memory_added信号")
	assert_has_signal(fe2_system, "memory_unlocked", "应有memory_unlocked信号")
	assert_has_signal(fe2_system, "memory_deleted", "应有memory_deleted信号")

func test_initial_state():
	assert_eq(fe2_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_true(fe2_system._memories is Array, "记忆列表应为数组")
	assert_eq(fe2_system._memories.size(), 0, "初始时记忆列表应为空")
	assert_eq(fe2_system._total_memories, 0, "初始总记忆数应为0")
	assert_eq(fe2_system._unlocked_fragments, 0, "初始解锁碎片数应为0")
