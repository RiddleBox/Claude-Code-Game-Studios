# app/app.gd
# 主应用控制器
# 负责应用启动、模块管理和生命周期控制

class_name App
extends Node

## 全局事件
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

## 初始化
func _init() -> void:
	_startup_time = Time.get_ticks_msec()
	print("[App] 应用初始化中...")

func _ready() -> void:
	# 1. 加载配置
	_load_config()

	# 2. 初始化模块加载器
	_module_loader = ModuleLoader.new()
	add_child(_module_loader)

	# 3. 注册所有模块
	_register_core_modules()
	_register_gameplay_modules()
	_register_feature_modules()

	# 4. 初始化所有模块
	_initialize_modules()

	# 5. 启动所有模块
	_start_modules()

## 加载配置
func _load_config() -> void:
	var config_path = "res://data/config/app.json"
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			_config = JSON.parse_string(content)
			print("[App] 配置文件加载成功")
			return

	print("[App] 无配置文件，使用默认配置")
	_config = {}

## 注册核心模块
func _register_core_modules() -> void:
	# F1: 窗口系统
	_register_f1_window_system()
	# F2: 状态机
	_register_f2_state_machine()
	# F3: 时间系统
	_register_f3_time_system()
	# F4: 存档系统
	_register_f4_save_system()
	# UI框架
	_register_ui_framework()

## 注册游戏逻辑模块
func _register_gameplay_modules() -> void:
	# C1: 角色动画系统 (中等优先级，依赖F2)
	_register_c1_animation_system()
	_register_c2_outing_return_cycle()

## 注册功能模块
func _register_feature_modules() -> void:
	# Fe1: 对话系统
	_register_fe1_dialogue_system()
	# Fe2: 记忆系统
	_register_fe2_memory_system()
	# Fe3: 好感度系统
	_register_fe3_affinity_system()
	# Fe5: 音频系统
	_register_fe5_audio_system()
	# P1: 主UI系统
	_register_p1_main_ui()

## 注册F1窗口系统
func _register_f1_window_system() -> void:
	# 从场景文件加载，确保CharacterSprite子节点正确实例化
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
		[], # 无依赖
		[], # 无可选依赖
		100 # 最高优先级
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
		["f1_window_system"], # 依赖F1
		[], # 无可选依赖
		90 # 高优先级
	)

	if success:
		print("[App] F2状态机已注册")
	else:
		push_error("[App] F2状态机注册失败")

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
		[], # 无依赖
		[], # 无可选依赖
		85 # 高优先级
	)

	if success:
		print("[App] F3时间系统已注册")
	else:
		push_error("[App] F3时间系统注册失败")

## 注册F4存档系统
func _register_f4_save_system() -> void:
	var module_class = load("res://src/core/f4_save_system/f4_save_system.gd")
	if not module_class:
		push_error("[App] 无法加载F4存档系统模块类")
		return

	var instance = module_class.new()
	if not instance:
		push_error("[App] 无法实例化F4存档系统")
		return

	var config = _config.get("f4_save_system", {})
	var success = _module_loader.register_module_instance(
		"f4_save_system",
		instance,
		config,
		["f1_window_system"], # 依赖F1窗口系统
		[], # 无可选依赖
		85 # 高优先级，介于F2(90)和F3(80)之间
	)

	if success:
		print("[App] F4存档系统已注册")
	else:
		push_error("[App] F4存档系统注册失败")

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
		["f1_window_system"], # 依赖F1窗口系统
		[], # 无可选依赖
		70 # 中等优先级
	)

	if success:
		print("[App] UI框架已注册")
	else:
		push_error("[App] UI框架注册失败")

## 注册C1角色动画系统
func _register_c1_animation_system() -> void:
	var module_class = load("res://src/gameplay/c1_character_animation_system/c1_character_animation_system.gd")
	if not module_class:
		push_error("[App] 无法加载C1角色动画系统模块类")
		return

	var config = _config.get("c1_character_animation_system", {})
	var success = _module_loader.register_module(
		"c1_character_animation_system",
		module_class,
		config,
		["f2_state_machine"], # 依赖F2状态机
		[], # 无可选依赖
		60 # 中等优先级
	)

	if success:
		print("[App] C1角色动画系统已注册")
	else:
		push_error("[App] C1角色动画系统注册失败")

## 注册C2外出返回循环系统
func _register_c2_outing_return_cycle() -> void:
	var module_class = load("res://src/gameplay/c2_outing_return_cycle/c2_outing_return_cycle.gd")
	if not module_class:
		push_error("[App] 无法加载C2外出返回循环系统模块类")
		return

	var config = _config.get("c2_outing_return_cycle", {})
	var success = _module_loader.register_module(
		"c2_outing_return_cycle",
		module_class,
		config,
		["f2_state_machine", "f3_time_system", "f4_save_system"], # 依赖F2状态机、F3时间系统、F4存档系统
		[], # 无可选依赖
		55 # 中等优先级，略低于C1(60)
	)

	if success:
		print("[App] C2外出返回循环系统已注册")
	else:
		push_error("[App] C2外出返回循环系统注册失败")

## 注册Fe1对话系统
func _register_fe1_dialogue_system() -> void:
	var module_class = load("res://src/gameplay/fe1_dialogue_system/fe1_dialogue_system.gd")
	if not module_class:
		push_error("[App] 无法加载Fe1对话系统模块类")
		return

	# 模块内部有add_child操作（Timer、气泡容器），必须用register_module_instance
	var instance = module_class.new()
	if not instance:
		push_error("[App] 无法实例化Fe1对话系统")
		return

	var config = _config.get("fe1_dialogue_system", {})
	var success = _module_loader.register_module_instance(
		"fe1_dialogue_system",
		instance,
		config,
		["ui_framework", "f1_window_system"], # 依赖UI框架和F1窗口系统
		[], # 无可选依赖
		55 # 中等优先级，低于C1
	)

	if success:
		print("[App] Fe1对话系统已注册")
	else:
		push_error("[App] Fe1对话系统注册失败")

## 注册Fe2记忆系统
func _register_fe2_memory_system() -> void:
	var fe2_module_class = load("res://src/gameplay/fe2_memory_system/fe2_memory_system.gd")
	if not fe2_module_class:
		push_error("[App] 无法加载Fe2记忆系统模块类")
		return

	# 实例化模块
	var instance = fe2_module_class.new()
	if not instance:
		push_error("[App] 无法实例化Fe2记忆系统")
		return

	var config = _config.get("fe2_memory_system", {})
	var success = _module_loader.register_module_instance(
		"fe2_memory_system",
		instance,
		config,
		["f4_save_system"], # 依赖存档系统
		[], # 无可选依赖
		50 # 中等优先级
	)

	if success:
		print("[App] Fe2记忆系统已注册")
	else:
		push_error("[App] Fe2记忆系统注册失败")

## 注册Fe3好感度系统
func _register_fe3_affinity_system() -> void:
	var fe3_module_class = load("res://src/gameplay/fe3_affinity_system/fe3_affinity_system.gd")
	if not fe3_module_class:
		push_error("[App] 无法加载Fe3好感度系统模块类")
		return

	# 实例化模块
	var instance = fe3_module_class.new()
	if not instance:
		push_error("[App] 无法实例化Fe3好感度系统")
		return

	var config = _config.get("fe3_affinity_system", {})
	var success = _module_loader.register_module_instance(
		"fe3_affinity_system",
		instance,
		config,
		["f4_save_system"], # 依赖存档系统
		["fe2_memory_system"], # 可选依赖记忆系统
		45 # 中等优先级，低于Fe2
	)

	if success:
		print("[App] Fe3好感度系统已注册")
	else:
		push_error("[App] Fe3好感度系统注册失败")

## 注册Fe5音频系统
func _register_fe5_audio_system() -> void:
	var module_class = load("res://src/gameplay/fe5_audio_system/fe5_audio_system.gd")
	if not module_class:
		push_error("[App] 无法加载Fe5音频系统模块类")
		return

	# 实例化模块（内部有AudioStreamPlayer需要add_child）
	var instance = module_class.new()
	if not instance:
		push_error("[App] 无法实例化Fe5音频系统")
		return

	var config = _config.get("fe5_audio_system", {})
	var success = _module_loader.register_module_instance(
		"fe5_audio_system",
		instance,
		config,
		[], # 无硬依赖
		["f4_save_system"], # 可选依赖存档系统
		40 # 中等优先级，低于Fe3
	)

	if success:
		print("[App] Fe5音频系统已注册")
	else:
		push_error("[App] Fe5音频系统注册失败")

## 注册P1主UI系统
func _register_p1_main_ui() -> void:
	var module_class = load("res://src/ui/p1_main_ui/p1_main_ui.gd")
	if not module_class:
		push_error("[App] 无法加载P1主UI系统模块类")
		return

	# 实例化模块（内部有UI节点需要add_child）
	var instance = module_class.new()
	if not instance:
		push_error("[App] 无法实例化P1主UI系统")
		return

	var config = _config.get("p1_main_ui", {})
	var success = _module_loader.register_module_instance(
		"p1_main_ui",
		instance,
		config,
		["ui_framework"], # 依赖UI框架
		["fe3_affinity_system", "fe2_memory_system", "fe5_audio_system"], # 可选依赖
		35 # 中等优先级，低于Fe5
	)

	if success:
		print("[App] P1主UI系统已注册")
	else:
		push_error("[App] P1主UI系统注册失败")

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

		# Sprint3验证：自动运行集成测试
		print("[App] Sprint3验证 - 开始集成测试...")
		call_deferred("run_integration_tests")
	else:
		push_error("[App] 模块启动失败")
		# 即使部分模块失败，应用仍可运行
		status = AppStatus.RUNNING
		app_started.emit(false)

		# Sprint3验证：仍然尝试运行集成测试
		print("[App] Sprint3验证 - 模块启动有错误，仍然尝试集成测试...")
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

	# 清理测试运行器
	_cleanup_test_runner()

	status = AppStatus.SHUTDOWN
	app_shutdown.emit()
	print("[App] 应用已停止")

## 运行集成测试
func run_integration_tests() -> void:
	print("[App] 开始运行集成测试...")

	if status != AppStatus.RUNNING:
		print("[App] 警告: 应用未处于运行状态，测试可能不准确")
		print("[App] 当前状态: %s" % AppStatus.keys()[status])

	# 清理之前的测试运行器
	_cleanup_test_runner()

	# 加载Sprint3测试脚本
	var test_script_path = "res://tests/integration/sprint3_integration_test.gd"
	var test_script = load(test_script_path)
	if not test_script:
		push_error("[App] 无法加载测试脚本: %s" % test_script_path)
		return

	# 实例化测试运行器
	_test_runner = test_script.new()
	if not _test_runner:
		push_error("[App] 无法实例化测试脚本")
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

## 获取模块实例
func get_module(module_id: String) -> Node:
	if _module_loader:
		return _module_loader.get_module(module_id)
	return null

## 获取模块状态
func get_module_status() -> Dictionary:
	if _module_loader:
		return _module_loader.get_all_module_status()
	return {}

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
	push_error("[App] 模块错误: %s - %s" % [module_id, error.get("message", "未知错误")])
