extends Node

## Fe4 共鸣成长系统
## 负责玩家与角色的共鸣度积累和成长解锁

# ModuleLoader required properties
var module_id: String = ""
var dependencies: Array[String] = []
var optional_dependencies: Array[String] = []

#region 信号定义

## 共鸣度变化时触发
signal resonance_changed(character_id: String, old_value: float, new_value: float, delta: float)

## 共鸣等级变化时触发
signal resonance_tier_changed(character_id: String, old_tier: int, new_tier: int)

## 成就解锁时触发
signal achievement_unlocked(achievement_id: String, achievement_name: String)

#endregion

#region 常量定义

## 共鸣等级阈值
const TIER_THRESHOLDS := {
	0: 0.0,     # 初识
	1: 10.0,    # 熟悉
	2: 30.0,    # 默契
	3: 60.0,    # 知音
	4: 100.0    # 灵魂伴侣
}

## 共鸣度范围
const MIN_RESONANCE := 0.0
const MAX_RESONANCE := 150.0

## 每日互动衰减
const DAILY_DECAY := 0.5

#endregion

#region 私有变量

## 角色共鸣度存储 {character_id: float}
var _resonance_values: Dictionary = {}

## 共鸣等级缓存 {character_id: int}
var _resonance_tiers: Dictionary = {}

## 成就列表 {achievement_id: Dictionary}
var _achievements: Dictionary = {}

## 已解锁成就 {achievement_id: bool}
var _unlocked_achievements: Dictionary = {}

## 依赖的模块
var _f4_save_system: Node = null
var _f3_time_system: Node = null

#endregion

#region IModule接口实现

func get_module_info() -> Dictionary:
	return {
		"id": "fe4_resonance_growth_system",
		"name": "共鸣成长系统",
		"version": "1.0.0",
		"dependencies": ["f4_save_system"],
		"optional_dependencies": ["f3_time_system", "c6_relationship_value_system"]
	}

func initialize(_config: Dictionary = {}) -> bool:
	print("[Fe4] Initializing Resonance Growth System...")

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[Fe4] Cannot get App node")
		return false

	_f4_save_system = app.get_module("f4_save_system")
	if not _f4_save_system:
		push_error("[Fe4] Required dependency f4_save_system not found")
		return false

	_f3_time_system = app.get_module("f3_time_system")
	_load_from_save()

	print("[Fe4] Resonance Growth System initialized")
	return true

func start() -> bool:
	print("[Fe4] Starting Resonance Growth System...")
	return true

func shutdown() -> void:
	print("[Fe4] Shutting down Resonance Growth System...")

	# 保存数据
	_save_to_save()

	# 清理数据
	_resonance_values.clear()
	_resonance_tiers.clear()

	print("[Fe4] Resonance Growth System shut down")

#endregion

#region 公共API

## 获取角色的共鸣度
func get_resonance_value(character_id: String) -> float:
	return _resonance_values.get(character_id, 0.0)

## 获取角色的共鸣等级
func get_resonance_tier(character_id: String) -> int:
	if _resonance_tiers.has(character_id):
		return _resonance_tiers[character_id]

	# 计算并缓存等级
	var tier := _calculate_tier(get_resonance_value(character_id))
	_resonance_tiers[character_id] = tier
	return tier

## 修改共鸣度（增加或减少）
func modify_resonance(character_id: String, delta: float) -> void:
	var old_value := get_resonance_value(character_id)
	var new_value := clampf(old_value + delta, MIN_RESONANCE, MAX_RESONANCE)

	if abs(new_value - old_value) < 0.01:
		return  # 变化太小，忽略

	# 更新共鸣度
	_resonance_values[character_id] = new_value

	# 检查等级变化
	var old_tier := get_resonance_tier(character_id)
	var new_tier := _calculate_tier(new_value)

	if new_tier != old_tier:
		_resonance_tiers[character_id] = new_tier
		resonance_tier_changed.emit(character_id, old_tier, new_tier)

	# 触发共鸣度变化信号
	resonance_changed.emit(character_id, old_value, new_value, delta)

	# 检查成就
	_check_achievements(character_id)

	# 保存到存档
	_save_to_save()

## 设置共鸣度（直接设置）
func set_resonance_value(character_id: String, value: float) -> void:
	var old_value := get_resonance_value(character_id)
	var delta := value - old_value
	modify_resonance(character_id, delta)

## 获取所有角色的共鸣度
func get_all_resonance() -> Dictionary:
	return _resonance_values.duplicate()

## 获取成就列表
func get_all_achievements() -> Dictionary:
	return _achievements.duplicate()

## 检查成就是否已解锁
func is_achievement_unlocked(achievement_id: String) -> bool:
	return _unlocked_achievements.get(achievement_id, false)

## 解锁成就
func unlock_achievement(achievement_id: String) -> bool:
	if not _achievements.has(achievement_id) or _unlocked_achievements.get(achievement_id, false):
		return false

	_unlocked_achievements[achievement_id] = true
	var achievement: Dictionary = _achievements[achievement_id]
	achievement_unlocked.emit(achievement_id, achievement.get("name", achievement_id))
	_save_to_save()
	return true

#endregion

#region 私有方法

## 根据共鸣度计算等级
func _calculate_tier(value: float) -> int:
	var tier := 0

	for threshold_tier in TIER_THRESHOLDS.keys():
		if value >= TIER_THRESHOLDS[threshold_tier]:
			tier = threshold_tier
		else:
			break

	return tier

## 初始化成就列表
func _init_achievements() -> void:
	_achievements = {
		"first_chat": {
			"id": "first_chat",
			"name": "初次对话",
			"description": "与Aria进行第一次对话",
			"icon": ""
		},
		"resonance_tier_1": {
			"id": "resonance_tier_1",
			"name": "熟悉",
			"description": "达到共鸣等级1",
			"icon": ""
		},
		"resonance_tier_4": {
			"id": "resonance_tier_4",
			"name": "灵魂伴侣",
			"description": "达到最高共鸣等级",
			"icon": ""
		}
	}

## 检查成就解锁条件
func _check_achievements(character_id: String) -> void:
	var resonance := get_resonance_value(character_id)
	var tier := get_resonance_tier(character_id)

	# 检查等级成就
	if tier >= 1 and not is_achievement_unlocked("resonance_tier_1"):
		unlock_achievement("resonance_tier_1")

	if tier >= 4 and not is_achievement_unlocked("resonance_tier_4"):
		unlock_achievement("resonance_tier_4")

## 从存档加载
func _load_from_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("get_data"):
		return

	var saved_resonance = _f4_save_system.get_data("fe4.resonance")
	if saved_resonance is Dictionary:
		_resonance_values = saved_resonance.duplicate()

		# 重新计算所有等级缓存
		_resonance_tiers.clear()
		for character_id in _resonance_values.keys():
			var tier := _calculate_tier(_resonance_values[character_id])
			_resonance_tiers[character_id] = tier

	var saved_achievements = _f4_save_system.get_data("fe4.achievements")
	if saved_achievements is Dictionary:
		_unlocked_achievements = saved_achievements.duplicate()

	print("[Fe4] Loaded %d resonance values from save" % _resonance_values.size())

## 保存到存档
func _save_to_save() -> void:
	if not _f4_save_system or not _f4_save_system.has_method("set_data"):
		return

	_f4_save_system.set_data("fe4.resonance", _resonance_values.duplicate())
	_f4_save_system.set_data("fe4.achievements", _unlocked_achievements.duplicate())

#endregion
