extends GutTest

# FE5 音频系统单元测试

var fe5_system: Fe5AudioSystem

func before_each():
	fe5_system = Fe5AudioSystem.new()
	add_child_autofree(fe5_system)

func after_each():
	if fe5_system and is_instance_valid(fe5_system):
		fe5_system.queue_free()

func test_module_metadata():
	assert_eq(fe5_system.module_id, "fe5_audio_system", "模块ID应为fe5_audio_system")
	assert_eq(fe5_system.module_name, "音频系统", "模块名称应为音频系统")
	assert_eq(fe5_system.category, "gameplay", "类别应为gameplay")
	assert_eq(fe5_system.priority, "medium", "优先级应为medium")

func test_dependencies():
	assert_eq(fe5_system.dependencies.size(), 0, "应无硬依赖")
	assert_true(fe5_system.optional_dependencies.has("f4_save_system"), "应有可选依赖f4_save_system")

func test_audio_types():
	assert_eq(Fe5AudioSystem.AudioType.CLICK, 0, "点击音效类型应为0")
	assert_eq(Fe5AudioSystem.AudioType.HOVER, 1, "悬停音效类型应为1")
	assert_eq(Fe5AudioSystem.AudioType.DIALOGUE_NORMAL, 2, "普通对话音效类型应为2")
	assert_eq(Fe5AudioSystem.AudioType.DIALOGUE_HAPPY, 3, "开心对话音效类型应为3")
	assert_eq(Fe5AudioSystem.AudioType.DIALOGUE_SAD, 4, "伤心对话音效类型应为4")
	assert_eq(Fe5AudioSystem.AudioType.DIALOGUE_SURPRISE, 5, "惊讶对话音效类型应为5")
	assert_eq(Fe5AudioSystem.AudioType.LEVEL_UP, 6, "升级音效类型应为6")
	assert_eq(Fe5AudioSystem.AudioType.ACHIEVEMENT, 7, "成就音效类型应为7")
	assert_eq(Fe5AudioSystem.AudioType.MEMORY_UNLOCK, 8, "回忆解锁音效类型应为8")
	assert_eq(Fe5AudioSystem.AudioType.OUTING_START, 9, "外出开始音效类型应为9")
	assert_eq(Fe5AudioSystem.AudioType.OUTING_RETURN, 10, "外出归来音效类型应为10")

func test_constants():
	assert_eq(Fe5AudioSystem.DEFAULT_SFX_VOLUME, 0.8, "默认音效音量应为0.8")
	assert_eq(Fe5AudioSystem.DEFAULT_VOICE_VOLUME, 1.0, "默认语音音量应为1.0")
	assert_eq(Fe5AudioSystem.MAX_SFX_SOURCES, 8, "最大音效源数量应为8")
	assert_eq(Fe5AudioSystem.SFX_PATH_PREFIX, "res://assets/audio/sfx/", "音效路径前缀应正确")
	assert_eq(Fe5AudioSystem.VOICE_PATH_PREFIX, "res://assets/audio/voice/", "语音路径前缀应正确")

func test_signals():
	assert_has_signal(fe5_system, "audio_played", "应有audio_played信号")
	assert_has_signal(fe5_system, "volume_changed", "应有volume_changed信号")
	assert_has_signal(fe5_system, "mute_toggled", "应有mute_toggled信号")

func test_initial_state():
	assert_eq(fe5_system.status, IModule.ModuleStatus.UNINITIALIZED, "初始状态应为UNINITIALIZED")
	assert_eq(fe5_system._sfx_volume, Fe5AudioSystem.DEFAULT_SFX_VOLUME, "初始音效音量应为默认值")
	assert_eq(fe5_system._voice_volume, Fe5AudioSystem.DEFAULT_VOICE_VOLUME, "初始语音音量应为默认值")
	assert_false(fe5_system._is_muted, "初始时不应静音")
	assert_true(fe5_system._sfx_players is Array, "音效播放器池应为数组")
	assert_eq(fe5_system._next_player_index, 0, "下一个播放器索引初始应为0")
	assert_true(fe5_system._audio_cache is Dictionary, "音频缓存应为字典")
