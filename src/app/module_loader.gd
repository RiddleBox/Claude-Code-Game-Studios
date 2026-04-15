# app/module_loader.gd
# 模块加载器
# 负责模块的生命周期管理、依赖解析和错误处理

class_name ModuleLoader
extends Node

## 模块加载状态信号
signal module_registered(module_id: String, module_name: String)
signal module_initialized(module_id: String, success: bool)
signal module_started(module_id: String, success: bool)
signal module_stopped(module_id: String)
signal module_shutdown(module_id: String)
signal module_error(module_id: String, error: Dictionary)
signal all_modules_initialized(success: bool)
signal all_modules_started(success: bool)

## 模块注册表 {module_id: module_instance}
var _modules: Dictionary = {}

## 模块配置 {module_id: config_data}
var _module_configs: Dictionary = {}

## 模块状态 {module_id: status_data}
var _module_status: Dictionary = {}

## 依赖关系图
var _dependency_graph: DependencyGraph

## 模块优先级映射 {module_id: priority_value}
var _module_priorities: Dictionary = {}

## 初始化加载器
func _ready() -> void:
	_dependency_graph = DependencyGraph.new()
	print("[ModuleLoader] Module loader initialized")

## 注册模块
## @param module_id: 模块唯一标识符
## @param module_class: 模块类（必须实现IModule接口）
## @param config: 模块配置
## @param dependencies: 依赖模块列表
## @param optional_dependencies: 可选依赖模块列表
## @param priority: 模块优先级（0-100，越高越优先）
## 注册已实例化的模块节点（从场景文件加载时使用）
## 与 register_module() 功能相同，但接受现成的 Node 实例而非 GDScript 类
func register_module_instance(module_id: String, instance: Node,
					config: Dictionary = {}, dependencies: Array[String] = [],
					optional_dependencies: Array[String] = [], priority: int = 50) -> bool:
	if module_id in _modules:
		push_error("[ModuleLoader] Module already registered: %s" % module_id)
		return false

	instance.module_id = module_id
	instance.dependencies = dependencies.duplicate()
	instance.optional_dependencies = optional_dependencies.duplicate()

	_modules[module_id] = instance
	_module_configs[module_id] = config.duplicate()
	_module_priorities[module_id] = priority
	add_child(instance)
	print("[ModuleLoader] Module (scene instance) added to scene tree: %s" % module_id)

	var module_info = {
		"name": instance.module_name if instance.get("module_name") != null else module_id,
		"category": instance.category if instance.get("category") != null else "unknown",
		"priority": priority
	}
	_dependency_graph.add_module(module_id, dependencies, optional_dependencies, module_info)
	_module_status[module_id] = {
		"registered": true,
		"initialized": false,
		"started": false,
		"errors": []
	}
	emit_signal("module_registered", module_id,
		instance.module_name if instance.get("module_name") != null else module_id)
	return true

func register_module(module_id: String, module_class: GDScript,
					config: Dictionary = {}, dependencies: Array[String] = [],
					optional_dependencies: Array[String] = [], priority: int = 50) -> bool:

	# 检查模块是否已注册
	if module_id in _modules:
		push_error("[ModuleLoader] Module already registered: %s" % module_id)
		return false

	# 检查模块类是否实现IModule接口
	var instance = module_class.new()
	if false: # 临时绕过接口检查 (implements关键字不兼容)
		push_error("[ModuleLoader] Module class does not implement IModule interface: %s" % module_id)
		return false

	# 设置模块属性
	instance.module_id = module_id
	instance.dependencies = dependencies.duplicate()
	instance.optional_dependencies = optional_dependencies.duplicate()

	# 存储模块实例和配置
	_modules[module_id] = instance
	_module_configs[module_id] = config.duplicate()
	_module_priorities[module_id] = priority

	# 将模块实例添加到场景树（作为ModuleLoader的子节点）
	add_child(instance)
	print("[ModuleLoader] Module added to scene tree: %s" % module_id)

	# 更新依赖图
	var module_info = {
		"name": instance.module_name if instance.get("module_name") != null else module_id,
		"category": instance.category if instance.get("category") != null else "unknown",
		"priority": priority
	}
	_dependency_graph.add_module(module_id, dependencies, optional_dependencies, module_info)

	# 初始化状态
	_module_status[module_id] = {
		"status": IModule.ModuleStatus.UNINITIALIZED,
		"initialized": false,
		"started": false,
		"error_count": 0,
		"last_error": null,
		"start_time": 0,
		"initialization_time": 0
	}

	print("[ModuleLoader] Module registered: %s (deps: %s)" % [module_id, str(dependencies)])
	module_registered.emit(module_id, instance.module_name if instance.get("module_name") != null else module_id)
	return true

## 加载模块配置从文件
## @param config_path: 配置文件路径
func load_module_config(config_path: String) -> bool:
	if not FileAccess.file_exists(config_path):
		push_error("[ModuleLoader] Config file not found: %s" % config_path)
		return false

	var file = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("[ModuleLoader] Failed to open config file: %s" % config_path)
		return false

	var content = file.get_as_text()
	file.close()

	var config = JSON.parse_string(content)
	if config == null:
		push_error("[ModuleLoader] Invalid JSON in config file: %s" % config_path)
		return false

	# 应用配置到所有模块
	for module_id in config.keys():
		if module_id in _module_configs:
			_module_configs[module_id].merge(config[module_id], true)

	print("[ModuleLoader] Loaded module config from: %s" % config_path)
	return true

## 初始化所有模块（按依赖顺序）
## @param async: 是否异步初始化
func initialize_all_modules(async: bool = false) -> bool:
	print("[ModuleLoader] Initializing all modules...")

	# 验证依赖关系
	var available_modules = _modules.keys()
	var validation = _dependency_graph.validate_dependencies(available_modules)

	if not validation["valid"]:
		push_error("[ModuleLoader] Dependency validation failed:")
		for module_id in validation["missing_deps"].keys():
			push_error("  %s missing deps: %s" % [module_id, str(validation["missing_deps"][module_id])])
		if not str(validation["cycles"]).is_empty():
			push_error("  Circular dependencies: %s" % str(validation["cycles"]))
		return false

	# 获取初始化顺序
	var init_order = _dependency_graph.get_startup_order(_module_priorities)
	print("[ModuleLoader] Initialization order: %s" % str(init_order))

	if async:
		# 异步初始化（TODO: 实现协程版本）
		print("[ModuleLoader] Async initialization not implemented yet, falling back to sync")
		return _initialize_modules_sync(init_order)
	else:
		return _initialize_modules_sync(init_order)

## 同步初始化模块（内部方法）
func _initialize_modules_sync(init_order: Array[String]) -> bool:
	var success = true

	for module_id in init_order:
		var module = _modules.get(module_id)
		if not module:
			push_error("[ModuleLoader] Module not found: %s" % module_id)
			success = false
			continue

		# 检查依赖是否已初始化
		var all_deps_ready = true
		for dep_id in module.dependencies:
			var dep_status = _module_status.get(dep_id, {})
			if not dep_status.get("initialized", false):
				push_error("[ModuleLoader] Dependency not initialized: %s -> %s" % [module_id, dep_id])
				all_deps_ready = false
				break

		if not all_deps_ready:
			_module_status[module_id]["status"] = IModule.ModuleStatus.ERROR
			_module_status[module_id]["last_error"] = {
				"code": -1,
				"message": "Dependencies not ready",
				"details": module.dependencies
			}
			module_error.emit(module_id, _module_status[module_id]["last_error"])
			success = false
			continue

		# 初始化模块
		var start_time = Time.get_ticks_msec()
		_module_status[module_id]["status"] = IModule.ModuleStatus.INITIALIZING

		var config = _module_configs.get(module_id, {})
		var init_success = module.initialize(config)

		var end_time = Time.get_ticks_msec()
		_module_status[module_id]["initialization_time"] = end_time - start_time

		if init_success:
			_module_status[module_id]["status"] = IModule.ModuleStatus.INITIALIZED
			_module_status[module_id]["initialized"] = true
			print("[ModuleLoader] Module initialized: %s (%d ms)" % [module_id, end_time - start_time])
		else:
			_module_status[module_id]["status"] = IModule.ModuleStatus.ERROR
			_module_status[module_id]["last_error"] = {
				"code": -2,
				"message": "Initialization failed",
				"details": module.get_status() if module.has_method("get_status") else {}
			}
			push_error("[ModuleLoader] Module initialization failed: %s" % module_id)
			module_error.emit(module_id, _module_status[module_id]["last_error"])
			success = false

		module_initialized.emit(module_id, init_success)

	all_modules_initialized.emit(success)
	return success

## 启动所有模块
func start_all_modules() -> bool:
	print("[ModuleLoader] Starting all modules...")

	var start_order = _dependency_graph.get_startup_order(_module_priorities)
	var success = true

	for module_id in start_order:
		var module = _modules.get(module_id)
		if not module:
			continue

		# 只启动已初始化的模块
		if not _module_status[module_id].get("initialized", false):
			print("[ModuleLoader] Skipping uninitialized module: %s" % module_id)
			continue

		# 启动模块
		_module_status[module_id]["status"] = IModule.ModuleStatus.STARTING
		_module_status[module_id]["start_time"] = Time.get_ticks_msec()

		var start_success = module.start()

		if start_success:
			_module_status[module_id]["status"] = IModule.ModuleStatus.RUNNING
			_module_status[module_id]["started"] = true
			print("[ModuleLoader] Module started: %s" % module_id)
		else:
			_module_status[module_id]["status"] = IModule.ModuleStatus.ERROR
			_module_status[module_id]["last_error"] = {
				"code": -3,
				"message": "Start failed",
				"details": module.get_status()
			}
			push_error("[ModuleLoader] Module start failed: %s" % module_id)
			module_error.emit(module_id, _module_status[module_id]["last_error"])
			success = false

		module_started.emit(module_id, start_success)

	all_modules_started.emit(success)
	return success

## 停止所有模块
func stop_all_modules() -> void:
	print("[ModuleLoader] Stopping all modules...")

	# 按反向依赖顺序停止
	var stop_order = _dependency_graph.get_startup_order(_module_priorities)
	stop_order.reverse()

	for module_id in stop_order:
		var module = _modules.get(module_id)
		if not module:
			continue

		# 只停止已启动的模块
		if not _module_status[module_id].get("started", false):
			continue

		_module_status[module_id]["status"] = IModule.ModuleStatus.STOPPING
		module.stop()
		_module_status[module_id]["status"] = IModule.ModuleStatus.STOPPED
		_module_status[module_id]["started"] = false

		print("[ModuleLoader] Module stopped: %s" % module_id)
		module_stopped.emit(module_id)

## 关闭所有模块
func shutdown_all_modules() -> void:
	print("[ModuleLoader] Shutting down all modules...")

	# 按反向依赖顺序关闭
	var shutdown_order = _dependency_graph.get_startup_order(_module_priorities)
	shutdown_order.reverse()

	for module_id in shutdown_order:
		var module = _modules.get(module_id)
		if not module:
			continue

		_module_status[module_id]["status"] = IModule.ModuleStatus.SHUTDOWN
		module.shutdown()

		print("[ModuleLoader] Module shutdown: %s" % module_id)
		module_shutdown.emit(module_id)

	# 清理
	_modules.clear()
	_module_configs.clear()
	_module_status.clear()
	_module_priorities.clear()

## 获取模块实例
## @param module_id: 模块ID
## @return: 模块实例，不存在返回null
func get_module(module_id: String) -> Node:
	return _modules.get(module_id)

## 检查模块是否就绪
## @param module_id: 模块ID
## @return: 模块就绪返回true
func is_module_ready(module_id: String) -> bool:
	var status = _module_status.get(module_id, {})
	return status.get("started", false) and status.get("status") == IModule.ModuleStatus.RUNNING

## 获取模块状态
## @param module_id: 模块ID
## @return: 模块状态字典
func get_module_status(module_id: String) -> Dictionary:
	var status = _module_status.get(module_id, {}).duplicate()
	var module = _modules.get(module_id)
	if module and module.has_method("get_status"):
		status["module_info"] = module.get_status()
	return status

## 获取所有模块状态
## @return: 所有模块状态字典
func get_all_module_status() -> Dictionary:
	var result = {}
	for module_id in _modules.keys():
		result[module_id] = get_module_status(module_id)
	return result

## 重新加载模块
## @param module_id: 模块ID
## @param new_config: 新配置（可选）
func reload_module(module_id: String, new_config: Dictionary = {}) -> bool:
	var module = _modules.get(module_id)
	if not module:
		push_error("[ModuleLoader] Module not found: %s" % module_id)
		return false

	# 停止模块
	if _module_status[module_id].get("started", false):
		module.stop()
		_module_status[module_id]["started"] = false
		_module_status[module_id]["status"] = IModule.ModuleStatus.STOPPED

	# 更新配置
	if not new_config.is_empty():
		_module_configs[module_id] = new_config.duplicate()

	# 重新初始化
	_module_status[module_id]["status"] = IModule.ModuleStatus.INITIALIZING
	var init_success = module.initialize(_module_configs[module_id])

	if init_success:
		_module_status[module_id]["status"] = IModule.ModuleStatus.INITIALIZED
		_module_status[module_id]["initialized"] = true

		# 重新启动
		var start_success = module.start()
		if start_success:
			_module_status[module_id]["status"] = IModule.ModuleStatus.RUNNING
			_module_status[module_id]["started"] = true
			print("[ModuleLoader] Module reloaded: %s" % module_id)
			return true
		else:
			_module_status[module_id]["status"] = IModule.ModuleStatus.ERROR
			push_error("[ModuleLoader] Module restart failed: %s" % module_id)
			return false
	else:
		_module_status[module_id]["status"] = IModule.ModuleStatus.ERROR
		push_error("[ModuleLoader] Module reinitialization failed: %s" % module_id)
		return false

## 报告模块错误
## @param module_id: 模块ID
## @param error: 错误信息
func report_module_error(module_id: String, error: Dictionary) -> void:
	var module = _modules.get(module_id)
	if not module:
		push_error("[ModuleLoader] Cannot report error for unknown module: %s" % module_id)
		return

	# 更新状态
	_module_status[module_id]["status"] = IModule.ModuleStatus.ERROR
	_module_status[module_id]["last_error"] = error.duplicate()
	_module_status[module_id]["error_count"] = _module_status[module_id].get("error_count", 0) + 1

	# 尝试让模块处理错误
	var handled = module.handle_error(error)
	if not handled:
		# 模块无法处理，上报给加载器
		push_error("[ModuleLoader] Module error not handled by module %s: %s" % [module_id, str(error)])
		module_error.emit(module_id, error)

## 获取依赖图可视化
## @return: Graphviz DOT格式字符串
func get_dependency_graph_viz() -> String:
	return _dependency_graph.to_dot_format()
