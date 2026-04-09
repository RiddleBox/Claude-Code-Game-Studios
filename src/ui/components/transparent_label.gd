# src/ui/components/transparent_label.gd
# 透明窗口标签组件

class_name TransparentLabel
extends Label

## 阴影颜色（增强透明窗口可读性）
@export var shadow_color: Color = Color(0, 0, 0, 0.5):
	set(value):
		shadow_color = value
		if _shadow_label:
			_shadow_label.label_settings.font_color = value

## 阴影偏移（像素）
@export var shadow_offset: Vector2 = Vector2(1, 1):
	set(value):
		shadow_offset = value
		if _shadow_label:
			_shadow_label.position = value

## 是否启用阴影
@export var enable_shadow: bool = true:
	set(value):
		enable_shadow = value
		_update_shadow_visibility()

## 轮廓大小（像素）
@export var outline_size: int = 1:
	set(value):
		outline_size = value
		_update_label_settings()

## 轮廓颜色
@export var outline_color: Color = Color(0, 0, 0, 0.3):
	set(value):
		outline_color = value
		_update_label_settings()

# 阴影标签节点
var _shadow_label: Label = null
var _is_initialized: bool = false

func _ready() -> void:
	_is_initialized = true

	# 设置默认LabelSettings
	_update_label_settings()

	# 创建阴影效果（如果需要）
	if enable_shadow:
		_create_shadow()

	# 确保文本可读性
	_update_text_visibility()

func _update_label_settings() -> void:
	var settings = LabelSettings.new()
	settings.font_size = 16
	settings.font_color = modulate  # 使用节点自身的modulate作为文字颜色
	settings.outline_size = outline_size
	settings.outline_color = outline_color
	settings.antialiasing = TextServer.ANTIALIASING_GRAYSCALE

	label_settings = settings

	# 同步到阴影标签
	if _shadow_label:
		var shadow_settings = settings.duplicate()
		shadow_settings.font_color = shadow_color
		_shadow_label.label_settings = shadow_settings

func _create_shadow() -> void:
	if _shadow_label:
		_shadow_label.queue_free()

	_shadow_label = Label.new()
	_shadow_label.label_settings = label_settings.duplicate()
	_shadow_label.label_settings.font_color = shadow_color
	_shadow_label.text = text
	_shadow_label.position = shadow_offset

	add_child(_shadow_label)
	_move_shadow_to_back()

func _move_shadow_to_back() -> void:
	if _shadow_label and _shadow_label.get_parent() == self:
		move_child(_shadow_label, 0)

func _update_shadow_visibility() -> void:
	if not _is_initialized:
		return

	if enable_shadow:
		if not _shadow_label:
			_create_shadow()
		else:
			_shadow_label.visible = true
	elif _shadow_label:
		_shadow_label.visible = false

func _update_text_visibility() -> void:
	# 确保文字在透明背景下可读
	# 如果背景很暗，使用亮色文字；如果背景很亮，使用暗色文字
	# MVP阶段：使用轮廓和阴影增强可读性
	pass

## 设置文字（同步到阴影标签）
func set_text(new_text: String) -> void:
	text = new_text
	if _shadow_label:
		_shadow_label.text = new_text

## 设置字体大小
func set_font_size(size: int) -> void:
	if label_settings:
		label_settings.font_size = size
		if _shadow_label and _shadow_label.label_settings:
			_shadow_label.label_settings.font_size = size

## 设置文字颜色
func set_text_color(color: Color) -> void:
	modulate = color  # 使用modulate控制文字颜色
	if label_settings:
		label_settings.font_color = color

## 清除阴影
func clear_shadow() -> void:
	if _shadow_label:
		_shadow_label.queue_free()
		_shadow_label = null

## 获取推荐的最小尺寸（包含阴影）
func get_minimum_size_with_shadow() -> Vector2:
	var base_size = get_minimum_size()
	if enable_shadow:
		base_size += Vector2(abs(shadow_offset.x), abs(shadow_offset.y))
	return base_size

## 临时高亮文字（用于调试）
func highlight_text(temporary_color: Color = Color(1.0, 0.8, 0.0, 1.0), duration: float = 1.0) -> void:
	var original_color = modulate
	modulate = temporary_color

	# 创建定时器恢复原色
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func():
		modulate = original_color
	)

## 检查是否在透明窗口环境中
static func is_in_transparent_window() -> bool:
	# 检查当前视口是否配置为透明背景
	var viewport = Engine.get_main_loop().root
	if viewport:
		return viewport.transparent_bg
	return false

## 获取文字渲染区域（排除阴影）
func get_text_rect() -> Rect2:
	var text_rect = get_rect()
	if enable_shadow and _shadow_label:
		# 返回主文字区域（不包括阴影偏移）
		return Rect2(position, text_rect.size)
	return text_rect

## 启用/禁用抗锯齿
func set_antialiasing(enabled: bool) -> void:
	if label_settings:
		label_settings.antialiasing = TextServer.ANTIALIASING_GRAYSCALE if enabled else TextServer.ANTIALIASING_NONE
		if _shadow_label and _shadow_label.label_settings:
			_shadow_label.label_settings.antialiasing = label_settings.antialiasing

## 静态方法：创建适合透明窗口的标签
static func create_for_transparent_window(text: String = "", font_size: int = 16) -> TransparentLabel:
	var label = TransparentLabel.new()
	label.text = text
	label.set_font_size(font_size)
	label.enable_shadow = true
	label.outline_size = 1
	return label