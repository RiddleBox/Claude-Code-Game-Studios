# C1 角色动画资产规格（Character Animation Assets Specification）

> **Module**: C1 角色动画系统
> **Created**: 2026-04-19
> **Status**: Draft
> **Priority**: P0 MVP

---

## 资产清单概览

| 资产类别 | 数量 | 优先级 | 预估工作量 |
|---------|------|--------|-----------|
| 角色主体动画（Idle） | 4 帧 | P0 MVP | 4-6 小时 |
| 眨眼动画（Blink） | 3 帧 | P0 MVP | 2-3 小时 |
| 挥手动画（Wave） | 6 帧 | P0 MVP | 4-5 小时 |
| 表情资产（独立图层） | 3 个变体 | P0 MVP | 3-4 小时 |
| 行走动画（Walk） | 6 帧 | P1 垂直切片 | 4-5 小时 |
| 坐下动画（Sit） | 4 帧 | P1 垂直切片 | 3-4 小时 |
| 睡觉动画（Sleep） | 4 帧 | P1 垂直切片 | 3-4 小时 |

**总计 MVP 必需资产**: 16 个文件（13 帧 + 3 表情）
**总计预估工作量**: 13-18 小时

---

## 角色设计规格

### 首个角色：Mochi（もち）

**设计方向**: 柔软、圆润、非人类但亲近

**基础形态**:
- 物种：未定义（类似精灵/小妖怪，非具体动物）
- 比例：2.5 头身（超变形 Chibi 风格）
- 主体色：`#F4C2A8`（淡雅粉橙）+ `#F5F1E8`（温暖米白）
- 强调色：`#F4A460`（活力橙黄，用于细节和情绪高光）

**关键特征**:
- 大眼睛（占头部约 1/3），圆形，色彩 `#6B7FA8`（深邃蓝紫）
- 简化的嘴巴（小圆点或短线，表情变化时可扩展）
- 柔软的身体轮廓（无明显骨骼感，像布偶或软泥）
- 小手小脚（简化为圆形或椭圆形末端）
- 可选装饰：头顶一撮呆毛或小触角

**尺寸规格**:
- 精灵画布：512×512 px
- 角色主体高度：约 280-320 px（占画布 55-62%）
- 角色主体宽度：约 200-240 px
- 锚点位置：画布中心（256, 256）
- 边距：上下左右各留 10% 空白（约 50px），避免动画时裁切

---

## 1. Idle 动画（待机循环）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `char_mochi_idle_01.png` ~ `char_mochi_idle_04.png` |
| **帧数** | 4 帧 |
| **尺寸** | 512×512 px（每帧） |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 背景完全透明，角色主体 100% 不透明，边缘抗锯齿 |
| **帧率** | 8 fps（循环时长 0.5s） |
| **循环方式** | 正向循环（1→2→3→4→1） |

### 动画描述

**动作**: 轻微的呼吸感 + 身体微微上下浮动

**关键帧**:
1. **Frame 01**（起始帧）：角色站立，身体处于中间位置，眼睛睁开
2. **Frame 02**（吸气）：身体轻微向上浮动（+4px），身体略微膨胀（宽度 +2%）
3. **Frame 03**（呼气开始）：身体回到中间位置，身体恢复正常宽度
4. **Frame 04**（呼气结束）：身体轻微向下沉（-2px），身体略微收缩（宽度 -1%）

**构图**: INSIDE 模式（下半身被窗口底边遮挡，呈现上半身+头部）

**表情**: 中性平静（neutral），眼睛睁开，嘴巴小圆点

### AI 生成提示词模板

```
A cute chibi character named Mochi for a desktop pet game, 2.5 head-to-body ratio, soft rounded body shape like a plush toy, main color soft peach (#F4C2A8) with warm beige (#F5F1E8) accents, large round eyes (deep blue-purple #6B7FA8) taking up 1/3 of head, small dot mouth, simplified hands and feet as rounded shapes, gentle and approachable design, standing idle pose with slight breathing motion, upper body visible as if inside a window frame, illustration-quality NPR style with clear outlines and 2-3 layer cel shading, paper texture overlay, warm and healing aesthetic, transparent background, 512x512px canvas with character 280-320px tall

Style: illustration-quality NPR, clear outlines with variable line width, 2-3 layer saturated color cel shading, paper grain texture overlay, "animated illustration" feel
Mood: soft, gentle, healing, non-threatening, companionable
Technical: transparent background PNG, anti-aliased edges, anchor point at canvas center, 10% margin on all sides

Animation frame: [描述具体帧的动作]
- Frame 01: neutral standing position, body at center height, eyes open
- Frame 02: body lifted up 4px, slightly wider (+2%), inhaling
- Frame 03: body back to center, normal width
- Frame 04: body lowered 2px, slightly narrower (-1%), exhaling
```

### 分帧生成策略

**方法 1: 单帧独立生成**（推荐用于 AI 生成）
- 为每一帧单独生成图像，使用上述提示词 + 具体帧描述
- 优点：每帧质量可控
- 缺点：需要手动确保角色一致性（色彩、比例、特征）

**方法 2: 基础帧 + 手动调整**
- 生成 Frame 01 作为基础
- 在图像编辑软件中复制并手动调整位置/形变生成其他帧
- 优点：一致性最高
- 缺点：需要手动编辑技能

**方法 3: 动画序列生成**（实验性）
- 使用支持动画的 AI 工具（如 Runway Gen-2）生成短循环动画
- 提取关键帧
- 优点：动作流畅性好
- 缺点：风格一致性难控制，可能需要大量重试

### Godot 导入设置

```gdscript
# 创建 SpriteFrames 资源
var frames = SpriteFrames.new()
frames.add_animation("idle")
frames.set_animation_loop("idle", true)
frames.set_animation_speed("idle", 8.0)

frames.add_frame("idle", preload("res://assets/characters/mochi/char_mochi_idle_01.png"))
frames.add_frame("idle", preload("res://assets/characters/mochi/char_mochi_idle_02.png"))
frames.add_frame("idle", preload("res://assets/characters/mochi/char_mochi_idle_03.png"))
frames.add_frame("idle", preload("res://assets/characters/mochi/char_mochi_idle_04.png"))

# 使用 AnimatedSprite2D
var sprite = AnimatedSprite2D.new()
sprite.sprite_frames = frames
sprite.play("idle")
```

### 验收标准

- [ ] 4 帧循环播放流畅，无明显跳变
- [ ] 角色在所有帧中位置、比例、色彩一致（±5% 容差）
- [ ] 呼吸动作自然，不过于夸张
- [ ] 透明背景无意外不透明像素
- [ ] 边缘抗锯齿平滑，无明显锯齿
- [ ] 每帧文件大小 < 150KB

---

## 2. Blink 动画（眨眼）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `char_mochi_blink_01.png` ~ `char_mochi_blink_03.png` |
| **帧数** | 3 帧 |
| **尺寸** | 512×512 px（每帧） |
| **帧率** | 12 fps（总时长 0.25s） |
| **循环方式** | 单次播放（触发式） |

### 动画描述

**动作**: 快速眨眼

**关键帧**:
1. **Frame 01**：眼睛睁开（与 Idle Frame 01 相同）
2. **Frame 02**：眼睛半闭（上眼睑下移至眼睛中部）
3. **Frame 03**：眼睛完全闭合（上下眼睑合拢，呈现弧形线条）

**播放逻辑**: Blink 播放完成后自动返回 Idle 动画

### AI 生成提示词模板

```
[使用 Idle Frame 01 的基础提示词，修改眼睛部分]

- Frame 01: eyes fully open (same as idle)
- Frame 02: eyes half-closed, upper eyelid lowered to middle of eye
- Frame 03: eyes fully closed, curved line shape for closed eyelids

Keep all other elements identical to idle animation (body position, expression, colors)
```

### 验收标准

- [ ] 眨眼动作快速自然（0.25s）
- [ ] 除眼睛外其他部分与 Idle Frame 01 完全一致
- [ ] 闭眼时眼睑呈现自然弧形，不是直线
- [ ] 每帧文件大小 < 150KB

---

## 3. Wave 动画（挥手）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `char_mochi_wave_01.png` ~ `char_mochi_wave_06.png` |
| **帧数** | 6 帧 |
| **尺寸** | 512×512 px（每帧） |
| **帧率** | 8 fps（总时长 0.75s） |
| **循环方式** | 单次播放（触发式） |

### 动画描述

**动作**: 抬起右手（或左手）挥动 2-3 次

**关键帧**:
1. **Frame 01**：起始姿势（与 Idle 相同），手臂放下
2. **Frame 02**：手臂开始抬起（抬至身体侧面 45°）
3. **Frame 03**：手臂抬至最高点（约 90°），手掌朝向玩家
4. **Frame 04**：手掌向左摆动（第一次挥手）
5. **Frame 05**：手掌向右摆动（第二次挥手）
6. **Frame 06**：手臂开始放下，回到起始姿势

**次级动作**: 身体轻微倾斜（跟随手臂动作），头部轻微转向挥手方向

**表情**: 开心（happy），眼睛弯成月牙形，嘴巴上扬

### AI 生成提示词模板

```
[使用 Idle 基础提示词，添加动作和表情描述]

Animation frame: character waving hand in greeting gesture
- Frame 01: starting pose, arm down at side, neutral expression
- Frame 02: arm lifting to 45 degrees, body slightly leaning, expression starting to smile
- Frame 03: arm raised to 90 degrees, hand palm facing viewer, happy expression with crescent eyes and smiling mouth
- Frame 04: hand waving left, arm still raised
- Frame 05: hand waving right, arm still raised
- Frame 06: arm lowering back to starting position, expression returning to neutral

Secondary motion: body leans slightly following arm movement, head turns slightly toward waving direction
Expression: happy with crescent-shaped eyes and upward curved mouth in frames 3-5
```

### 验收标准

- [ ] 挥手动作流畅，有加速和减速感（ease-in-out）
- [ ] 手臂运动轨迹自然，不僵硬
- [ ] 表情变化与动作同步
- [ ] 次级动作（身体倾斜、头部转动）明显但不夸张
- [ ] 每帧文件大小 < 150KB

---

## 4. 表情资产（独立图层）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `char_mochi_face_neutral.png` / `happy.png` / `curious.png` |
| **数量** | 3 个变体（MVP） |
| **尺寸** | 256×256 px（仅面部区域） |
| **格式** | PNG，32-bit RGBA |
| **用途** | 独立于主体动画，可动态组合（可选功能） |

### 表情变体

#### 4.1 Neutral（中性）

**描述**: 平静、放松的默认表情

**特征**:
- 眼睛：圆形，睁开，瞳孔居中
- 嘴巴：小圆点或短横线
- 眉毛：无（或极淡的弧形）

#### 4.2 Happy（开心）

**描述**: 愉悦、满足的表情

**特征**:
- 眼睛：弯成月牙形（^_^）
- 嘴巴：上扬的弧线，露出小舌头（可选）
- 整体：面部轮廓略微上扬

#### 4.3 Curious（好奇）

**描述**: 疑惑、探索的表情

**特征**:
- 眼睛：睁大，瞳孔略微偏向一侧
- 嘴巴：小圆形（"o"形）
- 头部：轻微倾斜（通过主体动画实现，表情资产本身不倾斜）

### AI 生成提示词模板

```
Close-up facial expression for Mochi character, 256x256px, isolated face region only (no body), same style as full character (illustration-quality NPR, clear outlines, cel shading, paper texture), transparent background

Expression: [neutral / happy / curious]
- Neutral: round open eyes with centered pupils, small dot or short line mouth, calm and relaxed
- Happy: crescent-shaped eyes (^_^), upward curved smiling mouth, optional small tongue visible, slightly lifted facial contours
- Curious: wide open eyes with pupils slightly to one side, small "o" shaped mouth, inquisitive look

Colors: same as main character (eyes #6B7FA8, face #F4C2A8)
```

### 使用方式（可选功能）

```gdscript
# 表情系统（Post-MVP）
# 将表情作为独立 Sprite2D 叠加在角色头部
var face_sprite = Sprite2D.new()
face_sprite.texture = preload("res://assets/characters/mochi/char_mochi_face_happy.png")
face_sprite.position = Vector2(0, -80)  # 相对于角色锚点的偏移
character_node.add_child(face_sprite)
```

### 验收标准

- [ ] 表情风格与主体动画一致
- [ ] 表情特征清晰可辨（眼睛、嘴巴）
- [ ] 可独立使用或叠加在主体动画上
- [ ] 每个文件大小 < 50KB

---

## 5. Walk 动画（行走）

> **优先级**: P1 垂直切片

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `char_mochi_walk_01.png` ~ `char_mochi_walk_06.png` |
| **帧数** | 6 帧 |
| **帧率** | 8 fps（总时长 0.75s，循环） |

### 动画描述

**动作**: 左右脚交替迈步，身体上下轻微起伏

**关键帧**:
1. **Frame 01**：左脚向前，右脚在后，身体略低
2. **Frame 02**：双脚并拢，身体抬高（过渡帧）
3. **Frame 03**：右脚向前，左脚在后，身体略低
4. **Frame 04**：双脚并拢，身体抬高（过渡帧）
5. **Frame 05**：左脚向前（循环回 Frame 01 姿势）
6. **Frame 06**：过渡帧

**次级动作**: 手臂轻微前后摆动（与脚步相反），头部轻微上下浮动

### AI 生成提示词模板

```
[使用 Idle 基础提示词，添加行走动作]

Animation frame: character walking cycle
- Frame 01: left foot forward, right foot back, body slightly lowered
- Frame 02: feet together, body raised (transition)
- Frame 03: right foot forward, left foot back, body slightly lowered
- Frame 04: feet together, body raised (transition)
- Frame 05: left foot forward (same as frame 01)
- Frame 06: transition frame

Secondary motion: arms swing slightly opposite to legs, head bobs gently up and down
```

---

## 6. Sit 动画（坐下）

> **优先级**: P1 垂直切片

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `char_mochi_sit_01.png` ~ `char_mochi_sit_04.png` |
| **帧数** | 4 帧 |
| **帧率** | 8 fps（循环） |

### 动画描述

**动作**: 坐在窗口底边，双腿悬空或盘坐，身体轻微摇晃

**关键帧**:
1. **Frame 01**：坐姿，身体居中
2. **Frame 02**：身体轻微向左倾斜
3. **Frame 03**：身体回到居中
4. **Frame 04**：身体轻微向右倾斜

---

## 7. Sleep 动画（睡觉）

> **优先级**: P1 垂直切片

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `char_mochi_sleep_01.png` ~ `char_mochi_sleep_04.png` |
| **帧数** | 4 帧 |
| **帧率** | 6 fps（慢速循环） |

### 动画描述

**动作**: 蜷缩睡姿，轻微的呼吸起伏

**关键帧**:
1. **Frame 01**：身体蜷缩，眼睛闭合
2. **Frame 02**：身体略微膨胀（吸气）
3. **Frame 03**：身体恢复正常
4. **Frame 04**：身体略微收缩（呼气）

**特效**: 可选添加"Zzz"符号（通过代码叠加，非资产本身）

---

## 技术要求总结

### 文件命名规范

所有 C1 资产遵循命名规范：`char_[name]_[action]_[frame].png`

示例：
- `char_mochi_idle_01.png`
- `char_mochi_wave_03.png`
- `char_mochi_face_happy.png`

### 一致性检查清单

每个新帧必须通过以下检查：

- [ ] 角色主体色彩与首帧一致（±5% 容差）
- [ ] 角色比例与首帧一致（头身比、四肢长度）
- [ ] 轮廓线宽度一致（2-3px）
- [ ] 阴影层数和色彩一致（2-3 层 cel shading）
- [ ] 纸质纹理强度一致
- [ ] 锚点位置一致（画布中心）
- [ ] 边距一致（上下左右各 10%）

### 批量处理脚本

```python
# tools/validate_character_frames.py
# 验证角色帧动画的一致性

import PIL.Image
import numpy as np

def validate_frame_consistency(frame_paths):
    """
    检查多帧动画的一致性：
    - 尺寸一致性
    - 色彩分布相似度
    - 角色主体位置偏移范围
    """
    pass

def apply_paper_texture(frame_path, texture_path, strength=0.3):
    """
    为角色帧叠加纸质纹理
    """
    pass
```

---

## 资产制作优先级

### Phase 1: MVP 必需（P0）

**目标**: 验证角色动画系统基本功能

1. `char_mochi_idle_01.png` ~ `04.png` — Idle 动画（4 帧）
2. `char_mochi_blink_01.png` ~ `03.png` — Blink 动画（3 帧）
3. `char_mochi_wave_01.png` ~ `06.png` — Wave 动画（6 帧）
4. `char_mochi_face_neutral.png` — 中性表情
5. `char_mochi_face_happy.png` — 开心表情
6. `char_mochi_face_curious.png` — 好奇表情

**预估工作量**: 13-18 小时
**验收标准**: 角色可正常显示、播放 Idle 循环、响应交互触发 Wave 动画

### Phase 2: 垂直切片（P1）

**目标**: 完整角色动作集

7. `char_mochi_walk_01.png` ~ `06.png` — Walk 动画（6 帧）
8. `char_mochi_sit_01.png` ~ `04.png` — Sit 动画（4 帧）
9. `char_mochi_sleep_01.png` ~ `04.png` — Sleep 动画（4 帧）

**预估工作量**: 10-13 小时

---

## 外包/协作指南

### 交付包内容

1. **角色设计稿**（concept art）：正面、侧面、背面视图 + 表情板
2. **色彩配置文件**：精确的 Hex 色值 + Photoshop 色板
3. **动画时序表**（exposure sheet）：每个动画的关键帧描述
4. **参考视频**（可选）：真人演示动作或参考动画片段

### 质量控制流程

1. **首帧审核**：生成 Idle Frame 01，确认风格、比例、色彩后再继续
2. **动画预览**：每个动画完成后提供 GIF 预览，确认流畅度
3. **批量交付**：所有帧通过审核后统一交付源文件 + PNG

---

## 已知问题与待定事项

### 待定

- [ ] 角色具体物种/设定需与叙事方向协调（当前为"未定义精灵"）
- [ ] 是否需要多角色变体（不同色彩/装饰）供玩家选择
- [ ] 表情系统是否在 MVP 实现（当前为可选功能）
- [ ] 角色精灵的锚点位置最终确认（中心点 vs 脚底）

### 阻塞

- 无阻塞项（C1 资产可独立制作）

---

*本文档为 C1 角色动画系统的完整资产规格。所有资产制作需与 `design/art/art-direction.md` 保持一致。*
