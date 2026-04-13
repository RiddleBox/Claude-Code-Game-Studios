# src/ui/components/dialogue_bubble.gd
# 对话气泡组件，显示在角色头顶
# 支持不同样式、自动消失、排队显示

class_name DialogueBubble
extends TransparentPanel

## 气泡样式枚举
enum BubbleStyle {
	NORMAL,    # 普通对话（白色边框+半透明白色背景）
	THINKING,  # 思考对话（灰色边框+半透明灰色背景）
	HAPPY,     # 开心对话（黄色边框+半透明黄色背景）
	SURPRISE,  # 惊讶对话（橙色边框+半透明橙色背景）
	SAD        # 伤心对话（蓝色边框+半透明蓝色背景）
}

## 气泡样式配置
const STYLE_CONFIGS = {
	BubbleStyle.NORMAL: {
		"border_color": Color(1.0, 1.0, 1.0, 0.8),
		"background_color": Color(0.0, 0.0, 0.0, 0.3),
		"text_color": Color(1.0, 1.0, 1.0, 1.0)
	},
	BubbleStyle.THINKING: {
		"border_color": Color(0.7, 0.7, 0.7, 0.8),
		"background_color": Color(0.2, 0.2, 0.2, 0.3),
		"text_color": Color(0.9, 0.9, 0.9, 1.0)
	},
	BubbleStyle.HAPPY: {
		"border_color": Color(1.0, 0.9, 0.3, 0.8),
		"background_color": Color(0.3, 0.3, 0.1, 0.3),
		"text_color": Color(1.0, 0.95, 0.5, 1.0)
	},
	BubbleStyle.SURPRISE: {
		"border_color": Color(1.0, 0.6, 0.2, 0.8),
		"background_color": Color(0.3, 0.2, 0.1, 0.3),
		"text_color": Color(1.0, 0.7, 0.3, 1.0)
	},
	BubbleStyle.SAD: {
		"border_color": Color(0.3, 0.6, 1.0, 0.8),
		"background_color": Color(0.1, 0.2, 0.3, 0.3),
		"text_color": Color(0.4, 0.7, 1.0, 1.0)
	}
}

## 气泡最小宽度
const MIN_BUBBLE_WIDTH = 100
## 气泡最大宽度
const MAX_BUBBLE_WIDTH = 240
## 内边距（像素）
const PADDING = 12
## 显示持续时间（秒）
const DEFAULT_DISPLAY_DURATION = 4.0

## 当前气泡样式
var current_style: BubbleStyle = BubbleStyle.NORMAL:
	set(value):
		current_style = value
		_apply_style()

## 显示持续时间
var display_duration: float = DEFAULT_DISPLAY_DURATION
## 气泡消失信号
signal bubble_finished()
## 气泡被点击信号
signal bubble_clicked()

# 内部节点
var _label: TransparentLabel = null
var _auto_hide_timer: Timer = null

func _ready() -> void:
	# 基础配置
	corner_radius = 12
	border_width = 1.5
	show_border = true

	# 创建文本标签
	_label = TransparentLabel.create_for_transparent_window()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(MIN_BUBBLE_WIDTH - PADDING * 2, 0)
	_label.size_flags_horizontal = SIZE_EXPAND_FILL
	_label.size_flags_vertical = SIZE_EXPAND_FILL
	_label.mouse_filter = MOUSE_FILTER_IGNORE  # 让点击穿透到气泡本身
	add_child(_label)

	# 应用默认样式
	_apply_style()

	# 自动隐藏计时器
	_auto_hide_timer = Timer.new()
	_auto_hide_timer.one_shot = true
	_auto_hide_timer.timeout.connect(_on_timer_finished)
	add_child(_auto_hide_timer)

	# 监听点击
	mouse_filter = MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)

	# 默认隐藏
	visible = false

## 设置气泡内容
func set_content(text: String, style: BubbleStyle = BubbleStyle.NORMAL, duration: float = DEFAULT_DISPLAY_DURATION) -> void:
	current_style = style
	display_duration = duration

	# 更新文本
	if _label: _label.update_text(text)

	# 调整气泡大小
	if is_inside_tree(): call_deferred("_adjust_bubble_size")

	# 显示并开始计时
	_show_bubble()

## 手动关闭气泡
func close_bubble() -> void:
	if _auto_hide_timer and _auto_hide_timer.is_running():
		_auto_hide_timer.stop()
	_hide_bubble()

## 立即隐藏气泡（无动画）
func hide_immediately() -> void:
	if _auto_hide_timer and _auto_hide_timer.is_running():
		_auto_hide_timer.stop()
	visible = false
	queue_free()

## 获取气泡文本内容
func get_text() -> String:
	return _label.text if _label else ""

## 应用样式
func _apply_style() -> void:
	var config = STYLE_CONFIGS.get(current_style, STYLE_CONFIGS[BubbleStyle.NORMAL])
	border_color = config["border_color"]
	# 背景半透明
	color = config["background_color"]
	# 文字颜色
	if _label:
		_label.set_text_color(config["text_color"])

## 调整气泡大小
func _adjust_bubble_size() -> void:
	if not _label:
		return

	# 计算文本需要的大小
	var text_size = _label.get_minimum_size()
	# 限制最大宽度
	var final_width = clamp(text_size.x + PADDING * 2, MIN_BUBBLE_WIDTH, MAX_BUBBLE_WIDTH)
	var final_height = text_size.y + PADDING * 2

	size = Vector2(final_width, final_height)

	# 调整标签位置
	_label.position = Vector2(PADDING, PADDING)
	_label.size = Vector2(final_width - PADDING * 2, final_height - PADDING * 2)

## 显示气泡（带淡入动画）
func _show_bubble() -> void:
	visible = true
	modulate = Color(1.0, 1.0, 1.0, 0.0)

	# 淡入动画
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.finished.connect(func():
		# 开始计时自动隐藏
		if display_duration > 0:
			_auto_hide_timer.start(display_duration)
	)

## 隐藏气泡（带淡出动画）
func _hide_bubble() -> void:
	# 淡出动画
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func():
		visible = false
		bubble_finished.emit()
		queue_free()
	)

## 计时器到点，自动隐藏
func _on_timer_finished() -> void:
	_hide_bubble()

## 处理点击事件
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		bubble_clicked.emit()
		# 点击后提前消失
		_on_timer_finished()
