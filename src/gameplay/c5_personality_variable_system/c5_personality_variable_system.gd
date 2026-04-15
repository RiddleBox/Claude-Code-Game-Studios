# gameplay/c5_personality_variable_system/c5_personality_variable_system.gd
# C5 — 性格变量系统（Personality Variable System）
# 角色「内在自我」的数学表示
# 实现 IModule 接口，支持模块化架构

class_name C5PersonalityVariableSystem
extends Node

## IModule 接口实现
var module_id: String = "c5_personality_variable_system"
var module_name: String = "性格变量系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f4_save_system"]
var optional_dependencies: Array[String] = []
var config_path: String = "res://data/config/c5_personality_variable_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 单次 shift 最大 delta
const MAX_SHIFT_PER_CALL: float = 0.05

## 存档键名
const SAVE_KEY_PERSONALITY: String = "c5.personality"

## 轴定义配置路径
const AXES_CONFIG_PATH: String = "res://data/config/personality_axes.json"

## ==================== 信号 ====================

## 性格变化时触发
signal personality_shifted(axis_id: String, old_val: float, new_val: float, delta: float)

## ==================== 私有变量 ====================

## F4 存档系统引用
var _f4_save: Node = null

## 性格状态：{axis_id: float}
var _personality: Dictionary = {}

## 轴元数据：[{id, low_label, high_label, default, display_name}]
var _axes_meta: Array = []

## ==================== 硬编码默认轴定义（配置文件缺失时使用） ====================

var _default_axes_meta: Array = [
	{
		"id": "curiosity",
		"low_label": "淡漠",
		"high_label": "好奇",
		"default": 0.5,
		"display_name": "好奇心"
	},
	{
		"id": "warmth",
		"low_label": "冷静",
		"high_label": "温暖",
		"default": 0.5,
		"display_name": "温度"
	},
	{
		"id": "boldness",
		"low_label": "谨慎",
		"high_label": "大胆",
		"default": 0.5,
		"display_name": "胆量"
	},
	{
		"id": "melancholy",
		"low_label": "乐观",
		"high_label": "忧郁",
		"default": 0.5,
		"display_name": "情绪底色"
	}
]

## ==================== IModule 接口方法 ====================

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[C5] 初始化性格变量系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[C5] 无法获取 App 节点")
		return false

	_f4_save = app.get_module("f4_save_system")
	if not _f4_save:
		push_error("[C5] 无法获取 F4 存档系统模块")
		return false

	# 1. 加载轴定义
	_load_axes_config()

	# 2. 从 F4 加载性格状态
	_load_from_save()

	status = IModule.ModuleStatus.INITIALIZED
	print("[C5] 性格变量系统初始化完成，%d 条轴已加载" % _axes_meta.size())
	return true

## IModule.start() 实现
func start() -> bool:
	print("[C5] 启动性格变量系统...")
	status = IModule.ModuleStatus.STARTING

	status = IModule.ModuleStatus.RUNNING
	print("[C5] 性格变量系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[C5] 停止性格变量系统...")
	status = IModule.ModuleStatus.STOPPING

	# 保存到 F4
	_save_to_save()

	status = IModule.ModuleStatus.STOPPED
	print("[C5] 性格变量系统已停止")

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
		"axis_count": _axes_meta.size(),
		"personality": _personality.duplicate()
	}

## IModule.is_healthy() 实现
func is_healthy() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.get_last_error() 实现
func get_last_error() -> Dictionary:
	return last_error

## ==================== 公共 API ====================

## 读取单轴值
func get_axis(axis_id: String) -> float:
	if not _personality.has(axis_id):
		push_warning("[C5] 轴不存在: %s" % axis_id)
		return 0.5
	return _personality[axis_id]

## 读取全部轴值（返回副本，禁止直接修改）
func get_all() -> Dictionary:
	return _personality.duplicate()

## 内容评分：传入内容条目的 personality_weights 字典，返回匹配分
func score_content(weights: Dictionary) -> float:
	var score: float = 0.0
	for axis_id in weights:
		if _personality.has(axis_id):
			var weight: float = weights[axis_id]
			score += _personality[axis_id] * weight
	return score

## 性格变化（唯一写入入口）
func shift(axis_id: String, delta: float) -> void:
	if not _personality.has(axis_id):
		push_warning("[C5] shift 失败：轴不存在 %s" % axis_id)
		return

	# 截断 delta 防止跳变
	var actual_delta: float = delta
	if abs(actual_delta) > MAX_SHIFT_PER_CALL:
		push_warning("[C5] shift delta 超过上限 %.4f，已截断" % MAX_SHIFT_PER_CALL)
		actual_delta = MAX_SHIFT_PER_CALL if delta > 0 else -MAX_SHIFT_PER_CALL

	var old_val: float = _personality[axis_id]
	var new_val: float = clamp(old_val + actual_delta, 0.0, 1.0)

	# 保留4位小数
	new_val = float(round(new_val * 10000.0)) / 10000.0

	if new_val != old_val:
		_personality[axis_id] = new_val
		_save_to_save()
		personality_shifted.emit(axis_id, old_val, new_val, actual_delta)
		print("[C5] 性格变化: %s %.4f -> %.4f (delta: %.4f)" % [axis_id, old_val, new_val, actual_delta])

## 展示用软标签（仅供 UI 使用）
func get_display_label() -> String:
	var max_deviation: float = 0.0
	var label: String = "平静"

	for axis_id in _personality:
		var val: float = _personality[axis_id]
		var deviation: float = abs(val - 0.5)
		if deviation > max_deviation:
			max_deviation = deviation
			var meta: Dictionary = _get_axis_meta(axis_id)
			if meta:
				label = meta.high_label if val > 0.5 else meta.low_label

	return label

## 获取所有轴元数据
func get_all_axes_meta() -> Array:
	return _axes_meta.duplicate()

## ==================== 私有方法 ====================

## 加载轴定义配置
func _load_axes_config() -> void:
	_axes_meta = []

	if FileAccess.file_exists(AXES_CONFIG_PATH):
		var file = FileAccess.open(AXES_CONFIG_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_ARRAY:
				_axes_meta = parsed.duplicate()
				print("[C5] 从配置文件加载了 %d 条轴定义" % _axes_meta.size())
				_initialize_personality_defaults()
				return

	# 配置文件缺失或格式错误，使用硬编码默认值
	push_warning("[C5] 轴配置文件缺失或格式错误，使用硬编码默认值")
	_axes_meta = _default_axes_meta.duplicate()
	_initialize_personality_defaults()

## 用轴定义的默认值初始化性格状态
func _initialize_personality_defaults() -> void:
	for axis in _axes_meta:
		var axis_id: String = axis.get("id", "")
		var default_val: float = axis.get("default", 0.5)
		if not axis_id.is_empty():
			_personality[axis_id] = default_val

## 从 F4 加载数据
func _load_from_save() -> void:
	if not _f4_save:
		return

	var saved_personality = _f4_save.load(SAVE_KEY_PERSONALITY, {})
	if typeof(saved_personality) == TYPE_DICTIONARY:
		# 合并存档数据，处理兼容性
		for axis_id in saved_personality:
			if _personality.has(axis_id):
				var val: float = saved_personality[axis_id]
				# 修正超出范围的值
				if val < 0.0 or val > 1.0:
					push_warning("[C5] 存档值 %.4f 超出范围，已修正" % val)
					val = clamp(val, 0.0, 1.0)
				_personality[axis_id] = val
			# 存档中有但配置中已删除的轴，静默忽略
	else:
		push_warning("[C5] 存档数据格式错误，使用默认值")

	print("[C5] 从存档加载了性格状态")

## 保存到 F4
func _save_to_save() -> void:
	if not _f4_save:
		return

	_f4_save.save(SAVE_KEY_PERSONALITY, _personality.duplicate())

## 获取轴元数据
func _get_axis_meta(axis_id: String) -> Dictionary:
	for axis in _axes_meta:
		if axis.get("id", "") == axis_id:
			return axis
	return {}
