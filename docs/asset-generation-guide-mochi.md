# Mochi角色素材生成指南

## 角色概述

**Mochi** 是游戏的核心虚拟伙伴角色，设计风格为**简化几何+水彩质感**的混合风格。

### 核心设计原则
- **形态**：2.5头身，圆润柔和，简化几何形状
- **风格**：有机生物+轻微机械装饰的混合
- **质感**：水彩晕染边缘+纸质纹理叠加
- **情感**：温暖、友好、可爱但不幼稚
- **尺寸**：320×320px（可调整）

---

## 第一阶段：基础造型设计

### 生成目标
创建Mochi的**标准正面站立姿态**（Idle状态），作为所有后续变体的基础。

### AI生成提示词

#### Midjourney提示词
```
A cute virtual companion character named Mochi, 2.5 head-to-body ratio, simplified geometric shapes with soft rounded edges, watercolor texture with paper grain overlay, warm pastel color palette (cream white, dusty blue, lotus pink, matcha green), gentle expression, standing idle pose, front view, full body, white background, character design sheet style, cozy aesthetic, hand-drawn feel, soft lighting from top-left 45 degrees --ar 1:1 --style raw --v 6
```

#### Stable Diffusion提示词
```
Positive: 
cute virtual companion character, 2.5 head proportion, simplified geometric shapes, soft rounded forms, watercolor painting style, paper texture overlay, pastel colors (cream, dusty blue, pink, mint green), gentle friendly expression, standing pose, front view, full body, white background, character concept art, cozy aesthetic, hand-drawn illustration, soft natural lighting, high quality, detailed

Negative:
realistic, photorealistic, 3D render, overly complex details, sharp edges, neon colors, dark atmosphere, scary, aggressive, multiple characters, side view, back view, cropped, low quality, blurry, watermark
```

### 技术规格
- **分辨率**：至少1024×1024px（后期缩放到320×320px）
- **格式**：PNG（透明背景）
- **色彩模式**：RGB
- **背景**：纯白或透明

### 设计检查清单
生成后检查以下要点：
- [ ] 头身比例约为2.5:1
- [ ] 整体轮廓圆润柔和，无尖锐边角
- [ ] 使用Art Bible中的调色板颜色
- [ ] 边缘有轻微的水彩晕染感
- [ ] 表情温和友好
- [ ] 五官简化但有表现力
- [ ] 身体结构清晰（头/躯干/四肢可区分）

---

## 第二阶段：表情变体

基于第一阶段的基础造型，生成**4个核心表情**。

### 表情1：开心 (Happy)
**情绪描述**：愉悦、满足、温暖

**AI提示词修改**：
在基础提示词后添加：
```
, happy expression, gentle smile, slightly closed eyes showing joy, warm and cheerful mood
```

**预期效果**：
- 嘴角上扬的微笑
- 眼睛微眯成弯月形
- 整体氛围明亮温暖

---

### 表情2：悲伤 (Sad)
**情绪描述**：失落、沮丧、需要安慰

**AI提示词修改**：
```
, sad expression, downturned mouth, droopy eyes, melancholic mood, soft blue tones
```

**预期效果**：
- 嘴角下垂
- 眼睛低垂或微微湿润
- 色调偏冷（增加蓝色调）

---

### 表情3：惊讶 (Surprised)
**情绪描述**：好奇、意外、兴奋

**AI提示词修改**：
```
, surprised expression, wide open eyes, small open mouth, curious and excited mood
```

**预期效果**：
- 眼睛睁大
- 嘴巴微张成"O"形
- 整体姿态略微前倾

---

### 表情4：思考 (Thinking)
**情绪描述**：专注、沉思、认真

**AI提示词修改**：
```
, thinking expression, one eye slightly closed, hand near chin or head, contemplative mood
```

**预期效果**：
- 一只眼睛微眯
- 手部动作（托腮或摸头）
- 表情专注但放松

---

## 第三阶段：动画帧（可选）

如果需要简单动画效果，生成以下帧：

### 眨眼动画（3帧）
1. **眼睛全开**（使用基础造型）
2. **眼睛半闭**（眼睛高度50%）
3. **眼睛全闭**（眼睛完全闭合）

**提示词修改**：
```
Frame 2: , eyes half closed, blinking animation frame
Frame 3: , eyes fully closed, blinking animation frame
```

### 呼吸动画（2帧）
1. **吸气**（身体略微膨胀）
2. **呼气**（身体略微收缩）

**提示词修改**：
```
Frame 1: , body slightly expanded, breathing in
Frame 2: , body slightly contracted, breathing out
```

---

## 素材命名规范

生成后按以下规则重命名文件：

```
mochi_idle.png              # 基础站立姿态
mochi_happy.png             # 开心表情
mochi_sad.png               # 悲伤表情
mochi_surprised.png         # 惊讶表情
mochi_thinking.png          # 思考表情
mochi_blink_01.png          # 眨眼帧1（眼睛全开）
mochi_blink_02.png          # 眨眼帧2（眼睛半闭）
mochi_blink_03.png          # 眨眼帧3（眼睛全闭）
mochi_breathe_in.png        # 呼吸帧-吸气
mochi_breathe_out.png       # 呼吸帧-呼气
```

---

## 后处理步骤

生成素材后，在导入Godot前进行以下处理：

### 1. 背景移除
如果生成的图像有白色背景：
- 使用Photoshop/GIMP的魔棒工具删除白色背景
- 或使用在线工具：remove.bg

### 2. 尺寸调整
- 使用图像编辑软件缩放到320×320px
- 保持透明背景
- 导出为PNG格式

### 3. 质量检查
- [ ] 透明背景无白边
- [ ] 边缘抗锯齿平滑
- [ ] 颜色与Art Bible调色板一致
- [ ] 文件大小合理（每个文件<200KB）

---

## 导入到Godot

### 文件放置
将处理好的PNG文件放入：
```
assets/art/characters/mochi/
```

### Godot导入设置
在Godot中选中素材，在Inspector中设置：
- **Compress > Mode**: Lossless
- **Mipmaps > Generate**: false
- **Filter**: true（启用抗锯齿）
- **Repeat**: false

### 应用Shader
为角色应用纸质纹理Shader：
1. 创建ShaderMaterial
2. 选择 `res://src/shaders/paper_overlay.gdshader`
3. 设置参数：
   - `paper_texture`: `res://assets/art/textures/base/tex_paper_grain.png`
   - `paper_strength`: 0.25
   - `paper_scale`: 1.0

---

## 迭代优化

第一批素材生成后，根据以下标准评估：

### 视觉一致性
- [ ] 所有表情的角色造型一致（头身比、配色、装饰）
- [ ] 风格统一（几何简化程度、边缘柔和度）
- [ ] 符合Art Bible定义的混合风格

### 技术可行性
- [ ] 透明背景干净无瑕疵
- [ ] 尺寸适合320×320px画布
- [ ] 表情差异明显可辨识

### 情感表达
- [ ] 每个表情传达的情绪清晰
- [ ] 整体氛围温暖友好
- [ ] 适合长时间陪伴的虚拟伙伴定位

---

## 常见问题

### Q: AI生成的角色每次都不一样怎么办？
**A**: 使用Midjourney的 `--seed` 参数或Stable Diffusion的种子值固定随机性。第一次生成满意的造型后，记录种子值，后续表情变体使用相同种子。

### Q: 生成的角色太复杂/太简单？
**A**: 调整提示词：
- 太复杂：添加 "minimalist", "simple shapes", "flat design"
- 太简单：添加 "detailed texture", "subtle decorations", "refined design"

### Q: 颜色不符合调色板？
**A**: 在提示词中明确指定颜色：
```
color palette: cream white (#F5F1E8), dusty blue (#A8B8C8), lotus pink (#E8B4B8), matcha green (#C8D4B8)
```

### Q: 边缘太硬/太模糊？
**A**: 
- 太硬：添加 "soft edges", "watercolor style"
- 太模糊：添加 "clean edges", "vector-like", 减少水彩相关词汇

---

## 下一步

完成Mochi角色素材后，继续生成：
1. **窗口框架素材**（F1模块）- 参考 `design/art/specs/f1-window-assets.md`
2. **主界面UI素材**（P1模块）- 参考 `design/art/specs/p1-ui-assets.md`

所有素材规格详见：`design/art/` 目录下的对应文档。
