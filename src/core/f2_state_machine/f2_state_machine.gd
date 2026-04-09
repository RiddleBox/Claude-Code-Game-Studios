# core/f2_state_machine/f2_state_machine.gd
# F2 角色状态机模块化版本
# 实现IModule接口，支持模块化架构

class_name F2StateMachine
extends Node

## IModule接口实现
var module_id: String = "f2_state_machine"
var module_name: String = "角色状态机"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["f1_window_system"]
var optional_dependencies: Array[String] = []
var config_path: String = "res://data/config/f2_state_machine.json"
var category: String = "core"
var priority: String = "high"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## 原F2系统属性（从设计文档）
enum CharacterState {
	IDLE,            # 待机状态 (最低优先级)
	ATTENTIVE,       # 注意状态 (鼠标悬停)
	INTERACTING,     # 互动状态 (点击菜单)
	TALKING,         # 对话状态
	REACTING,        # 反应状态 (事件或语音确认)
	PERFORMING,      # 演出状态 (Aria响应/事件线)
	AWAY,            # 外出状态 (不可被打断)
	RETURNING,       # 归来状态 (不可被打断，最高优先级)
}

enum ReactionType {
	EVENT_REACTION,      # 事件触发的反应 (Reaction A)
	VOICE_CONFIRMATION,  # 语音确认反应 (Reaction B)
	ARIA_TIMEOUT,        # Aria响应超时反应
}

## 可调参数 (从设计文档)
const IDLE_FIDGET_INTERVAL: float = 45.0  # 秒
const ATTENTIVE_HOVER_DELAY: float = 1.5   # 秒
const ATTENTIVE_TIMEOUT: float = 8.0       # 秒
const INTERACTING_TIMEOUT: float = 5.0     # 秒 (点击后无操作超时)
const ARIA_RESPONSE_TIMEOUT: float = 30.0  # 秒

## 公共接口 (与原F2兼容)
var current_state: CharacterState = CharacterState.IDLE
var pending_departure: bool = false

## 私有变量
var _state_timer: float = 0.0
var _mouse_hover_timer: float = 0.0
var _aria_response_timer: float = 0.0
var _is_mouse_in_window: bool = false
var _current_reaction_type: ReactionType = ReactionType.EVENT_REACTION

## 状态机信号 (与原F2兼容)
signal state_changed(old_state: CharacterState, new_state: CharacterState)
signal state_change_requested(requested_state: CharacterState, accepted: bool, reason: String)
signal departure_accepted
signal departure_declined

## F1窗口系统引用
var _f1_system: Node = null

## IModule.initialize() 实现
func initialize(_config: Dictionary = {}) -> bool:
	print("[F2] 初始化角色状态机...")
	status = IModule.ModuleStatus.INITIALIZING

	# 应用配置
	# TODO: 从config加载参数值（如IDLE_FIDGET_INTERVAL等）

	# 初始化状态为IDLE
	current_state = CharacterState.IDLE

	# 重置所有计时器
	_reset_timers()

	# 启用_process回调
	set_process(true)

	status = IModule.ModuleStatus.INITIALIZED
	print("[F2] 角色状态机初始化完成")
	return true

## IModule.start() 实现
func start() -> bool:
	print("[F2] 启动角色状态机...")
	status = IModule.ModuleStatus.STARTING

	# 连接到F1窗口系统（依赖注入）
	# 注意：依赖模块应在此时已初始化
	# 连接将通过模块加载器的事件系统完成

	status = IModule.ModuleStatus.RUNNING
	print("[F2] 角色状态机启动完成")
	return true

## IModule.stop() 实现
func stop() -> void:
	print("[F2] 停止角色状态机...")
	status = IModule.ModuleStatus.STOPPING

	# 禁用_process回调
	set_process(false)

	status = IModule.ModuleStatus.STOPPED
	print("[F2] 角色状态机已停止")

## IModule.shutdown() 实现
func shutdown() -> void:
	print("[F2] 关闭角色状态机...")

	# 清理资源
	_f1_system = null

	status = IModule.ModuleStatus.SHUTDOWN
	print("[F2] 角色状态机已关闭")

## IModule.reload_config() 实现
func reload_config(_new_config: Dictionary = {}) -> bool:
	print("[F2] 重新加载配置...")

	# 应用新配置
	# TODO: 实现配置热重载

	print("[F2] 配置已重新加载")
	return true

## 连接到F1窗口系统（由模块加载器调用）
func connect_to_f1_system(f1_system: Node) -> void:
	_f1_system = f1_system
	print("[F2] 已连接到F1窗口系统")

	# 注册到F1的事件系统
	# TODO: 通过信号连接

## ========== 原F2系统功能（保持兼容）==========

func _ready() -> void:
	# 注意：在模块化架构中，初始化通过initialize()进行
	# _ready()仅用于设置节点层次结构
	pass

func _process(delta: float) -> void:
	# 状态机时间推进
	_state_timer += delta

	# 各状态特有逻辑
	match current_state:
		CharacterState.IDLE:
			_process_idle_state(delta)
		CharacterState.ATTENTIVE:
			_process_attentive_state(delta)
		CharacterState.INTERACTING:
			_process_interacting_state(delta)
		CharacterState.REACTING:
			_process_reacting_state(delta)

	# 检查延迟出发
	_check_pending_departure()

## 请求状态变更 (统一入口，与原F2兼容)
func request_state_change(new_state: CharacterState, requester: String = "unknown") -> bool:
	_print_debug("[F2] State change requested: %s → %s (by: %s)" % [_state_to_string(current_state), _state_to_string(new_state), requester])

	# 检查是否可以转换到新状态
	if not _can_transition_to(new_state):
		_print_debug("[F2] State change rejected: cannot transition from %s to %s" % [_state_to_string(current_state), _state_to_string(new_state)])
		state_change_requested.emit(new_state, false, "Transition not allowed")
		return false

	# 执行状态转换
	var old_state = current_state
	current_state = new_state

	# 重置状态特定计时器
	_on_state_exit(old_state)
	_on_state_enter(new_state, old_state)

	# 广播状态变更信号
	state_changed.emit(old_state, new_state)
	_print_debug("[F2] State changed: %s → %s" % [_state_to_string(old_state), _state_to_string(new_state)])

	state_change_requested.emit(new_state, true, "Success")
	return true

## 查询是否可接受某状态请求 (与原F2兼容)
func is_available_for(state: CharacterState) -> bool:
	return _can_transition_to(state)

## 触发外出请求 (C2专用接口，与原F2兼容)
func request_departure() -> void:
	_print_debug("[F2] Departure requested by C2")

	# 检查当前状态是否可以立即出发
	if _can_depart_immediately():
		# 立即出发
		request_state_change(CharacterState.AWAY, "C2")
		departure_accepted.emit()
		_print_debug("[F2] Departure accepted immediately")
	else:
		# 设置延迟出发标志
		pending_departure = true
		departure_declined.emit()
		_print_debug("[F2] Departure declined, pending until state changes")

## 触发归来请求 (C2专用接口，与原F2兼容)
func request_return() -> void:
	_print_debug("[F2] Return requested by C2")

	# 只有AWAY状态可以转换为RETURNING
	if current_state == CharacterState.AWAY:
		request_state_change(CharacterState.RETURNING, "C2")
	else:
		_print_debug("[F2] Return request ignored: not in AWAY state")

## 触发反应 (通用事件反应，与原F2兼容)
func trigger_reaction(reaction_type: ReactionType = ReactionType.EVENT_REACTION) -> void:
	_print_debug("[F2] Reaction triggered: %s" % _reaction_to_string(reaction_type))

	# 设置反应类型
	_current_reaction_type = reaction_type

	# 请求进入REACTING状态
	if request_state_change(CharacterState.REACTING, "event_system"):
		_print_debug("[F2] Reaction state entered")
	else:
		_print_debug("[F2] Reaction state rejected")

## 语音输入检测 (F5 Aria接口层，与原F2兼容)
func on_voice_input_detected() -> void:
	_print_debug("[F2] Voice input detected")

	# 触发语音确认反应
	trigger_reaction(ReactionType.VOICE_CONFIRMATION)

## Aria响应就绪 (F5 Aria接口层，与原F2兼容)
func on_aria_response_ready() -> void:
	_print_debug("[F2] Aria response ready")

	# 只有在REACTING状态且是语音确认反应时才转换
	if current_state == CharacterState.REACTING and _current_reaction_type == ReactionType.VOICE_CONFIRMATION:
		# 重置超时计时器
		_aria_response_timer = 0.0

		# 转换到PERFORMING状态
		request_state_change(CharacterState.PERFORMING, "F5")
	else:
		_print_debug("[F2] Aria response ignored: not in VOICE_CONFIRMATION reaction")

## 触发演出 (事件线/Aria任务完成，与原F2兼容)
func trigger_performance(performance_id: String) -> void:
	_print_debug("[F2] Performance triggered: %s" % performance_id)

	# TODO: 验证performance_id是否存在
	# 暂时假设存在，直接进入PERFORMING状态
	request_state_change(CharacterState.PERFORMING, "event_system")

## 对话结束 (Fe1对话系统，与原F2兼容)
func on_dialogue_ended() -> void:
	_print_debug("[F2] Dialogue ended")

	# 从TALKING状态回到IDLE
	if current_state == CharacterState.TALKING:
		request_state_change(CharacterState.IDLE, "Fe1")

## 演出结束 (演出系统，与原F2兼容)
func on_performance_ended() -> void:
	_print_debug("[F2] Performance ended")

	# 从PERFORMING状态回到IDLE或TALKING
	# TODO: 根据是否有碎片内容决定回到TALKING还是IDLE
	# 暂时回到IDLE
	if current_state == CharacterState.PERFORMING:
		request_state_change(CharacterState.IDLE, "performance_system")

## ========== 输入处理接口（由F1调用）==========

## 鼠标进入窗口区域 (由F1调用)
func on_mouse_entered_window() -> void:
	_is_mouse_in_window = true
	_mouse_hover_timer = 0.0

## 鼠标离开窗口区域 (由F1调用)
func on_mouse_exited_window() -> void:
	_is_mouse_in_window = false

	# 如果在ATTENTIVE状态，回到IDLE
	if current_state == CharacterState.ATTENTIVE:
		_print_debug("[F2] Mouse left window, returning to IDLE from ATTENTIVE")
		request_state_change(CharacterState.IDLE, "mouse_exit")

## 鼠标悬停更新 (由F1在_process中调用)
func update_mouse_hover(delta: float) -> void:
	if _is_mouse_in_window:
		_mouse_hover_timer += delta

		# 检查是否触发ATTENTIVE状态
		if current_state == CharacterState.IDLE and _mouse_hover_timer >= ATTENTIVE_HOVER_DELAY:
			_print_debug("[F2] Mouse hover detected, entering ATTENTIVE state")
			request_state_change(CharacterState.ATTENTIVE, "mouse_hover")

## 角色区域被点击 (由F1调用)
func on_character_clicked() -> void:
	_print_debug("[F2] Character clicked")

	# 从IDLE或ATTENTIVE状态进入INTERACTING
	if current_state == CharacterState.IDLE or current_state == CharacterState.ATTENTIVE:
		request_state_change(CharacterState.INTERACTING, "player_click")

## ========== 私有辅助方法（与原F2相同）==========

func _can_transition_to(new_state: CharacterState) -> bool:
	# 特殊情况: AWAY状态不能被打断 (除了RETURNING)
	if current_state == CharacterState.AWAY and new_state != CharacterState.RETURNING:
		return false

	# 特殊情况: RETURNING状态不能被打断
	if current_state == CharacterState.RETURNING:
		return false

	# 特殊情况: PERFORMING状态只能被更高优先级打断
	if current_state == CharacterState.PERFORMING:
		return _get_state_priority(new_state) > _get_state_priority(current_state)

	# 特殊规则: 允许转换到IDLE状态 (基础状态)
	if new_state == CharacterState.IDLE:
		return true

	# 一般情况: 检查状态优先级
	var current_priority = _get_state_priority(current_state)
	var new_priority = _get_state_priority(new_state)

	# 相同或更高优先级允许转换
	return new_priority >= current_priority

func _can_depart_immediately() -> bool:
	# 根据设计文档，以下状态可立即出发:
	# IDLE, ATTENTIVE, REACTING(A)
	# 注意: 需要区分REACTING的类型

	match current_state:
		CharacterState.IDLE, CharacterState.ATTENTIVE:
			return true
		CharacterState.REACTING:
			# 只有事件反应可以立即出发
			return _current_reaction_type == ReactionType.EVENT_REACTION
		_:
			return false

func _get_state_priority(state: CharacterState) -> int:
	# 根据设计文档的状态优先级定义
	match state:
		CharacterState.IDLE:       return 0
		CharacterState.ATTENTIVE:  return 1
		CharacterState.INTERACTING: return 2
		CharacterState.TALKING:    return 3
		CharacterState.REACTING:   return 4
		CharacterState.PERFORMING: return 5
		CharacterState.AWAY:       return 6  # 实际上AWAY不可被打断，但需要优先级值
		CharacterState.RETURNING:  return 7  # 最高优先级
		_:                         return 0

func _process_idle_state(delta: float) -> void:
	# 检查是否触发自发反应 (IDLE_FIDGET_INTERVAL)
	if _state_timer >= IDLE_FIDGET_INTERVAL:
		_print_debug("[F2] Idle fidget interval reached, triggering random reaction (timer: %s)" % _state_timer)

		# 触发随机事件反应
		trigger_reaction(ReactionType.EVENT_REACTION)

		# 重置计时器
		_state_timer = 0.0
	else:
		# 调试输出：每5秒打印一次计时器状态
		if int(_state_timer) % 5 == 0 and int(_state_timer - delta) % 5 != 0:
			_print_debug("[F2] Idle timer: %s/%s" % [_state_timer, IDLE_FIDGET_INTERVAL])

func _process_attentive_state(delta: float) -> void:
	# 检查注意超时 (ATTENTIVE_TIMEOUT)
	if _state_timer >= ATTENTIVE_TIMEOUT:
		_print_debug("[F2] Attentive timeout, returning to IDLE")

		# 自动回到IDLE状态
		request_state_change(CharacterState.IDLE, "attentive_timeout")

		# 重置计时器
		_state_timer = 0.0

func _process_interacting_state(delta: float) -> void:
	# 检查互动超时 (INTERACTING_TIMEOUT)
	if _state_timer >= INTERACTING_TIMEOUT:
		_print_debug("[F2] Interacting timeout, returning to IDLE (timer: %s)" % _state_timer)

		# 自动回到IDLE状态
		request_state_change(CharacterState.IDLE, "interacting_timeout")

		# 重置计时器
		_state_timer = 0.0
	else:
		# 调试输出：每秒打印一次计时器状态
		if int(_state_timer) % 1 == 0 and int(_state_timer - delta) % 1 != 0:
			_print_debug("[F2] Interacting timer: %s/%s" % [_state_timer, INTERACTING_TIMEOUT])

func _process_reacting_state(delta: float) -> void:
	# 根据反应类型处理
	match _current_reaction_type:
		ReactionType.EVENT_REACTION:
			# 事件反应: 动画播放完自动回到IDLE
			# 这里简化处理: 固定2秒后返回
			if _state_timer >= 2.0:
				_print_debug("[F2] Event reaction completed, returning to IDLE")
				request_state_change(CharacterState.IDLE, "reaction_complete")

		ReactionType.VOICE_CONFIRMATION:
			# 语音确认: 检查Aria响应超时
			_aria_response_timer += delta
			if _aria_response_timer >= ARIA_RESPONSE_TIMEOUT:
				_print_debug("[F2] Aria response timeout, triggering failure reaction")

				# 触发超时反应
				_current_reaction_type = ReactionType.ARIA_TIMEOUT
				_state_timer = 0.0  # 重置状态计时器重新开始超时反应

		ReactionType.ARIA_TIMEOUT:
			# 超时反应: 固定2秒后返回IDLE
			if _state_timer >= 2.0:
				_print_debug("[F2] Aria timeout reaction completed, returning to IDLE")
				request_state_change(CharacterState.IDLE, "aria_timeout")

func _check_pending_departure() -> void:
	# 检查是否有延迟出发请求
	if pending_departure and current_state == CharacterState.IDLE:
		_print_debug("[F2] Pending departure triggered from IDLE state")

		# 清除标志
		pending_departure = false

		# 进入AWAY状态
		request_state_change(CharacterState.AWAY, "C2_pending")
		departure_accepted.emit()

func _on_state_enter(new_state: CharacterState, old_state: CharacterState) -> void:
	# 重置状态计时器
	_state_timer = 0.0

	# 状态进入特殊处理
	match new_state:
		CharacterState.REACTING:
			# 重置Aria响应计时器
			_aria_response_timer = 0.0

		CharacterState.ATTENTIVE:
			# 重置鼠标悬停计时器
			_mouse_hover_timer = 0.0

func _on_state_exit(old_state: CharacterState) -> void:
	# 状态退出清理
	pass

func _reset_timers() -> void:
	_state_timer = 0.0
	_mouse_hover_timer = 0.0
	_aria_response_timer = 0.0

## ========== 调试工具 ==========

func _state_to_string(state: CharacterState) -> String:
	match state:
		CharacterState.IDLE:       return "IDLE"
		CharacterState.ATTENTIVE:  return "ATTENTIVE"
		CharacterState.INTERACTING: return "INTERACTING"
		CharacterState.TALKING:    return "TALKING"
		CharacterState.REACTING:   return "REACTING"
		CharacterState.PERFORMING: return "PERFORMING"
		CharacterState.AWAY:       return "AWAY"
		CharacterState.RETURNING:  return "RETURNING"
		_:                         return "UNKNOWN"

func _reaction_to_string(reaction: ReactionType) -> String:
	match reaction:
		ReactionType.EVENT_REACTION:     return "EVENT_REACTION"
		ReactionType.VOICE_CONFIRMATION: return "VOICE_CONFIRMATION"
		ReactionType.ARIA_TIMEOUT:       return "ARIA_TIMEOUT"
		_:                               return "UNKNOWN"

func _print_debug(message: String) -> void:
	print(message)