# Style Exploration Test Prompts v3

*Created: 2026-04-22*
*Purpose: 测试3个风格融合方向，解决"平庸、缺少记忆点"问题*

---

## 测试策略

**目标**: 找到独特但不怪异的视觉签名，让玩家3次曝光后能识别"这是Window Whisper的风格"

**测试场景**: Task 2 街景咖啡座（中等复杂度，适合对比）

**测试方向**:
1. **方向A（主推）**: 墨骨水彩 - 水彩下方显示墨线骨架
2. **方向B（备选）**: 选择性饱和 - 80%灰度+20%色彩焦点
3. **方向C（保底）**: 渐变网格叠加 - 几何网格+有机水彩

---

## 方向A: 墨骨水彩 (Ink Wash Underdrawing) ⭐ 主推

### 核心特征
- 水彩下方可见30-40%透明度的墨线骨架
- 墨线有书法质感（粗细变化、自信笔触）
- 墨线**不完整**（有意留白，不是完整线稿）
- 背景建筑有墨线结构，前景纯水彩

### 视觉钩子
"能看到艺术家的初稿草图" - 手工感、未完成美学、独特层次

### 完整提示词

**中文意图**:
```
水彩背景板，下方可见墨线草图骨架，安静街角咖啡座，松散的书法墨线（30%透明度）定义建筑边缘和咖啡座结构，墨线有粗细变化和自信笔触，线条有意留白不完整，水彩色块覆盖在墨线基础上，温暖午后阳光，前景用色彩定义形体（无墨线），背景建筑显示墨线结构，柔和色调（米色建筑+鼠尾草绿植物），大气宁静，有意的未完成美学，可见纸张纹理，手绘笔触感，16:9横向构图
```

**Nana Banana 提示词**:
```
Watercolor background plate with visible ink underdrawing, quiet street corner cafe, loose gestural ink sketch defining building edges and cafe structure at 30% opacity beneath watercolor washes, ink strokes have calligraphic quality with thick-thin variation and confident gestures, intentional gaps in ink lines creating strategic incompleteness, watercolor color masses applied over ink foundation, warm afternoon sunlight filtering through, color-defined forms in foreground without ink, ink structure visible in background buildings, muted pastel palette with cream buildings and sage green plants, atmospheric and peaceful quality, intentionally unfinished aesthetic suggesting artist's process, visible paper grain texture, hand-painted organic brush strokes, 16:9 landscape format, background plate for game character placement

Negative: complete ink outlines, uniform line weight, detailed linework filling every corner, pen and ink illustration, comic book style, heavy black lines, finished line art, vector art, sharp boundaries, architectural precision, every corner resolved, detailed furniture linework, window pane grid lines, chair slat details, decorative ironwork, tile patterns, individual leaves, wood grain texture, fabric folds, photorealistic, 3D render, CGI, oversaturated colors, neon colors, pure black shadows, crowded, busy streets, cars, vehicles, people, characters, text on signs
```

### 预期效果
- 背景建筑有淡淡的棕褐色/灰色墨线骨架（像草图）
- 墨线不连续，有呼吸感
- 水彩色块柔和覆盖，墨线若隐若现
- 前景咖啡座纯水彩（无墨线），自然形成层次

### 评估重点
- **Dimension 7 (细节克制度)**: 墨线应该简化结构，不增加细节密度
- **记忆点**: 用户能否描述"能看到底下的草图线条"
- **治愈感**: 墨线是否温暖（棕褐色）而非冰冷（纯黑）

---

## 方向B: 选择性饱和 (Selective Color Saturation)

### 核心特征
- 80%画面接近灰度（10-20%饱和度）
- 20%区域全饱和（60-80%）在光照/情感焦点
- 色彩作为情感聚光灯
- "记忆褪色，唯有关键时刻鲜明"美学

### 视觉钩子
"色彩只出现在重要的地方" - 戏剧性、情感引导、独特对比

### 完整提示词

**中文意图**:
```
选择性饱和水彩背景板，安静街角咖啡座大部分去饱和至接近灰度（10-20%饱和度），战略性色彩焦点在温暖午后阳光区域和盆栽植物（60-80%饱和度），色彩出现在光照处形成情感焦点，柔和的近单色调色板+选择性暖色点缀，大气沉思质感，记忆般美学（色彩突出重要元素），可见纸张纹理，柔和边缘，16:9横向构图
```

**Nana Banana 提示词**:
```
Watercolor background plate with selective color saturation, quiet street corner cafe mostly desaturated to near-grayscale (10-20% saturation), strategic color pops at warm afternoon sunlight areas and potted plants (60-80% saturation), color appears where light hits creating emotional focal points, muted near-monochrome palette with selective warm color accents in amber and sage green, atmospheric and contemplative quality, memory-like aesthetic with color highlighting important elements, visible paper grain texture, soft edges and watercolor bleeding, color as emotional spotlight not decoration, 16:9 landscape format, background plate for game character placement

Negative: uniform saturation, fully colored, vibrant everywhere, rainbow colors, oversaturated, neon colors, flat desaturation, pure black and white, no color variation, cold color pops, blue or purple accents, harsh contrast, detailed linework, pen and ink outlines, complete illustration, finished artwork, architectural precision, photorealistic, 3D render, CGI
```

### 预期效果
- 整体画面柔和灰调（奶油色、浅灰、米色）
- 阳光照射的窗户/门框区域呈现温暖琥珀色（全饱和）
- 盆栽植物的绿色鲜明（全饱和）
- 其他区域褪色，像褪色的记忆

### 评估重点
- **记忆点**: 用户能否描述"大部分是灰的，只有几处有颜色"
- **治愈感**: 是否感觉"忧郁但温暖"而非"冰冷悲伤"
- **可用性**: 色彩焦点是否自然引导视线，不会分散注意力

---

## 方向C: 渐变网格叠加 (Gradient Mesh Overlay)

### 核心特征
- 水彩基础上叠加10-20%透明度的几何渐变网格
- 网格跟随透视（不是平面叠加）
- 网格内有渐变色彩过渡
- 有机水彩+几何结构的对比

### 视觉钩子
"几何亲吻水彩" - 现代感、窗格隐喻、微妙结构

### 完整提示词

**中文意图**:
```
带微妙几何渐变网格叠加的水彩背景板，安静街角咖啡座用柔和水彩绘制，精致网格图案跟随场景透视叠加（15%透明度），网格单元内有温和色彩渐变过渡，有机水彩与几何结构的并置，温暖午后阳光，柔和色调，网格暗示窗格隐喻，当代与传统美学融合，可见纸张纹理，柔和边缘，16:9横向构图
```

**Nana Banana 提示词**:
```
Watercolor background plate with subtle geometric gradient mesh overlay, quiet street corner cafe painted in soft watercolor washes, delicate grid pattern following scene perspective overlaid at 15% opacity, gradients within grid cells creating gentle color shifts, juxtaposition of organic watercolor and geometric structure, warm afternoon sunlight, muted pastel palette with cream buildings and sage green plants, mesh suggests window pane metaphor reinforcing game theme, contemporary meets traditional aesthetic, visible paper grain texture, soft edges and watercolor bleeding, grid is barely visible and non-intrusive, 16:9 landscape format, background plate for game character placement

Negative: heavy grid, dominant geometric pattern, cold digital overlay, perfect mathematical grid, harsh lines, vector grid, wireframe, technical drawing, graph paper, busy pattern, distracting overlay, detailed linework, pen and ink outlines, complete illustration, architectural precision, photorealistic, 3D render, CGI, oversaturated colors, neon colors
```

### 预期效果
- 水彩咖啡座场景（与当前风格相似）
- 非常微妙的暖色调网格叠加（需要仔细看才能发现）
- 网格跟随建筑透视，不是平面贴图
- 网格内有温和的色彩渐变（米色→琥珀色）

### 评估重点
- **记忆点**: 用户能否描述"有一层淡淡的网格"
- **治愈感**: 网格是否温暖（暖色调）而非冰冷（灰色）
- **可用性**: 网格是否太明显/分散注意力

---

## 测试流程

### 第1步: 生成3个版本（今天）
1. 使用上述3个提示词在Nana Banana生成Task 2场景
2. 每个方向生成1张（共3张）
3. 技术参数：1920×1080px, PNG, <2MB

### 第2步: 7维度评估（今天）
使用 `generation-task-pack-001.md` 的评分标准：
- Dimension 1-6: 构图、色彩、空气透视、纸质感、边缘、清晰度
- **Dimension 7 (细节克制度)**: 重点评估，必须≥3分

### 第3步: 记忆点测试（明天）
给5个人看3张图（不说明差异），问：
1. "哪张最有记忆点？"
2. "用3个词描述每张图"
3. "哪张你愿意看8小时？"

### 第4步: 决策（明天）
- 如果某个方向≥60%选择率 → 采用为主风格
- 如果都不理想 → 测试方向2（撕纸拼贴）或方向4（留白主导）
- 如果多个方向都好 → 混合使用（不同场景类型用不同风格）

---

## 快速对比表

| 维度 | 方向A 墨骨水彩 | 方向B 选择性饱和 | 方向C 渐变网格 |
|------|---------------|-----------------|---------------|
| **记忆点强度** | 高 | 高 | 中 |
| **治愈感契合度** | 高（手工感） | 中（可能偏忧郁） | 中高（现代感） |
| **AI生成难度** | 中（3/5） | 低（2/5） | 低（2/5） |
| **后期处理时间** | 15-30分钟 | 10-20分钟 | 5-15分钟 |
| **风险等级** | 中 | 中 | 低 |
| **独特性** | 高（少见） | 中（Sin City风格） | 中（Gris风格） |
| **可扩展性** | 好（批量生产） | 好（后期处理） | 极好（Shader） |

---

## 推荐优先级

### 第1优先: 方向A（墨骨水彩）⭐
**理由**:
- 解决核心问题：增加记忆点但不增加细节密度
- 手工感强，契合治愈定位
- 市场上少见，有辨识度
- 技术可行，可批量生产

**如果失败**: 墨线太重/太乱 → 调整透明度或切换到方向C

### 第2优先: 方向C（渐变网格）
**理由**:
- 最安全，风险低
- 可用Godot Shader实现（无需每张图手动处理）
- 契合"窗口"主题
- 如果方向A失败，这是可靠备选

**如果失败**: 网格太明显/太冷 → 调整透明度和色温

### 第3优先: 方向B（选择性饱和）
**理由**:
- 戏剧性强，但可能偏离"治愈"定位
- 适合特定场景（回忆、梦境）而非全局风格
- 如果前两个都失败，可作为"情感高潮场景"的特殊风格

---

## 后续计划

### 如果方向A成功
1. 更新 `visual-design-system.md` 添加"墨骨水彩"为核心签名
2. 更新 `generation-task-pack-001.md` 所有提示词包含墨线元素
3. 创建墨线透明度指南（不同场景类型用不同透明度）
4. 探索墨线作为叙事工具（回忆场景墨线更明显，现实场景更淡）

### 如果方向C成功
1. 在Godot创建 `window_mesh_overlay.gdshader`
2. 网格密度/透明度可通过代码动态调整
3. 不同时间段/情绪状态改变网格颜色
4. 网格可作为UI元素的视觉呼应

### 如果都不理想
1. 测试高风险方向：撕纸拼贴（方向2）或留白主导（方向4）
2. 考虑混合策略：基础水彩+多种风格叠加选项
3. 重新审视参考图，寻找遗漏的视觉特征

---

## 附录: 后期处理指南

### 如果AI生成的墨线太重（方向A）
1. 在Photoshop/Krita中分离墨线层
2. 降低透明度至20-30%
3. 使用柔光混合模式（Soft Light）而非正常模式
4. 用橡皮擦工具（柔边，30%透明度）擦除部分墨线，增加留白

### 如果色彩焦点不够明显（方向B）
1. 复制图层，下层去饱和至10%
2. 上层保留原色，用遮罩擦除非焦点区域
3. 焦点区域可增加饱和度+10-20%
4. 添加微妙发光效果（Outer Glow, 2px, 10%透明度）

### 如果网格太明显（方向C）
1. 降低网格层透明度至5-10%
2. 使用暖色调渐变（米色→琥珀色）而非灰色
3. 添加高斯模糊（0.5-1px）柔化网格边缘
4. 使用叠加混合模式（Overlay）而非正常模式

---

*准备好了！复制对应方向的提示词到Nana Banana，生成3张对比图，然后我们评估结果。*
