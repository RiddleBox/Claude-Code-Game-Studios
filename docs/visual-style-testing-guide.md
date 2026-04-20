# 基础纹理生成和Shader测试指南

## 步骤1：生成基础纹理

1. 在Godot编辑器中打开项目
2. 在FileSystem面板中双击打开 `tools/texture_generator.tscn`
3. 按 **F5** 或点击右上角的 **运行当前场景** 按钮
4. 查看输出日志确认生成成功：
   ```
   === 开始生成基础纹理 ===
   生成 tex_paper_grain.png...
	 ✓ 已保存: res://assets/art/textures/base/tex_paper_grain.png
   生成 tex_watercolor_edge.png...
	 ✓ 已保存: res://assets/art/textures/base/tex_watercolor_edge.png
   生成 tex_noise_soft.png...
	 ✓ 已保存: res://assets/art/textures/base/tex_noise_soft.png
   === 纹理生成完成 ===
   ```
5. 场景会自动退出
6. 在FileSystem面板中刷新（右键 > Refresh）查看生成的纹理

## 步骤2：测试Shader效果

1. 打开测试场景：`tests/visual/shader_test.tscn`
2. 场景中有3个Sprite对比：
   - **Original**: 原始精灵（无Shader）
   - **WithPaper**: 应用纸质纹理Shader
   - **WithEdge**: 应用边缘柔化Shader

3. 配置纸质纹理Shader：
   - 选中 `TestSprites/WithPaper/Sprite` 节点
   - 在Inspector中找到 **Material > Shader Parameters**
   - 将 `paper_texture` 参数设置为 `res://assets/art/textures/base/tex_paper_grain.png`
   - 调整参数观察效果：
	 - `paper_strength`: 0.2-0.4（纹理强度）
	 - `paper_scale`: 0.5-2.0（纹理缩放）

4. 测试边缘柔化Shader：
   - 选中 `TestSprites/WithEdge/Sprite` 节点
   - 调整参数：
	 - `edge_softness`: 0.02-0.1（边缘柔化范围）
	 - `edge_threshold`: 0.05-0.2（透明度阈值）
	 - `glow_enabled`: true（启用发光效果）

5. 运行场景（F5）查看实时效果

## 步骤3：创建材质预设

如果Shader效果满意，可以创建可复用的材质预设：

1. 在FileSystem中右键 `assets/materials/` 目录
2. 选择 **Create New > Resource > ShaderMaterial**
3. 命名为 `mat_character_paper.tres`
4. 在Inspector中：
   - 设置 **Shader** 为 `res://src/shaders/paper_overlay.gdshader`
   - 配置 **Shader Parameters**（使用测试中确定的最佳参数）
5. 保存材质

重复此过程创建其他材质预设（参考 `assets/materials/README.md`）

## 预期效果

### 纸质纹理Shader
- 精灵表面应显示细微的纸张纹理
- 纹理应与精灵颜色自然融合
- 不应出现明显的重复图案

### 边缘柔化Shader
- 精灵边缘应有柔和的过渡
- 不应出现锯齿或硬边
- 可选的发光效果应均匀分布

## 故障排查

### 纹理生成失败
- 检查 `assets/art/textures/base/` 目录是否存在
- 查看Godot输出日志的错误信息
- 确认Godot版本为4.6+

### Shader不显示效果
- 确认纹理已正确分配到 `paper_texture` 参数
- 检查 `paper_strength` 是否为0（应设置为0.2-0.4）
- 确认Sprite有有效的纹理（不是空的）

### 纹理显示异常
- 检查纹理导入设置（Inspector > Import）
- 确认 **Filter** 设置为 **Linear**
- 确认 **Repeat** 设置为 **Enabled**（对于平铺纹理）

## 下一步

如果测试通过：
1. 根据测试结果调整Shader参数的默认值
2. 创建完整的9个材质预设（参考 `assets/materials/README.md`）
3. 开始为F1/C1/P1模块生成实际资产
4. 应用材质预设到实际资产

如果效果不理想：
1. 记录具体问题（纹理太强/太弱、边缘不自然等）
2. 调整生成脚本的参数
3. 重新生成纹理并测试
4. 必要时考虑调整Shader代码
