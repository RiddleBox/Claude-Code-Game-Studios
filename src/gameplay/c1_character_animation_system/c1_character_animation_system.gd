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

## 动画状态枚举（与F2状态机对应）
enum AnimationState {
	IDLE,        # 待机
	THINKING,    # 思考
	WORKING,     # 工作
	PLAYING,     # 玩耍
	SLEEPING     # 睡眠
}

## 默认动画参数
const DEFAULT_TRANSITION_DURATION: float = 0.3  # 动画过渡时间（秒）
const DEFAULT_BLEND_TIME: float = 0.2  # 动画混合时间（秒）

## ==================== 系统状态 ====================

## 公共信号
signal animation_changed(state: AnimationState, mode: CompositionMode)
signal composition_mode_changed(mode: CompositionMode)
signal animation_completed(state: AnimationState)

## 私有变量
var _current_state: AnimationState = AnimationState.IDLE
var _current_mode: CompositionMode = CompositionMode.INSIDE
var _f2_module: Node = null  # F2状态机模块引用
var _animation_player: AnimationPlayer = null  # 动画播放器节点
var _sprite_node: Sprite2D = null  # 角色精灵节点
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

	# 创建动画节点（如果不存在）
	_setup_animation_nodes()

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
	if _animation_player and _animation_player.is_playing():
		_animation_player.stop()
		_is_animating = false

	status = IModule.ModuleStatus.STOPPED
	print("[C1] 角色动画系统已停止")

## IModule.shutdown() 实现
func shutdown() -> void:
	print("[C1] 关闭角色动画系统...")

	# 清理动画资源
	if _animation_player:
		_animation_player.queue_free()
		_animation_player = null

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

	if not _animation_player:
		issues.append("动画播放器未初始化")

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

## ==================== 私有辅助方法 ====================

func _setup_animation_nodes() -> void:
	# 创建角色精灵节点
	_sprite_node = Sprite2D.new()
	_sprite_node.name = "CharacterSprite"
	add_child(_sprite_node)

	# 创建动画播放器
	_animation_player = AnimationPlayer.new()
	_animation_player.name = "AnimationPlayer"
	add_child(_animation_player)

	# TODO: 加载动画资源并添加到动画播放器
	print("[C1] 动画节点已创建")

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

func _on_f2_state_changed(new_state: String) -> void:
	# 将F2状态字符串映射到动画状态枚举
	var anim_state = _map_f2_state_to_animation(new_state)

	# 切换动画状态
	change_state(anim_state)

func _map_f2_state_to_animation(f2_state: String) -> AnimationState:
	# 简单映射：F2状态名 -> 动画状态
	match f2_state:
		"idle":
			return AnimationState.IDLE
		"thinking":
			return AnimationState.THINKING
		"working":
			return AnimationState.WORKING
		"playing":
			return AnimationState.PLAYING
		"sleeping":
			return AnimationState.SLEEPING
		_:
			push_warning("[C1] 未知F2状态: %s，默认使用IDLE" % f2_state)
			return AnimationState.IDLE

func _play_animation(state: AnimationState, mode: CompositionMode) -> void:
	# 根据状态和模式生成动画名称
	var anim_name = _get_animation_name(state, mode)

	if not _animation_player.has_animation(anim_name):
		push_error("[C1] 动画不存在: %s" % anim_name)
		return

	# 播放动画
	_animation_player.play(anim_name, -1, 1.0, false)
	_is_animating = true

	print("[C1] 播放动画: %s" % anim_name)
	animation_changed.emit(state, mode)

	# 监听动画完成
	# 注意：Godot AnimationPlayer 的 animation_finished 信号在动画播放完成时触发
	_animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _get_animation_name(state: AnimationState, mode: CompositionMode) -> String:
	# 动画命名模式：状态_模式
	# 例如：idle_inside, thinking_leaning_out
	var state_str = AnimationState.keys()[state].to_lower()
	var mode_str = CompositionMode.keys()[mode].to_lower()
	return "%s_%s" % [state_str, mode_str]

func _on_animation_finished(anim_name: String) -> void:
	_is_animating = false

	# 解析动画名称获取状态
	var parts = anim_name.split("_")
	if parts.size() >= 1:
		var state_str = parts[0].to_upper()
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