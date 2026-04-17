extends Node

## C7 对话记忆库
## 负责存储和管理玩家与角色的对话记录

# ModuleLoader required properties
var module_id: String = ""
var dependencies: Array[String] = []
var optional_dependencies: Array[String] = []

#region 信号定义

## 对话记录入库时触发
signal exchange_recorded(exchange_id: String, character_id: String)

#endregion

#region 常量定义

## 摘要触发阈值
const SUMMARIZE_THRESHOLD := 20

## 每次摘要压缩的记录数
const SUMMARIZE_BATCH_SIZE := 10

## 最大原始对话数
const MAX_RAW_EXCHANGES := 500

## 近期对话默认条数
const RECENT_EXCHANGES_DEFAULT := 5

#endregion

#region 私有变量

## 对话记录存储 {exchange_id: ExchangeRecord}
var _exchanges: Dictionary = {}

## 摘要记录存储 {summary_id: MemorySummary}
var _summaries: Dictionary = {}

## 对话记录自增计数器
var _exchange_counter: int = 0

## 摘要记录自增计数器
var _summary_counter: int = 0

## 依赖的模块
var _f4_save_system: Node = null
var _f3_time_system: Node = null
var _f5_aria_interface: Node = null

#endregion

#region IModule接口实现

func get_module_info() -> Dictionary:
	return {
		"id": "c7_dialogue_memory_bank",
		"name": "对话记忆库",
		"version": "1.0.0",
		"dependencies": ["f4_save_system"],
		"optional_dependencies": ["f3_time_system", "f5_aria_interface"]
	}

func initialize(_config: Dictionary = {}) -> bool:
	print("[C7] Initializing Dialogue Memory Bank...")

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[C7] Cannot get App node")
		return false

	_f4_save_system = app.get_module("f4_save_system")
	if not _f4_save_system:
		push_error("[C7] Required dependency f4_save_system not found")
		return false

	# 获取可选依赖
	_f3_time_system = app.get_module("f3_time_system")
	_f5_aria_interface = app.get_module("f5_aria_interface")

	# 加载保存的数据
	_load_from_save()

	print("[C7] Dialogue Memory Bank initialized")
	return true

func start() -> bool:
	print("[C7] Starting Dialogue Memory Bank...")
	return true

func shutdown() -> void:
	print("[C7] Shutting down Dialogue Memory Bank...")

	# 保存数据
	_save_to_save()

	# 清理数据
	_exchanges.clear()
	_summaries.clear()

	print("[C7] Dialogue Memory Bank shut down")

#endregion

#region 公共API

## 记录对话交换
func record_exchange(user_input: String, character_response: String, character_id: String = "aria", personality_tags: Array = []) -> String:
	_exchange_counter += 1
	var exchange_id := "ex_%03d" % _exchange_counter

	var timestamp: int
	if _f3_time_system and _f3_time_system.has_method("get_timestamp"):
		timestamp = _f3_time_system.get_timestamp()
	else:
		timestamp = Time.get_ticks_msec()

	var exchange := {
		"id": exchange_id,
		"user_input": user_input,
		"character_response": character_response,
		"personality_tags": personality_tags.duplicate(),
		"timestamp": timestamp,
		"is_summarized": false,
		"character_id": character_id
	}

	_exchanges[exchange_id] = exchange

	# 立即保存
	_save_to_save()

	# 触发信号
	exchange_recorded.emit(exchange_id, character_id)

	# 检查是否需要触发摘要
	_check_and_trigger_summarization()

	# 检查是否需要清理旧数据
	_purge_old_exchanges()

	return exchange_id

## 获取近期未摘要的对话记录
func get_recent_exchanges(character_id: String, count: int = RECENT_EXCHANGES_DEFAULT) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	# 按时间倒序排序
	var sorted_exchanges := _exchanges.values()
	sorted_exchanges.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.timestamp > b.timestamp
	)

	for exchange in sorted_exchanges:
		if result.size() >= count:
			break
		if exchange.character_id == character_id and not exchange.is_summarized:
			result.append(exchange.duplicate())

	return result

## 获取所有摘要记录
func get_summarized_memories(character_id: String = "aria") -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for summary in _summaries.values():
		if summary.get("character_id", character_id) == character_id:
			result.append(summary.duplicate())

	# 按时间倒序排序
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.timestamp_range.get("to", 0) > b.timestamp_range.get("to", 0)
	)

	return result

## 获取所有对话记录（调试用）
func get_all_exchanges() -> Dictionary:
	return _exchanges.duplicate()

## 获取所有摘要（调试用）
func get_all_summaries() -> Dictionary:
	return _summaries.duplicate()

#endregion

#region 私有方法

## 检查并触发摘要
func _check_and_trigger_summarization() -> void:
	var unsummarized: Array[Dictionary] = []
	for exchange in _exchanges.values():
		if not exchange.is_summarized:
			unsummarized.append(exchange)

	if unsummarized.size() >= SUMMARIZE_THRESHOLD:
		# 按时间正序排序，取最旧的批次
		unsummarized.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return a.timestamp < b.timestamp
		)

		var batch := unsummarized.slice(0, min(SUMMARIZE_BATCH_SIZE, unsummarized.size()))
		_generate_summary(batch)

## 生成摘要
func _generate_summary(exchange_batch: Array[Dictionary]) -> void:
	if exchange_batch.is_empty():
		return

	_summary_counter += 1
	var summary_id := "sum_%03d" % _summary_counter

	# 生成规则摘要（简化实现）
	var first_exchange := exchange_batch[0]
	var last_exchange := exchange_batch[exchange_batch.size() - 1]

	var content := "[简短回顾] "
	if not first_exchange.user_input.is_empty():
		content += first_exchange.user_input.substr(0, min(10, first_exchange.user_input.length())) + "... "
	if not last_exchange.character_response.is_empty():
		content += last_exchange.character_response.substr(0, min(10, last_exchange.character_response.length())) + " "
	content += "(共 " + str(exchange_batch.size()) + " 条对话)"

	# 提取记忆标签（取出现频率最高的标签）
	var tag_counts: Dictionary = {}
	for exchange in exchange_batch:
		for tag in exchange.personality_tags:
			tag_counts[tag] = tag_counts.get(tag, 0) + 1

	var memory_tags: Array[String] = []
	for tag in tag_counts.keys():
		memory_tags.append(tag)
	memory_tags.sort_custom(func(a: String, b: String) -> bool:
		return tag_counts[a] > tag_counts[b]
	)
	memory_tags = memory_tags.slice(0, min(3, memory_tags.size()))

	# 创建摘要记录
	var summary := {
		"id": summary_id,
		"source_exchange_ids": [],
		"content": content,
		"summary_type": "rule",
		"memory_tags": memory_tags,
		"timestamp_range": {
			"from": first_exchange.timestamp,
			"to": last_exchange.timestamp
		},
		"character_id": first_exchange.get("character_id", "aria")
	}

	# 记录源对话ID
	for exchange in exchange_batch:
		summary.source_exchange_ids.append(exchange.id)
		# 标记为已摘要
		if _exchanges.has(exchange.id):
			_exchanges[exchange.id].is_summarized = true

	_summaries[summary_id] = summary

	# 保存
	_save_to_save()

## 清理旧的已摘要记录
func _purge_old_exchanges() -> void:
	if _exchanges.size() <= MAX_RAW_EXCHANGES:
		return

	# 按时间正序排序
	var sorted_exchanges := _exchanges.values()
	sorted_exchanges.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.timestamp < b.timestamp
	)

	# 删除最旧的已摘要记录
	var to_delete: Array[String] = []
	for exchange in sorted_exchanges:
		if _exchanges.size() - to_delete.size() <= MAX_RAW_EXCHANGES:
			break
		if exchange.is_summarized:
			to_delete.append(exchange.id)

	for id in to_delete:
		_exchanges.erase(id)

	if not to_delete.is_empty():
		_save_to_save()

## 从存档加载
func _load_from_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("get_data"):
		return

	var saved_exchanges = _f4_save_system.get_data("c7.exchanges")
	if saved_exchanges is Dictionary:
		_exchanges = saved_exchanges.duplicate()

	var saved_summaries = _f4_save_system.get_data("c7.summaries")
	if saved_summaries is Dictionary:
		_summaries = saved_summaries.duplicate()

	var saved_counter = _f4_save_system.get_data("c7.exchange_counter")
	if saved_counter is int:
		_exchange_counter = saved_counter

	var saved_sum_counter = _f4_save_system.get_data("c7.summary_counter")
	if saved_sum_counter is int:
		_summary_counter = saved_sum_counter

	print("[C7] Loaded %d exchanges, %d summaries from save" % [_exchanges.size(), _summaries.size()])

## 保存到存档
func _save_to_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("set_data"):
		return

	_f4_save_system.set_data("c7.exchanges", _exchanges.duplicate())
	_f4_save_system.set_data("c7.summaries", _summaries.duplicate())
	_f4_save_system.set_data("c7.exchange_counter", _exchange_counter)
	_f4_save_system.set_data("c7.summary_counter", _summary_counter)

#endregion
