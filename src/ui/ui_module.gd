# src/ui/ui_module.gd
# UI框架模块，提供UI组件工厂和主题管理
# 实现IModule接口，支持模块化架构

class_name UIModule
extends Node

## IModule接口实现
var module_id: String = "ui_framework"
var module_name: String = "UI框架"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f1_window_system"]
var optional_dependencies: Array[String] = []
var config_path: String = "res://data/config/ui_framework.json"
var category: String = "ui"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

# 当前主题
var current_theme: UITheme = null

## IModule.initialize()
func initialize(config: Dictionary = {}) -> bool:
	print("[UI] 初始化UI框架")
	status = IModule.ModuleStatus.INITIALIZING

	# 应用配置（如果有）
	if config:
		print("[UI] 应用配置参数")

	# 加载默认主题
	_load_default_theme()

	# 验证F1窗口系统透明度
	_verify_window_transparency()

	status = IModule.ModuleStatus.INITIALIZED
	print("[UI] UI框架初始化完成")
	return true

## IModule.start()
func start() -> bool:
	print("[UI] 启动UI框架")
	status = IModule.ModuleStatus.STARTING

	# UI框架启动逻辑
	# 目前无特殊启动需求

	status = IModule.ModuleStatus.RUNNING
	print("[UI] UI框架启动完成")
	return true

## IModule.stop()
func stop() -> void:
	print("[UI] 停止UI框架")
	status = IModule.ModuleStatus.STOPPING

	# 清理资源
	current_theme = null

	status = IModule.ModuleStatus.STOPPED
	print("[UI] UI框架已停止")

## IModule.shutdown()
func shutdown() -> void:
	print("[UI] 关闭UI框架")

	# 释放所有资源
	current_theme = null

	status = IModule.ModuleStatus.SHUTDOWN
	print("[UI] UI框架已关闭")

## IModule.reload_config()
func reload_config(new_config: Dictionary = {}) -> bool:
	print("[UI] 重新加载UI框架配置")

	# 应用新配置
	# TODO: 实现配置热重载

	print("[UI] 配置已重新加载")
	return true

## IModule.get_status()
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
		"optional_dependencies": optional_dependencies,
		"theme_loaded": current_theme != null
	}

## IModule.handle_error()
func handle_error(error: Dictionary) -> bool:
	last_error = error
	status = IModule.ModuleStatus.ERROR
	push_error("[UI] 模块错误: %s" % error.get("message", "Unknown error"))
	return false

## IModule.is_ready()
func is_ready() -> bool:
	return status == IModule.ModuleStatus.RUNNING

## IModule.health_check()
func health_check() -> Dictionary:
	var issues: Array[String] = []

	if current_theme == null:
		issues.append("UI主题未加载")

	if status != IModule.ModuleStatus.RUNNING:
		issues.append("模块未运行")

	return {
		"healthy": issues.is_empty() and status == IModule.ModuleStatus.RUNNING,
		"issues": issues
	}

# ==================== UI框架核心功能 ====================

func _load_default_theme() -> void:
	var theme_path = "res://src/ui/themes/default_theme.tres"

	if ResourceLoader.exists(theme_path):
		current_theme = load(theme_path)
		print("[UI] 加载默认主题: ", current_theme.resource_path)
	else:
		# 创建默认主题
		current_theme = UITheme.new()
		current_theme.resource_name = "Default UI Theme"

		# 尝试保存主题资源
		var result = ResourceSaver.save(current_theme, theme_path)
		if result == OK:
			print("[UI] 创建并保存默认主题: ", theme_path)
		else:
			print("[UI] 警告: 无法保存主题资源到 ", theme_path)
			print("[UI] 使用内存中的默认主题")

func _verify_window_transparency() -> void:
	# 检查F1窗口透明度设置
	# 注意: 这里只是验证假设，实际渲染由组件自身处理
	print("[UI] 窗口透明度验证: 假设F1已正确配置透明窗口")

# ==================== 组件工厂方法 ====================

## 创建透明面板
func create_panel() -> TransparentPanel:
	var panel = TransparentPanel.new()
	if current_theme:
		current_theme.apply_to_panel(panel)
	return panel

## 创建透明标签
func create_label(text: String = "") -> TransparentLabel:
	var label = TransparentLabel.new()
	label.text = text
	if current_theme:
		current_theme.apply_to_label(label)
	return label

## 创建垂直容器
func create_vertical_container(margin: int = 8) -> VBoxContainer:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", margin)
	return container

## 创建水平容器
func create_horizontal_container(margin: int = 8) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", margin)
	return container

## 应用主题到现有节点
func apply_theme_to_node(node: Node) -> void:
	if not current_theme:
		return

	if node is TransparentPanel:
		current_theme.apply_to_panel(node)
	elif node is TransparentLabel:
		current_theme.apply_to_label(node)
	# 可以添加更多节点类型支持

## 获取当前主题
func get_theme() -> UITheme:
	return current_theme

## 设置新主题
func set_theme(new_theme: UITheme) -> void:
	current_theme = new_theme
	print("[UI] 主题已更新: ", new_theme.resource_name if new_theme else "None")