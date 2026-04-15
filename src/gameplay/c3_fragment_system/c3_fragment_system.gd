# gameplay/c3_fragment_system/c3_fragment_system.gd
# C3 — 碎片系统（Fragment System）
# 窗语叙事内容的核心容器
# 实现 IModule 接口，支持模块化架构

class_name C3FragmentSystem
extends Node

## IModule 接口实现
var module_id: String = "c3_fragment_system"
var module_name: String = "碎片系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f4_save_system", "f3_time_system"]
var optional_dependencies: Array[String] = ["c2_outing_return_cycle"]
var config_path: String = "res://data/config/c3_fragment_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 碎片类型枚举
enum FragmentType {
	DIALOGUE,  # 对话片段
	SCENE,     # 场景印象
	OBJECT,    # 物件描述
	EMOTION    # 情绪印象
}

## 存档键名
const SAVE_KEY_FRAGMENTS: String = "c3.fragments"
const SAVE_KEY_COUNTER: String = "c3.fragment_counter"

## ==================== 信号 ====================

## 碎片入库完成时触发
signal fragments_received(fragment_ids: Array[String])

## ==================== 私有变量 ====================

## F4 存档系统引用
var _f4_save: Node = null

## F3 时间系统引用
var _f3_time: Node = null

## C2 外出-归来循环引用（可选依赖）
var _c2_outing: Node = null

## 碎片存储：{fragment_id: FragmentRecord}
var _fragments: Dictionary = {}

## 碎片 ID 计数器
var _fragment_counter: int = 0

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[C3] 初始化碎片系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[C3] 无法获取 App 节点")
		return false

	_f4_save = app.get_module("f4_save_system")
	if not _f4_save:
		push_error("[C3] 无法获取 F4 存档系统模块")
		return false

	_f3_time = app.get_module("f3_time_system")
	if not _f3_time:
		push_error("[C3] 无法获取 F3 时间系统模块")
		return false

	# 获取可选依赖模块
	_c2_outing = app.get_module("c2_outing_return_cycle")

	# 从 F4 加载数据
	_load_from_save()

	status = IModule.ModuleStatus.INITIALIZED
	print("[C3] 碎片系统初始化完成，已加载 %d 条碎片" % _fragments.size())
	return true

## IModule.start() 实现
func start() -> bool:
	print("[C3] 启动碎片系统...")
	status = IModule.ModuleStatus.STARTING

	# 订阅 C2 信号
	if _c2_outing and _c2_outing.has_signal("return_completed"):
		_c2_outing.return_completed.connect(_on_c2_return_completed)
		print("[C3] 已订阅 C2 return_completed 信号")
	else:
		print("[C3] C2 外出-归来循环不可用，将通过 API 接收碎片")

	status = IModule.ModuleStatus.RUNNING
	print("[C3] 碎片系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[C3] 停止碎片系统...")
	status = IModule.ModuleStatus.STOPPING

	# 保存到 F4
	_save_to_save()

	status = IModule.ModuleStatus.STOPPED
	print("[C3] 碎片系统已停止")

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
		"fragment_count": _fragments.size(),
		"unread_count": get_unread().size()
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共 API ====================

## 返回所有碎片，按 acquired_at 降序
func get_all() -> Array:
	var result: Array = _fragments.values()
	result.sort_custom(func(a, b): return a.acquired_at > b.acquired_at)
	return result

## 返回所有未读碎片
func get_unread() -> Array:
	var result: Array = []
	for frag in _fragments.values():
		if not frag.is_read:
			result.append(frag)
	return result

## 按类型筛选碎片
func get_by_type(type_str: String) -> Array:
	var result: Array = []
	for frag in _fragments.values():
		if frag.type == type_str:
			result.append(frag)
	result.sort_custom(func(a, b): return a.acquired_at > b.acquired_at)
	return result

## 按外出批次查询
func get_by_outing(outing_id: String) -> Array:
	var result: Array = []
	for frag in _fragments.values():
		if frag.outing_id == outing_id:
			result.append(frag)
	result.sort_custom(func(a, b): return a.acquired_at > b.acquired_at)
	return result

## 返回最新 n 条碎片
func get_latest(n: int) -> Array:
	var all: Array = get_all()
	if all.size() <= n:
		return all
	return all.slice(0, n)

## 标记碎片为已读
func mark_read(fragment_id: String) -> void:
	if not _fragments.has(fragment_id):
		push_warning("[C3] 标记已读失败：碎片不存在 %s" % fragment_id)
		return

	_fragments[fragment_id].is_read = true
	_save_to_save()
	print("[C3] 碎片已标记为已读: %s" % fragment_id)

## 手动接收碎片（当 C2 不可用时使用）
func receive_fragments(fragment_payloads: Array, outing_id: String) -> Array[String]:
	var received_ids: Array[String] = []

	for payload in fragment_payloads:
		var frag_id = _create_and_store_fragment(payload, outing_id)
		if not frag_id.is_empty():
			received_ids.append(frag_id)

	if not received_ids.is_empty():
		_save_to_save()
		fragments_received.emit(received_ids)
		print("[C3] 接收到 %d 条碎片: %s" % [received_ids.size(), received_ids])

	return received_ids

## ==================== 私有方法 ====================

## 从 F4 加载数据
func _load_from_save() -> void:
	if not _f4_save:
		return

	# 加载碎片计数器
	_fragment_counter = _f4_save.load(SAVE_KEY_COUNTER, 0)

	# 加载碎片数据
	var saved_fragments = _f4_save.load(SAVE_KEY_FRAGMENTS, {})
	if typeof(saved_fragments) == TYPE_DICTIONARY:
		_fragments = saved_fragments.duplicate()
	else:
		push_warning("[C3] 存档数据格式错误，使用空库")
		_fragments = {}
		_fragment_counter = 0

	print("[C3] 从存档加载了 %d 条碎片，计数器 = %d" % [_fragments.size(), _fragment_counter])

## 保存到 F4
func _save_to_save() -> void:
	if not _f4_save:
		return

	_f4_save.save(SAVE_KEY_FRAGMENTS, _fragments.duplicate())
	_f4_save.save(SAVE_KEY_COUNTER, _fragment_counter)

	print("[C3] 已保存 %d 条碎片到存档" % _fragments.size())

## C2 return_completed 信号回调
func _on_c2_return_completed(fragments: Array, outing_id: String) -> void:
	print("[C3] 收到 C2 归来事件，outing_id = %s" % outing_id)
	receive_fragments(fragments, outing_id)

## 创建并存储单个碎片
func _create_and_store_fragment(payload: Dictionary, outing_id: String) -> String:
	# 验证必要字段
	if not payload.has("content_id") or not payload.has("type") or not payload.has("text"):
		push_warning("[C3] 碎片数据格式错误，跳过: %s" % payload)
		return ""

	# 生成碎片 ID
	var frag_id = "frag_" + str(_fragment_counter).pad_zeros(4)
	_fragment_counter += 1

	# 获取时间戳
	var acquired_at: int = 0
	if _f3_time and _f3_time.has_method("get_current_timestamp"):
		acquired_at = _f3_time.get_current_timestamp()
	else:
		acquired_at = Time.get_unix_time_from_system()

	# 创建碎片记录
	var fragment: Dictionary = {
		"id": frag_id,
		"content_id": payload.get("content_id", ""),
		"type": payload.get("type", "dialogue"),
		"text": payload.get("text", ""),
		"emotion_tag": payload.get("emotion_tag", "peaceful"),
		"ref_id": payload.get("ref_id", ""),
		"acquired_at": acquired_at,
		"outing_id": outing_id,
		"is_read": false
	}

	# 存入内存
	_fragments[frag_id] = fragment

	print("[C3] 碎片入库: %s (type: %s)" % [frag_id, fragment.type])
	return frag_id
