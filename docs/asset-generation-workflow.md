# 游戏素材生成工作流

本文档定义了从AI生成到Godot集成的完整素材制作流程。

---

## 工作流概览

```
1. 查阅规格文档 → 2. AI生成素材 → 3. 后处理优化 → 4. 导入Godot → 5. 应用Shader → 6. 测试验证
```

---

## 阶段1：查阅规格文档

### 必读文档
在生成任何素材前，先阅读以下文档：

#### 核心艺术指导
- **`design/art/art-direction.md`** - 整体视觉风格、调色板、光照系统
- **`design/art/visual-style-overview.md`** - 混合风格系统概览

#### 模块资产规格
根据你要制作的模块，查阅对应规格：
- **F1窗口系统**: `design/art/specs/f1-window-assets.md`
- **C1角色动画**: `design/art/specs/c1-character-assets.md`
- **P1主界面UI**: `design/art/specs/p1-ui-assets.md`

#### 技术指南
- **`design/art/shader-guide.md`** - Shader使用和参数调整
- **`assets/art/textures/base/TEXTURE_SPECS.md`** - 基础纹理规格

### 提取关键信息
从规格文档中记录：
- [ ] 素材尺寸（像素）
- [ ] 配色方案（使用Art Bible调色板）
- [ ] 视觉风格（几何/水彩/混合）
- [ ] 技术要求（透明背景/分层/动画帧数）
- [ ] 文件命名规范

---

## 阶段2：AI生成素材

### 推荐工具

#### Midjourney（推荐）
- **优点**：风格一致性好，水彩质感自然
- **适合**：角色、背景、概念图
- **版本**：使用 `--v 6` 或更高版本
- **参数**：`--ar 1:1 --style raw`（保持原始风格）

#### Stable Diffusion
- **优点**：本地运行，可控性强
- **适合**：UI元素、图标、纹理
- **模型推荐**：Anything V5, Dreamshaper, Pastel Mix

#### DALL-E 3
- **优点**：理解自然语言好
- **适合**：快速原型、概念验证
- **限制**：风格一致性较弱

### 通用提示词模板

#### 基础结构
```
[主体描述], [风格关键词], [技术要求], [构图], [光照], [质量标签]
```

#### 必备关键词
所有素材都应包含：
- **风格**: `watercolor texture`, `paper grain overlay`, `simplified geometric shapes`
- **质感**: `hand-drawn feel`, `soft edges`, `cozy aesthetic`
- **调色板**: `pastel colors (cream, dusty blue, lotus pink, matcha green)`
- **光照**: `soft natural lighting from top-left 45 degrees`
- **质量**: `high quality`, `detailed`, `clean`

#### 负面提示词（Stable Diffusion）
```
realistic, photorealistic, 3D render, overly complex, sharp edges, neon colors, dark atmosphere, low quality, blurry, watermark, text, multiple views, cropped
```

### 生成策略

#### 角色素材
1. 先生成**基础造型**（Idle姿态）
2. 记录种子值（Seed）
3. 使用相同种子生成表情变体
4. 微调提示词保持一致性

#### 环境/背景素材
1. 生成**大尺寸原图**（2048×2048px）
2. 后期裁剪到目标尺寸
3. 保留PSD/分层文件便于调整

#### UI元素
1. 生成**矢量风格**（添加 `vector art`, `flat design`）
2. 确保边缘清晰
3. 单色或简单渐变

---

## 阶段3：后处理优化

### 必备工具
- **Photoshop/GIMP**: 专业图像编辑
- **Krita**: 免费开源，适合手绘风格
- **remove.bg**: 在线背景移除
- **TinyPNG**: PNG压缩优化

### 处理步骤

#### 3.1 背景移除
**目标**: 获得干净的透明背景

**方法**:
1. 使用魔棒工具选择白色背景
2. 删除背景层
3. 检查边缘是否有白边
4. 使用"收缩选区1px"后羽化处理白边

**检查**: 在深色背景上预览，确保无白边

---

#### 3.2 尺寸调整
**目标**: 调整到规格要求的像素尺寸

**方法**:
1. 图像 > 图像大小
2. 保持纵横比
3. 重采样方法选择"两次立方（平滑渐变）"
4. 确认透明背景未丢失

**标准尺寸**:
- 角色: 320×320px
- 窗口框架: 400×300px
- UI按钮: 128×48px
- 背景: 1920×1080px（可缩放）

---

#### 3.3 颜色校正
**目标**: 匹配Art Bible调色板

**Art Bible调色板**:
```
主色调:
- 奶油白 #F5F1E8
- 灰蓝 #A8B8C8
- 莲粉 #E8B4B8
- 抹茶绿 #C8D4B8

强调色:
- 琥珀金 #D4A574
- 薰衣草 #B8A8C8
```

**方法**:
1. 使用色相/饱和度调整整体色调
2. 使用曲线调整明暗对比
3. 避免过饱和颜色
4. 保持柔和温暖的氛围

---

#### 3.4 边缘优化
**目标**: 柔化边缘，增加手绘感

**方法**:
1. 选择 > 修改 > 羽化（1-2px）
2. 滤镜 > 模糊 > 高斯模糊（0.5-1px）
3. 不要过度模糊，保持清晰度

**注意**: 如果使用edge_softening.gdshader，可以跳过此步骤

---

#### 3.5 导出设置
**格式**: PNG-24（支持透明度）

**设置**:
- 透明度: 启用
- 交错: 无
- 压缩: 最佳（9级）
- 元数据: 移除（减小文件大小）

**文件大小目标**:
- 角色/UI元素: <200KB
- 背景: <500KB
- 纹理: <100KB

---

## 阶段4：导入Godot

### 文件组织

#### 目录结构
```
assets/art/
├── characters/
│   └── mochi/
│       ├── mochi_idle.png
│       ├── mochi_happy.png
│       └── ...
├── environments/
│   └── backgrounds/
│       └── main_bg.png
├── ui/
│   ├── buttons/
│   ├── panels/
│   └── icons/
└── windows/
    ├── frames/
    └── decorations/
```

#### 命名规范
```
[类型]_[名称]_[状态/变体].[扩展名]

示例:
char_mochi_idle.png
ui_button_primary_normal.png
bg_main_day.png
window_frame_01.png
```

### Godot导入配置

#### 默认设置（适用于大多数素材）
在Godot Inspector中：
```
Compress > Mode: Lossless
Compress > High Quality: true
Mipmaps > Generate: false
Roughness > Enabled: false
Process > Fix Alpha Border: true
Process > Premult Alpha: false
Detect 3D > Enabled: false
SVG > Scale: 1.0
```

#### 特殊情况

**像素艺术风格**（如果使用）:
```
Filter: false  # 关闭抗锯齿
Mipmaps: false
```

**大型背景图**:
```
Compress > Mode: VRAM Compressed
Mipmaps > Generate: true  # 启用Mipmap优化性能
```

**UI元素**:
```
Compress > Mode: Lossless
Filter: true
Mipmaps: false
```

---

## 阶段5：应用Shader

### Shader选择

根据素材类型选择合适的Shader：

#### paper_overlay.gdshader
**适用**: 角色、UI元素、前景物体

**效果**: 叠加纸质纹理，增加手绘质感

**参数**:
```gdscript
paper_texture: res://assets/art/textures/base/tex_paper_grain.png
paper_strength: 0.25  # 角色用0.2-0.3，UI用0.15-0.25
paper_scale: 1.0
```

---

#### edge_softening.gdshader
**适用**: 几何形状角色、矢量风格UI

**效果**: 柔化边缘，减少生硬感

**参数**:
```gdscript
edge_texture: res://assets/art/textures/base/tex_watercolor_edge.png
edge_width: 2.0  # 像素宽度，根据素材尺寸调整
edge_softness: 0.5  # 0.0=硬边缘，1.0=完全柔化
```

---

### 应用步骤

#### 方法1：通过场景编辑器
1. 选中Sprite2D节点
2. Inspector > CanvasItem > Material > 新建ShaderMaterial
3. ShaderMaterial > Shader > 加载对应.gdshader文件
4. 调整Shader Parameters

#### 方法2：通过代码
```gdscript
# 在角色脚本中
func _ready():
    var material = ShaderMaterial.new()
    material.shader = load("res://src/shaders/paper_overlay.gdshader")
    material.set_shader_parameter("paper_texture", load("res://assets/art/textures/base/tex_paper_grain.png"))
    material.set_shader_parameter("paper_strength", 0.25)
    $Sprite2D.material = material
```

---

## 阶段6：测试验证

### 视觉测试

#### 使用测试场景
打开 `tests/visual/shader_test.tscn` 进行快速预览：
1. 替换测试场景中的Sprite2D纹理为你的素材
2. 运行场景（F6）
3. 在不同背景下观察效果

#### 检查清单
- [ ] 透明背景无白边/黑边
- [ ] 颜色与Art Bible调色板一致
- [ ] Shader效果自然不过度
- [ ] 在320×320px画布上清晰可辨
- [ ] 与其他素材风格统一

---

### 技术测试

#### 性能检查
运行游戏并打开调试信息（F3）：
- FPS稳定在60
- 纹理内存占用合理（<50MB for MVP）
- 无纹理加载卡顿

#### 兼容性检查
- [ ] Windows 10/11正常显示
- [ ] 缩放到不同分辨率无失真
- [ ] Shader在不同GPU上正常工作

---

### 迭代优化

如果测试发现问题：

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| 边缘有白边 | 背景移除不彻底 | 重新处理透明背景，使用"收缩选区" |
| 颜色过饱和 | AI生成色彩过艳 | 降低饱和度10-20%，调整色相 |
| Shader效果过强 | 参数设置过高 | 降低paper_strength到0.15-0.2 |
| 文件过大 | 压缩不足 | 使用TinyPNG压缩，或降低分辨率 |
| 风格不一致 | 不同批次生成 | 使用相同种子值重新生成 |
| 模糊不清 | 尺寸过小 | 生成更高分辨率原图后缩放 |

---

## 批量生成建议

### MVP阶段优先级

#### 第一批（核心可玩）
1. **Mochi角色** - 1个基础造型 + 2个表情（开心/悲伤）
2. **窗口框架** - 1个标准框架
3. **主界面背景** - 1个简单背景

**目标**: 让游戏可以运行并展示核心交互

---

#### 第二批（完善体验）
1. Mochi剩余表情（惊讶/思考）
2. 窗口装饰元素（边框/阴影）
3. UI按钮和面板

**目标**: 完善视觉反馈和UI交互

---

#### 第三批（润色打磨）
1. 动画帧（眨眼/呼吸）
2. 特效素材（粒子/光效）
3. 音频可视化元素

**目标**: 增加动态感和沉浸感

---

## 工具和资源

### AI生成工具
- **Midjourney**: https://midjourney.com
- **Stable Diffusion WebUI**: https://github.com/AUTOMATIC1111/stable-diffusion-webui
- **DALL-E 3**: https://openai.com/dall-e-3

### 图像编辑工具
- **GIMP** (免费): https://www.gimp.org
- **Krita** (免费): https://krita.org
- **Photoshop** (付费): https://www.adobe.com/products/photoshop.html

### 在线工具
- **remove.bg**: https://www.remove.bg (背景移除)
- **TinyPNG**: https://tinypng.com (PNG压缩)
- **Coolors**: https://coolors.co (调色板生成)

### Godot资源
- **Godot Shader文档**: https://docs.godotengine.org/en/stable/tutorials/shaders/
- **Godot资产库**: https://godotengine.org/asset-library/

---

## 常见问题

### Q: AI生成的素材每次都不一样，如何保持一致性？
**A**: 
1. 使用种子值（Seed）固定随机性
2. 第一次生成满意后记录完整提示词和种子
3. 后续变体只修改必要部分（如表情描述）
4. 使用Midjourney的 `--cref` 参数引用已有图像

### Q: 生成的素材风格偏离Art Bible怎么办？
**A**:
1. 在提示词中明确指定调色板颜色代码
2. 添加 `reference: [Art Bible风格描述]`
3. 使用 `--style raw` 减少AI的风格化处理
4. 后期在Photoshop中手动调整色调

### Q: 透明背景总是有白边怎么办？
**A**:
1. 生成时在提示词中添加 `transparent background`, `alpha channel`
2. 后期使用"选择 > 修改 > 收缩选区1px"后删除
3. 使用"图层 > 修边 > 移去白色杂边"
4. 在Godot导入设置中启用 `Fix Alpha Border`

### Q: Shader效果看不出来？
**A**:
1. 确保素材有足够的颜色信息（不是纯白/纯黑）
2. 调高paper_strength参数到0.4-0.5测试
3. 在深色背景上预览效果
4. 检查纹理路径是否正确加载

### Q: 文件太大影响性能怎么办？
**A**:
1. 使用TinyPNG压缩（通常可减少60-80%）
2. 降低分辨率（角色从512px降到320px）
3. 大型背景使用VRAM压缩模式
4. 移除不必要的元数据

---

## 下一步

完成素材生成后：
1. 将素材集成到对应模块（F1/C1/P1）
2. 运行单元测试确保功能正常
3. 进行视觉回归测试
4. 更新 `/gate-check` 验证MVP达标

详细集成步骤参考各模块的实现文档。
