# Theme 01 Prompts: Modern Fantasy Rooftop Terrace

*Created: 2026-04-24*
*For: Nana Banana (primary), Midjourney (backup)*

---

## Prompt Strategy

**核心挑战**：
1. 平衡"现代感"与"奇幻感"（避免纯现代或纯奇幻）
2. 控制远景细节密度（避免背景过于复杂）
3. 体现"悬浮"等魔法元素（AI可能难以理解）

**解决方案**：
- 明确描述"现代建筑+魔法点缀"
- 强调"远景简化轮廓"
- 用具体例子（"玻璃幕墙+魔法光纹"）

---

## Nana Banana Prompt（推荐）

### 正向提示词（中文）

```
建筑师手绘速写风格，钢笔线条加淡水彩渲染，现代奇幻都市高层露台场景，

前景：木质地板，小圆桌上有冒热气的茶杯和翻开的书，简约木椅上搭着外套，地面有拖鞋，2-3个小盆栽，前景密集线条细节和木纹，

中景：简约现代木质栏杆（横向木条），一侧浅色墙面，栏杆上挂着小型球形魔法灯（淡光），地板木纹清晰，

远景：现代奇幻都市天际线，玻璃幕墙高楼群，标志性尖塔顶部有魔法光环，悬浮的圆环结构（魔法支撑），远处天空有流线型悬浮交通工具剪影，淡蓝天空，几朵白云，

午后阳光从上方照入，暖木色前景，米黄中景，淡蓝灰远景，前景极密集交叉排线，中景适度细节，远景极简轮廓，选择性上色（木质暖橙色，天空蓝白渐变，建筑灰蓝色），整体纸张底色淡米黄，水彩略微溢出线稿边缘，16:9横向构图

关键强化：
- 现代建筑+魔法元素点缀（modern architecture with magic accents）
- 远景极简轮廓（minimal outline for distant buildings）
- 前景密集细节（dense linework in foreground）
- 悬浮结构（floating structures with magic support）
```

### 负向提示词（中文）

```
纯白纸张底色，平涂颜色无渐变，色彩严格在线稿内不溢出，饱和度过高，鲜艳颜色，漫画风格，完成的插画，工整，可爱风格，对称构图，

中世纪城堡，石头建筑，蒸汽朋克齿轮，古代建筑，传统奇幻风格，飞艇，马车，

室内场景，封闭空间，无天空，无远景，

远景过多细节，背景建筑窗户清晰，背景人物，背景车辆细节，

前景过于简单，前景无细节，前景无生活痕迹
```

---

## Midjourney Prompt（备用）

### 正向提示词（英文）

```
Architectural pen sketch with light watercolor wash, modern fantasy city rooftop terrace scene, 

foreground: wooden deck floor with small round table, steaming tea cup and open book on table, minimalist wooden chair with draped jacket, slippers on floor, 2-3 small potted plants, extremely dense cross-hatching and wood grain details, 

midground: minimalist modern wooden railing with horizontal slats, light-colored wall on one side, small spherical magic lamp hanging on railing (soft glow), clear floor wood grain, 

background: modern fantasy city skyline, glass curtain wall skyscrapers, iconic spire with magic light ring at top, floating circular structure (magic-supported), streamlined hovering vehicle silhouettes in distant sky, pale blue sky with few white clouds, 

afternoon sunlight from above, warm wood tones in foreground, beige midground, pale blue-gray background, extremely dense linework in foreground, moderate detail in midground, minimal outline for distant buildings, selective coloring (warm orange wood, blue-white gradient sky, gray-blue buildings), overall paper base in pale cream, watercolor slightly bleeding beyond line edges, 16:9 landscape --style raw --stylize 350 --ar 16:9

Key emphasis:
- modern architecture with subtle magic accents
- minimal outline for distant buildings
- dense cross-hatching in foreground
- floating structures with magic support
```

### 负向提示词（英文）

```
pure white paper base, flat color without gradient, color strictly within lines, oversaturated, vibrant colors, comic style, finished illustration, neat, cute style, symmetrical composition, 

medieval castle, stone buildings, steampunk gears, ancient architecture, traditional fantasy style, airships, horse carriages, 

indoor scene, enclosed space, no sky, no distant view, 

excessive detail in background, clear windows in background buildings, background characters, detailed background vehicles, 

overly simple foreground, no detail in foreground, no living traces in foreground
```

---

## Stable Diffusion Prompt（高级）

### 正向提示词

```
(architectural sketch:1.3), (pen and watercolor:1.2), modern fantasy rooftop terrace, 

(foreground:1.4): wooden deck, small table with (steaming tea cup:1.2), open book, chair with jacket, slippers, potted plants, (extremely detailed linework:1.4), (wood grain texture:1.3), 

(midground:1.2): modern wooden railing, light wall, magic lamp, (moderate detail:1.1), 

(background:1.0): (modern city skyline:1.2), glass buildings, (magic elements:1.2), floating structures, hovering vehicles, blue sky, (minimal detail:0.8), (simplified outline:1.1), 

afternoon light, (warm tones foreground:1.2), (cool tones background:0.9), (selective coloring:1.2), (watercolor bleeding:1.1), pale cream paper, 16:9 landscape

Negative: pure white paper, flat color, comic style, medieval, steampunk, traditional fantasy, excessive background detail, symmetrical, cute style
```

**推荐模型**：
- Base: Stable Diffusion XL
- LoRA: "architectural sketch" + "watercolor style"
- Sampler: DPM++ 2M Karras
- Steps: 30-40
- CFG Scale: 7

---

## Generation Strategy

### Phase 1: Initial Generation（首次生成）

**目标**：验证整体构图和氛围

**步骤**：
1. 使用 Nana Banana 完整提示词
2. 生成 3-5 张
3. 快速评估：
   - 是否有露台+栏杆+远景天际线？
   - 前景是否有桌椅+茶杯+书？
   - 远景是否有现代建筑+魔法元素？

**预期问题**：
- 可能生成纯现代场景（无魔法元素）
- 可能生成纯奇幻场景（无现代感）
- 远景可能过于复杂

---

### Phase 2: Iteration（迭代调整）

**如果问题1：无魔法元素（纯现代）**

**调整**：
- 正向提示词加强："魔法光环明显"，"悬浮结构清晰可见"
- 增加权重（如果工具支持）："(magic light ring:1.3)"

**如果问题2：无现代感（纯奇幻）**

**调整**：
- 正向提示词加强："玻璃幕墙"，"现代简约设计"
- 负向提示词加强："中世纪"，"石头城堡"，"传统奇幻"

**如果问题3：远景过于复杂**

**调整**：
- 正向提示词加强："远景极简轮廓"，"背景模糊"
- 负向提示词加强："背景过多细节"，"背景建筑窗户清晰"

**如果问题4：前景过于简单**

**调整**：
- 正向提示词加强："前景极密集线条"，"木纹清晰"
- 检查是否遗漏关键物品（茶杯、书、外套）

---

### Phase 3: Quality Scoring（质量评分）

使用 7 维度评分系统：

| 维度 | 目标 | 评分标准 |
|------|------|---------|
| 1. 世界观辨识度 | ≥3 | 能看出是现代奇幻（有魔法元素+现代建筑） |
| 2. 空间可读性 | ≥4 | 一眼看出是露台（栏杆+地板+天空） |
| 3. 角色活动区清晰度 | ≥4 | 前景地面空间充足，可放置角色 |
| 4. 生活感/使用痕迹 | ≥3 | 有茶杯/书/外套等使用痕迹 |
| 5. 色彩层次 | ≥4 | 前景暖色，远景冷色，层次分明 |
| 6. 光照合理性 | ≥3 | 午后阳光方向一致 |
| 7. 细节密度对比 | ≥4 | 前景密集，远景简化，对比明显 |

**通过标准**：所有维度 ≥3，至少 5 个维度 ≥4

---

## Fallback Strategy（备用方案）

**如果 3 轮迭代后仍未达标**：

### 选项A：切换工具
- 从 Nana Banana 切换到 Midjourney
- Midjourney 对"现代+奇幻"混合风格理解更好

### 选项B：简化魔法元素
- 移除"悬浮结构"（难以生成）
- 只保留"建筑顶部光环"（更容易）
- 移除"悬浮交通工具"（可后期添加）

### 选项C：分层生成
- Pass 1: 生成基础构图（露台+天际线）
- Pass 2: 手动添加魔法元素（Photoshop 叠加光效）
- Pass 3: 最终润色

---

## Expected Output（预期产出）

### 理想结果描述

**整体**：
- 一个现代简约的高层露台
- 前景有温馨的茶歇场景（桌椅+茶杯+书）
- 远景是现代奇幻都市天际线（玻璃高楼+魔法光效）
- 午后阳光明媚，色彩温暖

**前景**（占画面下 1/2）：
- 木质地板纹理清晰
- 小圆桌+椅子+茶杯+书，细节丰富
- 线条密集，有手绘速写感

**中景**（占画面中 1/3）：
- 木质栏杆清晰可见
- 栏杆上有小型魔法灯（球形，淡光）
- 一侧有浅色墙面

**远景**（占画面上 1/3）：
- 淡蓝天空+白云
- 现代高楼轮廓（玻璃幕墙）
- 标志性建筑有魔法光环（顶部发光）
- 可能有悬浮结构剪影
- 细节极简，不抢前景

**色彩**：
- 前景：暖木色（#D2691E）+ 米黄（#F5DEB3）
- 中景：原木色（#CD853F）+ 浅灰白（#F5F5F5）
- 远景：淡蓝（#87CEEB）+ 灰蓝（#708090）
- 魔法光：淡青色（#AFEEEE，低透明度）

---

## Test Checklist（测试检查清单）

生成后检查：

**构图**：
- [ ] 前景有地板+桌椅
- [ ] 中景有栏杆
- [ ] 远景有天空+建筑

**物品**：
- [ ] 桌上有茶杯
- [ ] 桌上有书
- [ ] 椅子上有外套或地面有拖鞋
- [ ] 有 1-2 个盆栽

**世界观**：
- [ ] 远景建筑是现代风格（玻璃幕墙）
- [ ] 有至少 1 个魔法元素（光环/悬浮结构/魔法灯）

**细节密度**：
- [ ] 前景线条密集（木纹、物品轮廓清晰）
- [ ] 远景简化（建筑只有轮廓）

**色彩**：
- [ ] 前景偏暖色
- [ ] 远景偏冷色
- [ ] 有色彩层次

**氛围**：
- [ ] 整体温馨悠闲
- [ ] 光照明亮（午后感）
- [ ] 有生活气息（不是样板间）

---

## Next Steps

1. **复制 Nana Banana 提示词**
2. **生成 3-5 张测试**
3. **评分并选择最佳**
4. **如需迭代，参考 Phase 2 调整策略**
5. **达标后进入后期处理**

---

*本提示词基于 `theme-01-modern-fantasy-rooftop.md` 生成，遵循 `scene-generation-workflow.md` 的 Stage 3 流程。*
