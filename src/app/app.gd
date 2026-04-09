# app/app.gd
# 主应用控制器
# 负责应用启动、模块管理和生命周期控制

class_name App
extends Node

## 应用状态信号
signal app_initialized(success: bool)
signal app_started(success: bool)
signal app_stopping()
signal app_shutdown()

## 模块加载器实例
var _module_loader: ModuleLoader

## 应用配置
var _config: Dictionary = {}

## 应用状态
enum AppStatus {
	BOOTING,      # 启动中
	INITIALIZING, # 初始化中
	RUNNING,      # 运行中
	STOPPING,     # 停止中
	SHUTDOWN      # 已关闭
}

var status: AppStatus = AppStatus.BOOTING

## 启动时间
var _startup_time: int = 0

## 测试相关
var _test_runner: Node = null

## 应用初始化
func _ready() -> void:
	_startup_time = Time.get_ticks_msec()
	print("[App] 窗语应用启动中...")
	print("[App] Godot版本: %s" % Engine.get_version_info()["string"])
	print("[App] 平台: %s" % OS.get_name())

	# 设置应用基本属性
	_setup_application()

	# 初始化模块加载器
	_initialize_module_loader()

	# 加载应用配置
	_load_config()

	# 注册核心模块
	_register_core_modules()

	# 初始化所有模块
	_initialize_modules()

## 设置应用基本属性
func _setup_application() -> void:
	# 设置进程模式
	Engine.max_fps = 60
	print("[App] 目标帧率: %d FPS" % Engine.max_fps)

	# 设置错误处理
	# 注意: 在Godot中，错误处理主要通过打印和信号
	# 这里可以添加自定义错误处理器

## 初始化模块加载器
func _initialize_module_loader() -> void:
	_module_loader = ModuleLoader.new()
	add_child(_module_loader)

	# 连接模块加载器信号
	_module_loader.module_registered.connect(_on_module_registered)
	_module_loader.module_initialized.connect(_on_module_initialized)
	_module_loader.module_started.connect(_on_module_started)
	_module_loader.module_error.connect(_on_module_error)
	_module_loader.all_modules_initialized.connect(_on_all_modules_initialized)
	_module_loader.all_modules_started.connect(_on_all_modules_started)

	print("[App] 模块加载器已初始化")

## 加载应用配置
func _load_config() -> bool:
	var config_path = "res://data/config/app.json"
	if not FileAccess.file_exists(config_path):
		print("[App] 应用配置文件不存在: %s" % config_path)
		_config = _get_default_config()
		return true

	var file = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("[App] 无法打开配置文件: %s" % config_path)
		_config = _get_default_config()
		return false

	var content = file.get_as_text()
	file.close()

	var parsed_config = JSON.parse_string(content)
	if parsed_config == null:
		push_error("[App] 配置文件JSON格式错误: %s" % config_path)
		_config = _get_default_config()
		return false

	_config = parsed_config
	print("[App] 应用配置已加载")
	return true

## 获取默认配置
func _get_default_config() -> Dictionary:
	return {
		"app": {
			"name": "窗语",
			"version": "0.1.0",
			"debug": true,
			"log_level": "info"
		},
		"modules": {
			"async_initialization": false,
			"error_recovery": true,
			"auto_reload": false
		},
		"performance": {
			"target_fps": 60,
			"memory_warning_threshold_mb": 512
		}
	}

## 注册核心模块
func _register_core_modules() -> void:
	print("[App] 注册核心模块...")

	# F1: 桌面窗口系统 (最高优先级)
	_register_f1_window_system()

	# F2: 角色状态机 (高优先级，依赖F1)
	_register_f2_state_machine()

	# F3: 时间/节奏系统 (中等优先级，可选依赖F4)
	_register_f3_time_system()

	# UI: UI框架 (中等优先级，依赖F1)
	_register_ui_framework()

	# 其他模块将在后续阶段注册

## 注册F1窗口系统
func _register_f1_window_system() -> void:
	# 从场景文件加载，确保 CharacterSprite 子节点正确实例化
	var scene = load("res://src/core/f1_window_system/f1_window_system.tscn")
	if not scene:
		push_error("[App] 无法加载F1窗口系统场景")
		return
	var instance = scene.instantiate()
	if not instance:
		push_error("[App] 无法实例化F1窗口系统场景")
		return

	var config = _config.get("f1_window_system", {})
	var success = _module_loader.register_module_instance(
		"f1_window_system",
		instance,
		config,
		[],  # 无依赖
		[],  # 无可选依赖
		100  # 最高优先级
	)

	if success:
		print("[App] F1窗口系统已注册")
	else:
		push_error("[App] F1窗口系统注册失败")

## 注册F2状态机
func _register_f2_state_machine() -> void:
	var module_class = load("res://src/core/f2_state_machine/f2_state_machine.gd")
	if not module_class:
		push_error("[App] 无法加载F2状态机模块类")
		return

	var config = _config.get("f2_state_machine", {})
	var success = _module_loader.register_module(
		"f2_state_machine",
		module_class,
		config,
		["f1_window_system"],  # 依赖F1
		[],  # 无可选依赖
		90   # 高优先级
	)

	if success:
		print("[App] F2状态机已注册")
	else:
		push_error("[App] F2状态机注册失败")

## 初始化所有模块
func _initialize_modules() -> void:
	print("[App] 初始化所有模块...")
	status = AppStatus.INITIALIZING

	var async = _config.get("modules", {}).get("async_initialization", false)
	var success = _module_loader.initialize_all_modules(async)

	if success:
		print("[App] 所有模块初始化成功")
	else:
		push_error("[App] 模块初始化失败")
		# 即使部分模块失败，仍尝试启动应用
		# 错误恢复机制将处理失败模块

	# 启动所有模块
	_start_modules()

## 启动所有模块
func _start_modules() -> void:
	print("[App] 启动所有模块...")

	var success = _module_loader.start_all_modules()

	if success:
		status = AppStatus.RUNNING
		var startup_time = Time.get_ticks_msec() - _startup_time
		print("[App] 应用启动完成，耗时: %d ms" % startup_time)
		app_started.emit(true)

		# Sprint 1 验证：自动运行集成测试
		print("[App] Sprint 1 验证 - 开始集成测试...")
		call_deferred("run_integration_tests")
	else:
		push_error("[App] 模块启动失败")
		# 即使部分模块失败，应用仍可运行
		status = AppStatus.RUNNING
		app_started.emit(false)

		# Sprint 1 验证：仍然尝试运行集成测试
		print("[App] Sprint 1 验证 - 模块启动有错误，仍然尝试集成测试...")
		call_deferred("run_integration_tests")

## 应用停止
func stop() -> void:
	if status == AppStatus.STOPPING or status == AppStatus.SHUTDOWN:
		return

	print("[App] 停止应用中...")
	status = AppStatus.STOPPING
	app_stopping.emit()

	# 停止所有模块
	_module_loader.stop_all_modules()

	status = AppStatus.SHUTDOWN
	print("[App] 应用已停止")

## 应用关闭
func shutdown() -> void:
	if status == AppStatus.SHUTDOWN:
		return

	print("[App] 关闭应用中...")

	# 关闭所有模块
	_module_loader.shutdown_all_modules()

	# 清理资源
	_config.clear()

	status = AppStatus.SHUTDOWN
	print("[App] 应用已关闭")
	app_shutdown.emit()

## 应用退出处理
func _exit_tree() -> void:
	print("[App] 应用退出中...")
	shutdown()

## 获取模块加载器
func get_module_loader() -> ModuleLoader:
	return _module_loader

## 获取模块实例
func get_module(module_id: String) -> Node:
	return _module_loader.get_module(module_id)

## 检查模块是否就绪
func is_module_ready(module_id: String) -> bool:
	return _module_loader.is_module_ready(module_id)

## 获取应用状态报告
func get_status_report() -> Dictionary:
	var module_status = _module_loader.get_all_module_status()
	var running_modules = 0
	var error_modules = 0

	for module_id in module_status.keys():
		var status = module_status[module_id].get("status", IModule.ModuleStatus.UNINITIALIZED)
		if status == IModule.ModuleStatus.RUNNING:
			running_modules += 1
		elif status == IModule.ModuleStatus.ERROR:
			error_modules += 1

	return {
		"app": {
			"status": status,
			"uptime": Time.get_ticks_msec() - _startup_time,
			"version": _config.get("app", {}).get("version", "0.1.0")
		},
		"modules": {
			"total": module_status.size(),
			"running": running_modules,
			"errors": error_modules,
			"details": module_status
		},
		"performance": {
			"fps": Engine.get_frames_per_second(),
			"memory_used_mb": OS.get_static_memory_usage() / (1024.0 * 1024.0)
		}
	}

## 重新加载模块
func reload_module(module_id: String, new_config: Dictionary = {}) -> bool:
	print("[App] 重新加载模块: %s" % module_id)
	return _module_loader.reload_module(module_id, new_config)

## 模块事件处理
func _on_module_registered(module_id: String, module_name: String) -> void:
	print("[App] 模块注册: %s (%s)" % [module_id, module_name])

func _on_module_initialized(module_id: String, success: bool) -> void:
	if success:
		print("[App] 模块初始化成功: %s" % module_id)
	else:
		push_error("[App] 模块初始化失败: %s" % module_id)

func _on_module_started(module_id: String, success: bool) -> void:
	if success:
		print("[App] 模块启动成功: %s" % module_id)
	else:
		push_error("[App] 模块启动失败: %s" % module_id)

func _on_module_error(module_id: String, error: Dictionary) -> void:
	push_error("[App] 模块错误: %s - %s" % [module_id, error.get("message", "Unknown error")])

func _on_all_modules_initialized(success: bool) -> void:
	if success:
		print("[App] 所有模块初始化完成")
	else:
		push_error("[App] 模块初始化完成（有错误）")
	app_initialized.emit(success)

func _on_all_modules_started(success: bool) -> void:
	if success:
		print("[App] 所有模块启动完成")
	else:
		push_error("[App] 模块启动完成（有错误）")

## 调试工具：打印依赖图
func print_dependency_graph() -> void:
	var dot = _module_loader.get_dependency_graph_viz()
	print("[App] 依赖关系图:")
	print(dot)

## 调试工具：打印状态报告
func print_status_report() -> void:
	var report = get_status_report()
	print("[App] 状态报告:")
	print(JSON.stringify(report, "\t"))

## 注册F3时间系统
func _register_f3_time_system() -> void:
	var module_class = load("res://src/core/f3_time_system/f3_time_system.gd")
	if not module_class:
		push_error("[App] 无法加载F3时间系统模块类")
		return

	var config = _config.get("f3_time_system", {})
	var success = _module_loader.register_module(
		"f3_time_system",
		module_class,
		config,
		[],  # 原设计依赖F4，简化版为空依赖
		["f4_save_system"],  # 可选依赖F4
		80   # 中等优先级
	)

	if success:
		print("[App] F3时间系统已注册")
	else:
		push_error("[App] F3时间系统注册失败")

## 注册UI框架
func _register_ui_framework() -> void:
	var module_class = load("res://src/ui/ui_module.gd")
	if not module_class:
		push_error("[App] 无法加载UI框架模块类")
		return

	var config = _config.get("ui_framework", {})
	var success = _module_loader.register_module(
		"ui_framework",
		module_class,
		config,
		["f1_window_system"],  # 依赖F1窗口系统
		[],  # 无可选依赖
		70   # 中等优先级
	)

	if success:
		print("[App] UI框架已注册")
	else:
		push_error("[App] UI框架注册失败")

## 注册F4存档系统
func _register_f4_save_system() -> void:
	var module_class = load("res://src/core/f4_save_system/f4_save_system.gd")
	if not module_class:
		push_error("[App] 无法加载F4存档系统模块类")
		return

	var config = _config.get("f4_save_system", {})
	var success = _module_loader.register_module(
		"f4_save_system",
		module_class,
		config,
		["f1_window_system"],  # 依赖F1窗口系统
		[],  # 无可选依赖
		85   # 高优先级，介于F2(90)和F3(80)之间
	)

	if success:
		print("[App] F4存档系统已注册")
	else:
		push_error("[App] F4存档系统注册失败")

## 集成测试功能

## 运行集成测试
func run_integration_tests() -> void:
	print("[App] 开始运行集成测试...")

	if status != AppStatus.RUNNING:
		print("[App] 警告: 应用未处于运行状态，测试可能不准确")
		print("[App] 当前状态: %s" % AppStatus.keys()[status])

	# 清理之前的测试运行器
	_cleanup_test_runner()

	# 加载测试场景
	var test_scene_path = "res://tests/integration/sprint1_test.tscn"
	var test_scene = load(test_scene_path)
	if not test_scene:
		push_error("[App] 无法加载测试场景: %s" % test_scene_path)
		return

	# 实例化测试运行器
	_test_runner = test_scene.instantiate()
	if not _test_runner:
		push_error("[App] 无法实例化测试场景")
		return

	# 添加到场景树
	add_child(_test_runner)
	print("[App] 测试运行器已启动")
	print("[App] 测试结果将在控制台输出")

## 清理测试运行器
func _cleanup_test_runner() -> void:
	if _test_runner and _test_runner.is_inside_tree():
		_test_runner.queue_free()
		_test_runner = null
		print("[App] 测试运行器已清理")