# src/ui/components/transparent_panel.gd
# 透明面板组件，专为F1透明窗口设计

class_name TransparentPanel
extends ColorRect

## 边框颜色（支持透明度）
@export var border_color: Color = Color(1.0, 1.0, 1.0, 0.3):
	set(value):
		border_color = value
		if _border_node:
			_border_node.default_color = value

## 边框宽度（像素）
@export var border_width: float = 1.0:
	set(value):
		border_width = value
		if _border_node:
			_border_node.width = value

## 圆角半径（像素）
@export var corner_radius: float = 8.0

## 是否显示边框
@export var show_border: bool = true:
	set(value):
		show_border = value
		_update_border_visibility()

## 自动调整边框点
@export var auto_update_border: bool = true

# 内部节点
var _border_node: Line2D = null
var _is_initialized: bool = false

func _ready() -> void:
	_is_initialized = true

	# 确保背景透明（F1透明窗口要求）
	self_modulate = Color(1, 1, 1, 0)  # 完全透明背景
	color = Color(0, 0, 0, 0)  # 无颜色填充

	# 创建边框节点（如果需要）
	if show_border and border_width > 0:
		_create_border()

	# 应用圆角（如果支持）
	if corner_radius > 0:
		_setup_rounded_corners()

	# 连接大小变化信号
	resized.connect(_on_resized)

func _create_border() -> void:
	if _border_node:
		_border_node.queue_free()

	_border_node = Line2D.new()
	_border_node.width = border_width
	_border_node.default_color = border_color
	_border_node.closed = true
	_border_node.antialiased = true

	_update_border_points()

	add_child(_border_node)
	_move_border_to_back()

func _move_border_to_back() -> void:
	if _border_node and _border_node.get_parent() == self:
		move_child(_border_node, 0)

func _update_border_points() -> void:
	if not _border_node or not _is_initialized:
		return

	# 计算边框点（内部偏移一半边框宽度以避免像素溢出）
	var half_border = border_width / 2.0
	var points = PackedVector2Array([
		Vector2(half_border, half_border),
		Vector2(size.x - half_border, half_border),
		Vector2(size.x - half_border, size.y - half_border),
		Vector2(half_border, size.y - half_border),
		Vector2(half_border, half_border)
	])

	_border_node.points = points

func _setup_rounded_corners() -> void:
	# MVP阶段：圆角通过简单的材质实现
	# Godot 4.6.1中可以通过StyleBoxFlat实现，但透明窗口需要特殊处理
	# 暂时使用占位实现，后续可扩展为Shader
	pass

func _update_border_visibility() -> void:
	if not _is_initialized:
		return

	if show_border and border_width > 0:
		if not _border_node:
			_create_border()
		else:
			_border_node.visible = true
	elif _border_node:
		_border_node.visible = false

func _on_resized() -> void:
	if auto_update_border and _border_node:
		_update_border_points()

## 设置面板大小
func set_panel_size(new_size: Vector2) -> void:
	size = new_size
	_update_border_points()

## 设置边框样式
func set_border_style(new_color: Color, new_width: float) -> void:
	border_color = new_color
	border_width = new_width

	if _border_node:
		_border_node.default_color = new_color
		_border_node.width = new_width
		_update_border_points()

## 获取内容区域（排除边框）
func get_content_rect() -> Rect2:
	var content_margin = border_width
	return Rect2(
		content_margin,
		content_margin,
		size.x - content_margin * 2,
		size.y - content_margin * 2
	)

## 清除边框
func clear_border() -> void:
	if _border_node:
		_border_node.queue_free()
		_border_node = null

## 临时高亮边框（用于调试）
func highlight_border(temporary_color: Color = Color(1.0, 0.0, 0.0, 0.8), duration: float = 1.0) -> void:
	if not _border_node:
		return

	var original_color = border_color
	border_color = temporary_color

	# 创建定时器恢复原色
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func():
		border_color = original_color
	)

## 检查是否在透明窗口环境中
static func is_in_transparent_window() -> bool:
	# 检查当前视口是否配置为透明背景
	var viewport = Engine.get_main_loop().root
	if viewport:
		return viewport.transparent_bg
	return false

## 获取推荐的最小尺寸（避免边框重叠）
## 注意：不使用 get_minimum_size() 以避免覆盖 Control 原生方法
func get_panel_minimum_size() -> Vector2:
	var min_size = border_width * 4  # 每边留出边框空间
	return Vector2(min_size, min_size)