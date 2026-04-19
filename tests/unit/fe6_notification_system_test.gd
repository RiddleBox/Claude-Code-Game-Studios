extends GutTest

# FE6 通知系统单元测试

var fe6_system: Fe6NotificationSystem

func before_each():
	fe6_system = Fe6NotificationSystem.new()
	add_child_autofree(fe6_system)

func after_each():
	if fe6_system and is_instance_valid(fe6_system):
		fe6_system.queue_free()

func test_module_metadata():
	assert_eq(fe6_system.module_id, "fe6_notification_system", "模块ID应为fe6_notification_system")
	assert_eq(fe6_system.module_name, "通知提醒系统", "模块名称应为通知提醒系统")
	assert_eq(fe6_system.category, "gameplay", "类别应为gameplay")
	assert_eq(fe6_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_true(fe6_system.dependencies.has("f1_window_system"), "应依赖f1_window_system")
	assert_true(fe6_system.optional_dependencies.has("c2_outing_return_cycle"), "应有可选依赖c2_outing_return_cycle")
	assert_true(fe6_system.optional_dependencies.has("c4_event_line_system"), "应有可选依赖c4_event_line_system")
	assert_true(fe6_system.optional_dependencies.has("fe2_memory_system"), "应有可选依赖fe2_memory_system")

func test_constants():
	assert_eq(Fe6NotificationSystem.SUBTLE_THRESHOLD, 0.3, "微妙阈值应为0.3")
	assert_eq(Fe6NotificationSystem.EXPRESSIVE_THRESHOLD, 0.7, "表达阈值应为0.7")
	assert_eq(Fe6NotificationSystem.SAVE_KEY_DND_MODE, "fe6.dnd_mode", "勿扰模式存档键应为fe6.dnd_mode")

func test_notification_priority_enum():
	assert_eq(Fe6NotificationSystem.NotificationPriority.LOW, 0, "低优先级应为0")
	assert_eq(Fe6NotificationSystem.NotificationPriority.NORMAL, 1, "普通优先级应为1")
	assert_eq(Fe6NotificationSystem.NotificationPriority.HIGH, 2, "高优先级应为2")
	assert_eq(Fe6NotificationSystem.NotificationPriority.URGENT, 3, "紧急优先级应为3")

func test_tray_state_enum():
	assert_eq(Fe6NotificationSystem.TrayState.NORMAL, 0, "正常状态应为0")
	assert_eq(Fe6NotificationSystem.TrayState.NOTICE, 1, "有通知状态应为1")
	assert_eq(Fe6NotificationSystem.TrayState.ATTENTION, 2, "需要注意状态应为2")

func test_signals():
	assert_has_signal(fe6_system, "notification_shown", "应有notification_shown信号")
	assert_has_signal(fe6_system, "notification_dismissed", "应有notification_dismissed信号")
	assert_has_signal(fe6_system, "note_unread_on_return", "应有note_unread_on_return信号")

func test_initial_state():
	assert_eq(fe6_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_true(fe6_system._notification_queue is Array, "通知队列应为数组")
	assert_eq(fe6_system._notification_queue.size(), 0, "初始时通知队列应为空")
