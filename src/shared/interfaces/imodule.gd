# interface/imodule.gd
# 模块接口定义
# 所有模块必须实现此接口

class_name IModule
extends RefCounted

## 模块唯一标识符 (如 "f1_window_system")
var module_id: String

## 模块显示名称 (如 "桌面窗口系统")
var module_name: String

## 模块版本 (语义化版本，如 "1.0.0")
var module_version: String

## 必需依赖模块ID列表
var dependencies: Array[String] = []

## 可选依赖模块ID列表 (模块可降级运行)
var optional_dependencies: Array[String] = []

## 模块配置路径 (相对于res://data/config/)
var config_path: String = ""

## 模块类别: "core", "character", "feature", "ui"
var category: String = ""

## 模块优先级: "critical", "high", "normal", "low"
var priority: String = "normal"

## 模块状态
enum ModuleStatus {
	UNINITIALIZED,  # 未初始化
	INITIALIZING,   # 初始化中
	INITIALIZED,    # 已初始化
	STARTING,       # 启动中
	RUNNING,        # 运行中
	STOPPING,       # 停止中
	STOPPED,        # 已停止
	ERROR,          # 错误状态
	SHUTDOWN        # 已关闭
}

var status: ModuleStatus = ModuleStatus.UNINITIALIZED

## 错误信息
var last_error: Dictionary = {}

## 初始化模块
## 在模块启动前调用，用于加载资源、建立连接等
## @param config: 模块配置字典
## @return: 初始化成功返回true，失败返回false
func initialize(config: Dictionary = {}) -> bool:
	push_error("IModule.initialize() must be implemented by subclass")
	return false

## 启动模块
## 初始化成功后调用，开始模块的正常运行
## @return: 启动成功返回true，失败返回false
func start() -> bool:
	push_error("IModule.start() must be implemented by subclass")
	return false

## 停止模块
## 暂停模块运行，但保持资源加载
func stop() -> void:
	push_error("IModule.stop() must be implemented by subclass")

## 关闭模块
## 释放所有资源，模块将无法再次使用
func shutdown() -> void:
	push_error("IModule.shutdown() must be implemented by subclass")

## 获取模块状态信息
## @return: 包含模块详细状态的字典
func get_status() -> Dictionary:
	return {
		"module_id": module_id,
		"module_name": module_name,
		"module_version": module_version,
		"status": status,
		"category": category,
		"priority": priority,
		"last_error": last_error,
		"dependencies": dependencies,
		"optional_dependencies": optional_dependencies
	}

## 处理模块错误
## @param error: 错误信息字典 {code: int, message: String, details: Variant}
## @return: 错误已处理返回true，需要上层处理返回false
func handle_error(error: Dictionary) -> bool:
	last_error = error
	status = ModuleStatus.ERROR
	push_error("Module %s error: %s" % [module_id, error.get("message", "Unknown error")])
	return false

## 检查模块是否就绪
## @return: 模块可正常使用返回true
func is_ready() -> bool:
	return status == ModuleStatus.RUNNING

## 重新加载模块配置
## @param new_config: 新配置字典
## @return: 重载成功返回true，失败返回false
func reload_config(new_config: Dictionary = {}) -> bool:
	push_error("IModule.reload_config() must be implemented by subclass")
	return false

## 模块健康检查
## @return: 健康状态字典 {healthy: bool, issues: Array[String]}
func health_check() -> Dictionary:
	return {
		"healthy": status == ModuleStatus.RUNNING,
		"issues": [] if status == ModuleStatus.RUNNING else ["Module not running"]
	}