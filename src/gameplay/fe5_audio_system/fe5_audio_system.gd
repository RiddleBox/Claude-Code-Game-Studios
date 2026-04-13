# gameplay/fe5_audio_system/fe5_audio_system.gd
# Fe5音频系统 - 负责角色互动音效、情绪语音播放
# 实现IModule接口，支持模块化架构

class_name Fe5AudioSystem
extends Node

## IModule接口实现
var module_id: String = "fe5_audio_system"
var module_name: String = "音频系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = []  # 无硬依赖
var optional_dependencies: Array[String] = ["f4_save_system"]
var config_path: String = "res://data/config/fe5_audio_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 音效类型枚举
enum AudioType {
	CLICK = 0,           # 点击音效
	HOVER = 1,           # 鼠标悬停音效
	DIALOGUE_NORMAL = 2, # 普通对话音效
	DIALOGUE_HAPPY = 3,  # 开心对话音效
	DIALOGUE_SAD = 4,    # 伤心对话音效
	DIALOGUE_SURPRISE = 5, # 惊讶对话音效
	LEVEL_UP = 6,        # 好感度升级音效
	ACHIEVEMENT = 7,     # 成就解锁音效
	MEMORY_UNLOCK = 8,    # 回忆碎片解锁音效
	OUTING_START = 9,     # 外出开始音效
	OUTING_RETURN = 10   # 外出归来音效
}

## 默认音效音量
const DEFAULT_SFX_VOLUME: float = 0.8
## 默认语音音量
const DEFAULT_VOICE_VOLUME: float = 1.0
## 音效池大小（最大同时播放音效数量）
const MAX_SFX_SOURCES: int = 8
## 音效资源路径前缀
const SFX_PATH_PREFIX: String = "res://assets/audio/sfx/"
## 语音资源路径前缀
const VOICE_PATH_PREFIX: String = "res://assets/audio/voice/"

## ==================== 信号 ====================

signal audio_played(audio_type: int, path: String)  # 音频播放时触发
signal volume_changed(sfx_volume: float, voice_volume: float)  # 音量变化时触发
signal mute_toggled(is_muted: bool)  # 静音切换时触发

## ==================== 私有变量 ====================

## 音效音量
var _sfx_volume: float = DEFAULT_SFX_VOLUME
## 语音音量
var _voice_volume: float = DEFAULT_VOICE_VOLUME
## 是否静音
var _is_muted: bool = false
## 存档系统引用
var _f4_save: Node = null
## 音效播放器池
var _sfx_players: Array = []
## 当前可用的音效播放器索引
var _next_player_index: int = 0
## 音效资源缓存（避免重复加载）
var _audio_cache: Dictionary = {}

## ==================== IModule接口方法 ====================

## IModule.initialize()实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[FE5] 初始化音频系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取可选依赖模块
	var app = get_parent()
	if app and app.has_method("get_module"):
		_f4_save = app.get_module("f4_save_system")

	# 加载音量设置
	_load_volume_settings()

	# 创建音效播放器池
	_create_sfx_players()

	status = IModule.ModuleStatus.INITIALIZED
	print("[FE5] 音频系统初始化完成")
	return true

## IModule.start()实现
func start() -> bool:
	print("[FE5] 启动音频系统...")
	status = IModule.ModuleStatus.STARTING

	# 注册存档回调
	if _f4_save and _f4_save.has_signal("before_save"):
		if not _f4_save.is_connected("before_save", _on_before_save): _f4_save.connect("before_save", _on_before_save)

	status = IModule.ModuleStatus.RUNNING
	print("[FE5] 音频系统启动完成")
	return true

## IModule.stop()实现
func stop() -> void:
	print("[FE5] 停止音频系统...")
	status = IModule.ModuleStatus.STOPPING

	# 保存音量设置
	_save_volume_settings()

	# 停止所有音效
	_stop_all_audio()

	status = IModule.ModuleStatus.STOPPED
	print("[FE5] 音频系统已停止")

## IModule.get_module_info()实现
func get_module_info() -> Dictionary:
	return {
		"id": module_id,
		"name": module_name,
		"version": module_version,
		"category": category,
		"priority": priority,
		"status": status,
		"dependencies": dependencies,
		"optional_dependencies": optional_dependencies,
		"settings": {
			"sfx_volume": _sfx_volume,
			"voice_volume": _voice_volume,
			"is_muted": _is_muted
		}
	}

## IModule.is_healthy()实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error()实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共API ====================

## 播放音效
## @param audio_type: 音效类型（AudioType枚举）
## @param custom_path: 自定义音效路径，不传则使用默认路径
## @param volume_scale: 音量缩放（0.0~2.0）
func play_sfx(audio_type: int, custom_path: String = "", volume_scale: float = 1.0) -> bool:
	if _is_muted:
		return false

	var sfx_path = custom_path
	if sfx_path.is_empty():
		sfx_path = _get_default_sfx_path(audio_type)

	if sfx_path.is_empty():
		return false

	return _play_audio(sfx_path, _sfx_volume * volume_scale, false)

## 播放对话语音
## @param dialogue_id: 对话ID
## @param emotion: 情绪类型（可选，用于选择对应情绪的语音）
## @param volume_scale: 音量缩放（0.0~2.0）
func play_voice(dialogue_id: String, emotion: String = "normal", volume_scale: float = 1.0) -> bool:
	if _is_muted:
		return false

	var voice_path = _get_voice_path(dialogue_id, emotion)
	if voice_path.is_empty():
		return false

	return _play_audio(voice_path, _voice_volume * volume_scale, true)

## 播放自定义音效
## @param path: 音效资源完整路径
## @param volume: 音量（0.0~1.0）
func play_custom_sfx(path: String, volume: float = 1.0) -> bool:
	if _is_muted:
		return false
	return _play_audio(path, volume, false)

## 停止所有音效
func stop_all() -> void:
	_stop_all_audio()

## 设置音效音量
## @param volume: 音量值（0.0~1.0）
func set_sfx_volume(volume: float) -> void:
	_sfx_volume = clamp(volume, 0.0, 1.0)
	volume_changed.emit(_sfx_volume, _voice_volume)
	print("[FE5] 音效音量设置为: %.2f" % _sfx_volume)

## 获取音效音量
func get_sfx_volume() -> float:
	return _sfx_volume

## 设置语音音量
## @param volume: 音量值（0.0~1.0）
func set_voice_volume(volume: float) -> void:
	_voice_volume = clamp(volume, 0.0, 1.0)
	volume_changed.emit(_sfx_volume, _voice_volume)
	print("[FE5] 语音音量设置为: %.2f" % _voice_volume)

## 获取语音音量
func get_voice_volume() -> float:
	return _voice_volume

## 设置静音
## @param muted: 是否静音
func set_muted(muted: bool) -> void:
	_is_muted = muted
	if _is_muted:
		_stop_all_audio()
	mute_toggled.emit(_is_muted)
	print("[FE5] 静音状态: %s" % ("开启" if _is_muted else "关闭"))

## 获取静音状态
func is_muted() -> bool:
	return _is_muted

## 切换静音
func toggle_mute() -> bool:
	set_muted(!_is_muted)
	return _is_muted

## ==================== 私有方法 ====================

## 创建音效播放器池
func _create_sfx_players() -> void:
	for i in range(MAX_SFX_SOURCES):
		var player = AudioStreamPlayer.new()
		player.name = "SfxPlayer_%d" % i
		add_child(player)
		_sfx_players.append(player)

	print("[FE5] 创建了 %d 个音效播放器" % MAX_SFX_SOURCES)

## 获取可用的音效播放器
func _get_available_player() -> AudioStreamPlayer:
	for i in range(MAX_SFX_SOURCES):
		var player = _sfx_players[_next_player_index]
		_next_player_index = (_next_player_index + 1) % MAX_SFX_SOURCES

		if not player.playing:
			return player

	# 如果所有播放器都在播放，就用当前索引的（会覆盖正在播放的）
	return _sfx_players[_next_player_index]

## 加载音频资源（带缓存）
func _load_audio_resource(path: String) -> AudioStream:
	if _audio_cache.has(path):
		return _audio_cache[path]

	var resource = load(path)
	if resource is AudioStream:
		_audio_cache[path] = resource
		return resource

	print("[FE5] 音频资源加载失败: %s" % path)
	return null

## 播放音频
func _play_audio(path: String, volume: float, _is_voice: bool) -> bool:
	var stream = _load_audio_resource(path)
	if not stream:
		return false

	var player = _get_available_player()
	if not player:
		return false

	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.play()

	audio_played.emit(0, path)
	return true

## 停止所有音频
func _stop_all_audio() -> void:
	for player in _sfx_players:
		if player.playing:
			player.stop()

	print("[FE5] 停止所有音效")

## 获取默认音效路径
func _get_default_sfx_path(audio_type: int) -> String:
	match audio_type:
		AudioType.CLICK:
			return SFX_PATH_PREFIX + "click.wav"
		AudioType.HOVER:
			return SFX_PATH_PREFIX + "hover.wav"
		AudioType.DIALOGUE_NORMAL:
			return SFX_PATH_PREFIX + "dialogue_normal.wav"
		AudioType.DIALOGUE_HAPPY:
			return SFX_PATH_PREFIX + "dialogue_happy.wav"
		AudioType.DIALOGUE_SAD:
			return SFX_PATH_PREFIX + "dialogue_sad.wav"
		AudioType.DIALOGUE_SURPRISE:
			return SFX_PATH_PREFIX + "dialogue_surprise.wav"
		AudioType.LEVEL_UP:
			return SFX_PATH_PREFIX + "level_up.wav"
		AudioType.ACHIEVEMENT:
			return SFX_PATH_PREFIX + "achievement.wav"
		AudioType.MEMORY_UNLOCK:
			return SFX_PATH_PREFIX + "memory_unlock.wav"
		AudioType.OUTING_START:
			return SFX_PATH_PREFIX + "outing_start.wav"
		AudioType.OUTING_RETURN:
			return SFX_PATH_PREFIX + "outing_return.wav"

	return ""

## 获取语音路径
func _get_voice_path(dialogue_id: String, emotion: String) -> String:
	var emotion_part = "_%s" % emotion if emotion != "normal" else ""
	return VOICE_PATH_PREFIX + dialogue_id + emotion_part + ".wav"

## 加载音量设置
func _load_volume_settings() -> void:
	if not _f4_save:
		return

	_sfx_volume = clamp(_f4_save.load("fe5_audio.sfx_volume", DEFAULT_SFX_VOLUME), 0.0, 1.0)
	_voice_volume = clamp(_f4_save.load("fe5_audio.voice_volume", DEFAULT_VOICE_VOLUME), 0.0, 1.0)
	_is_muted = _f4_save.load("fe5_audio.is_muted", false)

	print("[FE5] 音量设置已加载 - 音效: %.2f, 语音: %.2f, 静音: %s" % [_sfx_volume, _voice_volume, _is_muted])

## 保存音量设置
func _save_volume_settings() -> void:
	if not _f4_save:
		return

	_f4_save.save("fe5_audio.sfx_volume", _sfx_volume)
	_f4_save.save("fe5_audio.voice_volume", _voice_volume)
	_f4_save.save("fe5_audio.is_muted", _is_muted)

	print("[FE5] 音量设置已保存")

## 存档前回调
func _on_before_save() -> void:
	_save_volume_settings()
