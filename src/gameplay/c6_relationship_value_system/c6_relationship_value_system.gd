extends Node

## C6 关系值系统
## 负责计算和管理玩家与角色之间的关系值

# ModuleLoader required properties
var module_id: String = ""
var dependencies: Array[String] = []
var optional_dependencies: Array[String] = []

#region 信号定义

## 关系值变化时触发
signal relationship_changed(character_id: String, old_value: float, new_value: float, delta: float)

## 关系等级变化时触发
signal relationship_tier_changed(character_id: String, old_tier: int, new_tier: int)

#endregion

#region 常量定义

## 关系等级阈值
const TIER_THRESHOLDS := {
	0: -100.0,  # 陌生人
	1: 0.0,     # 认识
	2: 20.0,    # 熟悉
	3: 50.0,    # 亲密
	4: 80.0,    # 挚友
}

## 关系值范围
const MIN_VALUE := -100.0
const MAX_VALUE := 100.0

#endregion

#region 私有变量

## 角色关系值存储 {character_id: float}
var _relationship_values: Dictionary = {}

## 关系等级缓存 {character_id: int}
var _relationship_tiers: Dictionary = {}

## 依赖的模块
var _f4_save_system: Node = null

#endregion

#region IModule接口实现

func get_module_info() -> Dictionary:
	return {
		"id": "c6_relationship_value_system",
		"name": "关系值系统",
		"version": "1.0.0",
		"dependencies": ["f4_save_system"],
		"optional_dependencies": ["c5_personality_variable_system"]
	}

func initialize(_config: Dictionary = {}) -> bool:
	print("[C6] Initializing Relationship Value System...")

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[C6] Cannot get App node")
		return false

	_f4_save_system = app.get_module("f4_save_system")
	_load_from_save()

	print("[C6] Relationship Value System initialized")
	return true

func start() -> bool:
	print("[C6] Starting Relationship Value System...")
	return true

func shutdown() -> void:
	print("[C6] Shutting down Relationship Value System...")

	# 保存关系值
	_save_to_save()

	# 清理数据
	_relationship_values.clear()
	_relationship_tiers.clear()

	print("[C6] Relationship Value System shut down")

#endregion

#region 公共API

## 获取角色的关系值
func get_relationship_value(character_id: String) -> float:
	return _relationship_values.get(character_id, 0.0)

## 获取角色的关系等级
func get_relationship_tier(character_id: String) -> int:
	if _relationship_tiers.has(character_id):
		return _relationship_tiers[character_id]

	# 计算并缓存等级
	var tier := _calculate_tier(get_relationship_value(character_id))
	_relationship_tiers[character_id] = tier
	return tier

## 修改关系值（增加或减少）
func modify_relationship(character_id: String, delta: float) -> void:
	var old_value := get_relationship_value(character_id)
	var new_value := clampf(old_value + delta, MIN_VALUE, MAX_VALUE)

	if abs(new_value - old_value) < 0.01:
		return  # 变化太小，忽略

	# 更新关系值
	_relationship_values[character_id] = new_value

	# 检查等级变化
	var old_tier := get_relationship_tier(character_id)
	var new_tier := _calculate_tier(new_value)

	if new_tier != old_tier:
		_relationship_tiers[character_id] = new_tier
		relationship_tier_changed.emit(character_id, old_tier, new_tier)

	# 触发关系值变化信号
	relationship_changed.emit(character_id, old_value, new_value, delta)

	# 保存到存档
	_save_to_save()

## 设置关系值（直接设置）
func set_relationship_value(character_id: String, value: float) -> void:
	var old_value := get_relationship_value(character_id)
	var delta := value - old_value
	modify_relationship(character_id, delta)

## 获取所有角色的关系值
func get_all_relationships() -> Dictionary:
	return _relationship_values.duplicate()

## 获取指定等级的所有角色
func get_characters_by_tier(tier: int) -> Array[String]:
	var result: Array[String] = []

	for character_id in _relationship_values.keys():
		if get_relationship_tier(character_id) == tier:
			result.append(character_id)

	return result

## 重置角色的关系值
func reset_relationship(character_id: String) -> void:
	if _relationship_values.has(character_id):
		modify_relationship(character_id, -get_relationship_value(character_id))

#endregion

#region 私有方法

## 根据关系值计算等级
func _calculate_tier(value: float) -> int:
	var tier := 0

	for threshold_tier in TIER_THRESHOLDS.keys():
		if value >= TIER_THRESHOLDS[threshold_tier]:
			tier = threshold_tier
		else:
			break

	return tier

## 从存档加载关系值
func _load_from_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("get_data"):
		return

	var saved_data = _f4_save_system.get_data("c6_relationships")
	if saved_data is Dictionary:
		_relationship_values = saved_data.duplicate()

		# 重新计算所有等级缓存
		_relationship_tiers.clear()
		for character_id in _relationship_values.keys():
			var tier := _calculate_tier(_relationship_values[character_id])
			_relationship_tiers[character_id] = tier

		print("[C6] Loaded %d relationships from save" % _relationship_values.size())

## 保存关系值到存档
func _save_to_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("set_data"):
		return

	_f4_save_system.set_data("c6_relationships", _relationship_values.duplicate())

#endregion
