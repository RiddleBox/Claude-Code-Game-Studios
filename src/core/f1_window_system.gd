extends Node2D

# F1 — 桌面窗口系统 (Production GDExtension 版)
# 采用 ADR-001 混合 Hook 方案：GDExtension 拦截 WM_NCHITTEST 实现像素级点击穿透

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

var character_sprite: Sprite2D = null

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO  # 鼠标位置与窗口位置的偏移量
var win32_hook: Node = null  # GDExtension F1Win32Hook 实例

# F2 状态机引用
var state_machine: Node = null
var _f2_connected: bool = false  # 标记F2是否已连接

# 调试图形
var _debug_rect: ColorRect = null

# 鼠标悬停检测
var _mouse_in_window: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("[F1] F1 Window System _ready() called (modular architecture)")
	# 实际初始化在initialize()方法中进行
	# 这里只打印消息，避免重复初始化

func _init_desktop_mode() -> void:
	print("[F1] Initializing in DESKTOP mode (standalone application)")

	# 1. 确保窗口透明与置顶
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	print("[F1] Window flags set: transparent, always-on-top, borderless")

	# 设置窗口位置，确保可见
	DisplayServer.window_set_position(Vector2(100, 100))
	print("[F1] Window position set to (100, 100)")

	# 获取并打印窗口大小
	var window_size = DisplayServer.window_get_size()
	print("[F1] Window size: ", window_size)

	# 2. 确保视口透明背景
	var viewport = get_viewport()
	if viewport:
		viewport.transparent_bg = true
		print("[F1] Viewport transparent background enabled")
	else:
		print("[F1] WARNING: Viewport is null, transparent background not set")

	# 3. 尝试加载 GDExtension Hook (Windows 平台)
	_try_load_gdextension_hook()

	# 4. 初始化拖拽功能
	_init_drag_handling()

	# 5. 初始化F2状态机
# 	_try_connect_f2_state_machine()

	# 6. 设置系统托盘图标 (TODO: Sprint 1 后续任务)
	# _setup_system_tray()

	print("[F1] Desktop mode initialization complete")

func _init_editor_mode() -> void:
	print("[F1] Initializing in EDITOR mode (limited features)")

	# 在编辑器模式下，窗口功能有限
	# 我们只能测试基本逻辑，不能测试桌面窗口特性

	# 初始化拖拽功能（在编辑器中可能无法实际移动窗口）
	_init_drag_handling()

	# 初始化F2状态机（编辑器模式下也可测试状态逻辑）
# 	_try_connect_f2_state_machine()

	# 显示提示信息
	print("[F1] NOTE: To test full F1 functionality:")
	print("[F1]   1. Export project (Project → Export...)")
	print("[F1]   2. Run from command line: godot --path .")
	print("[F1]   3. Or change editor run settings to use separate window")



func _try_load_gdextension_hook() -> void:
	# 尝试加载 GDExtension Win32 Hook
	# 注意: 仅 Windows 平台有效，其他平台回退到基础模式
	if OS.get_name() == "Windows":
		# GDExtension 集成将在 Sprint 1 后期实现
		# 目前使用回退模式
		print("[F1] Windows platform detected. GDExtension integration pending.")
		_setup_fallback_click_passthrough()
	else:
		print("[F1] Non-Windows platform: ", OS.get_name(), ". Using fallback mode.")
		_setup_fallback_click_passthrough()

# GDExtension 相关方法占位
func _initialize_gdextension() -> void:
	# TODO: Sprint 1 后期实现 GDExtension 加载
	# 1. 检查 GDExtension 库是否加载
	# 2. 实例化 F1Win32Hook
	# 3. 配置点击穿透参数
	pass

func _create_gdextension_instance() -> Node:
	# TODO: 创建 GDExtension 实例
	# 返回 null 表示失败
	return null

func _check_gdextension_available() -> bool:
	# TODO: 检查 GDExtension 是否可用
	return false

func _update_hit_map_from_character() -> void:
	# 从角色精灵生成 Alpha 贴图用于点击穿透判定
	if win32_hook and character_sprite.texture:
		var image = character_sprite.texture.get_image()
		if image:
			win32_hook.update_hit_map(image)
			print("[F1] Hit map updated from character texture: ", image.get_size())

func _setup_fallback_click_passthrough() -> void:
	# 回退方案: 使用 DisplayServer 多边形蒙版
	# MVP 阶段: 仅角色矩形区域可交互，其他区域穿透

	# 检查character_sprite是否存在
	if character_sprite == null:
		print("[F1] WARNING: character_sprite is null, cannot set up click passthrough")
		return

	var character_rect = character_sprite.get_rect()
	var _polygon = PackedVector2Array([
		character_rect.position,
		Vector2(character_rect.end.x, character_rect.position.y),
		character_rect.end,
		Vector2(character_rect.position.x, character_rect.end.y)
	])

	# 尝试设置点击穿透 (暂时禁用以测试基本功能)
	# 注意: 先确保窗口能加载，稍后再实现点击穿透
	print("[F1] Click-through temporarily disabled for initial testing")
	# if DisplayServer.has_method("window_set_mouse_passthrough"):
	# 	# 在Godot 4.6.1中，这应该是正确的方法
	# 	DisplayServer.window_set_mouse_passthrough(polygon)
	# 	print("[F1] Fallback click passthrough configured")
	# else:
	# 	# 如果API不可用，只记录警告
	# 	print("[F1] Warning: window_set_mouse_passthrough() not available. Click-through disabled.")

func _is_point_on_character_interactive(pos: Vector2) -> bool:
	# 检查点是否在角色交互区域内
	# 如果 GDExtension 已加载，它会通过 WM_NCHITTEST 处理像素级判定
	# 这里作为备份逻辑

	# 检查character_sprite是否存在
	if character_sprite == null:
		print("[F1] WARNING: character_sprite is null, cannot check point")
		return false

	# 获取精灵矩形（相对于精灵自身坐标系）
	var local_rect = character_sprite.get_rect()

	# 将矩形转换到父节点（F1）坐标系
	# 需要考虑精灵的位置、缩放和旋转
	var sprite_transform = character_sprite.get_transform()
	var sprite_position = character_sprite.position
	var sprite_scale = character_sprite.scale

	# 应用变换：将局部矩形点转换到父节点坐标系
	# 简化：矩形中心在精灵位置，大小按缩放调整
	var rect_in_parent = Rect2(
		sprite_position - (local_rect.size * sprite_scale) / 2.0,  # 左上角
		local_rect.size * sprite_scale                            # 缩放后的大小
	)

	var is_inside = rect_in_parent.has_point(pos)

	# 调试信息
	if is_inside:
		print("[F1] Click detected on character at position: ", pos)
	else:
		# 只在调试时输出详细信息
		pass  # 不输出未命中的详细信息

	return is_inside

func _init_drag_handling() -> void:
	# 初始化拖拽处理
	if character_sprite:
		print("[F1] Drag handling initialized. Character sprite: ", character_sprite.name)
	else:
		print("[F1] Drag handling initialized. Character sprite: [null]")

# 系统托盘功能 (Sprint 1 后续任务)
# func _setup_system_tray() -> void:
#     # TODO: 实现系统托盘图标和菜单
#     pass

func save_window_position() -> void:
	# 保存窗口位置到 F4 存档系统 (Sprint 2 实现)
	var window_pos = DisplayServer.window_get_position()
	print("[F1] Window position to save: ", window_pos)
	# F4.save_window_position(window_pos)

func load_window_position() -> void:
	# 从 F4 存档系统加载窗口位置 (Sprint 2 实现)
	# var saved_pos = F4.load_window_position()
	# if saved_pos:
	#     DisplayServer.window_set_position(saved_pos)
	pass

# === F2 状态机集成 ===

func _try_connect_f2_state_machine() -> bool:
	# 尝试连接F2角色状态机（从模块加载器）
	# 返回true表示连接成功，false表示需要重试

	if _f2_connected:
		return true  # 已经连接

	if state_machine != null:
		# 已经有状态机引用，标记为已连接
		_f2_connected = true
		print("[F1] F2 state machine already connected")
		return true

	# 尝试从模块加载器获取F2实例
	var module_loader = get_parent()
	if module_loader and module_loader.has_method("get_module"):
		var f2_module = module_loader.get_module("f2_state_machine")
		if f2_module:
			state_machine = f2_module
			_f2_connected = true
			print("[F1] F2 Character State Machine obtained from module loader")
			return true

	# F2模块可能尚未初始化，需要等待
	print("[F1] F2 state machine not ready yet, waiting...")
	return false

func _process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = DisplayServer.mouse_get_position()
		# 将 Vector2i 转换为 Vector2 进行计算
		DisplayServer.window_set_position(Vector2(mouse_pos) - drag_offset)

	# 尝试连接F2状态机（如果尚未连接）
	if not _f2_connected:
		_try_connect_f2_state_machine()

	# 鼠标悬停检测 (转发给F2状态机)
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

	# 如果鼠标在窗口内，更新悬停计时器
	if _mouse_in_window and state_machine:
		# 调用F2的鼠标悬停更新
		if state_machine.has_method("update_mouse_hover"):
			state_machine.update_mouse_hover(delta)

func _on_mouse_entered_window() -> void:
	# 通知F2状态机鼠标进入窗口
	print("[F1] Mouse entered window")
	if state_machine and state_machine.has_method("on_mouse_entered_window"):
		state_machine.on_mouse_entered_window()

func _on_mouse_exited_window() -> void:
	# 通知F2状态机鼠标离开窗口
	print("[F1] Mouse exited window\n")
	if state_machine and state_machine.has_method("on_mouse_exited_window"):
		state_machine.on_mouse_exited_window()

func _input(event: InputEvent) -> void:
	# 只处理鼠标按钮事件
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 判断是否点在角色身上 (像素级判定由 GDExtension 处理)
				var local_pos = get_local_mouse_position()
				print("[F1] Mouse click detected - Local: ", local_pos, " Global: ", get_global_mouse_position(), " Screen: ", DisplayServer.mouse_get_position())
				if _is_point_on_character_interactive(local_pos):
					is_dragging = true
					# 计算鼠标位置与窗口位置的偏移量
					var mouse_screen_pos = DisplayServer.mouse_get_position()
					var window_pos = DisplayServer.window_get_position()
					drag_offset = Vector2(mouse_screen_pos) - Vector2(window_pos)
					print("[F1] Drag started. Offset: ", drag_offset)

					# 通知F2状态机角色被点击
					if state_machine and state_machine.has_method("on_character_clicked"):
						state_machine.on_character_clicked()
			else:
				if is_dragging:
					print("[F1] Drag ended. Window position: ", DisplayServer.window_get_position(), "\n")
				is_dragging = false

## ========== IModule接口方法 ==========

func initialize(_config: Dictionary = {}) -> bool:
	print("[F1] 初始化桌面窗口系统 (IModule)...")
	status = IModule.ModuleStatus.INITIALIZING

	# 保存配置
	# 可以在这里从config加载参数

	# 确保CharacterSprite有纹理（必须在窗口初始化前）
	_setup_character_sprite()

	# 执行窗口系统初始化（模块化架构中_ready()可能不被调用）
	# 检查是否在编辑器中
	if Engine.is_editor_hint():
		print("[F1] WARNING: Running in editor embedded window. Desktop features limited.")
		_init_editor_mode()
	else:
		# 独立运行模式
		_init_desktop_mode()

	status = IModule.ModuleStatus.INITIALIZED
	print("[F1] 桌面窗口系统初始化完成")
	return true

func start() -> bool:
	print("[F1] 启动桌面窗口系统...")
	status = IModule.ModuleStatus.STARTING

	# F1窗口系统在_ready()中已经启动
	# 这里只需标记运行状态

	status = IModule.ModuleStatus.RUNNING
	print("[F1] 桌面窗口系统启动完成")
	return true

func stop() -> void:
	print("[F1] 停止桌面窗口系统...")
	status = IModule.ModuleStatus.STOPPING

	# 停止所有活动
	# 当前无特殊停止逻辑

	status = IModule.ModuleStatus.STOPPED
	print("[F1] 桌面窗口系统已停止")

func shutdown() -> void:
	print("[F1] 关闭桌面窗口系统...")

	# 清理资源
	state_machine = null

	status = IModule.ModuleStatus.SHUTDOWN
	print("[F1] 桌面窗口系统已关闭")

func reload_config(_new_config: Dictionary = {}) -> bool:
	print("[F1] 重新加载配置...")
	# TODO: 实现配置热重载
	print("[F1] 配置已重新加载")
	return true

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

func handle_error(error: Dictionary) -> bool:
	last_error = error
	status = IModule.ModuleStatus.ERROR
	push_error("[F1] 模块错误: %s" % error.get("message", "Unknown error"))
	return false

func is_ready() -> bool:
	return status == IModule.ModuleStatus.RUNNING

func _setup_character_sprite() -> void:
	# 确保character_sprite存在
	if character_sprite == null:
		character_sprite = Sprite2D.new()
		add_child(character_sprite)
		print("[F1] Created CharacterSprite dynamically for modular architecture")
	else:
		print("[F1] Character sprite already exists, reusing")

	# 尝试加载纹理
	var texture = load("res://icon.svg")
	if texture:
		character_sprite.texture = texture
		print("[F1] Loaded character texture: ", texture.resource_path)
	else:
		print("[F1] WARNING: Could not load character texture")

	# 获取窗口大小并计算中心位置
	var window_size = DisplayServer.window_get_size()
	var window_center = Vector2(window_size) / 2.0
	character_sprite.position = window_center

	# 设置缩放（根据纹理大小调整）
	var target_size = Vector2(160, 160)  # 目标显示大小
	if texture:
		var tex_size = texture.get_size()
		var scale_x = target_size.x / tex_size.x
		var scale_y = target_size.y / tex_size.y
		character_sprite.scale = Vector2(scale_x, scale_y)
	else:
		character_sprite.scale = Vector2(0.5, 0.5)  # 默认缩放

	character_sprite.centered = true

	# 确保精灵可见
	character_sprite.visible = true
	character_sprite.modulate = Color.WHITE  # 确保不透明
	character_sprite.z_index = 1  # 确保在前景渲染

	# 调试信息
		print("[F1] Character sprite initialized - Position: ", character_sprite.position, " Scale: ", character_sprite.scale)

	# 添加调试矩形（验证渲染）
	if _debug_rect == null:
		_debug_rect = ColorRect.new()
		_debug_rect.color = Color(1.0, 0.0, 0.0, 0.5)  # 半透明红色
		_debug_rect.size = Vector2(100, 100)
		_debug_rect.position = window_center - Vector2(50, 50)  # 居中
		add_child(_debug_rect)
		print("[F1] Debug rectangle added at: ", _debug_rect.position)
	else:
		print("[F1] Debug rectangle already exists")

func health_check() -> Dictionary:
	return {
		"healthy": status == IModule.ModuleStatus.RUNNING,
		"issues": [] if status == IModule.ModuleStatus.RUNNING else ["Module not running"]
	}
