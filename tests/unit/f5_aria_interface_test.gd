extends GutTest

# F5 Aria接口单元测试

var f5_system: F5AriaInterface

func before_each():
	f5_system = F5AriaInterface.new()
	add_child_autofree(f5_system)

func after_each():
	if f5_system and is_instance_valid(f5_system):
		f5_system.queue_free()

func test_module_metadata():
	assert_eq(F5AriaInterface.MODULE_ID, "F5", "模块ID应为F5")
	assert_eq(F5AriaInterface.MODULE_NAME, "Aria Interface Layer", "模块名称应为Aria Interface Layer")
	assert_eq(F5AriaInterface.MODULE_CATEGORY, "Foundation", "模块类别应为Foundation")

func test_connection_state_enum():
	assert_eq(F5AriaInterface.ConnectionState.DISCONNECTED, 0, "DISCONNECTED枚举值应为0")
	assert_eq(F5AriaInterface.ConnectionState.CONNECTING, 1, "CONNECTING枚举值应为1")
	assert_eq(F5AriaInterface.ConnectionState.CONNECTED, 2, "CONNECTED枚举值应为2")
	assert_eq(F5AriaInterface.ConnectionState.ERROR, 3, "ERROR枚举值应为3")
	assert_eq(F5AriaInterface.ConnectionState.DEGRADED, 4, "DEGRADED枚举值应为4")

func test_constants():
	assert_eq(F5AriaInterface.LLM_TIMEOUT, 15.0, "LLM超时应为15秒")
	assert_eq(F5AriaInterface.TTS_TIMEOUT, 10.0, "TTS超时应为10秒")
	assert_eq(F5AriaInterface.RECONNECT_INTERVAL, 300.0, "重连间隔应为300秒")
	assert_eq(F5AriaInterface.FALLBACK_SCRIPT_COOLDOWN, 3, "降级脚本冷却应为3")

func test_signals():
	assert_has_signal(f5_system, "connection_state_changed", "应有connection_state_changed信号")
	assert_has_signal(f5_system, "aria_interaction_completed", "应有aria_interaction_completed信号")
	assert_has_signal(f5_system, "tts_audio_ready", "应有tts_audio_ready信号")
	assert_has_signal(f5_system, "llm_stream_chunk", "应有llm_stream_chunk信号")

func test_initial_state():
	# 注意：F5需要父节点有get_module方法，这里测试初始状态
	assert_false(f5_system._is_initialized, "初始时不应已初始化")
	assert_false(f5_system._is_running, "初始时不应运行")

func test_module_properties():
	assert_eq(f5_system.module_id, "", "module_id初始应为空字符串")
	assert_true(f5_system.dependencies is Array, "dependencies应为数组")
	assert_true(f5_system.optional_dependencies is Array, "optional_dependencies应为数组")
