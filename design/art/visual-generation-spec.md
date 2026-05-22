# 跨世界观察视觉生成规范（Cross-World Observation Visual Generation Spec）

*Created: 2026-05-08*
*Version: 1.0*
*Status: Active*
*Type: Visual Production Standard*

---

## 文档定位

**这是美术资产生成的执行标准**，用于指导所有场景背景、角色场景的视觉生成。

本规范：
- 基于 `design/core/connection-relationship.md` 的核心哲学
- 提供可执行的Prompt设计规范
- 确保视觉输出符合项目的世界观和观看关系
- 适用于AI生成、手绘、外包等所有美术生产流程

**来源**：与ChatGPT的深度讨论和迭代验证

---

## 0. 核心目标（North Star）

玩家不是进入角色世界的人。

玩家是：

> 通过某个媒介观察另一个真实存在的生活。

角色不是为玩家表演。

角色只是活着。

玩家只是窥见。

### 视觉目标

```
authentic private existence, quietly witnessed
真实的私人存在，被安静地见证
```

**不是**：

```
staged companionship
被安排的陪伴
```

---

## 1. 十二条世界观规则（必须遵守）

### Rule 1 — Observer is not physically present

**玩家不是**：
- 桌对面的人
- 房间里的客人
- 共处者
- 参与者

**玩家是**：
- 观察附着点
- 可能是：设备、装置、小物件、固定观察位、环境里的无害存在

**Prompt implications**：

✅ **允许**：
```
unnoticed observing presence
attached viewpoint
observer-side perch
quiet observation point
```

❌ **避免**：
```
shared desk
sitting across from her
companion perspective
interactive viewpoint
```

---

### Rule 2 — Character is self-contained

角色必须按自己的生活逻辑行动。

她不会：
- 对镜头摆姿势
- 朝观察者展示内容
- 把物品朝玩家摆放
- 为玩家腾位置

✅ **正确**：
```
fully engaged in her own private workflow
self-contained domestic behavior
unaware natural activity
private lived routine
```

❌ **错误**：
```
looking toward viewer
sharing notes
showing her book
offering tea
facing the observer
```

---

### Rule 3 — Observer Presence Must Have Physical Logic

镜头不能是幽灵。

必须有"附着位置"。

否则空间会悬空。

✅ **允许**：
- shelf edge
- workbench corner
- side apparatus
- doorway edge
- alcove lip
- cabinet gap
- observer-side ledge

❌ **错误**：
```
floating camera
abstract cinematic view
free camera
dramatic angle
```

**原因**：这些会变成概念图镜头，而不是世界内观察镜头。

---

### Rule 4 — Foreground Must Explain Viewpoint

前景不是装饰。

前景是物理定位证据。

**作用**：说明"我在哪看"。

✅ **好的前景**：
```
partial bottle silhouette
shelf edge
blurred apparatus detail
cabinet frame
hanging tools
observer-side clutter
wooden ledge
foreground obstruction
```

❌ **坏前景**：
```
decorative clutter only
random cinematic blur
center framing objects
```

**重点**：前景不能挡主体，前景只用于 anchoring（锚定）。

---

### Rule 5 — No Literal Portal Framing

**非常重要**

❌ **禁止**："通过一个圆洞看过去"

**原因**：模型会生成 porthole、magical portal、telescope frame、circular window frame

**结果**：玩家变成 physically separated viewer，而不是 attached unnoticed presence

❌ **禁止词**：
```
through portal
through aperture
through circular opening
through porthole
through viewing device
framed by portal
```

✅ **正确替代**：
```
observer-side anchored viewpoint
subtle environmental framing
attached observational position
```

---

### Rule 6 — No Face-to-Face Social Composition

❌ **禁止**：对桌构图

**原因**：模型默认对面有人，然后：
- 书朝玩家
- 茶杯 for two
- social symmetry

❌ **禁止**：
```
shared desk
across from her
opposite seat
face-to-face composition
```

✅ **允许**：
```
offset observer position
side vantage
peripheral observation
angled observer perch
```

---

### Rule 7 — Composition Should Preserve Private Life

画面要像：偶然看到

不是：刻意构图给你看

✅ **允许**：
- asymmetry
- off-center subject
- partially obscured framing
- lived disorder
- imperfect placement

❌ **避免**：
- perfect symmetry
- centered presentation
- character staged toward viewer

---

### Rule 8 — Environmental Storytelling > Character Portrait

主角不是脸。

主角是：她的生活。

**Prompt priority**：

```
环境 > 行为 > 人物
```

**不是**：

```
人物 > 环境
```

✅ **正确**：
```
environmental storytelling
lived-in domestic realism
architectural intimacy
private ritual
```

❌ **错误**：
```
beautiful girl portrait
detailed face focus
cinematic character closeup
```

**原因**：否则会变二次元角色图。

---

### Rule 9 — Stable Style Layer

风格层独立。

**推荐固定**：
```
architectural editorial illustration
restrained cinematic environmental storytelling
precise fine ink linework
subtle paper grain texture
muted desaturated palette
lived-in architectural detail
quiet atmospheric realism
refined publication illustration aesthetic
```

**作用**：固定线条、色彩、质感、插画语言

主题层可以替换。

---

### Rule 10 — Prompt Layer Order

**最稳定顺序**：

```
Style
↓
World behavior rules
↓
Viewpoint rules
↓
Composition rules
↓
Subject action
↓
Environmental detail
```

**推荐结构**：
```
[STYLE]
[WORLD RELATIONSHIP]
[VIEWPOINT PHYSICS]
[COMPOSITION]
[SUBJECT ACTION]
[ENVIRONMENT]
```

---

### Rule 11 — Avoid Semantic Contamination

模型会继承前文 bias。

**例如**：

一旦用了 `portal`、`aperture`、`resonance window`
→ 后面全变圆洞

一旦用了 `shared desk`
→ 后面全变 companionship

**建议**：
- 重大实验：新对话
- 同线程适合：微调
- 新线程适合：构图验证

---

### Rule 12 — Good Prompt Skeleton

**万能模板**：

```
architectural editorial illustration,
restrained cinematic environmental storytelling,
precise fine ink linework,
subtle paper grain texture,
muted desaturated palette,
lived-in architectural detail,
quiet atmospheric realism,
refined publication illustration aesthetic,

private lived existence quietly observed,
the character remains fully engaged in her own self-contained activity,
not staged for an observer,

viewpoint anchored from a believable unnoticed observer-side perch within the environment,
foreground environmental objects subtly implying physical observer placement,

asymmetrical intimate composition,
environment-first storytelling,

[SUBJECT ACTION],

[ENVIRONMENT DETAILS]
```

---

## 2. 实战示例

### Example A — 魔药工坊

```
architectural editorial illustration,
restrained cinematic environmental storytelling,
precise fine ink linework,
subtle paper grain texture,
muted desaturated palette,
lived-in architectural detail,
quiet atmospheric realism,
refined publication illustration aesthetic,

private lived existence quietly observed,
the character remains fully engaged in her own self-contained activity,
not staged for an observer,

viewpoint anchored from a narrow observer-side shelf near the workshop,
subtle foreground bottles and wooden shelf edges implying physical observer placement,

asymmetrical intimate environmental composition,

a young woman quietly reading from a worn alchemical notebook while tending a large simmering cauldron,
surrounded by dried herbs, glass bottles, handwritten botanical notes, old tools, warm window light, believable domestic magical workshop
```

---

### Example B — 夜间书房

```
architectural editorial illustration,
restrained cinematic environmental storytelling,
precise fine ink linework,
subtle paper grain texture,
muted desaturated palette,
lived-in architectural detail,

private lived existence quietly observed,
the character remains immersed in her own routine,
not staged toward the observer,

viewpoint anchored from the edge of a nearby bookshelf,
foreground partial book spines and shelf shadows implying observer position,

off-center contemplative composition,

a young scholar writing late into the night by candlelight,
papers, annotated manuscripts, tea stains, cramped study walls, quiet rain outside
```

---

### Example C — 厨房生活

```
architectural editorial illustration,
restrained cinematic environmental storytelling,
precise fine ink linework,
subtle paper grain texture,
muted desaturated palette,

private life quietly witnessed,
self-contained natural domestic behavior,

viewpoint anchored from a kitchen side cabinet,
foreground ceramic jars and hanging utensils subtly framing the view,

environment-first storytelling,

a woman preparing soup while reading a handwritten recipe,
warm domestic clutter, herbs, wooden shelves, soft daylight
```

---

### Example Origin — 原始满意版（参考）

```
architectural editorial illustration, restrained cinematic environmental storytelling, miniature diorama sensibility, precise fine ink linework, subtle paper grain texture, muted desaturated palette, lived-in architectural detail, poetic negative space, calm contemplative atmosphere,

viewed from a shared desk across a cross-world resonance aperture, intimate situated observer perspective, partial foreground occlusion, quiet co-presence,

a young woman quietly working at her desk in an unfamiliar fantasy dwelling, books, handwritten notes, ceramic cup, soft window light, distant strange cityscape beyond the window, believable domestic environment
```

**注意**：此版本包含 `shared desk` 和 `aperture`，在后续迭代中被Rule 5和Rule 6替代。

---

## 3. 与项目核心哲学的对应

本规范直接实现了 `connection-relationship.md` 中的核心原则：

| 核心原则 | 对应规则 |
|---------|---------|
| **元原则1：玩家不是操作者，而是偶然的邻居** | Rule 1, Rule 6 |
| **元原则2：存在大于互动** | Rule 2, Rule 8 |
| **元原则3：想象力来自缺失（不完整原则）** | Rule 7, Rule 5 |
| **设计柱1：窥视感** | Rule 3, Rule 4, Rule 7 |
| **设计柱2：真实存在感** | Rule 2, Rule 8 |
| **设计柱4：陪伴不打扰** | Rule 9（低对比、安静氛围） |
| **镜头语言：被截取的生活镜头** | Rule 7, Rule 8 |
| **镜头语言：玩家视角必须"有位置"** | Rule 3, Rule 4 |
| **镜头语言：非表演性镜头** | Rule 2 |

---

## 4. 质量检查清单

每个生成的场景必须通过以下检查：

### 世界观检查
- [ ] 角色是否在忙自己的事（不是看镜头）？
- [ ] 玩家视角是否有物理附着位置？
- [ ] 是否避免了"对桌构图"？
- [ ] 是否避免了"圆洞/传送门"框架？

### 构图检查
- [ ] 是否非对称、非居中？
- [ ] 前景是否暗示了观察位置？
- [ ] 环境叙事是否优先于角色特写？
- [ ] 是否像"偶然看到"而非"刻意展示"？

### 风格检查
- [ ] 是否符合固定的风格层关键词？
- [ ] 线条、色彩、质感是否一致？
- [ ] 是否避免了二次元角色图风格？

### 情绪检查
- [ ] 是否传达"安静的私人存在"？
- [ ] 是否有生活感和时间感？
- [ ] 是否符合"治愈日常"的基调？

---

## 5. 常见错误与修正

### 错误 1：角色看向镜头

**症状**：角色眼神朝向观察者，像在营业

**原因**：Prompt中使用了 `looking toward viewer`、`facing observer`

**修正**：
```
fully engaged in her own activity
absorbed in her work
unaware of observation
```

---

### 错误 2：对桌构图

**症状**：桌子中间有对称轴，书朝向玩家

**原因**：使用了 `shared desk`、`across from her`

**修正**：
```
offset observer position
side vantage point
angled observation
```

---

### 错误 3：圆形传送门框架

**症状**：画面被圆形洞口框住

**原因**：使用了 `portal`、`aperture`、`through opening`

**修正**：
```
observer-side anchored viewpoint
subtle environmental framing
```

---

### 错误 4：角色特写

**症状**：脸部占据大部分画面，环境模糊

**原因**：Prompt中人物描述在环境之前

**修正**：调整顺序，环境 > 行为 > 人物

---

### 错误 5：悬浮镜头

**症状**：视角像无人机，没有物理依据

**原因**：缺少前景和观察位置描述

**修正**：
```
viewpoint anchored from [specific location]
foreground [specific objects] implying observer placement
```

---

## 6. 迭代优化流程

### 第一轮：验证世界观

重点检查：
- 角色是否自洽？
- 观察关系是否正确？
- 是否避免了禁忌词？

### 第二轮：优化构图

重点检查：
- 前景是否有效？
- 非对称是否自然？
- 环境叙事是否充分？

### 第三轮：统一风格

重点检查：
- 线条质感是否一致？
- 色彩饱和度是否克制？
- 是否符合"安静氛围"？

### 第四轮：细节打磨

重点检查：
- 生活痕迹是否足够？
- 时间感是否体现？
- 情绪是否到位？

---

## 7. 扩展到不同主题

本规范的核心规则（Rule 1-8, 11）**不随主题改变**。

可变部分：
- **Subject Action**：角色在做什么
- **Environment Details**：具体的环境元素
- **World Type**：奇幻/蒸汽朋克/现代异世界等

**示例**：

同样的规则，不同的主题：

**主题：蒸汽朋克工程师**
```
[固定风格层]
[固定世界观规则]
[固定视角规则]

a young engineer adjusting brass gears on a complex mechanical apparatus,
surrounded by blueprints, copper pipes, pressure gauges, warm gas lamp light, industrial workshop
```

**主题：现代异世界学者**
```
[固定风格层]
[固定世界观规则]
[固定视角规则]

a researcher annotating field notes beside strange botanical specimens,
surrounded by pressed flowers, glass slides, reference books, soft desk lamp, quiet study room
```

---

## 8. 与其他文档的关系

### 本规范是执行层文档

- **connection-relationship.md**：提供哲学基础
- **art-direction.md**：提供风格方向
- **scene-content-framework.md**：提供内容维度
- **本文档**：提供可执行的生成标准

### 决策优先级

当生成结果与规范冲突时：

1. **世界观规则（Rule 1-8）** > 视觉美观
2. **核心哲学** > 技术实现
3. **情绪正确** > 细节完美

**宁可构图不完美，也不能破坏世界观**

---

## 9. 适用范围

本规范适用于：

✅ **适用**：
- 场景背景生成（AI生成/手绘）
- 角色场景插画
- 概念图设计
- 外包美术指导
- 视觉风格验证

❌ **不适用**：
- 角色立绘（单独的角色设计有其他规范）
- UI元素设计
- 图标设计
- 纯装饰性美术

---

## 10. 版本历史

### v1.0 (2026-05-08)
- 初始版本
- 整合ChatGPT讨论的十二条规则
- 提供三个验证通过的示例
- 建立质量检查清单

---

*本文档为活文档，随视觉生产实践持续优化。所有美术资产生成必须符合本规范，确保视觉输出与项目核心哲学一致。*
