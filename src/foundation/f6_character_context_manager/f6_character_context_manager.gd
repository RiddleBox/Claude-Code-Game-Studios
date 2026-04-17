extends Node

## F6 角色上下文管理器
## 负责组装LLM调用所需的完整上下文（System Prompt + 对话历史 + 当前情境）

# ModuleLoader required properties
var module_id: String = ""
var dependencies: Array[String] = []
var optional_dependencies: Array[String] = []

#region 常量定义

## 近期对话保留轮数
const RECENT_EXCHANGES := 10

## 最大上下文Token数（估算）
const MAX_CONTEXT_TOKENS := 4000

## 平均每个字符的Token数（中文约0.5，英文约0.25）
const AVG_TOKENS_PER_CHAR := 0.4

#endregion

#region 私有变量

## 依赖的模块
var _c5_personality: Node = null
var _c6_relationship: Node = null
var _c7_memory: Node = null
var _f4_save_system: Node = null

## 角色Prompt模板配置
var _character_config: Dictionary = {}

#endregion

#region IModule接口实现

func get_module_info() -> Dictionary:
	return {
		"id": "f6_character_context_manager",
		"name": "角色上下文管理器",
		"version": "1.0.0",
		"dependencies": ["f4_save_system"],
		"optional_dependencies": ["c5_personality_variable_system", "c6_relationship_value_system", "c7_dialogue_memory_bank"]
	}

func initialize(_config: Dictionary = {}) -> bool:
	print("[F6] Initializing Character Context Manager...")

	# 获取依赖模块（通过App节点）
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[F6] Cannot get App node")
		return false

	_f4_save_system = app.get_module("f4_save_system")
	if not _f4_save_system:
		push_error("[F6] Required dependency f4_save_system not found")
		return false

	# 获取可选依赖
	_c5_personality = app.get_module("c5_personality_variable_system")
	_c6_relationship = app.get_module("c6_relationship_value_system")
	_c7_memory = app.get_module("c7_dialogue_memory_bank")

	# 加载角色配置
	_load_character_config()

	print("[F6] Character Context Manager initialized")
	return true

func start() -> bool:
	print("[F6] Starting Character Context Manager...")
	return true

func shutdown() -> void:
	print("[F6] Shutting down Character Context Manager...")
	_character_config.clear()
	print("[F6] Character Context Manager shut down")

#endregion

#region 公共API

## 构建完整的LLM上下文
## @param user_input: 玩家当前输入
## @param character_id: 角色ID（默认为"aria"）
## @return: 上下文对象 {system_prompt, messages, current_input, metadata}
func build_context(user_input: String, character_id: String = "aria") -> Dictionary:
	var context := {
		"system_prompt": "",
		"messages": [],
		"current_input": user_input,
		"metadata": {
			"personality_tags": [],
			"context_tokens": 0
		}
	}

	# 1. 构建System Prompt
	context.system_prompt = _build_system_prompt(character_id)

	# 2. 获取对话历史
	var history := _get_dialogue_history(character_id)

	# 3. 组装messages数组
	context.messages = _assemble_messages(context.system_prompt, history, user_input)

	# 4. 估算Token数
	context.metadata.context_tokens = _estimate_tokens(context)

	# 5. 如果超出限制，进行压缩
	if context.metadata.context_tokens > MAX_CONTEXT_TOKENS:
		context = _compress_context(context)

	return context

## 获取角色的基础配置
func get_character_config(character_id: String = "aria") -> Dictionary:
	return _character_config.get(character_id, {})

#endregion

#region 私有方法 - System Prompt构建

## 构建System Prompt
func _build_system_prompt(character_id: String) -> String:
	var config := get_character_config(character_id)
	if config.is_empty():
		return _get_fallback_prompt(character_id)

	var prompt: String = config.get("base_template", "")

	# 填充变量
	prompt = prompt.replace("{name}", str(config.get("name", character_id)))
	prompt = prompt.replace("{world}", str(config.get("world", "未知世界")))
	prompt = prompt.replace("{speech_style}", str(config.get("speech_style", "自然对话")))

	# 注入性格描述
	if _c5_personality and _c5_personality.has_method("get_axis"):
		prompt = prompt.replace("{personality_description}", _generate_personality_description(character_id))
	else:
		prompt = prompt.replace("{personality_description}", "温暖而好奇")

	# 注入关系状态
	if _c6_relationship and _c6_relationship.has_method("get_relationship_tier"):
		prompt = prompt.replace("{relationship_stage}", _generate_relationship_description(character_id))
	else:
		prompt = prompt.replace("{relationship_stage}", "初识阶段")

	return prompt

## 根据C5性格值生成性格描述
func _generate_personality_description(character_id: String) -> String:
	if not _c5_personality:
		return "温暖而好奇"

	var warmth: float = _c5_personality.get_axis("warmth")
	var curiosity: float = _c5_personality.get_axis("curiosity")
	var playfulness: float = _c5_personality.get_axis("playfulness")

	var traits: Array[String] = []

	# 温暖度
	if warmth > 0.6:
		traits.append("温暖体贴")
	elif warmth < 0.4:
		traits.append("冷静理性")

	# 好奇度
	if curiosity > 0.6:
		traits.append("充满好奇")
	elif curiosity < 0.4:
		traits.append("沉稳内敛")

	# 玩心度
	if playfulness > 0.6:
		traits.append("活泼俏皮")
	elif playfulness < 0.4:
		traits.append("严肃认真")

	if traits.is_empty():
		return "平和自然"

	return "、".join(traits)

## 根据C6关系值生成关系描述
func _generate_relationship_description(character_id: String) -> String:
	if not _c6_relationship:
		return "初识阶段"

	var tier: int = _c6_relationship.get_relationship_tier(character_id)

	match tier:
		0: return "陌生人，刚刚认识"
		1: return "认识阶段，开始了解彼此"
		2: return "熟悉阶段，已经建立信任"
		3: return "亲密阶段，彼此关心"
		4: return "挚友阶段，深厚的情感纽带"
		_: return "初识阶段"

## 降级Prompt（无配置时使用）
func _get_fallback_prompt(character_id: String) -> String:
	return "你是%s，一个温暖、好奇、善于倾听的AI伙伴。你会记住与玩家的对话，用自然的方式回应。" % character_id

#endregion

#region 私有方法 - 对话历史获取

## 获取对话历史
func _get_dialogue_history(character_id: String) -> Array[Dictionary]:
	var history: Array[Dictionary] = []

	if not _c7_memory or not _c7_memory.has_method("get_recent_exchanges"):
		return history

	# 从C7获取近期对话
	var exchanges = _c7_memory.get_recent_exchanges(character_id, RECENT_EXCHANGES)

	for exchange in exchanges:
		# 玩家输入
		if exchange.has("user_input") and not exchange.user_input.is_empty():
			history.append({
				"role": "user",
				"content": exchange.user_input
			})

		# 角色回应
		if exchange.has("character_response") and not exchange.character_response.is_empty():
			history.append({
				"role": "assistant",
				"content": exchange.character_response
			})

	return history

#endregion

#region 私有方法 - Messages组装

## 组装完整的messages数组
func _assemble_messages(system_prompt: String, history: Array[Dictionary], current_input: String) -> Array[Dictionary]:
	var messages: Array[Dictionary] = []

	# 1. System message
	messages.append({
		"role": "system",
		"content": system_prompt
	})

	# 2. 对话历史
	messages.append_array(history)

	# 3. 当前用户输入
	messages.append({
		"role": "user",
		"content": current_input
	})

	return messages

#endregion

#region 私有方法 - Token估算与压缩

## 估算上下文的Token数
func _estimate_tokens(context: Dictionary) -> int:
	var total_chars := 0

	# System prompt
	total_chars += context.system_prompt.length()

	# Messages
	for msg in context.messages:
		total_chars += msg.content.length()

	# 当前输入
	total_chars += context.current_input.length()

	return int(total_chars * AVG_TOKENS_PER_CHAR)

## 压缩上下文（超出Token限制时）
func _compress_context(context: Dictionary) -> Dictionary:
	# 简单策略：保留system prompt和最新3轮对话
	var compressed := context.duplicate(true)
	var messages: Array[Dictionary] = []

	# 保留system message
	if not compressed.messages.is_empty() and compressed.messages[0].role == "system":
		messages.append(compressed.messages[0])

	# 保留最新6条消息（3轮对话）
	var start_idx: int = max(1, compressed.messages.size() - 6)
	for i in range(start_idx, compressed.messages.size()):
		var msg: Dictionary = compressed.messages[i]
		messages.append(msg)

	compressed.messages = messages
	compressed.metadata.context_tokens = _estimate_tokens(compressed)

	return compressed

#endregion

#region 私有方法 - 配置加载

## 加载角色配置
func _load_character_config() -> void:
	var config_path := "res://data/config/character_prompts.json"

	if not FileAccess.file_exists(config_path):
		push_warning("[F6] Character config not found: %s, using fallback" % config_path)
		_character_config = _get_default_config()
		return

	var file := FileAccess.open(config_path, FileAccess.READ)
	if not file:
		push_error("[F6] Failed to open character config: %s" % config_path)
		_character_config = _get_default_config()
		return

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)

	if error != OK:
		push_error("[F6] Failed to parse character config JSON: %s" % json.get_error_message())
		_character_config = _get_default_config()
		return

	_character_config = json.data
	print("[F6] Loaded character config for %d characters" % _character_config.size())

## 获取默认配置
func _get_default_config() -> Dictionary:
	return {
		"aria": {
			"name": "Aria",
			"world": "窗语世界",
			"base_template": "你是{name}，来自{world}。你的性格是{personality_description}。你和玩家的关系目前处于{relationship_stage}。你说话的方式是{speech_style}。",
			"speech_style": "温暖自然，善于倾听"
		}
	}

#endregion
