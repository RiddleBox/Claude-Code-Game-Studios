# src/ui/components/transparent_button.gd
# 透明窗口按钮组件

class_name TransparentButton
extends Button

## 正常状态颜色
@export var normal_color: Color = Color(0.2, 0.6, 1.0, 0.3)
## 悬停状态颜色
@export var hover_color: Color = Color(0.3, 0.7, 1.0, 0.5)
## 按下状态颜色
@export var pressed_color: Color = Color(0.1, 0.5, 0.9, 0.7)
## 禁用状态颜色
@export var disabled_color: Color = Color(0.5, 0.5, 0.5, 0.2)

## 边框颜色
@export var border_color: Color = Color(1.0, 1.0, 1.0, 0.5)
## 边框宽度
@export var border_width: int = 1

## 圆角半径
@export var corner_radius: int = 4

## 文字颜色
@export var text_color: Color = Color(1.0, 1.0, 1.0, 0.9)

## 是否启用悬停效果
@export var enable_hover_effect: bool = true

## 是否启用按下效果
@export var enable_press_effect: bool = true

# 样式盒
var _normal_style: StyleBoxFlat = null
var _hover_style: StyleBoxFlat = null
var _pressed_style: StyleBoxFlat = null
var _disabled_style: StyleBoxFlat = null

var _is_initialized: bool = false

func _ready() -> void:
	_is_initialized = true

	# 设置按钮默认属性
	focus_mode = Control.FOCUS_NONE  # 透明窗口通常不需要键盘焦点
	mouse_filter = Control.MOUSE_FILTER_PASS  # 允许鼠标事件传递

	# 创建样式
	_create_styles()

	# 应用样式
	_apply_styles()

	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _create_styles() -> void:
	# 创建正常状态样式
	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = normal_color
	_normal_style.border_color = border_color
	_normal_style.border_width_left = border_width
	_normal_style.border_width_top = border_width
	_normal_style.border_width_right = border_width
	_normal_style.border_width_bottom = border_width
	_normal_style.corner_radius_top_left = corner_radius
	_normal_style.corner_radius_top_right = corner_radius
	_normal_style.corner_radius_bottom_right = corner_radius
	_normal_style.corner_radius_bottom_left = corner_radius

	# 创建悬停状态样式
	_hover_style = _normal_style.duplicate()
	_hover_style.bg_color = hover_color

	# 创建按下状态样式
	_pressed_style = _normal_style.duplicate()
	_pressed_style.bg_color = pressed_color

	# 创建禁用状态样式
	_disabled_style = _normal_style.duplicate()
	_disabled_style.bg_color = disabled_color

func _apply_styles() -> void:
	# 应用样式到按钮
	add_theme_stylebox_override("normal", _normal_style)
	add_theme_stylebox_override("hover", _hover_style)
	add_theme_stylebox_override("pressed", _pressed_style)
	add_theme_stylebox_override("disabled", _disabled_style)

	# 设置文字颜色
	add_theme_color_override("font_color", text_color)
	add_theme_color_override("font_hover_color", text_color)
	add_theme_color_override("font_pressed_color", text_color)
	add_theme_color_override("font_disabled_color", Color(text_color.r, text_color.g, text_color.b, 0.5))

	# 设置文字对齐
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _on_mouse_entered() -> void:
	if enable_hover_effect:
		# 可以添加悬停动画或效果
		pass

func _on_mouse_exited() -> void:
	if enable_hover_effect:
		# 恢复正常状态
		pass

## 设置按钮颜色
func set_button_colors(new_normal: Color, new_hover: Color, new_pressed: Color) -> void:
	normal_color = new_normal
	hover_color = new_hover
	pressed_color = new_pressed

	if _is_initialized:
		_normal_style.bg_color = normal_color
		_hover_style.bg_color = hover_color
		_pressed_style.bg_color = pressed_color

## 设置边框样式
func set_border_style(new_color: Color, new_width: int) -> void:
	border_color = new_color
	border_width = new_width

	if _is_initialized:
		_update_border_width()

func _update_border_width() -> void:
	if not _is_initialized:
		return

	for style in [_normal_style, _hover_style, _pressed_style, _disabled_style]:
		if style:
			style.border_width_left = border_width
			style.border_width_top = border_width
			style.border_width_right = border_width
			style.border_width_bottom = border_width
			style.border_color = border_color

## 设置圆角
func set_corner_radius(radius: int) -> void:
	corner_radius = radius

	if _is_initialized:
		_update_corner_radius()

func _update_corner_radius() -> void:
	if not _is_initialized:
		return

	for style in [_normal_style, _hover_style, _pressed_style, _disabled_style]:
		if style:
			style.corner_radius_top_left = corner_radius
			style.corner_radius_top_right = corner_radius
			style.corner_radius_bottom_right = corner_radius
			style.corner_radius_bottom_left = corner_radius

## 设置文字颜色
func set_button_text_color(color: Color) -> void:
	text_color = color

	if _is_initialized:
		add_theme_color_override("font_color", text_color)
		add_theme_color_override("font_hover_color", text_color)
		add_theme_color_override("font_pressed_color", text_color)

## 临时高亮按钮（用于调试）
func highlight_button(temporary_color: Color = Color(1.0, 0.8, 0.0, 0.8), duration: float = 1.0) -> void:
	var original_normal = normal_color
	var original_hover = hover_color
	var original_pressed = pressed_color

	normal_color = temporary_color
	hover_color = temporary_color.lightened(0.1)
	pressed_color = temporary_color.darkened(0.1)

	set_button_colors(normal_color, hover_color, pressed_color)

	# 创建定时器恢复原色
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func():
		set_button_colors(original_normal, original_hover, original_pressed)
	)

## 启用/禁用悬停效果
func set_hover_effect(enabled: bool) -> void:
	enable_hover_effect = enabled
	if not enabled and _is_initialized:
		# 强制应用正常样式
		add_theme_stylebox_override("hover", _normal_style)

## 检查是否在透明窗口环境中
static func is_in_transparent_window() -> bool:
	# 检查当前视口是否配置为透明背景
	var viewport = Engine.get_main_loop().root
	if viewport:
		return viewport.transparent_bg
	return false

## 静态方法：创建适合透明窗口的按钮
static func create_for_transparent_window(text: String = "", size: Vector2 = Vector2(100, 40)) -> TransparentButton:
	var button = TransparentButton.new()
	button.text = text
	button.custom_minimum_size = size
	button.enable_hover_effect = true
	button.enable_press_effect = true
	return button

## 获取推荐的最小尺寸（考虑边框和圆角）
func get_recommended_size() -> Vector2:
	var min_width = max(custom_minimum_size.x, 60)  # 最小宽度
	var min_height = max(custom_minimum_size.y, 30)  # 最小高度
	return Vector2(min_width, min_height)