# src/ui/themes/ui_theme.gd
# UI主题资源，集中管理样式配置

class_name UITheme
extends Resource

## 主色调
@export var primary_color: Color = Color(0.2, 0.6, 1.0, 0.8)
## 次要色调
@export var secondary_color: Color = Color(0.8, 0.8, 0.8, 0.6)
## 文字颜色
@export var text_color: Color = Color(1.0, 1.0, 1.0, 0.9)
## 警告颜色
@export var warning_color: Color = Color(1.0, 0.6, 0.2, 0.8)
## 错误颜色
@export var error_color: Color = Color(1.0, 0.2, 0.2, 0.8)

## 字体大小
@export var font_size_small: int = 12
@export var font_size_normal: int = 16
@export var font_size_large: int = 20

## 间距（像素）
@export var margin_small: int = 4
@export var margin_normal: int = 8
@export var margin_large: int = 16

## 边框宽度
@export var border_width_normal: float = 1.0
@export var border_width_thick: float = 2.0

## 圆角半径
@export var corner_radius_small: float = 4.0
@export var corner_radius_normal: float = 8.0
@export var corner_radius_large: float = 16.0

## 阴影设置
@export var shadow_color: Color = Color(0, 0, 0, 0.5)
@export var shadow_offset: Vector2 = Vector2(1, 1)

## 应用主题到透明面板
func apply_to_panel(panel: TransparentPanel) -> void:
	if not panel:
		return

	panel.border_color = primary_color
	panel.border_width = border_width_normal
	panel.corner_radius = corner_radius_normal

	# 设置面板默认大小（可选）
	if panel.size == Vector2.ZERO:
		panel.size = Vector2(200, 100)

## 应用主题到透明标签
func apply_to_label(label: TransparentLabel) -> void:
	if not label:
		return

	# 创建或更新LabelSettings
	var label_settings = LabelSettings.new()
	label_settings.font_color = text_color
	label_settings.font_size = font_size_normal
	label_settings.outline_size = 1
	label_settings.outline_color = Color(0, 0, 0, 0.3)

	label.label_settings = label_settings
	label.shadow_color = shadow_color
	label.shadow_offset = shadow_offset

## 创建面板样式预设
func create_panel_style() -> Dictionary:
	return {
		"border_color": primary_color,
		"border_width": border_width_normal,
		"corner_radius": corner_radius_normal,
		"background_color": Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.1)
	}

## 创建标签样式预设
func create_label_style() -> Dictionary:
	return {
		"font_color": text_color,
		"font_size": font_size_normal,
		"shadow_color": shadow_color,
		"shadow_offset": shadow_offset
	}

## 创建警告样式
func create_warning_style() -> Dictionary:
	var style = create_panel_style()
	style["border_color"] = warning_color
	style["border_width"] = border_width_thick
	return style

## 创建错误样式
func create_error_style() -> Dictionary:
	var style = create_panel_style()
	style["border_color"] = error_color
	style["border_width"] = border_width_thick
	return style

## 获取颜色变体（亮度调整）
func get_color_variant(base_color: Color, brightness_multiplier: float) -> Color:
	var hsv = base_color
	var adjusted = Color.from_hsv(hsv.h, hsv.s, hsv.v * brightness_multiplier, base_color.a)
	return adjusted

## 获取亮色变体
func get_light_color(base_color: Color) -> Color:
	return get_color_variant(base_color, 1.3)

## 获取暗色变体
func get_dark_color(base_color: Color) -> Color:
	return get_color_variant(base_color, 0.7)

## 验证主题配置
func validate() -> Array[String]:
	var issues: Array[String] = []

	# 检查颜色有效性
	if primary_color.a == 0.0:
		issues.append("主色调完全透明，可能影响可见性")

	if text_color.a < 0.5:
		issues.append("文字颜色透明度较高，可能影响可读性")

	# 检查字体大小范围
	if font_size_small < 8:
		issues.append("字体大小过小 (小于8px)")
	if font_size_large > 48:
		issues.append("字体大小过大 (大于48px)")

	# 检查间距合理性
	if margin_small < 0:
		issues.append("小间距为负值")
	if margin_large < margin_small:
		issues.append("大间距小于小间距")

	return issues