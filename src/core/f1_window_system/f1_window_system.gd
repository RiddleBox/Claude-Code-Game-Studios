# core/f1_window_system/f1_window_system.gd
# F1 桌面窗口系统模块化版本
# 实现IModule接口，支持模块化架构

class_name F1WindowSystem
extends Node

## IModule接口实现
var module_id: String = "f1_window_system"
var module_name: String = "桌面窗口系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = []
var optional_dependencies: Array[String] = []
var config_path: String = "res://data/config/f1_window_system.json"
var category: String = "core"
var priority: String = "critical"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## 窗口系统信号
signal window_initialized(success: bool)
signal window_position_changed(position: Vector2)
signal window_drag_started()
signal window_drag_ended()
signal mouse_entered_window()
signal mouse_exited_window()
signal character_clicked()

## 原F1系统属性
# C1 实现前 CharacterSprite 子节点不存在，用 get_node_or_null 避免报错
@onready var character_sprite: Sprite2D = get_node_or_null("CharacterSprite")

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var win32_hook: Node = null

var _mouse_in_window: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO

## 配置参数
var _config: Dictionary = {}
var _is_editor_mode: bool = false

## IModule.initialize() 实现
func initialize(config: Dictionary = {}) -> bool:
	print("[F1] 初始化桌面窗口系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 保存配置
	_config = config.duplicate()

	# 检查是否在编辑器内运行
	_is_editor_mode = Engine.is_editor_hint()

	if _is_editor_mode:
		print("[F1] 警告：在编辑器内运行，桌面功能受限")
		_init_editor_mode()
	else:
		print("[F1] 在独立应用模式下运行")
		_init_desktop_mode()

	status = IModule.ModuleStatus.INITIALIZED
	window_initialized.emit(true)
	print("[F1] 桌面窗口系统初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[F1] 启动桌面窗口系统...")
	status = IModule.ModuleStatus.STARTING

	# 启用处理回调
	set_process(true)
	set_process_input(true)

	status = IModule.ModuleStatus.RUNNING
	print("[F1] 桌面窗口系统已启动")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[F1] 停止桌面窗口系统...")
	status = IModule.ModuleStatus.STOPPING

	# 禁用处理回调
	set_process(false)
	set_process_input(false)

	# 停止拖拽
	is_dragging = false

	status = IModule.ModuleStatus.STOPPED
	print("[F1] 桌面窗口系统已停止")

## IModule.shutdown() 实现
func shutdown() -> void:
	print("[F1] 关闭桌面窗口系统...")

	# 清理资源
	if win32_hook:
		win32_hook.queue_free()
		win32_hook = null

	# 保存窗口位置
	save_window_position()

	status = IModule.ModuleStatus.SHUTDOWN
	print("[F1] 桌面窗口系统已关闭")

## IModule.reload_config() 实现
func reload_config(new_config: Dictionary = {}) -> bool:
	print("[F1] 重新加载配置...")

	# 合并新配置
	_config.merge(new_config, true)

	# 应用新配置
	_apply_config()

	print("[F1] 配置已重新加载")
	return true

## 原F1系统方法（保持兼容）
func _init_desktop_mode() -> void:
	print("[F1] 初始化桌面模式")

	# 1. 设置窗口标志
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	print("[F1] 窗口标志已设置：透明、置顶、无边框")

	# 2. 设置视口透明背景
	get_viewport().transparent_bg = true
	print("[F1] 视口透明背景已启用")

	# 3. 尝试加载GDExtension Hook
	_try_load_gdextension_hook()

	# 4. 初始化拖拽功能
	_init_drag_handling()

	# 5. 加载保存的窗口位置
	load_window_position()

	print("[F1] 桌面模式初始化完成")

func _init_editor_mode() -> void:
	print("[F1] 初始化编辑器模式（功能受限）")

	# 在编辑器模式下，窗口功能有限
	# 我们只能测试基本逻辑，不能测试桌面窗口特性

	# 初始化拖拽功能（在编辑器中可能无法实际移动窗口）
	_init_drag_handling()

	# 显示提示信息
	print("[F1] 注意：要测试完整F1功能：")
	print("[F1]   1. 导出项目（项目 → 导出...）")
	print("[F1]   2. 从命令行运行：godot --path .")
	print("[F1]   3. 或更改编辑器运行设置使用独立窗口")

func _try_load_gdextension_hook() -> void:
	# 尝试加载 GDExtension Win32 Hook
	# 注意: 仅 Windows 平台有效，其他平台回退到基础模式
	if OS.get_name() == "Windows":
		# GDExtension 集成将在后续实现
		# 目前使用回退模式
		print("[F1] 检测到Windows平台。GDExtension集成待实现。")
		_setup_fallback_click_passthrough()
	else:
		print("[F1] 非Windows平台: ", OS.get_name(), "。使用回退模式。")
		_setup_fallback_click_passthrough()

func _setup_fallback_click_passthrough() -> void:
	# 回退方案: 使用 DisplayServer 多边形蒙版
	# MVP 阶段: 仅角色矩形区域可交互，其他区域穿透
	# 注意: character_sprite 在 C1 实现前可能为 null，跳过设置
	if not character_sprite:
		print("[F1] CharacterSprite 未就绪（C1 未实现），跳过点击穿透设置")
		return

	var character_rect = character_sprite.get_rect()
	var _polygon = PackedVector2Array([
		character_rect.position,
		Vector2(character_rect.end.x, character_rect.position.y),
		character_rect.end,
		Vector2(character_rect.position.x, character_rect.end.y)
	])

	# 尝试设置点击穿透 (暂时禁用以测试基本功能)
	print("[F1] 点击穿透暂时禁用用于初始测试")

func _is_point_on_character_interactive(pos: Vector2) -> bool:
	# 检查点是否在角色交互区域内
	# 如果 GDExtension 已加载，它会通过 WM_NCHITTEST 处理像素级判定
	# 这里作为备份逻辑
	if not character_sprite:
		return false
	if win32_hook:
		# GDExtension 会处理精确判定，这里只做粗略检查
		return character_sprite.get_rect().has_point(pos)
	else:
		# 回退模式: 使用矩形判定
		return character_sprite.get_rect().has_point(pos)

func _init_drag_handling() -> void:
	# 初始化拖拽处理
	# 注意: character_sprite 在 C1 实现前可能为 null
	var sprite_name = character_sprite.name if character_sprite else "（未就绪）"
	print("[F1] 拖拽处理已初始化。角色精灵: ", sprite_name)

func save_window_position() -> void:
	# 保存窗口位置到 F4 存档系统
	var window_pos = DisplayServer.window_get_position()
	print("[F1] 要保存的窗口位置: ", window_pos)
	# TODO: 调用F4存档系统

func load_window_position() -> void:
	# 从 F4 存档系统加载窗口位置
	# TODO: 调用F4存档系统
	pass

## 处理循环
func _process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = DisplayServer.mouse_get_position()
		# 将 Vector2i 转换为 Vector2 进行计算
		DisplayServer.window_set_position(Vector2(mouse_pos) - drag_offset)

	# 鼠标悬停检测
	_update_mouse_hover(delta)

func _update_mouse_hover(delta: float) -> void:
	# 检测鼠标是否在窗口内
	var mouse_pos = DisplayServer.mouse_get_position()
	var window_pos = DisplayServer.window_get_position()
	var window_size = DisplayServer.window_get_size()

	# 检查鼠标是否在窗口范围内
	var window_rect = Rect2(Vector2(window_pos), Vector2(window_size))
	var is_mouse_in_window_now = window_rect.has_point(Vector2(mouse_pos))

	# 检测鼠标进入/离开事件
	if is_mouse_in_window_now and not _mouse_in_window:
		_mouse_in_window = true
		_last_mouse_position = Vector2(mouse_pos)
		_on_mouse_entered_window()
	elif not is_mouse_in_window_now and _mouse_in_window:
		_mouse_in_window = false
		_on_mouse_exited_window()

func _on_mouse_entered_window() -> void:
	# 通知其他系统鼠标进入窗口
	print("[F1] 鼠标进入窗口")
	mouse_entered_window.emit()

func _on_mouse_exited_window() -> void:
	# 通知其他系统鼠标离开窗口
	print("[F1] 鼠标离开窗口")
	mouse_exited_window.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 判断是否点在角色身上
				var click_pos = get_viewport().get_mouse_position()
				if _is_point_on_character_interactive(click_pos):
					is_dragging = true
					# 计算鼠标位置与窗口位置的偏移量
					var mouse_screen_pos = DisplayServer.mouse_get_position()
					var window_pos = DisplayServer.window_get_position()
					drag_offset = Vector2(mouse_screen_pos) - Vector2(window_pos)
					print("[F1] 拖拽开始。偏移: ", drag_offset)

					# 发送角色被点击信号
					character_clicked.emit()
					window_drag_started.emit()
			else:
				if is_dragging:
					print("[F1] 拖拽结束。窗口位置: ", DisplayServer.window_get_position())
					window_drag_ended.emit()
				is_dragging = false

## 公共API（供其他模块使用）
## 获取窗口位置
func get_window_position() -> Vector2:
	return Vector2(DisplayServer.window_get_position())

## 设置窗口位置
func set_window_position(position: Vector2) -> void:
	DisplayServer.window_set_position(position)
	window_position_changed.emit(position)

## 获取窗口大小
func get_window_size() -> Vector2:
	return Vector2(DisplayServer.window_get_size())

## 检查是否在桌面模式
func is_desktop_mode() -> bool:
	return not _is_editor_mode

## 检查是否正在拖拽
func is_dragging_window() -> bool:
	return is_dragging

## 检查鼠标是否在窗口内
func is_mouse_in_window() -> bool:
	return _mouse_in_window

## 应用配置
func _apply_config() -> void:
	# 应用窗口配置
	var window_config = _config.get("window", {})

	if window_config.has("transparent"):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, window_config["transparent"])

	if window_config.has("always_on_top"):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, window_config["always_on_top"])

	if window_config.has("borderless"):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, window_config["borderless"])

	print("[F1] 窗口配置已应用")

## 健康检查
func health_check() -> Dictionary:
	var issues: Array[String] = []

	# 检查窗口状态
	if not DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT):
		issues.append("窗口未设置为透明")

	if not get_viewport().transparent_bg:
		issues.append("视口透明背景未启用")

	return {
		"healthy": issues.is_empty(),
		"issues": issues,
		"window_position": get_window_position(),
		"window_size": get_window_size(),
		"is_desktop_mode": is_desktop_mode(),
		"is_dragging": is_dragging
	}