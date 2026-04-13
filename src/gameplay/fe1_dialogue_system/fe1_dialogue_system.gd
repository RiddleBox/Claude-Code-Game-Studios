# src/gameplay/fe1_dialogue_system/fe1_dialogue_system.gd
# Fe1对话气泡系统
# 实现IModule接口，负责管理对话的触发、排队、显示

class_name DialogueSystem
extends Node


## IModule接口实现
var module_id: String = "fe1_dialogue_system"
var module_name: String = "对话系统"
var module_version: String = "1.0.0"
var dependencies: Array[String] = ["ui_framework", "f1_window_system"]
var optional_dependencies: Array[String] = ["c2_outing_return_cycle", "c1_character_animation_system"]
var config_path: String = "res://data/config/fe1_dialogue_system.json"
var category: String = "gameplay"
var priority: String = "medium"
var status: IModule.ModuleStatus = IModule.ModuleStatus.UNINITIALIZED
var last_error: Dictionary = {}

## 系统常量
const DEFAULT_BUBBLE_DURATION = 4.0
const MIN_BUBBLE_INTERVAL = 2.0  # 气泡之间最小间隔时间
const MAX_QUEUE_SIZE = 3  # 队列最大长度，超过的会被丢弃

## 公共信号
signal dialogue_triggered(content: String, style: int)  # 对话触发
signal dialogue_clicked(content: String)  # 对话被点击
signal dialogue_finished(content: String)  # 对话显示完成

## 私有变量
var _ui_module: UIModule = null
var _f1_window: Node = null
var _bubble_parent: Node2D = null  # 气泡父节点（角色位置上方）

var _dialogue_queue: Array = []  # 等待显示的对话队列
var _is_showing_bubble: bool = false  # 是否正在显示气泡
var _last_bubble_time: float = 0.0  # 上次气泡显示时间
var _idle_timer: Timer = null  # 空闲随机对话计时器

## 对话配置（从JSON加载）
var _idle_dialogues: Array = []
var _event_dialogues: Dictionary = {}

# ==================== IModule接口方法 ====================
func initialize(_config: Dictionary = {}) -> bool:
	print("[Fe1] 初始化对话系统")
	status = IModule.ModuleStatus.INITIALIZING

	# 获取依赖模块
	if not _connect_to_dependencies():
		push_error("[Fe1] 无法连接到依赖模块")
		return false

	# 创建气泡父节点（放在F1窗口里，和角色同层级）
	_create_bubble_parent()

	# 加载对话配置
	_load_dialogue_config()

	# 初始化空闲计时器
	_setup_idle_timer()

	status = IModule.ModuleStatus.INITIALIZED
	print("[Fe1] 对话系统初始化完成")
	return true

func start() -> bool:
	print("[Fe1] 启动对话系统")
	status = IModule.ModuleStatus.STARTING

	# 开始空闲对话计时
	if _idle_timer:
		_idle_timer.start()

	status = IModule.ModuleStatus.RUNNING
	print("[Fe1] 对话系统启动完成")
	return true

func stop() -> void:
	print("[Fe1] 停止对话系统")
	status = IModule.ModuleStatus.STOPPING

	# 停止计时器
	if _idle_timer and _idle_timer.is_running():
		_idle_timer.stop()

	# 清除所有正在显示和等待的对话
	_clear_all_dialogues()

	status = IModule.ModuleStatus.STOPPED
	print("[Fe1] 对话系统已停止")

func shutdown() -> void:
	print("[Fe1] 关闭对话系统")

	# 清理资源
	if _bubble_parent:
		_bubble_parent.queue_free()
		_bubble_parent = null

	_dialogue_queue.clear()
	_idle_dialogues.clear()
	_event_dialogues.clear()

	status = IModule.ModuleStatus.SHUTDOWN
	print("[Fe1] 对话系统已关闭")

# ==================== 公共API ====================
## 触发对话
## @param text: 对话内容
## @param style: 气泡样式，默认普通
## @param duration: 显示时长，0表示永久显示直到点击，默认4秒
## @param priority: 优先级，数值越大越优先，会插队显示
func show_dialogue(text: String, style: int = DialogueBubble.BubbleStyle.NORMAL, duration: float = DEFAULT_BUBBLE_DURATION, prio: int = 0) -> bool:
	if text.is_empty():
		push_warning("[Fe1] 尝试显示空对话")
		return false

	# 构建对话数据
	var dialogue = {
		"text": text,
		"style": style,
		"duration": duration,
		"priority": prio,
		"timestamp": Time.get_unix_time_from_system()
	}

	# 如果当前没有显示，且间隔足够，直接显示
	if not _is_showing_bubble and Time.get_ticks_msec() - _last_bubble_time >= MIN_BUBBLE_INTERVAL * 1000:
		_show_dialogue(dialogue)
		return true
	else:
		# 加入队列，按优先级排序
		if _dialogue_queue.size() < MAX_QUEUE_SIZE:
			# 插入到合适的位置（优先级高的在前，同优先级按时间排序）
			var inserted = false
			for i in range(_dialogue_queue.size()):
				if dialogue["priority"] > _dialogue_queue[i]["priority"]:
					_dialogue_queue.insert(i, dialogue)
					inserted = true
					break
			if not inserted:
				_dialogue_queue.append(dialogue)
			print("[Fe1] 对话加入队列，当前队列长度: %d" % _dialogue_queue.size())
			return true
		else:
			print("[Fe1] 对话队列已满，丢弃对话: %s" % text)
			return false

## 触发事件对话
## @param event_type: 事件类型（比如"outing_start", "outing_return", "idle"等）
## @param duration: 显示时长，默认4秒
func trigger_event_dialogue(event_type: String, duration: float = DEFAULT_BUBBLE_DURATION) -> bool:
	if not _event_dialogues.has(event_type):
		print("[Fe1] 没有对应事件的对话配置: %s" % event_type)
		return false

	var dialogues = _event_dialogues[event_type]
	if dialogues.is_empty():
		return false

	# 随机选择一条对话
	var selected = dialogues[randi() % dialogues.size()]
	var style = selected.get("style", DialogueBubble.BubbleStyle.NORMAL)

	return show_dialogue(selected["content"], style, duration, 1)

## 立即关闭所有对话
func close_all_dialogues() -> void:
	_clear_all_dialogues()

## 加载自定义对话配置
func load_custom_config(_config_path: String) -> bool:
	if not FileAccess.file_exists(config_path):
		push_error("[Fe1] 对话配置文件不存在: %s" % config_path)
		return false

	var file = FileAccess.open(config_path, FileAccess.READ)
	if not file:
		push_error("[Fe1] 无法打开对话配置文件: %s" % config_path)
		return false

	var content = file.get_as_text()
	file.close()

	var config = JSON.parse_string(content)
	if not config is Dictionary:
		push_error("[Fe1] 对话配置文件格式错误: %s" % config_path)
		return false

	_process_config(config)
	print("[Fe1] 加载自定义对话配置成功: %s" % config_path)
	return true

# ==================== 内部方法 ====================
func _connect_to_dependencies() -> bool:
	# 获取UI模块
	var app = get_parent()
	if not app or not app.has_method("get_module"):
		push_error("[Fe1] 无法获取App节点")
		return false

	_ui_module = app.get_module("ui_framework")
	if not _ui_module:
		push_error("[Fe1] 无法获取UI框架模块")
		return false

	# 获取F1窗口模块
	_f1_window = app.get_module("f1_window_system")
	if not _f1_window:
		push_error("[Fe1] 无法获取F1窗口系统模块")
		return false

	print("[Fe1] 依赖模块连接成功")
	return true

func _create_bubble_parent() -> void:
	# 创建气泡父节点，放在F1窗口的根节点上，方便调整位置
	_bubble_parent = Node2D.new()
	_bubble_parent.name = "DialogueBubbleContainer"
	_bubble_parent.z_index = 100  # 显示在角色前面

	# 初始位置在角色头顶上方，基于F1窗口的角色精灵位置
	# 默认居中，距离顶部50像素
	var window_size = get_viewport().size if get_viewport() else Vector2(400, 600)
	_bubble_parent.position = Vector2(window_size.x / 2, 50)

	_f1_window.add_child(_bubble_parent)
	print("[Fe1] 气泡容器创建完成")

func _load_dialogue_config() -> void:
	# 先加载默认配置
	var default_config_path = "res://data/config/dialogues/default_dialogues.json"
	if FileAccess.file_exists(default_config_path):
		var file = FileAccess.open(default_config_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var config = JSON.parse_string(content)
			if config is Dictionary:
				_process_config(config)
				print("[Fe1] 加载默认对话配置成功")
			else:
				push_warning("[Fe1] 默认对话配置格式错误")
	else:
		# 如果没有配置文件，使用内置默认对话
		_setup_default_dialogues()
		print("[Fe1] 没有找到对话配置文件，使用内置默认对话")

func _process_config(config: Dictionary) -> void:
	# 处理空闲对话
	if config.has("idle_dialogues") and config["idle_dialogues"] is Array:
		_idle_dialogues = config["idle_dialogues"]
		print("[Fe1] 加载空闲对话: %d 条" % _idle_dialogues.size())

	# 处理事件对话
	if config.has("event_dialogues") and config["event_dialogues"] is Dictionary:
		_event_dialogues = config["event_dialogues"]
		print("[Fe1] 加载事件对话类型: %d 种" % _event_dialogues.size())

func _setup_default_dialogues() -> void:
	# 内置的默认对话，防止没有配置文件时也能运行
	_idle_dialogues = [
		{"content": "今天天气真好~", "style": DialogueBubble.BubbleStyle.HAPPY},
		{"content": "你在忙什么呢？", "style": DialogueBubble.BubbleStyle.NORMAL},
		{"content": "有点无聊，要不要出去走走？", "style": DialogueBubble.BubbleStyle.THINKING},
		{"content": "工作别太累啦，注意休息~", "style": DialogueBubble.BubbleStyle.NORMAL},
		{"content": "好期待今天会有什么有趣的事~", "style": DialogueBubble.BubbleStyle.HAPPY}
	]

	_event_dialogues = {
		"outing_start": [
			{"content": "我出门啦，很快回来~", "style": DialogueBubble.BubbleStyle.HAPPY},
			{"content": "出去散散步，一会见！", "style": DialogueBubble.BubbleStyle.NORMAL}
		],
		"outing_return": [
			{"content": "我回来啦！外面好热闹~", "style": DialogueBubble.BubbleStyle.HAPPY},
			{"content": "回来啦，今天玩得很开心~", "style": DialogueBubble.BubbleStyle.HAPPY}
		],
		"idle_random": _idle_dialogues,
		"mouse_enter": [
			{"content": "呀，你摸到我啦~", "style": DialogueBubble.BubbleStyle.SURPRISE},
			{"content": "哈喽~", "style": DialogueBubble.BubbleStyle.HAPPY}
		],
		"mouse_click": [
			{"content": "哎呀，别戳我~", "style": DialogueBubble.BubbleStyle.SURPRISE},
			{"content": "怎么啦，有事吗？", "style": DialogueBubble.BubbleStyle.NORMAL}
		]
	}

func _setup_idle_timer() -> void:
	_idle_timer = Timer.new()
	_idle_timer.one_shot = true
	_idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(_idle_timer)

	# 设置随机的触发间隔（1~3分钟随机）
	_reset_idle_timer()

func _reset_idle_timer() -> void:
	if _idle_timer:
		var random_interval = randi_range(60, 180)  # 1到3分钟随机
		_idle_timer.wait_time = random_interval
		_idle_timer.start()
		print("[Fe1] 下次随机对话将在 %.1f 秒后触发" % random_interval)

func _on_idle_timer_timeout() -> void:
	# 触发随机空闲对话，优先级0
	if not _is_showing_bubble and _idle_dialogues.size() > 0:
		trigger_event_dialogue("idle_random")

	# 重置计时器
	_reset_idle_timer()

func _show_dialogue(dialogue: Dictionary) -> void:
	if not _bubble_parent or not _ui_module:
		push_error("[Fe1] 气泡容器或UI模块不存在，无法显示对话")
		return

	_is_showing_bubble = true
	_last_bubble_time = Time.get_ticks_msec()

	# 创建气泡
	var bubble = DialogueBubble.new()
	bubble.set_content(dialogue["text"], dialogue["style"], dialogue["duration"])

	# 连接信号
	bubble.bubble_finished.connect(_on_bubble_finished)
	bubble.bubble_clicked.connect(func():
		dialogue_clicked.emit(dialogue["text"])
	)

	# 添加到父节点
	_bubble_parent.add_child(bubble)

	# 播放出现动画
	bubble.modulate = Color(1, 1, 1, 0)
	bubble.position = Vector2(0, 20)  # 初始位置偏下
	var tween = bubble.create_tween()
	tween.parallel().tween_property(bubble, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(bubble, "position:y", 0.0, 0.2)

	dialogue_triggered.emit(dialogue["text"], dialogue["style"])
	print("[Fe1] 显示对话: %s" % dialogue["text"])

func _on_bubble_finished() -> void:
	_is_showing_bubble = false

	# 队列里有等待的对话，显示下一个
	if _dialogue_queue.size() > 0:
		var next_dialogue = _dialogue_queue.pop_front()
		# 延迟一点时间再显示下一个
		await get_tree().create_timer(0.5).timeout
		_show_dialogue(next_dialogue)

	dialogue_finished.emit("")

func _clear_all_dialogues() -> void:
	# 清除队列
	_dialogue_queue.clear()

	# 关闭当前显示的气泡
	if _bubble_parent:
		for child in _bubble_parent.get_children():
			if child is DialogueBubble:
				child.hide_immediately()

	_is_showing_bubble = false
