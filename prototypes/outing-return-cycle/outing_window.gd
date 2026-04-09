# PROTOTYPE - NOT FOR PRODUCTION
# Question: Can the outing-return cycle create a sense of "companionship"?
# Date: 2026-04-07
# Purpose: Test core C2 Outing-Return Cycle mechanics

extends Control

# 状态枚举
enum State {
	AT_HOME,      # 在家状态
	AWAY,         # 外出中
	COOLDOWN,     # 归来冷却期
}

# 调谐参数 (原型简化)
const MIN_OUTING_INTERVAL = 20.0   # 保底冷却时间 (秒，原型中1秒=1分钟)
const RESTLESSNESS_PER_MINUTE = 5  # 每分钟累积的不安度（符合C2设计）
const RESTLESSNESS_MAX = 100       # 不安度上限，达到后强制出发（符合C2设计）
const FORCE_OUTING_THRESHOLD = 90  # 强制外出阈值 (90% of RESTLESSNESS_MAX)
const MIN_OUTING_DURATION = 10.0   # 最小外出时长 (秒)
const MAX_OUTING_DURATION = 45.0   # 最大外出时长 (秒)

# 状态变量
var current_state = State.AT_HOME
var restlessness = 0.0  # 不安度 (0-100, 符合C2设计)
var cooldown_timer = 0.0
var outing_timer = 0.0
var outing_duration = 0.0
var simulated_minutes = 0  # 模拟的分钟数
var outing_purpose = {}   # 存储外出目的，确保叙事连贯性

# 生成外出目的 (包含目的地、理由、情绪基调、归来主题)
func _generate_outing_purpose():
	var purposes = [
		{
			"destination": "图书馆",
			"reason": "想找一本关于星星的书",
			"mood": "curious",
			"return_themes": ["看到有趣的天文图，想起小时候看星星的夜晚", "发现一本旧日记，里面夹着干枯的枫叶", "和管理员聊了天，他推荐了一本冷门的好书"]
		},
		{
			"destination": "咖啡馆",
			"reason": "和小林约了见面",
			"mood": "social",
			"return_themes": ["小林分享了她在京都的旅行见闻，那些古老的庭院真美", "尝试了新的咖啡豆，有种柑橘的香气", "讨论了最近读的一本书，我们对结局有不同的理解"]
		},
		{
			"destination": "公园",
			"reason": "想看看春天的花开得怎样",
			"mood": "contemplative",
			"return_themes": ["看到樱花飘落，像下了一场淡粉色的雪", "遇到遛狗的老人，他的柴犬很亲人", "在长椅上写了点东西，关于时间和季节的变化"]
		},
		{
			"destination": "市场",
			"reason": "买点新鲜的蔬菜",
			"mood": "practical",
			"return_themes": ["发现一种没见过的紫色水果，摊主说是本地的特产", "和卖菜的阿姨聊了种植方法，她送了我一把小葱", "看到手工艺人在编织篮子，手指翻飞像在跳舞"]
		},
		{
			"destination": "美术馆",
			"reason": "有新展出的水墨画",
			"mood": "inspired",
			"return_themes": ["有一幅画让人想起家乡的山，雾蒙蒙的很有意境", "听到艺术家讲解创作理念，他说空白也是画的一部分", "在纪念品店买了明信片，想寄给远方的朋友"]
		}
	]
	return purposes[randi() % purposes.size()]

# 节点引用
@onready var state_label = $StatusPanel/VBoxContainer/StateLabel
@onready var time_label = $StatusPanel/VBoxContainer/TimeLabel
@onready var restlessness_label = $StatusPanel/VBoxContainer/RestlessnessLabel
@onready var log_text = $LogPanel/LogText
@onready var out_button = $StatusPanel/VBoxContainer/ButtonContainer/OutButton
@onready var return_button = $StatusPanel/VBoxContainer/ButtonContainer/ReturnButton

# 初始化
func _ready():
	print("原型脚本加载成功")

	# 设置窗口拖拽
	# 在Godot 4中，Control节点本身不直接支持拖拽，需要处理输入事件
	set_process_input(true)

	# 启动时间模拟器
	var timer = Timer.new()
	timer.wait_time = 1.0  # 1秒 = 1分钟 (加速)
	timer.autostart = true
	timer.timeout.connect(_on_minute_tick)
	add_child(timer)

	# 初始日志
	_add_log("原型启动: 外出-归来循环测试")
	_add_log("时间加速: 1秒 = 1分钟")
	_add_log("保底冷却: " + str(MIN_OUTING_INTERVAL) + "秒")
	_add_log("外出时长: " + str(MIN_OUTING_DURATION) + "-" + str(MAX_OUTING_DURATION) + "秒")

	_update_ui()

	# 连接按钮信号
	out_button.pressed.connect(_on_out_button_pressed)
	return_button.pressed.connect(_on_return_button_pressed)

# 每分钟tick (原型加速: 1秒 = 1分钟)
func _on_minute_tick():
	simulated_minutes += 1

	match current_state:
		State.AT_HOME:
			_process_home_state()
		State.COOLDOWN:
			_process_cooldown_state()
		State.AWAY:
			_process_away_state()

	_update_ui()

# 处理在家状态
func _process_home_state():
	# 累积不安度 (符合C2设计: 每分钟+5, 上限100)
	restlessness = min(restlessness + RESTLESSNESS_PER_MINUTE, RESTLESSNESS_MAX)

	# 检查是否达到外出尝试阈值 (符合C2设计)
	# 强制出发条件: restlessness >= RESTLESSNESS_MAX
	if restlessness >= RESTLESSNESS_MAX:
		_trigger_outing()
	# 随机尝试条件: random < restlessness / RESTLESSNESS_MAX
	elif randf() < restlessness / float(RESTLESSNESS_MAX):
		_trigger_outing()

# 处理冷却状态
func _process_cooldown_state():
	cooldown_timer -= 1.0  # 1分钟

	if cooldown_timer <= 0:
		current_state = State.AT_HOME
		_add_log("冷却结束，可以再次外出了")

# 处理外出状态
func _process_away_state():
	outing_timer -= 1.0  # 1分钟

	if outing_timer <= 0:
		_trigger_return()

# 触发外出
func _trigger_outing():
	# 检查冷却期
	if current_state == State.COOLDOWN:
		return

	# 设置外出参数
	current_state = State.AWAY
	outing_duration = MIN_OUTING_DURATION + randf() * (MAX_OUTING_DURATION - MIN_OUTING_DURATION)
	outing_timer = outing_duration

	# 重置不安度 (符合C2设计: 出发后重置为0)
	restlessness = 0.0

	# 生成外出目的 (原型简化，但符合叙事连贯性需求)
	# 存储外出目的，确保归来叙事一致
	outing_purpose = _generate_outing_purpose()

	_add_log("📤 出门了: " + outing_purpose.destination + " - " + outing_purpose.reason)

# 触发归来
func _trigger_return():
	current_state = State.COOLDOWN
	cooldown_timer = MIN_OUTING_INTERVAL

	# 生成连贯的归来叙事 (基于外出目的)
	var feedback = _generate_return_feedback()

	_add_log(feedback)
	# 注意: 生产版本中不显示"冷却期"这样的测试信息

# 更新UI
func _update_ui():
	# 状态显示
	match current_state:
		State.AT_HOME:
			state_label.text = "状态: 在家 🏠"
		State.COOLDOWN:
			state_label.text = "状态: 冷却中 ⏱️ (" + str(int(cooldown_timer)) + "秒)"
		State.AWAY:
			state_label.text = "状态: 外出中 🚶 (" + str(int(outing_timer)) + "秒)"

	# 时间显示
	var hours = simulated_minutes / 60
	var minutes = simulated_minutes % 60
	time_label.text = "时间: %02d:%02d" % [hours, minutes]

	# 外出压力
	restlessness_label.text = "外出压力: %.2f" % restlessness

# 添加日志
func _add_log(message: String):
	# 使用简单的时间戳格式
	var now = Time.get_datetime_dict_from_system()
	var timestamp = "%02d:%02d:%02d" % [now.hour, now.minute, now.second]
	log_text.text += "\n[" + timestamp + "] " + message
	# 限制日志长度
	var lines = log_text.text.split("\n")
	if lines.size() > 20:
		log_text.text = "\n".join(lines.slice(-20))

# 输入处理 - 实现窗口拖拽 (暂时注释，Godot 4.6.1 API需要调整)
# func _input(event):
# 	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
# 		if event.pressed:
# 			# 开始拖拽
# 			get_window().drag(event.position, true)
# 		else:
# 			# 结束拖拽
# 			get_window().drag(Vector2(), false)

# 手动触发外出 (测试用)
func _on_out_button_pressed():
	if current_state == State.AT_HOME:
		_trigger_outing()

# 手动触发归来 (测试用)
func _on_return_button_pressed():
	if current_state == State.AWAY:
		_trigger_return()

# 生成归来反馈 (基于外出目的，确保叙事连贯)
func _generate_return_feedback() -> String:
	if outing_purpose.has("return_themes") and outing_purpose.return_themes.size() > 0:
		var theme = outing_purpose.return_themes[randi() % outing_purpose.return_themes.size()]
		var mood_emoji = ""
		match outing_purpose.mood:
			"curious": mood_emoji = "🔍"
			"social": mood_emoji = "👥"
			"contemplative": mood_emoji = "💭"
			"practical": mood_emoji = "🛒"
			"inspired": mood_emoji = "🎨"
			_: mood_emoji = "📝"
		return "📥 回来了: " + mood_emoji + " " + theme
	else:
		return "📥 回来了"
