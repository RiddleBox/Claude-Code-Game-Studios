# tools/generate_c1_placeholder_frames.gd
# 生成C1角色动画系统的透明背景占位符帧
# 使用方法: 在Godot编辑器中运行此脚本(工具脚本)

@tool
extends EditorScript

# 8个动画状态
const STATES = [
	"idle", "attentive", "interacting", "talking",
	"reacting", "performing", "away", "returning"
]

# 每个状态对应的颜色(用于区分)
const STATE_COLORS = {
	"idle": Color(0.3, 0.6, 0.9, 1.0),        # 蓝色
	"attentive": Color(0.9, 0.7, 0.3, 1.0),   # 橙色
	"interacting": Color(0.5, 0.9, 0.4, 1.0), # 绿色
	"talking": Color(0.9, 0.4, 0.5, 1.0),     # 粉色
	"reacting": Color(0.8, 0.3, 0.8, 1.0),    # 紫色
	"performing": Color(0.9, 0.9, 0.3, 1.0),  # 黄色
	"away": Color(0.5, 0.5, 0.5, 0.3),        # 半透明灰色
	"returning": Color(0.3, 0.9, 0.9, 1.0)    # 青色
}

# 每个状态的帧数
const FRAMES_PER_STATE = 2  # 简单的2帧循环动画

func _run() -> void:
	print("[C1占位符生成器] 开始生成...")

	# 创建SpriteFrames资源
	var sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")  # 移除默认动画

	# 为每个状态生成动画
	for state in STATES:
		sprite_frames.add_animation(state)
		sprite_frames.set_animation_speed(state, 8.0)  # 8fps
		sprite_frames.set_animation_loop(state, true)

		var color = STATE_COLORS[state]

		# 生成该状态的帧
		for frame_idx in range(FRAMES_PER_STATE):
			var texture = _generate_frame(state, frame_idx, color)
			sprite_frames.add_frame(state, texture, 1.0, frame_idx)

		print("[C1占位符生成器] 已生成动画: %s (%d帧)" % [state, FRAMES_PER_STATE])

	# 保存SpriteFrames资源
	var output_path = "res://assets/art/characters/placeholder_frame/character_frames_transparent.tres"
	var err = ResourceSaver.save(sprite_frames, output_path)

	if err == OK:
		print("[C1占位符生成器] ✓ 成功保存到: %s" % output_path)
	else:
		push_error("[C1占位符生成器] ✗ 保存失败,错误码: %d" % err)

## 生成单帧图像
func _generate_frame(state: String, frame_idx: int, color: Color) -> ImageTexture:
	var size = 256  # 256x256像素
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	# 填充透明背景
	image.fill(Color(0, 0, 0, 0))

	# 绘制圆形(代表角色头部)
	var center = Vector2(size / 2, size / 2)
	var radius = size * 0.35

	# 简单的帧间变化(缩放)
	var scale_factor = 1.0 + (frame_idx * 0.05)  # 第2帧稍微大一点
	var current_radius = radius * scale_factor

	_draw_circle(image, center, current_radius, color)

	# 绘制状态文字
	_draw_text(image, state, Vector2(size / 2, size * 0.85), Color.WHITE)

	return ImageTexture.create_from_image(image)

## 绘制实心圆
func _draw_circle(image: Image, center: Vector2, radius: float, color: Color) -> void:
	var size = image.get_size()

	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)

			if dist <= radius:
				# 抗锯齿边缘
				var alpha = 1.0
				if dist > radius - 2:
					alpha = (radius - dist) / 2.0

				var final_color = color
				final_color.a *= alpha
				image.set_pixel(x, y, final_color)

## 绘制简单文字(使用像素点阵)
func _draw_text(image: Image, text: String, pos: Vector2, color: Color) -> void:
	# 简化版:只绘制一个小方块作为标识
	var marker_size = 8
	var start_x = int(pos.x - marker_size / 2)
	var start_y = int(pos.y - marker_size / 2)

	for y in range(marker_size):
		for x in range(marker_size):
			var px = start_x + x
			var py = start_y + y
			if px >= 0 and px < image.get_width() and py >= 0 and py < image.get_height():
				image.set_pixel(px, py, color)
