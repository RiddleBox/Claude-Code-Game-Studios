# gameplay/c1_character_animation_system/c1_character_animation_system.gd
# C1 角色动画系统模块化版本
# 实现IModule接口，支持模块化架构
# 依赖F2状态机，订阅状态变化并合成动画
# 支持两种合成模式：INSIDE（窗内）和LEANING_OUT（探出）

class_name C1CharacterAnimationSystem
extends Node

## IModule接口实现
var module_id: String = "c1_character_animation_system"
var module_name: String = "角色动画系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f2_state_machine"]  # 依赖F2状态机
var optional_dependencies: Array[String] = []  # 无可选依赖
var config_path: String = "res://data/config/c1_character_animation_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## ==================== 系统常量 ====================

## 合成模式枚举（与GDD一致）
enum CompositionMode {
	INSIDE,      # 窗内模式：角色完全在窗框内，动画受限
	LEANING_OUT  # 探出模式：角色部分探出窗外，动画更自由
}

## 动画状态枚举(与F2状态机对应,与GDD对齐)
enum AnimationState {
	IDLE,           # 待机状态
	ATTENTIVE,      # 注意状态(抬头关注)
	INTERACTING,    # 交互状态
	TALKING,        # 对话状态
	REACTING,       # 反应状态(A/B类型)
	PERFORMING,     # 演出状态
	AWAY,           # 离开状态(不可见)
	RETURNING       # 归来状态
}

## 默认动画参数
const DEFAULT_TRANSITION_DURATION: float = 0.3  # 动画过渡时间(秒)
const DEFAULT_BLEND_TIME: float = 0.2  # 动画混合时间(秒)
## 公共信号
signal animation_changed(state: AnimationState, mode: CompositionMode)
signal composition_mode_changed(mode: CompositionMode)
signal animation_completed(state: AnimationState)
signal animation_event(event_name: String)  # 动画关键帧事件(供Fe5音频系统订阅)
## 私有变量
var _current_state: AnimationState = AnimationState.IDLE
var _current_mode: CompositionMode = CompositionMode.INSIDE
var _f2_module: Node = null  # F2状态机模块引用
var _sprite_node: AnimatedSprite2D = null  # 角色精灵节点(帧动画)
var _is_animating: bool = false

## ==================== IModule接口方法 ====================

## IModule.initialize() 实现
func initialize(config: Dictionary = {}) -> bool:
	print("[C1] 初始化角色动画系统...")
	status = IModule.ModuleStatus.INITIALIZING

	# 应用配置参数
	if config.has("transition_duration"):
		# TODO: 应用动画过渡时间
		pass

	# 隐藏F1场景中的静态CharacterSprite(如果存在)
	_hide_f1_static_sprite()

	# 创建动画节点（如果不存在）
	_setup_animation_nodes()

	# 连接F1点击信号
	_connect_to_f1()

	# 连接F2状态机信号
	var connect_success = _connect_to_f2()
	if not connect_success:
		push_error("[C1] 无法连接到F2状态机")
		return false

	status = IModule.ModuleStatus.INITIALIZED
	print("[C1] 角色动画系统初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[C1] 启动角色动画系统...")
	status = IModule.ModuleStatus.STARTING

	# 开始播放默认动画
	_play_animation(_current_state, _current_mode)

	status = IModule.ModuleStatus.RUNNING
	print("[C1] 角色动画系统启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[C1] 停止角色动画系统...")
	status = IModule.ModuleStatus.STOPPING

	# 停止当前动画
	if _sprite_node and _sprite_node.is_playing():
		_sprite_node.stop()
		_is_animating = false

	status = IModule.ModuleStatus.STOPPED
	print("[C1] 角色动画系统已停止")

## IModule.shutdown() 实现
func shutdown() -> void:
	print("[C1] 关闭角色动画系统...")

	# 清理动画资源
	if _sprite_node:
		_sprite_node.queue_free()
		_sprite_node = null

	# 重置状态
	_current_state = AnimationState.IDLE
	_current_mode = CompositionMode.INSIDE
	_is_animating = false

	status = IModule.ModuleStatus.SHUTDOWN
	print("[C1] 角色动画系统已关闭")

## IModule.reload_config() 实现
func reload_config(new_config: Dictionary = {}) -> bool:
	print("[C1] 重新加载配置")
	# TODO: 实现配置热重载
	return true

## IModule.handle_error() 实现
func handle_error(error: Dictionary) -> bool:
	last_error = error
	status = IModule.ModuleStatus.ERROR
	push_error("[C1] 模块错误: %s" % error.get("message", "Unknown error"))
	return false

## IModule.health_check() 实现
func health_check() -> Dictionary:
	var issues: Array[String] = []

	if status != IModule.ModuleStatus.RUNNING:
		issues.append("模块未运行")

	if not _f2_module:
		issues.append("未连接到F2状态机")

	if not _sprite_node:
		issues.append("角色精灵节点未初始化")

	return {
		"healthy": issues.is_empty() and status == IModule.ModuleStatus.RUNNING,
		"issues": issues
	}

## ==================== 动画API ====================

## 切换动画状态
## @param state: 目标动画状态
## @param force: 强制立即切换（忽略当前动画）
func change_state(state: AnimationState, force: bool = false) -> void:
	if state == _current_state and not force:
		return  # 状态未变化

	print("[C1] 切换动画状态: %s -> %s" % [AnimationState.keys()[_current_state], AnimationState.keys()[state]])
	_current_state = state

	# 播放对应动画
	_play_animation(state, _current_mode)

## 切换合成模式
## @param mode: 目标合成模式
func change_composition_mode(mode: CompositionMode) -> void:
	if mode == _current_mode:
		return  # 模式未变化

	print("[C1] 切换合成模式: %s -> %s" % [CompositionMode.keys()[_current_mode], CompositionMode.keys()[mode]])
	_current_mode = mode

	# 模式变化可能需要重新播放当前状态动画
	_play_animation(_current_state, mode)
	composition_mode_changed.emit(mode)

## 获取当前动画状态
func get_current_state() -> AnimationState:
	return _current_state

## 获取当前合成模式
func get_current_mode() -> CompositionMode:
	return _current_mode

## 检查是否正在播放动画
func is_animating() -> bool:
	return _is_animating

## 获取角色当前占用区域(供F1点击检测和P1 UI避让使用)
## @return Rect2: 角色在viewport坐标系中的矩形区域
func get_character_bounds() -> Rect2:
	if not _sprite_node:
		return Rect2(0, 0, 0, 0)  # 无精灵节点,返回空区域

	# 获取精灵的全局位置
	var sprite_global_pos = _sprite_node.global_position

	# 获取精灵的实际尺寸(考虑缩放)
	var base_size = Vector2(256, 256)  # 占位符基础尺寸
	var sprite_size = base_size * _sprite_node.scale

	# 考虑精灵的中心锚点(centered=true)
	var top_left = sprite_global_pos - sprite_size / 2
	return Rect2(top_left, sprite_size)

## 获取当前构图模式(供P1查询窗框光效)
## @return String: 构图模式名称
func get_composition_mode() -> String:
	return CompositionMode.keys()[_current_mode]

## ==================== 私有辅助方法 ====================

## 设置动画节点(AnimatedSprite2D)
func _setup_animation_nodes() -> void:
	# 创建AnimatedSprite2D节点
	_sprite_node = AnimatedSprite2D.new()
	_sprite_node.name = "CharacterSprite"
	_sprite_node.centered = true

	# 加载SpriteFrames资源(透明背景版本)
	var frames_path = "res://assets/art/characters/placeholder_frame/character_frames_transparent.tres"
	var sprite_frames = load(frames_path) as SpriteFrames
	if sprite_frames:
		_sprite_node.sprite_frames = sprite_frames
		print("[C1] 已加载SpriteFrames资源: ", frames_path)
	else:
		push_error("[C1] 无法加载SpriteFrames资源: ", frames_path)

	add_child(_sprite_node)

	# 等待节点进入场景树后设置全局位置
	await get_tree().process_frame

	# 设置全局位置(屏幕中心偏下,假设1920x1080分辨率)
	var viewport_size = get_viewport().get_visible_rect().size
	_sprite_node.global_position = Vector2(viewport_size.x / 2, viewport_size.y * 0.6)

	# 设置缩放(占位符是256x256,缩小到合适大小)
	_sprite_node.scale = Vector2(0.5, 0.5)  # 缩小到128x128

	print("[C1] AnimatedSprite2D节点已设置,全局位置: ", _sprite_node.global_position)

## 隐藏F1场景中的静态CharacterSprite
func _hide_f1_static_sprite() -> void:
	# 获取F1模块引用
	var f1_module = get_parent().get_module("f1_window_system")
	if not f1_module:
		push_warning("[C1] F1窗口系统模块不存在,跳过隐藏静态精灵")
		return

	# 查找F1场景中的CharacterSprite节点
	var static_sprite = f1_module.get_node_or_null("CharacterSprite")
	if static_sprite:
		static_sprite.visible = false
		print("[C1] 已隐藏F1静态CharacterSprite")
	else:
		print("[C1] F1场景中未找到CharacterSprite节点")

## 连接F1点击信号
func _connect_to_f1() -> void:
	# 获取F1模块引用
	var f1_module = get_parent().get_module("f1_window_system")
	if not f1_module:
		push_warning("[C1] F1窗口系统模块不存在,跳过连接点击信号")
		return

	# 连接character_clicked信号
	if f1_module.has_signal("character_clicked"):
		f1_module.character_clicked.connect(_on_character_clicked)
		print("[C1] 已连接F1角色点击信号")
	else:
		push_warning("[C1] F1模块缺少character_clicked信号")

## 处理角色点击事件
func _on_character_clicked() -> void:
	print("[C1] 角色被点击!")

	# 切换到INTERACTING状态
	change_state(AnimationState.INTERACTING)

	# 通知F2状态机(如果F2支持外部触发状态切换)
	if _f2_module and _f2_module.has_method("trigger_interaction"):
		_f2_module.trigger_interaction()

func _connect_to_f2() -> bool:
	# 获取F2模块引用
	_f2_module = get_parent().get_module("f2_state_machine")
	if not _f2_module:
		push_error("[C1] F2状态机模块不存在")
		return false

	# 连接状态变化信号
	# 注意：需要根据F2实际的信号名称调整
	# 假设F2有信号state_changed(new_state: String)
	if _f2_module.has_signal("state_changed"):
		_f2_module.state_changed.connect(_on_f2_state_changed)
	else:
		push_warning("[C1] F2状态机缺少state_changed信号，使用备用方法")
		# 备用：轮询或使用其他信号

	print("[C1] 已连接到F2状态机")
	return true

func _on_f2_state_changed(_old_state: int, new_state: int) -> void:
	# 将F2状态枚举转换为字符串
	var state_string = _f2_module._state_to_string(new_state).to_lower()
	var anim_state = _map_f2_state_to_animation(state_string)
	# 切换动画状态
	change_state(anim_state)

func _map_f2_state_to_animation(f2_state: String) -> AnimationState:
	# F2状态名 -> C1动画状态(与GDD对齐)
	match f2_state:
		"idle":
			return AnimationState.IDLE
		"attentive":
			return AnimationState.ATTENTIVE
		"interacting":
			return AnimationState.INTERACTING
		"talking":
			return AnimationState.TALKING
		"reacting":
			return AnimationState.REACTING
		"performing":
			return AnimationState.PERFORMING
		"away":
			return AnimationState.AWAY
		"returning":
			return AnimationState.RETURNING
		_:
			push_warning("[C1] 未知F2状态: %s,默认使用IDLE" % f2_state)
			return AnimationState.IDLE

## 播放指定状态和模式的动画
func _play_animation(state: AnimationState, mode: CompositionMode) -> void:
	if not _sprite_node:
		push_warning("[C1] AnimatedSprite2D节点未初始化")
		return

	# 获取动画名称(只使用状态名,不带模式后缀)
	var anim_name = AnimationState.keys()[state].to_lower()

	# 检查动画是否存在
	if not _sprite_node.sprite_frames or not _sprite_node.sprite_frames.has_animation(anim_name):
		push_warning("[C1] 动画不存在: %s" % anim_name)
		return

	# 播放动画
	_sprite_node.play(anim_name)
	_is_animating = true

	print("[C1] 播放动画: %s" % anim_name)
	animation_changed.emit(state, mode)

	# 监听动画完成
	if not _sprite_node.animation_finished.is_connected(_on_animation_finished):
		_sprite_node.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	_is_animating = false

	# 获取当前播放的动画名称
	var anim_name = _sprite_node.animation if _sprite_node else ""

	# 解析动画名称获取状态
	var state_str = anim_name.to_upper()
	var state = AnimationState.get(state_str, AnimationState.IDLE)
	animation_completed.emit(state)

	print("[C1] 动画完成: %s" % anim_name)

## ==================== 调试工具 ====================

## 打印当前状态摘要
func print_status() -> void:
	print("[C1] 当前状态: %s, 合成模式: %s, 正在动画: %s" % [
		AnimationState.keys()[_current_state],
		CompositionMode.keys()[_current_mode],
		"是" if _is_animating else "否"
	])

## 强制播放指定动画（用于测试）
func play_test_animation(state: AnimationState, mode: CompositionMode) -> void:
	print("[C1] 测试播放动画: %s/%s" % [
		AnimationState.keys()[state],
		CompositionMode.keys()[mode]
	])
	_play_animation(state, mode)
