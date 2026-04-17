extends Node
class_name F5AriaInterface

## F5 Aria接口层
## 负责AI能力的统一入口：STT、LLM、TTS
## 包含降级模式和连接状态管理

# 连接状态枚举
enum ConnectionState {
	DISCONNECTED,  # 无API Key或未配置
	CONNECTING,    # 正在验证API Key
	CONNECTED,     # API验证成功
	ERROR,         # API调用失败
	DEGRADED       # API Key无效或额度耗尽
}

# 信号
signal connection_state_changed(state: ConnectionState)
signal aria_interaction_completed(personality_tags: Array)
signal tts_audio_ready(audio_stream: AudioStream)
signal llm_stream_chunk(text: String)

# 模块信息
const MODULE_ID := "F5"
const MODULE_NAME := "Aria Interface Layer"
const MODULE_CATEGORY := "Foundation"

# ModuleLoader required properties
var module_id: String = ""
var dependencies: Array[String] = []
var optional_dependencies: Array[String] = []

# 配置参数
const LLM_TIMEOUT := 15.0  # 秒
const TTS_TIMEOUT := 10.0  # 秒
const RECONNECT_INTERVAL := 300.0  # 5分钟
const FALLBACK_SCRIPT_COOLDOWN := 3

# 内部状态
var _current_state: ConnectionState = ConnectionState.DISCONNECTED
var _api_key: String = ""
var _api_base_url: String = "https://api.openai.com/v1"
var _model_name: String = "gpt-3.5-turbo"
var _is_initialized := false
var _is_running := false
var _last_error: String = ""
var _recent_fallback_scripts: Array[String] = []
var _reconnect_timer: Timer = null
var _http_request: HTTPRequest = null
var _current_request_id: int = 0

# 依赖的模块引用
var _f4_save_system = null
var _f6_context_manager = null
var _c7_memory_library = null

# 降级脚本库
var _fallback_scripts: Array = []

#region IModule接口实现

func initialize(_config: Dictionary = {}) -> bool:
	if _is_initialized:
		push_warning("[F5] Already initialized")
		return true

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[F5] 无法获取 App 节点")
		return false

	_f4_save_system = app.get_module("f4_save_system")
	_f6_context_manager = app.get_module("f6_character_context_manager")
	_c7_memory_library = app.get_module("c7_dialogue_memory_bank")

	# F4是必需的（读取API Key）
	if not _f4_save_system:
		_last_error = "Missing required dependency: F4 (Save System)"
		push_error("[F5] " + _last_error)
		return false

	# 创建HTTPRequest节点
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.timeout = LLM_TIMEOUT

	# 创建重连定时器
	_reconnect_timer = Timer.new()
	add_child(_reconnect_timer)
	_reconnect_timer.wait_time = RECONNECT_INTERVAL
	_reconnect_timer.one_shot = false
	_reconnect_timer.timeout.connect(_on_reconnect_timer_timeout)

	# 加载降级脚本库
	_load_fallback_scripts()

	# 从F4加载API Key
	_load_api_config()

	_is_initialized = true
	print("[F5] Aria Interface Layer initialized")
	return true

func start() -> bool:
	if not _is_initialized:
		_last_error = "Cannot start: not initialized"
		push_error("[F5] " + _last_error)
		return false

	if _is_running:
		push_warning("[F5] Already running")
		return true

	# 验证API连接
	_verify_api_connection()

	_is_running = true
	print("[F5] Aria Interface Layer started")
	return true

func stop() -> void:
	if not _is_running:
		return

	# 停止重连定时器
	if _reconnect_timer:
		_reconnect_timer.stop()

	# 取消当前请求
	if _http_request and _http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_http_request.cancel_request()

	_is_running = false
	print("[F5] Aria Interface Layer stopped")

func get_module_info() -> Dictionary:
	return {
		"id": MODULE_ID,
		"name": MODULE_NAME,
		"category": MODULE_CATEGORY,
		"version": "1.0.0",
		"dependencies": ["F4"],
		"optional_dependencies": ["F6", "C7"]
	}

func is_healthy() -> bool:
	return _is_initialized and _is_running and _last_error.is_empty()

func get_last_error() -> String:
	return _last_error

#endregion

#region 公共API

## 获取当前连接状态
func get_connection_state() -> ConnectionState:
	return _current_state

## 设置API配置
func set_api_config(api_key: String, base_url: String = "", model: String = "") -> void:
	_api_key = api_key
	if not base_url.is_empty():
		_api_base_url = base_url
	if not model.is_empty():
		_model_name = model

	# 保存到F4
	if _f4_save_system and _f4_save_system.has_method("set_value"):
		_f4_save_system.set_value("settings.aria_api_key", _api_key)
		_f4_save_system.set_value("settings.aria_base_url", _api_base_url)
		_f4_save_system.set_value("settings.aria_model", _model_name)

	# 重新验证连接
	if _is_running:
		_verify_api_connection()

## 发送LLM请求（异步）
func send_llm_request(user_input: String) -> void:
	if not _is_running:
		push_warning("[F5] Cannot send request: not running")
		return

	# 检查连接状态
	if _current_state == ConnectionState.DISCONNECTED or _current_state == ConnectionState.DEGRADED:
		# 降级模式：使用预设脚本
		_handle_degraded_interaction(user_input)
		return

	# 构建上下文（如果F6可用）
	var context: Dictionary = {}
	if _f6_context_manager and _f6_context_manager.has_method("build_context"):
		context = _f6_context_manager.build_context(user_input)
	else:
		# 简单上下文
		context = {
			"messages": [
				{"role": "system", "content": "You are a helpful AI companion."},
				{"role": "user", "content": user_input}
			]
		}

	# 发送HTTP请求
	_send_http_llm_request(context)

## 发送TTS请求（异步）
func send_tts_request(text: String) -> void:
	if not _is_running:
		return

	# TODO: 实现TTS调用
	# 当前版本暂不实现，直接发出信号
	push_warning("[F5] TTS not implemented yet")

#endregion

#region 内部方法

## 加载API配置
func _load_api_config() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("get_value"):
		return

	_api_key = _f4_save_system.get_value("settings.aria_api_key", "")
	_api_base_url = _f4_save_system.get_value("settings.aria_base_url", "https://api.openai.com/v1")
	_model_name = _f4_save_system.get_value("settings.aria_model", "gpt-3.5-turbo")

	# 根据API Key设置初始状态
	if _api_key.is_empty():
		_set_connection_state(ConnectionState.DISCONNECTED)
	else:
		_set_connection_state(ConnectionState.CONNECTING)

## 验证API连接
func _verify_api_connection() -> void:
	if _api_key.is_empty():
		_set_connection_state(ConnectionState.DISCONNECTED)
		return

	_set_connection_state(ConnectionState.CONNECTING)

	# TODO: 发送测试请求验证API Key
	# 当前版本简化：直接设置为CONNECTED
	await get_tree().create_timer(0.5).timeout
	_set_connection_state(ConnectionState.CONNECTED)

## 设置连接状态
func _set_connection_state(new_state: ConnectionState) -> void:
	if _current_state == new_state:
		return

	_current_state = new_state
	connection_state_changed.emit(new_state)

	# 根据状态启动/停止重连定时器
	if new_state == ConnectionState.ERROR and _reconnect_timer:
		_reconnect_timer.start()
	elif new_state == ConnectionState.CONNECTED and _reconnect_timer:
		_reconnect_timer.stop()

## 发送HTTP LLM请求
func _send_http_llm_request(context: Dictionary) -> void:
	if not _http_request:
		return

	_current_request_id += 1
	var request_id := _current_request_id

	# 构建请求体
	var request_body := {
		"model": _model_name,
		"messages": context.get("messages", []),
		"stream": false  # 当前版本不使用流式输出
	}

	var json_body := JSON.stringify(request_body)
	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer " + _api_key
	]

	var url := _api_base_url + "/chat/completions"

	# 发送请求
	var error := _http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		_last_error = "Failed to send HTTP request: " + str(error)
		push_error("[F5] " + _last_error)
		_set_connection_state(ConnectionState.ERROR)
		return

	# 等待响应
	var response_data = await _http_request.request_completed
	_handle_llm_response(response_data, request_id)

## 处理LLM响应
func _handle_llm_response(response_data: Array, request_id: int) -> void:
	# 检查请求是否已过期
	if request_id != _current_request_id:
		return

	var result: int = response_data[0]
	var response_code: int = response_data[1]
	var headers: PackedStringArray = response_data[2]
	var body: PackedByteArray = response_data[3]

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_last_error = "LLM request failed: " + str(response_code)
		push_error("[F5] " + _last_error)
		_set_connection_state(ConnectionState.ERROR)
		# 降级处理
		_handle_degraded_interaction("")
		return

	# 解析响应
	var json_str := body.get_string_from_utf8()
	var json := JSON.new()
	var parse_error := json.parse(json_str)
	if parse_error != OK:
		_last_error = "Failed to parse LLM response"
		push_error("[F5] " + _last_error)
		_set_connection_state(ConnectionState.ERROR)
		return

	var response_dict: Dictionary = json.data
	var choices: Array = response_dict.get("choices", [])
	if choices.is_empty():
		_last_error = "Empty LLM response"
		push_error("[F5] " + _last_error)
		return

	var message: Dictionary = choices[0].get("message", {})
	var content: String = message.get("content", "")

	# 发出流式输出信号（虽然不是真正的流式）
	llm_stream_chunk.emit(content)

	# 发出交互完成信号
	var personality_tags: Array = []  # TODO: 从响应中提取性格标签
	aria_interaction_completed.emit(personality_tags)

	# 记录到C7对话记忆库
	if _c7_memory_library and _c7_memory_library.has_method("record_exchange"):
		# TODO: 需要保存原始用户输入
		pass

## 处理降级交互
func _handle_degraded_interaction(user_input: String) -> void:
	# 从降级脚本库中选择一个脚本
	var script := _select_fallback_script()
	if script.is_empty():
		return

	# 发出流式输出信号
	var text: String = script.get("text", "[...]")
	llm_stream_chunk.emit(text)

	# 发出交互完成信号（降级模式）
	aria_interaction_completed.emit([])

## 选择降级脚本
func _select_fallback_script() -> Dictionary:
	if _fallback_scripts.is_empty():
		return {}

	# 过滤掉最近使用的脚本
	var available_scripts: Array[Dictionary] = []
	for script in _fallback_scripts:
		var script_id: String = script.get("id", "")
		if not _recent_fallback_scripts.has(script_id):
			available_scripts.append(script)

	# 如果所有脚本都用过了，清空历史
	if available_scripts.is_empty():
		_recent_fallback_scripts.clear()
		available_scripts = _fallback_scripts.duplicate()

	# 根据权重随机选择
	var total_weight := 0.0
	for script in available_scripts:
		total_weight += script.get("weight", 1.0)

	var rand_value := randf() * total_weight
	var cumulative_weight := 0.0
	for script in available_scripts:
		cumulative_weight += script.get("weight", 1.0)
		if rand_value <= cumulative_weight:
			var script_id: String = script.get("id", "")
			_recent_fallback_scripts.append(script_id)
			if _recent_fallback_scripts.size() > FALLBACK_SCRIPT_COOLDOWN:
				_recent_fallback_scripts.pop_front()
			return script

	# 默认返回第一个
	return available_scripts[0] if not available_scripts.is_empty() else {}

## 加载降级脚本库
func _load_fallback_scripts() -> void:
	var file_path := "res://data/config/fallback_scripts.json"
	if not FileAccess.file_exists(file_path):
		push_warning("[F5] Fallback scripts file not found: " + file_path)
		# 使用默认脚本
		_fallback_scripts = [
			{"id": "default_1", "text": "[...]", "weight": 0.7, "type": "action"},
			{"id": "default_2", "text": "今天的阳光照得有点暖...", "weight": 0.3, "type": "monologue"}
		]
		return

	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[F5] Failed to open fallback scripts file")
		return

	var json_str := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_error := json.parse(json_str)
	if parse_error != OK:
		push_error("[F5] Failed to parse fallback scripts JSON")
		return

	var data = json.data
	if data is Dictionary:
		_fallback_scripts = data.get("scripts", [])
	elif data is Array:
		_fallback_scripts = data

## 重连定时器超时
func _on_reconnect_timer_timeout() -> void:
	if _current_state == ConnectionState.ERROR:
		print("[F5] Attempting to reconnect...")
		_verify_api_connection()

#endregion
