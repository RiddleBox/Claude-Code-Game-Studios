@tool
extends EditorScript

## 程序化生成基础纹理库
## 用法：在Godot编辑器中 File > Run 运行此脚本

const OUTPUT_DIR = "res://assets/art/textures/base/"

func _run() -> void:
	print("=== 开始生成基础纹理 ===")

	# 确保输出目录存在
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

	# 生成三个基础纹理
	generate_paper_grain()
	generate_watercolor_edge()
	generate_soft_noise()

	print("=== 纹理生成完成 ===")
	print("输出目录: ", OUTPUT_DIR)
	print("请在Godot编辑器中刷新文件系统查看生成的纹理")


## 纹理1: 纸质纹理 (512x512, 无缝平铺)
func generate_paper_grain() -> void:
	print("生成 tex_paper_grain.png...")

	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.08  # 中等频率
	noise.fractal_octaves = 3
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

	# 直接从噪声生成图像
	var size := 512
	var image := Image.create(size, size, false, Image.FORMAT_RGB8)

	# 手动采样噪声填充图像
	for y in range(size):
		for x in range(size):
			var noise_val := noise.get_noise_2d(float(x), float(y))
			# 将-1到1范围映射到0.4-0.6范围（40-60%灰度）
			var gray := (noise_val + 1.0) * 0.1 + 0.4
			image.set_pixel(x, y, Color(gray, gray, gray))

	if image == null:
		push_error("无法生成纸质纹理图像")
		return

	# 保存
	var path := OUTPUT_DIR + "tex_paper_grain.png"
	var err := image.save_png(path)
	if err == OK:
		print("  ✓ 已保存: ", path)
	else:
		push_error("  ✗ 保存失败: ", path)


## 纹理2: 水彩边缘纹理 (256x256, 带Alpha通道)
func generate_watercolor_edge() -> void:
	print("生成 tex_watercolor_edge.png...")

	var size := 256
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size / 2.0, size / 2.0)
	var max_radius := size * 0.4  # 半径约为图像的40%

	# 生成径向渐变 + 轻微噪声扰动
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.05

	for y in range(size):
		for x in range(size):
			var pos := Vector2(x, y)
			var dist := pos.distance_to(center)

			# 添加轻微噪声扰动（模拟水彩不规则边缘）
			var noise_val := noise.get_noise_2d(x, y) * 10.0
			dist += noise_val

			# 计算alpha：中心完全不透明，边缘渐变到透明
			var alpha := 1.0 - smoothstep(max_radius * 0.6, max_radius, dist)
			alpha = clamp(alpha, 0.0, 1.0)

			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	# 轻微模糊以柔化边缘
	# 注意：Godot 4.x没有内置高斯模糊，这里用简单的box blur近似
	image = apply_simple_blur(image, 3)

	# 保存
	var path := OUTPUT_DIR + "tex_watercolor_edge.png"
	var err := image.save_png(path)
	if err == OK:
		print("  ✓ 已保存: ", path)
	else:
		push_error("  ✗ 保存失败: ", path)


## 纹理3: 柔和噪声纹理 (256x256, 无缝平铺)
func generate_soft_noise() -> void:
	print("生成 tex_noise_soft.png...")

	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.02  # 低频率 = 大块柔和形状
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

	# 直接从噪声生成图像
	var size := 256
	var image := Image.create(size, size, false, Image.FORMAT_RGB8)

	# 手动采样噪声填充图像
	for y in range(size):
		for x in range(size):
			var noise_val := noise.get_noise_2d(float(x), float(y))
			# 将-1到1范围映射到0.45-0.55范围（45-55%灰度）
			var gray := (noise_val + 1.0) * 0.05 + 0.45
			image.set_pixel(x, y, Color(gray, gray, gray))

	if image == null:
		push_error("无法生成柔和噪声纹理图像")
		return

	# 保存
	var path := OUTPUT_DIR + "tex_noise_soft.png"
	var err := image.save_png(path)
	if err == OK:
		print("  ✓ 已保存: ", path)
	else:
		push_error("  ✗ 保存失败: ", path)


## 简单的box blur实现（3x3核）
func apply_simple_blur(image: Image, iterations: int) -> Image:
	var width: int = image.get_width()
	var height: int = image.get_height()

	for _i in range(iterations):
		var blurred := Image.create(width, height, false, image.get_format())

		for y in range(height):
			for x in range(width):
				var sum := Color(0, 0, 0, 0)
				var count := 0

				# 3x3邻域
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						var nx := clamp(x + dx, 0, width - 1)
						var ny := clamp(y + dy, 0, height - 1)
						sum += image.get_pixel(nx, ny)
						count += 1

				blurred.set_pixel(x, y, sum / count)

		image = blurred

	return image
