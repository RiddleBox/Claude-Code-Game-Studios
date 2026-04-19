extends GutTest

# FE1 对话系统单元测试

var fe1_system: DialogueSystem

func before_each():
	fe1_system = DialogueSystem.new()
	add_child_autofree(fe1_system)

func after_each():
	if fe1_system and is_instance_valid(fe1_system):
		fe1_system.queue_free()

func test_module_metadata():
	assert_eq(fe1_system.module_id, "fe1_dialogue_system", "模块ID应为fe1_dialogue_system")
	assert_eq(fe1_system.module_name, "对话系统", "模块名称应为对话系统")
	assert_eq(fe1_system.category, "gameplay", "类别应为gameplay")
	assert_eq(fe1_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(fe1_system.dependencies.has("ui_framework"), "应依赖ui_framework")
	assert_true(fe1_system.dependencies.has("f1_window_system"), "应依赖f1_window_system")
	assert_true(fe1_system.optional_dependencies.has("c2_outing_return_cycle"), "应有可选依赖c2_outing_return_cycle")
	assert_true(fe1_system.optional_dependencies.has("c1_character_animation_system"), "应有可选依赖c1_character_animation_system")

func test_constants():
	assert_eq(DialogueSystem.DEFAULT_BUBBLE_DURATION, 4.0, "默认气泡持续时间应为4秒")
	assert_eq(DialogueSystem.MIN_BUBBLE_INTERVAL, 2.0, "最小气泡间隔应为2秒")
	assert_eq(DialogueSystem.MAX_QUEUE_SIZE, 3, "最大队列大小应为3")

func test_signals():
	assert_has_signal(fe1_system, "dialogue_triggered", "应有dialogue_triggered信号")
	assert_has_signal(fe1_system, "dialogue_clicked", "应有dialogue_clicked信号")
	assert_has_signal(fe1_system, "dialogue_finished", "应有dialogue_finished信号")

func test_initial_state():
	assert_eq(fe1_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_true(fe1_system._dialogue_queue is Array, "对话队列应为数组")
	assert_eq(fe1_system._dialogue_queue.size(), 0, "初始时对话队列应为空")
	assert_false(fe1_system._is_showing_bubble, "初始时不应显示气泡")
	assert_eq(fe1_system._last_bubble_time, 0.0, "上次气泡时间初始应为0")
	assert_true(fe1_system._idle_dialogues is Array, "空闲对话应为数组")
	assert_true(fe1_system._event_dialogues is Dictionary, "事件对话应为字典")
