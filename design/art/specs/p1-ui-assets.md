# P1 主界面 UI 资产规格（Main UI Assets Specification）

> **Module**: P1 主界面 UI
> **Created**: 2026-04-19
> **Status**: Draft
> **Priority**: P0 MVP

---

## 资产清单概览

| 资产类别 | 数量 | 优先级 | 预估工作量 |
|---------|------|--------|-----------|
| 对话气泡 | 2 个部件 | P0 MVP | 2-3 小时 |
| 通知弹窗 | 2 个部件 | P1 垂直切片 | 2-3 小时 |
| 状态指示器 | 2 个图标 | P1 垂直切片 | 1-2 小时 |
| 泄漏内容特效 | 3 个变体 | P0 MVP | 3-4 小时 |
| 交互菜单背景 | 1 个 | P0 MVP | 1-2 小时 |

**总计 MVP 必需资产**: 6 个文件
**总计预估工作量**: 6-9 小时

---

## 设计原则

P1 主界面 UI 的核心设计原则是**不打扰**：

1. **半透明优先**：所有 UI 元素背景 60-80% 不透明，保持桌面可见性
2. **最小化装饰**：功能优先，避免过度装饰
3. **高对比度文字**：确保在任何背景下可读（对比度 ≥ 4.5:1）
4. **柔和动画**：淡入淡出 + 轻微滑动，避免突兀弹出
5. **自动避让**：UI 元素自动避开角色命中区，不遮挡主体

---

## 1. 对话气泡（Dialogue Bubble）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_bubble_dialogue.png` + `ui_bubble_tail.png` |
| **尺寸** | 主体 256×128 px，尾巴 32×32 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 背景 80% 不透明，边缘渐变至透明 |
| **9-Slice** | 主体使用 9-slice，尾巴不使用 |

### 1.1 对话气泡主体

**视觉描述**:

**结构**:
- 外形：圆角矩形（圆角半径 16px）
- 背景色：`#F5F1E8`（温暖米白），80% 不透明
- 边框：2px 宽，色彩 `#8A9BA8`（中性灰蓝），100% 不透明
- 内阴影：轻微内阴影（`#000000` 5% 叠加），营造纸质凹陷感
- 纹理：叠加纸质颗粒纹理（强度 20%）

**9-Slice 切片参数**:
- 上下左右各 32px
- 中心区域可拉伸以适应文字长度

### AI 生成提示词模板

```
A dialogue bubble UI element for desktop pet game, rounded rectangle shape with 16px corner radius, warm beige background (#F5F1E8) at 80% opacity, 2px border in gray-blue (#8A9BA8) fully opaque, subtle inner shadow for paper-like inset effect, paper grain texture overlay at 20% strength, soft and non-intrusive design, transparent background PNG, 256x128px, suitable for 9-slice scaling

Style: flat geometric with soft edges, paper texture, minimalist
Mood: warm, readable, gentle presence
Technical: 80% opacity background, 100% opacity border, 9-slice margins 32px on all sides
```

### 1.2 对话气泡尾巴

**视觉描述**:

**结构**:
- 外形：三角形指向角色，边缘柔化
- 色彩：与主体背景一致（`#F5F1E8`，80% 不透明）
- 边框：与主体边框一致（`#8A9BA8`，2px）
- 方向：指向角色头部位置

**AI 生成提示词模板**:

```
A dialogue bubble tail (pointer) for desktop pet game, triangular shape pointing downward toward character, soft rounded edges, warm beige (#F5F1E8) at 80% opacity matching bubble body, 2px border in gray-blue (#8A9BA8), seamless connection to main bubble, transparent background PNG, 32x32px

Style: matches dialogue bubble main body, soft geometric
Technical: must align seamlessly with main bubble border
```

### Godot 使用方式

```gdscript
# 对话气泡组合节点
var bubble_container = Control.new()

# 主体（NinePatchRect）
var bubble_body = NinePatchRect.new()
bubble_body.texture = preload("res://assets/ui/ui_bubble_dialogue.png")
bubble_body.patch_margin_left = 32
bubble_body.patch_margin_top = 32
bubble_body.patch_margin_right = 32
bubble_body.patch_margin_bottom = 32
bubble_body.size = Vector2(200, 80)  # 根据文字内容动态调整

# 尾巴（Sprite2D）
var bubble_tail = Sprite2D.new()
bubble_tail.texture = preload("res://assets/ui/ui_bubble_tail.png")
bubble_tail.position = Vector2(100, 80)  # 指向角色

# 文字（Label）
var label = Label.new()
label.text = "你好！"
label.add_theme_color_override("font_color", Color("#6B7FA8"))
label.add_theme_constant_override("shadow_offset_x", 1)
label.add_theme_constant_override("shadow_offset_y", 1)
label.add_theme_color_override("font_shadow_color", Color("#FFFFFF", 0.5))

bubble_container.add_child(bubble_body)
bubble_container.add_child(bubble_tail)
bubble_body.add_child(label)
```

### 验收标准

- [ ] 气泡在纯白、纯黑、桌面壁纸三种背景下均清晰可读
- [ ] 9-slice 拉伸至 150px、250px、350px 宽度无变形
- [ ] 尾巴与主体边框无缝连接，无明显断层
- [ ] 文字在气泡内对比度 ≥ 4.5:1（WCAG AA 标准）
- [ ] 纸质纹理可见但不干扰文字阅读
- [ ] 主体文件大小 < 80KB，尾巴 < 10KB

---

## 2. 泄漏内容特效（Leak Content Effects）

### 2.1 文字泄漏样式

**用途**: Fe2 泄漏内容系统推送的文字内容视觉样式

**实现方式**: 通过 Godot Label + 自定义主题，非独立图片资产

**样式规格**:

| 属性 | 值 |
|------|-----|
| **字体** | Noto Sans CJK SC（思源黑体），Regular 权重 |
| **字号** | 16px（1080p 分辨率下） |
| **颜色** | `#6B7FA8`（深邃蓝紫），70% 不透明 |
| **描边** | 1px 白色描边（`#FFFFFF` 50% 不透明） |
| **阴影** | 偏移 (1, 1)，色彩 `#000000` 30% 不透明 |
| **背景** | 可选半透明背景（`#F5F1E8` 60% 不透明，圆角 8px） |

**特效变体**:

#### 变体 A: 模糊文字（Blurred Text）

**描述**: 文字边缘模糊，模拟"听不清"的感觉

**实现**: Godot Shader

```gdscript
shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    // 简单模糊采样
    vec4 blur = vec4(0.0);
    float samples = 9.0;
    for (float x = -1.0; x <= 1.0; x += 1.0) {
        for (float y = -1.0; y <= 1.0; y += 1.0) {
            vec2 offset = vec2(x, y) * blur_amount * TEXTURE_PIXEL_SIZE;
            blur += texture(TEXTURE, UV + offset);
        }
    }
    COLOR = blur / samples;
}
```

#### 变体 B: 闪烁文字（Flickering Text）

**描述**: 文字不透明度快速闪烁，模拟"信号不稳定"

**实现**: Godot AnimationPlayer

```gdscript
# 动画关键帧
0.0s: modulate.a = 0.7
0.1s: modulate.a = 0.3
0.2s: modulate.a = 0.8
0.3s: modulate.a = 0.4
0.4s: modulate.a = 0.7
```

#### 变体 C: 扭曲文字（Distorted Text）

**描述**: 文字轻微扭曲变形，模拟"空间不稳定"

**实现**: Godot Shader

```gdscript
shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float time_scale : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * 10.0 + TIME * time_scale) * distortion_strength;
    uv.y += cos(uv.x * 10.0 + TIME * time_scale) * distortion_strength;
    COLOR = texture(TEXTURE, uv);
}
```

### 2.2 洞口光晕特效（Portal Glow）

**用途**: 泄漏内容类型为 `portal` 时，窗口边缘的光晕效果

| 属性 | 值 |
|------|-----|
| **文件名** | `vfx_portal_glow.png` |
| **尺寸** | 512×512 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 中心 60% 不透明，边缘完全透明 |

**视觉描述**:

**结构**:
- 中心：柔和的光晕，色彩 `#A8C5DD`（柔和天蓝）+ `#F4A460`（活力橙黄）混合
- 外围：径向渐变至透明
- 动画：通过 Godot Tween 控制 `modulate.a` 和 `scale` 实现脉冲效果

**AI 生成提示词模板**:

```
A soft glowing portal effect for desktop pet game, 512x512px, radial gradient from center to transparent edges, color blend of sky blue (#A8C5DD) and warm orange (#F4A460), gentle luminous glow simulating mysterious energy leaking through window frame, ethereal and subtle aesthetic, transparent background PNG

Style: soft radial gradient, luminous glow, watercolor-like edges
Mood: mysterious, gentle, otherworldly
Technical: center 60% opacity fading to 0% at edges, used with Godot Tween for pulsing animation
```

### 2.3 视觉闪现特效（Visual Flash）

**用途**: 泄漏内容类型为 `visual` 时，短暂的视觉闪现

| 属性 | 值 |
|------|-----|
| **文件名** | `vfx_visual_flash.png` |
| **尺寸** | 256×256 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 中心 80% 不透明，边缘完全透明 |

**视觉描述**:

**结构**:
- 形状：不规则光斑，类似闪电或能量波动
- 色彩：`#F4A460`（活力橙黄）为主，边缘混合 `#E8B4C8`（温柔粉红）
- 动画：快速淡入（0.1s）+ 停留（0.2s）+ 快速淡出（0.1s）

**AI 生成提示词模板**:

```
A brief visual flash effect for desktop pet game, 256x256px, irregular light burst shape like lightning or energy ripple, warm orange-yellow (#F4A460) main color with soft pink (#E8B4C8) edges, quick and subtle flash simulating something glimpsed through window, transparent background PNG

Style: irregular organic shape, energy burst, soft edges
Mood: surprising, brief, mysterious
Technical: center 80% opacity fading to 0% at edges, used with quick fade-in/out animation (0.1s/0.1s)
```

### 验收标准

- [ ] 文字泄漏在所有背景下可读（对比度 ≥ 4.5:1）
- [ ] 特效 Shader 性能良好（< 1ms per frame）
- [ ] 洞口光晕与窗口边框协调，不突兀
- [ ] 视觉闪现快速但不刺眼
- [ ] 每个特效文件大小 < 100KB

---

## 3. 通知弹窗（Notification Panel）

> **优先级**: P1 垂直切片

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_notification_bg.png` + `ui_icon_notification.png` |
| **尺寸** | 背景 320×80 px，图标 48×48 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 背景 80% 不透明 |

### 3.1 通知背景

**视觉描述**:

**结构**:
- 外形：圆角矩形（圆角半径 12px）
- 背景色：`#F5F1E8`（温暖米白），80% 不透明
- 边框：1px 宽，色彩 `#8A9BA8`（中性灰蓝）
- 阴影：轻微外阴影（`#000000` 10% 叠加，偏移 (2, 2)）
- 纹理：纸质颗粒纹理（强度 15%）

**9-Slice 切片参数**:
- 上下左右各 24px

**AI 生成提示词模板**:

```
A notification panel background for desktop pet game, rounded rectangle with 12px corner radius, warm beige (#F5F1E8) at 80% opacity, 1px border in gray-blue (#8A9BA8), subtle outer shadow (offset 2,2) for floating effect, paper grain texture overlay at 15% strength, minimalist and non-intrusive design, transparent background PNG, 320x80px, suitable for 9-slice scaling

Style: flat geometric, soft rounded corners, paper texture
Mood: gentle, informative, non-disruptive
Technical: 80% opacity, 9-slice margins 24px on all sides
```

### 3.2 通知图标

**视觉描述**:

**结构**:
- 外形：简化的铃铛或信封符号
- 色彩：`#F4A460`（活力橙黄）
- 背景：圆形底色（`#F5F1E8`，100% 不透明）
- 尺寸：图标主体占 48×48 画布的 70%

**AI 生成提示词模板**:

```
A notification icon for desktop pet game, 48x48px, simplified bell or envelope symbol in warm orange-yellow (#F4A460), circular background in warm beige (#F5F1E8) fully opaque, clean and recognizable design, flat geometric style, transparent background PNG

Style: flat icon design, minimalist, high legibility
Mood: friendly, informative
Technical: icon occupies 70% of 48x48 canvas, clear at small size
```

### Godot 使用方式

```gdscript
# 通知弹窗节点
var notification = NinePatchRect.new()
notification.texture = preload("res://assets/ui/ui_notification_bg.png")
notification.patch_margin_left = 24
notification.patch_margin_top = 24
notification.patch_margin_right = 24
notification.patch_margin_bottom = 24
notification.size = Vector2(300, 70)

# 图标
var icon = Sprite2D.new()
icon.texture = preload("res://assets/ui/ui_icon_notification.png")
icon.position = Vector2(30, 35)

# 文字
var label = Label.new()
label.text = "角色带回了新的碎片"
label.position = Vector2(60, 20)

notification.add_child(icon)
notification.add_child(label)

# 淡入动画
notification.modulate.a = 0.0
var tween = create_tween()
tween.tween_property(notification, "modulate:a", 1.0, 0.3)
tween.tween_interval(3.0)
tween.tween_property(notification, "modulate:a", 0.0, 0.3)
tween.tween_callback(notification.queue_free)
```

---

## 4. 状态指示器（Status Indicators）

> **优先级**: P1 垂直切片

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_indicator_out.png` + `ui_indicator_busy.png` |
| **尺寸** | 32×32 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 图标 100% 不透明，背景透明 |

### 4.1 外出状态指示器

**视觉描述**:

**结构**:
- 图标：简化的门或箭头符号（指向外）
- 色彩：`#8A9BA8`（中性灰蓝）
- 背景：圆形底色（`#F5F1E8`，80% 不透明）

**AI 生成提示词模板**:

```
A status indicator icon for "character is out", 32x32px, simplified door or outward arrow symbol in gray-blue (#8A9BA8), circular background in warm beige (#F5F1E8) at 80% opacity, minimalist and clear design, transparent background PNG

Style: flat icon, minimalist, clear meaning
Mood: neutral, informative
```

### 4.2 忙碌状态指示器

**视觉描述**:

**结构**:
- 图标：简化的沙漏或旋转符号
- 色彩：`#F4A460`（活力橙黄）
- 背景：圆形底色（`#F5F1E8`，80% 不透明）

**AI 生成提示词模板**:

```
A status indicator icon for "character is busy", 32x32px, simplified hourglass or spinning symbol in warm orange-yellow (#F4A460), circular background in warm beige (#F5F1E8) at 80% opacity, minimalist and clear design, transparent background PNG

Style: flat icon, minimalist, clear meaning
Mood: active, informative
```

---

## 5. 交互菜单背景（Interaction Menu Background）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_menu_interaction_bg.png` |
| **尺寸** | 160×120 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 背景 85% 不透明 |

**视觉描述**:

**结构**:
- 外形：圆角矩形（圆角半径 12px）
- 背景色：`#F5F1E8`（温暖米白），85% 不透明
- 边框：2px 宽，色彩 `#8A9BA8`（中性灰蓝）
- 阴影：明显外阴影（`#000000` 15% 叠加，偏移 (3, 3)），强化浮层感
- 纹理：纸质颗粒纹理（强度 20%）

**9-Slice 切片参数**:
- 上下左右各 24px

**AI 生成提示词模板**:

```
An interaction menu background for desktop pet game, rounded rectangle with 12px corner radius, warm beige (#F5F1E8) at 85% opacity, 2px border in gray-blue (#8A9BA8), prominent outer shadow (offset 3,3) for strong floating effect, paper grain texture overlay at 20% strength, clean and functional design, transparent background PNG, 160x120px, suitable for 9-slice scaling

Style: flat geometric, soft rounded corners, paper texture, floating panel
Mood: functional, accessible, clear hierarchy
Technical: 85% opacity for strong presence, 9-slice margins 24px on all sides
```

### Godot 使用方式

```gdscript
# 交互菜单
var menu = NinePatchRect.new()
menu.texture = preload("res://assets/ui/ui_menu_interaction_bg.png")
menu.patch_margin_left = 24
menu.patch_margin_top = 24
menu.patch_margin_right = 24
menu.patch_margin_bottom = 24
menu.size = Vector2(140, 100)

# 按钮（使用 Button 节点 + 自定义主题）
var btn1 = Button.new()
btn1.text = "戳一戳"
btn1.position = Vector2(10, 10)
btn1.size = Vector2(120, 30)

var btn2 = Button.new()
btn2.text = "看看它"
btn2.position = Vector2(10, 50)
btn2.size = Vector2(120, 30)

menu.add_child(btn1)
menu.add_child(btn2)

# 淡入 + 轻微回弹动画
menu.modulate.a = 0.0
menu.scale = Vector2(0.8, 0.8)
var tween = create_tween()
tween.set_parallel(true)
tween.tween_property(menu, "modulate:a", 1.0, 0.2)
tween.tween_property(menu, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
```

---

## 技术要求总结

### 文件命名规范

所有 P1 资产遵循命名规范：`ui_[component]_[variant].png`

示例：
- `ui_bubble_dialogue.png`
- `ui_notification_bg.png`
- `ui_indicator_out.png`
- `vfx_portal_glow.png`

### 字体配置

**推荐字体**: Noto Sans CJK SC（思源黑体）

**字号规格**:
- 标题：20px
- 正文：16px
- 辅助信息：14px
- 最小字号：12px（不低于此值以确保可读性）

**字体文件**:
```
assets/fonts/NotoSansCJKsc-Regular.ttf
assets/fonts/NotoSansCJKsc-Bold.ttf
```

### 可访问性检查

所有 UI 元素必须通过以下检查：

- [ ] 文字与背景对比度 ≥ 4.5:1（WCAG AA 标准）
- [ ] 最小可点击区域 ≥ 32×32 px
- [ ] 色盲友好（不依赖颜色单独传达信息）
- [ ] 支持键盘导航（通过 Godot focus 系统）
- [ ] 动画可关闭（通过设置选项）

### 性能要求

- 所有 UI 资产文件大小 < 100KB
- UI 渲染帧时间 < 2ms
- 动画过渡流畅（60fps）
- 内存占用 < 10MB（所有 UI 资产总和）

---

## 资产制作优先级

### Phase 1: MVP 必需（P0）

**目标**: 验证主界面 UI 基本功能

1. `ui_bubble_dialogue.png` — 对话气泡主体
2. `ui_bubble_tail.png` — 对话气泡尾巴
3. `vfx_portal_glow.png` — 洞口光晕特效
4. `vfx_visual_flash.png` — 视觉闪现特效
5. `ui_menu_interaction_bg.png` — 交互菜单背景

**预估工作量**: 6-9 小时
**验收标准**: 对话气泡可正常显示、泄漏内容特效可触发、交互菜单可弹出

### Phase 2: 垂直切片（P1）

**目标**: 完整 UI 体验

6. `ui_notification_bg.png` — 通知弹窗背景
7. `ui_icon_notification.png` — 通知图标
8. `ui_indicator_out.png` — 外出状态指示器
9. `ui_indicator_busy.png` — 忙碌状态指示器

**预估工作量**: 3-5 小时

---

## 外包/协作指南

### 交付包内容

1. **UI 设计稿**（Figma / Sketch）：所有 UI 元素的矢量源文件
2. **色彩配置文件**：精确的 Hex 色值 + 色板
3. **字体文件**：Noto Sans CJK SC（Regular + Bold）
4. **9-Slice 切片指南**：每个需要 9-slice 的资产的切片参数标注

### 质量控制流程

1. **对比度测试**：使用 WebAIM Contrast Checker 验证所有文字对比度
2. **多背景测试**：在纯白、纯黑、桌面壁纸三种背景下截图验证
3. **缩放测试**：9-slice 资产拉伸至 150%、200% 验证无变形
4. **动画预览**：提供 GIF 预览展示淡入淡出效果

---

## 已知问题与待定事项

### 待定

- [ ] 对话气泡是否需要多种色彩变体（如不同情绪对应不同背景色）
- [ ] 泄漏内容特效的具体触发频率和持续时间需与 Fe2 协调
- [ ] 交互菜单的具体按钮内容需与游戏设计协调
- [ ] 通知弹窗的位置（窗口上方 vs 下方）需实际测试后确定

### 阻塞

- 无阻塞项（P1 资产可独立制作）

---

*本文档为 P1 主界面 UI 的完整资产规格。所有资产制作需与 `design/art/art-direction.md` 保持一致。*
