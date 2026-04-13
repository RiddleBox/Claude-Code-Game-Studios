# gameplay/fe2_memory_system/fe2_memory_system.gd
# Fe2记忆系统 — 负责记录和管理用户与角色的所有互动历史、回忆碎片、用户偏好
# 实现 IModule 接口，支持模块化架构

class_name Fe2MemorySystem
extends Node

## IModule 接口实现
var module_id: String = "fe2_memory_system"
var module_name: String = "记忆系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f4_save_system"]  # 依赖存档系统
var optional_dependencies: Array[String] = ["fe3_affinity_system"]
var config_path: String = "res://data/config/fe2_memory_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================
# 记忆类型
enum MemoryType {
	DAILY_INTERACTION = 0,  # 日常互动（点击、对话、投喂等）
	SPECIAL_EVENT = 1,      # 特殊事件（节日、纪念日、自定义事件）
	MEMORY_FRAGMENT = 2,    # 回忆碎片（解锁剧情用）
	USER_PREFERENCE = 3,    # 用户偏好（喜欢的食物、习惯、兴趣等）
	SHARED_EXPERIENCE = 4   # 共同经历（一起完成的事情）
}

# 最大记忆存储数量
const MAX_MEMORIES = 1000

## ==================== 信号 ====================
signal memory_added(memory: Dictionary)  # 新记忆添加时触发
signal memory_unlocked(memory_id: String)  # 回忆碎片解锁时触发
signal memory_deleted(memory_id: String)  # 记忆删除时触发

## ==================== 私有变量 ====================
var _f4_save: Node = null  # 存档系统引用
var _memories: Array = []  # 所有记忆列表
var _total_memories: int = 0  # 总记忆数量
var _unlocked_fragments: int = 0  # 已解锁回忆碎片数量

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[FE2] 初始化记忆系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[FE2] 无法获取App节点")
		return false

	_f4_save = app.get_module("f4_save_system")
	if not _f4_save:
		push_error("[FE2] 无法获取存档系统模块")
		return false

	# 从存档加载记忆数据
	_load_from_save()

	status = IModule.ModuleStatus.INITIALIZED
	print("[FE2] 记忆系统初始化完成，已加载 %d 条记忆，已解锁 %d 个回忆碎片" % [_total_memories, _unlocked_fragments])
	return true

## IModule.start() 实现
func start() -> bool:
	print("[FE2] 启动记忆系统...")
	status = IModule.ModuleStatus.STARTING

	# 注册存档回调，存档时自动保存记忆
	if _f4_save:
		if not _f4_save.is_connected("before_save", _on_before_save): _f4_save.connect("before_save", _on_before_save)

	status = IModule.ModuleStatus.RUNNING
	print("[FE2] 记忆系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[FE2] 停止 fe2_memory_system...")
	status = IModule.ModuleStatus.STOPPING

	# 保存记忆数据
	_save_to_save()

	status = IModule.ModuleStatus.STOPPED
	print("[FE2] fe2_memory_system 已停止")

## IModule.get_module_info() 实现
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
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共API ====================
## 添加新记忆
## @param content: 记忆内容文本
## @param type: 记忆类型（MemoryType枚举）
## @param tags: 标签数组，用于分类查询
## @param importance: 重要程度 0~10（越高越不容易被自动清理）
## @param extra_data: 额外自定义数据
func add_memory(content: String, type: int = MemoryType.DAILY_INTERACTION, tags: Array = [], importance: int = 1, extra_data: Dictionary = {}) -> String:
	if content.is_empty():
		push_warning("[FE2] 尝试添加空内容记忆")
		return ""

	# 生成唯一记忆ID
	var memory_id = "mem_%d_%d" % [Time.get_unix_time_from_system(), randi() % 10000]

	# 构建记忆对象
	var memory = {
		"id": memory_id,
		"content": content,
		"type": type,
		"tags": tags,
		"importance": clamp(importance, 0, 10),
		"timestamp": Time.get_unix_time_from_system(),
		"extra_data": extra_data,
		"is_read": false
	}

	# 添加到记忆列表
	_memories.append(memory)
	_total_memories = _memories.size()

	# 超出最大数量时清理最旧/最不重要的记忆
	if _total_memories > MAX_MEMORIES:
		_cleanup_old_memories()

	# 触发事件
	memory_added.emit(memory)
	print("[FE2] 添加记忆: %s (类型: %d, 重要程度: %d)" % [content.left(20), type, importance])

	return memory_id

## 查询记忆（支持按类型、标签、时间范围过滤）
## @param type_filter: 记忆类型，-1表示所有类型
## @param tags_filter: 标签数组，只要包含任意一个标签就匹配
## @param start_time: 开始时间戳，0表示不限制
## @param end_time: 结束时间戳，0表示不限制
## @param limit: 返回数量限制，0表示不限制
## @param sort_by_time: 是否按时间倒序排序（最新的在前）
func query_memories(type_filter: int = -1, tags_filter: Array = [], start_time: int = 0, end_time: int = 0, limit: int = 0, sort_by_time: bool = true) -> Array:
	var results = []

	for memory in _memories:
		# 类型过滤
		if type_filter != -1 and memory.type != type_filter:
			continue

		# 标签过滤
		if tags_filter.size() > 0:
			var has_match = false
			for tag in tags_filter:
				if tag in memory.tags:
					has_match = true
					break
			if not has_match:
				continue

		# 时间范围过滤
		if start_time > 0 and memory.timestamp < start_time:
			continue
		if end_time > 0 and memory.timestamp > end_time:
			continue

		results.append(memory)

	# 排序
	if sort_by_time:
		results.sort_custom(func(a, b): return b.timestamp - a.timestamp)

	# 数量限制
	if limit > 0 and results.size() > limit:
		results = results.slice(0, limit)

	return results

## 解锁回忆碎片
## @param fragment_id: 碎片ID
## @param content: 碎片内容
## @param unlock_condition: 解锁条件描述
func unlock_memory_fragment(fragment_id: String, content: String, unlock_condition: String = "") -> bool:
	# 检查是否已经解锁
	var existing = query_memories(MemoryType.MEMORY_FRAGMENT, [fragment_id])
	if existing.size() > 0:
		print("[FE2] 回忆碎片 %s 已经解锁过了" % fragment_id)
		return false

	# 添加为特殊记忆
	add_memory(
		content,
		MemoryType.MEMORY_FRAGMENT,
		["memory_fragment", fragment_id],
		10,  # 回忆碎片重要程度最高
		{"unlock_condition": unlock_condition, "fragment_id": fragment_id}
	)

	_unlocked_fragments += 1
	memory_unlocked.emit(fragment_id)
	print("[FE2] 解锁回忆碎片: %s" % fragment_id)
	return true

## 获取已解锁回忆碎片数量
func get_unlocked_fragment_count() -> int:
	return _unlocked_fragments

## 获取总记忆数量
func get_total_memory_count() -> int:
	return _total_memories

## 标记记忆为已读
func mark_memory_as_read(memory_id: String) -> bool:
	for memory in _memories:
		if memory.id == memory_id:
			memory.is_read = true
			return true
	return false

## 删除记忆
func delete_memory(memory_id: String) -> bool:
	for i in range(_memories.size()):
		if _memories[i].id == memory_id:
			var memory = _memories[i]
			_memories.remove_at(i)
			_total_memories = _memories.size()

			# 如果是回忆碎片，计数器减1
			if memory.type == MemoryType.MEMORY_FRAGMENT:
				_unlocked_fragments = max(0, _unlocked_fragments - 1)

			memory_deleted.emit(memory_id)
			print("[FE2] 删除记忆: %s" % memory_id)
			return true
	return false

## ==================== 私有方法 ====================
## 清理旧记忆（超出最大数量时调用）
func _cleanup_old_memories() -> void:
	# 按重要程度排序，相同重要程度按时间升序（最旧的在前）
	_memories.sort_custom(func(a, b):
		if a.importance != b.importance:
			return a.importance - b.importance
		return a.timestamp - b.timestamp
	)

	# 删除最前面的20%记忆（最低重要程度/最旧的）
	var delete_count = ceil(MAX_MEMORIES * 0.2)
	var deleted = _memories.slice(0, delete_count)
	_memories = _memories.slice(delete_count)
	_total_memories = _memories.size()

	# 统计被删除的回忆碎片数量
	var fragments_deleted = 0
	for memory in deleted:
		if memory.type == MemoryType.MEMORY_FRAGMENT:
			fragments_deleted += 1
	_unlocked_fragments = max(0, _unlocked_fragments - fragments_deleted)

	print("[FE2] 清理了 %d 条旧记忆，其中包含 %d 个回忆碎片" % [delete_count, fragments_deleted])

## 从存档加载记忆数据
func _load_from_save() -> void:
	if not _f4_save:
		return

	# 读取存档数据
	var memories = _f4_save.load("memory_system.memories", [])
	_memories = memories
	_total_memories = _memories.size()
	_unlocked_fragments = _f4_save.load("memory_system.unlocked_fragments", 0)

## 保存记忆数据到存档
func _save_to_save() -> void:
	if not _f4_save:
		return

	_f4_save.save("memory_system.memories", _memories)
	_f4_save.save("memory_system.unlocked_fragments", _unlocked_fragments)
	_f4_save.save("memory_system.total_count", _total_memories)
	print("[FE2] 记忆数据已保存到存档")

## 存档前回调
func _on_before_save() -> void:
	_save_to_save()
