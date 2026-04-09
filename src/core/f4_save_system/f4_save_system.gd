# core/f4_save_system/f4_save_system.gd
# F4 存档系统模块化版本
# 实现IModule接口，支持模块化架构
# 标准JSON方案，依赖F1窗口系统

class_name F4SaveSystem
extends Node

## IModule接口实现
var module_id: String = "f4_save_system"
var module_name: String = "存档系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f1_window_system"]  # 依赖F1保存窗口位置
var optional_dependencies: Array[String] = []  # 无可选依赖
var config_path: String = "res://data/config/f4_save_system.json"
var category: String = "core"
var priority: String = "high"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 存档文件路径 (user:// 目录跨平台兼容)
const SAVE_FILE_PATH: String = "user://save.json"
## 存档版本号 (格式版本，非游戏版本)
const SAVE_VERSION: int = 1
## 自动保存间隔 (秒)
const AUTO_SAVE_INTERVAL: float = 300.0  # 5分钟

## ==================== 系统状态 ====================

## 公共信号
signal save_completed(success: bool, key_count: int)
signal load_completed(success: bool, key_count: int)
signal auto_save_triggered()
signal save_file_corrupted(recovered: bool)

## 私有变量
var _save_data: Dictionary = {}
var _auto_save_timer: Timer = null
var _is_dirty: bool = false  # 数据是否已修改需要保存
var _save_in_progress: bool = false

## ==================== IModule接口方法 ====================

## IModule.initialize() 实现
func initialize(config: Dictionary = {}) -> bool:
	print("[F4] 初始化存档系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 加载存档数据
	var load_success = _load_from_disk()
	if not load_success:
		print("[F4] 警告: 存档加载失败，使用空存档")
		# 创建新的存档结构
		_create_empty_save_data()

	# 设置自动保存计时器
	_setup_auto_save_timer()

	status = IModule.ModuleStatus.INITIALIZED
	print("[F4] 存档系统初始化完成，加载 %d 个键值" % _save_data.size())
	return true

## IModule.start() 实现
func start() -> bool:
	print("[F4] 启动存档系统...")
	status = IModule.ModuleStatus.STARTING

	if _auto_save_timer:
		_auto_save_timer.start()
		print("[F4] 自动保存计时器已启动，间隔 %.1f 秒" % AUTO_SAVE_INTERVAL)

	status = IModule.ModuleStatus.RUNNING
	print("[F4] 存档系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[F4] 停止存档系统...")
	status = IModule.ModuleStatus.STOPPING

	# 停止自动保存计时器
	if _auto_save_timer and _auto_save_timer.is_inside_tree():
		_auto_save_timer.stop()

	# 保存所有未保存的更改
	if _is_dirty and not _save_in_progress:
		print("[F4] 停止前保存脏数据...")
		_save_to_disk()

	status = IModule.ModuleStatus.STOPPED
	print("[F4] 存档系统已停止")

## IModule.shutdown() 实现
func shutdown() -> void:
	print("[F4] 关闭存档系统...")

	# 确保最后保存
	if _is_dirty and not _save_in_progress:
		print("[F4] 关闭前保存脏数据...")
		_save_to_disk()

	# 清理资源
	if _auto_save_timer:
		_auto_save_timer.queue_free()
		_auto_save_timer = null

	_save_data.clear()
	_is_dirty = false

	status = IModule.ModuleStatus.SHUTDOWN
	print("[F4] 存档系统已关闭")

## IModule.reload_config() 实现
func reload_config(new_config: Dictionary = {}) -> bool:
	print("[F4] 重新加载配置")
	# TODO: 实现配置热重载（如AUTO_SAVE_INTERVAL调整）
	return true

## IModule.handle_error() 实现
func handle_error(error: Dictionary) -> bool:
	last_error = error
	status = IModule.ModuleStatus.ERROR
	push_error("[F4] 模块错误: %s" % error.get("message", "Unknown error"))
	return false

## IModule.health_check() 实现
func health_check() -> Dictionary:
	var issues: Array[String] = []

	if status != IModule.ModuleStatus.RUNNING:
		issues.append("模块未运行")

	if not _auto_save_timer:
		issues.append("自动保存计时器未初始化")

	# 检查存档文件是否可访问
	var test_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if test_file:
		test_file.close()
	else:
		issues.append("存档文件无法访问: %s" % SAVE_FILE_PATH)

	return {
		"healthy": issues.is_empty() and status == IModule.ModuleStatus.RUNNING,
		"issues": issues
	}

## ==================== 核心存档API ====================

## 保存单个键值
## @param key: 存档键 (建议使用 "模块名.键名" 格式，如 "f1.window_position")
## @param value: 要保存的值 (必须是Godot可JSON序列化的类型)
## @return: 保存成功返回true
func save(key: String, value: Variant) -> bool:
	if key.is_empty():
		push_error("[F4] 保存失败: 键为空")
		return false

	_save_data[key] = value
	_is_dirty = true

	# 立即写入磁盘
	var success = _save_to_disk()
	if success:
		print("[F4] 已保存键: %s" % key)
	else:
		push_error("[F4] 保存键失败: %s" % key)

	return success

## 读取单个键值
## @param key: 存档键
## @param default: 键不存在时返回的默认值
## @return: 键对应的值，不存在则返回default
func load(key: String, default: Variant = null) -> Variant:
	if key.is_empty():
		push_error("[F4] 加载失败: 键为空")
		return default

	if not _save_data.has(key):
		return default

	return _save_data[key]

## 批量保存多个键值
## @param data: 包含键值对的字典
## @return: 保存成功返回true
func save_batch(data: Dictionary) -> bool:
	if data.is_empty():
		push_error("[F4] 批量保存失败: 数据为空")
		return false

	for key in data.keys():
		_save_data[key] = data[key]

	_is_dirty = true
	var success = _save_to_disk()

	if success:
		print("[F4] 批量保存 %d 个键值" % data.size())
	else:
		push_error("[F4] 批量保存失败")

	return success

## 删除单个键
## @param key: 要删除的存档键
## @return: 删除成功返回true (键不存在也返回true)
func delete(key: String) -> bool:
	if key.is_empty():
		push_error("[F4] 删除失败: 键为空")
		return false

	var existed = _save_data.erase(key)
	if existed:
		_is_dirty = true
		_save_to_disk()
		print("[F4] 已删除键: %s" % key)

	return true

## 获取所有存档键
## @return: 所有存档键的数组
func get_all_keys() -> Array[String]:
	return _save_data.keys()

## 检查键是否存在
## @param key: 存档键
## @return: 键存在返回true
func has_key(key: String) -> bool:
	return _save_data.has(key)

## 获取存档统计信息
## @return: 包含存档信息的字典
func get_stats() -> Dictionary:
	var total_keys = _save_data.size()
	var core_keys = 0
	var module_keys = {}

	# 分析键的分布
	for key in _save_data.keys():
		if key.begins_with("_"):  # 元数据键
			continue
		elif "." in key:
			var module = key.split(".")[0]
			module_keys[module] = module_keys.get(module, 0) + 1
		else:
			core_keys += 1

	return {
		"total_keys": total_keys,
		"core_keys": core_keys,
		"module_keys": module_keys,
		"is_dirty": _is_dirty,
		"save_version": _get_save_version(),
		"last_saved": _get_last_saved_timestamp()
	}

## 手动触发保存 (用于测试或紧急保存)
## @return: 保存成功返回true
func manual_save() -> bool:
	print("[F4] 手动触发保存...")
	return _save_to_disk()

## ==================== 私有辅助方法 ====================

func _setup_auto_save_timer() -> void:
	_auto_save_timer = Timer.new()
	_auto_save_timer.name = "AutoSaveTimer"
	add_child(_auto_save_timer)
	_auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	_auto_save_timer.one_shot = false
	_auto_save_timer.timeout.connect(_on_auto_save_timeout)

func _on_auto_save_timeout() -> void:
	if _is_dirty and not _save_in_progress:
		print("[F4] 自动保存触发...")
		auto_save_triggered.emit()
		_save_to_disk()

func _create_empty_save_data() -> void:
	_save_data = {}
	_update_metadata()

func _update_metadata() -> void:
	if not _save_data.has("_meta"):
		_save_data["_meta"] = {}

	_save_data["_meta"]["save_version"] = SAVE_VERSION
	_save_data["_meta"]["last_saved"] = Time.get_unix_time_from_system()
	_save_data["_meta"]["created"] = _save_data["_meta"].get("created", Time.get_unix_time_from_system())

func _get_save_version() -> int:
	if _save_data.has("_meta"):
		return _save_data["_meta"].get("save_version", 0)
	return 0

func _get_last_saved_timestamp() -> int:
	if _save_data.has("_meta"):
		return _save_data["_meta"].get("last_saved", 0)
	return 0

func _load_from_disk() -> bool:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		# 文件不存在是正常情况 (首次运行)
		var error = FileAccess.get_open_error()
		if error == ERR_FILE_NOT_FOUND:
			print("[F4] 存档文件不存在 (首次运行): %s" % SAVE_FILE_PATH)
			return true  # 不是错误
		else:
			push_error("[F4] 无法打开存档文件 (错误 %d): %s" % [error, SAVE_FILE_PATH])
			return false

	var json_text = file.get_as_text()
	file.close()

	if json_text.is_empty():
		push_error("[F4] 存档文件为空: %s" % SAVE_FILE_PATH)
		return false

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("[F4] 存档文件JSON解析失败 (错误 %d): %s" % [parse_result, json.get_error_message()])
		# 尝试恢复或创建新存档
		save_file_corrupted.emit(false)
		return false

	var loaded_data = json.get_data()
	if not loaded_data is Dictionary:
		push_error("[F4] 存档数据不是字典类型")
		return false

	_save_data = loaded_data
	_is_dirty = false

	# 验证和更新元数据
	_validate_and_upgrade_save_data()

	print("[F4] 存档加载成功: %s (%d 键值)" % [SAVE_FILE_PATH, _save_data.size()])
	save_file_corrupted.emit(true)
	return true

func _save_to_disk() -> bool:
	if _save_in_progress:
		push_error("[F4] 保存进行中，跳过重复保存")
		return false

	_save_in_progress = true

	# 更新元数据
	_update_metadata()

	# 转换为JSON
	var json = JSON.stringify(_save_data, "\t")
	if json.is_empty():
		push_error("[F4] JSON序列化失败")
		_save_in_progress = false
		return false

	# 写入文件
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("[F4] 无法写入存档文件 (错误 %d): %s" % [error, SAVE_FILE_PATH])
		_save_in_progress = false
		return false

	file.store_string(json)
	file.close()

	_is_dirty = false
	_save_in_progress = false

	print("[F4] 存档保存成功: %s (%d 键值)" % [SAVE_FILE_PATH, _save_data.size()])
	save_completed.emit(true, _save_data.size())
	return true

func _validate_and_upgrade_save_data() -> void:
	# 确保元数据存在
	if not _save_data.has("_meta"):
		_save_data["_meta"] = {}

	var meta = _save_data["_meta"]
	var current_version = meta.get("save_version", 0)

	# 版本迁移逻辑
	if current_version < SAVE_VERSION:
		print("[F4] 存档版本升级: %d -> %d" % [current_version, SAVE_VERSION])
		# TODO: 实现版本迁移逻辑
		meta["save_version"] = SAVE_VERSION
		meta["migrated_from"] = current_version
		_is_dirty = true

	# 确保必要字段存在
	if not meta.has("created"):
		meta["created"] = Time.get_unix_time_from_system()
		_is_dirty = true

	if not meta.has("last_saved"):
		meta["last_saved"] = Time.get_unix_time_from_system()
		_is_dirty = true

## ==================== 调试工具 ====================

## 打印存档内容摘要 (用于调试)
func print_save_summary() -> void:
	var stats = get_stats()
	print("[F4] 存档摘要:")
	print("  版本: %d" % stats["save_version"])
	print("  总键值: %d" % stats["total_keys"])
	print("  核心键: %d" % stats["core_keys"])
	print("  最后保存: %d" % stats["last_saved"])
	print("  脏数据: %s" % ("是" if stats["is_dirty"] else "否"))

	for module in stats["module_keys"].keys():
		print("  %s: %d 键值" % [module, stats["module_keys"][module]])

## 清空存档 (危险！仅用于测试)
func clear_save_for_testing() -> void:
	print("[F4] 警告: 清空存档数据 (测试模式)")
	_save_data.clear()
	_create_empty_save_data()
	_save_to_disk()
	print("[F4] 存档已清空")