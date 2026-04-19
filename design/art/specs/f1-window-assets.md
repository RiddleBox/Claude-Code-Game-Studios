# F1 窗口系统资产规格（Window System Assets Specification）

> **Module**: F1 桌面窗口系统
> **Created**: 2026-04-19
> **Status**: Draft
> **Priority**: P0 MVP

---

## 资产清单概览

| 资产类别 | 数量 | 优先级 | 预估工作量 |
|---------|------|--------|-----------|
| 窗口边框 | 2 个变体 | P0 MVP | 2-3 小时 |
| 控制按钮 | 3 组（每组 4 态） | P0 MVP | 3-4 小时 |
| 系统托盘图标 | 1 个 | P0 MVP | 1 小时 |
| 启动淡入特效 | 1 个（可选） | P1 垂直切片 | 2-3 小时 |

**总计 MVP 必需资产**: 14 个文件
**总计预估工作量**: 6-8 小时

---

## 1. 窗口边框（Window Border）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_window_border_normal.png` |
| **尺寸** | 512×512 px（9-slice 切片） |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 边框主体 70% 不透明，外围渐变至完全透明 |
| **色彩空间** | sRGB |
| **9-Slice 切片参数** | 上下左右各 64px，中心区域可拉伸 |

### 视觉描述

**风格**: 水彩晕染边缘 + 纸质纹理

**结构**:
- 外圈：柔和的水彩晕染效果，色彩从 `#F5F1E8`（温暖米白）向外渐变至透明
- 中圈：轻微的纸质颗粒纹理叠加，营造手绘质感
- 内圈：清晰但柔化的边界线，宽度约 2-3px，色彩 `#8A9BA8`（中性灰蓝）

**光照**: 左上方 45° 入射，边框左上侧轻微高光（`#FFFFFF` 10% 叠加），右下侧轻微阴影（`#000000` 5% 叠加）

### AI 生成提示词模板

```
A watercolor-style window frame border for a desktop pet game, soft edges with paper texture overlay, warm beige (#F5F1E8) color fading to transparent at outer edges, subtle gray-blue (#8A9BA8) inner border line 2-3px wide, gentle highlight from top-left at 45 degrees, cozy and non-intrusive aesthetic, hand-painted illustration quality, transparent background, 512x512px, suitable for 9-slice scaling

Style: watercolor wash, paper grain texture, soft geometric shapes
Mood: warm, healing, gentle presence
Technical: PNG with alpha channel, 70% opacity for main border, gradient fade to 0% at edges
```

### 变体：聚焦状态边框

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_window_border_focus.png` |
| **差异** | 内圈边界线色彩改为 `#F4A460`（活力橙黄），宽度增至 3-4px，轻微外发光效果 |

**AI 生成提示词**（基于上述模板修改）:
```
[使用上述基础提示词，追加]
, with inner border line changed to warm orange-yellow (#F4A460) 3-4px wide, subtle outer glow effect to indicate focus state, slightly more vibrant while maintaining gentle aesthetic
```

### Godot 导入设置

```gdscript
# 在 Godot 导入面板设置
Compress: Lossless
Mipmaps: Disabled
Filter: Linear
Repeat: Disabled

# 使用 NinePatchRect 节点
texture = preload("res://assets/ui/ui_window_border_normal.png")
patch_margin_left = 64
patch_margin_top = 64
patch_margin_right = 64
patch_margin_bottom = 64
```

### 验收标准

- [ ] 边框在纯白、纯黑、桌面壁纸三种背景下均清晰可见且不突兀
- [ ] 9-slice 拉伸至 320×320、480×480、640×640 三种尺寸无明显变形
- [ ] 透明度渐变平滑，无明显分层或色带
- [ ] 纸质纹理在 100% 缩放下可见但不抢眼
- [ ] 文件大小 < 200KB

---

## 2. 控制按钮（Control Buttons）

### 2.1 关闭按钮（Close Button）

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_btn_close_normal.png` / `hover.png` / `pressed.png` / `disabled.png` |
| **尺寸** | 32×32 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 按钮背景 90% 不透明，图标 100% 不透明 |

### 视觉描述

**Normal 状态**:
- 背景：圆角矩形（圆角半径 6px），色彩 `#F5F1E8`（温暖米白），90% 不透明
- 图标：简化的 "×" 符号，线宽 2px，色彩 `#8A9BA8`（中性灰蓝）
- 阴影：轻微内阴影，营造轻微凹陷感

**Hover 状态**:
- 背景色改为 `#F4A460`（活力橙黄），90% 不透明
- 图标色改为 `#FFFFFF`（白色）
- 轻微缩放至 105%（通过 Godot Tween 实现，非资产本身）

**Pressed 状态**:
- 背景色改为 `#E57373`（错误红，柔和版本）
- 图标色保持 `#FFFFFF`
- 缩放至 95%

**Disabled 状态**:
- 背景色改为 `#C8C8C8`（禁用灰），60% 不透明
- 图标色改为 `#8A9BA8`，50% 不透明

### AI 生成提示词模板

```
A close button icon for desktop pet game UI, 32x32px, rounded rectangle background (6px corner radius) in warm beige (#F5F1E8) 90% opacity, simple "×" symbol in center with 2px line width in gray-blue (#8A9BA8), subtle inner shadow for slight inset effect, flat geometric style with soft edges, minimalist and non-intrusive design, transparent background PNG

Style: flat geometric, soft rounded corners, paper texture overlay
Mood: gentle, accessible, clear function
Technical: 4 states needed - normal/hover/pressed/disabled
```

**Hover 状态提示词**:
```
[使用上述基础提示词，修改]
background color changed to warm orange-yellow (#F4A460), icon color changed to white (#FFFFFF), same dimensions and style
```

**Pressed 状态提示词**:
```
[使用上述基础提示词，修改]
background color changed to soft red (#E57373), icon color white (#FFFFFF), same dimensions and style
```

**Disabled 状态提示词**:
```
[使用上述基础提示词，修改]
background color changed to disabled gray (#C8C8C8) 60% opacity, icon color gray-blue (#8A9BA8) 50% opacity, same dimensions and style
```

### 2.2 设置按钮（Settings Button）

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_btn_settings_normal.png` / `hover.png` / `pressed.png` / `disabled.png` |
| **尺寸** | 32×32 px |
| **图标** | 齿轮符号（简化，6 齿） |

**AI 生成提示词**（基于关闭按钮模板）:
```
A settings button icon for desktop pet game UI, 32x32px, rounded rectangle background (6px corner radius) in warm beige (#F5F1E8) 90% opacity, simple gear icon with 6 teeth in center in gray-blue (#8A9BA8), subtle inner shadow, flat geometric style with soft edges, minimalist design, transparent background PNG

[Hover/Pressed/Disabled 状态同关闭按钮色彩变化规则]
```

### 2.3 最小化按钮（Minimize Button）

| 属性 | 值 |
|------|-----|
| **文件名** | `ui_btn_minimize_normal.png` / `hover.png` / `pressed.png` / `disabled.png` |
| **尺寸** | 32×32 px |
| **图标** | 简化的 "—" 符号（横线） |

**AI 生成提示词**（基于关闭按钮模板）:
```
A minimize button icon for desktop pet game UI, 32x32px, rounded rectangle background (6px corner radius) in warm beige (#F5F1E8) 90% opacity, simple horizontal line "—" symbol in center with 2px line width in gray-blue (#8A9BA8), subtle inner shadow, flat geometric style with soft edges, minimalist design, transparent background PNG

[Hover/Pressed/Disabled 状态同关闭按钮色彩变化规则]
```

### Godot 导入设置

```gdscript
# 所有按钮资产
Compress: Lossless
Mipmaps: Disabled
Filter: Linear
Repeat: Disabled

# 使用 TextureButton 节点
texture_normal = preload("res://assets/ui/ui_btn_close_normal.png")
texture_hover = preload("res://assets/ui/ui_btn_close_hover.png")
texture_pressed = preload("res://assets/ui/ui_btn_close_pressed.png")
texture_disabled = preload("res://assets/ui/ui_btn_close_disabled.png")
```

### 验收标准

- [ ] 所有按钮在 100% 缩放下图标清晰可辨，无模糊或锯齿
- [ ] Hover 状态色彩变化明显但不刺眼
- [ ] Pressed 状态视觉反馈清晰（配合 Godot 缩放动画）
- [ ] Disabled 状态明显区别于可用状态
- [ ] 四态之间过渡平滑（通过 Godot AnimationPlayer 实现）
- [ ] 每个文件大小 < 10KB

---

## 3. 系统托盘图标（System Tray Icon）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `icon_tray.png` |
| **尺寸** | 64×64 px（Windows 系统托盘推荐尺寸，自动缩放至 16×16 / 32×32） |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 背景完全透明，图标主体 100% 不透明 |

### 视觉描述

**设计方向**: 简化的窗口/洞口符号 + 角色剪影

**结构**:
- 主体：圆角矩形框（代表窗口），线宽 3px，色彩 `#8A9BA8`
- 内部：简化的角色剪影（圆形头部 + 简单身体轮廓），色彩 `#F4C2A8`（淡雅粉橙）
- 背景：完全透明

**风格**: 扁平几何，单色或双色，清晰可辨

### AI 生成提示词模板

```
A system tray icon for a desktop pet game, 64x64px, simplified window frame symbol (rounded rectangle outline 3px line width) in gray-blue (#8A9BA8) with a cute character silhouette inside (round head + simple body outline) in soft peach (#F4C2A8), flat geometric style, minimalist design, high contrast for small size visibility, transparent background PNG

Style: flat geometric, icon design, high legibility at 16x16px
Mood: friendly, recognizable, non-intrusive
Technical: must be clear when scaled down to 16×16px for Windows system tray
```

### Godot 导入设置

```gdscript
# 托盘图标通过 DisplayServer 设置，非 Godot 资产导入
# 在代码中使用：
DisplayServer.set_native_icon("res://assets/ui/icon_tray.png")
```

### 验收标准

- [ ] 缩放至 16×16px 时图标仍清晰可辨
- [ ] 在浅色和深色系统主题下均可见
- [ ] 与其他系统托盘图标风格协调，不突兀
- [ ] 文件大小 < 20KB

---

## 4. 启动淡入特效（Startup Fade-in Effect）

> **优先级**: P1 垂直切片（MVP 可跳过）

### 资产规格

| 属性 | 值 |
|------|-----|
| **文件名** | `vfx_startup_glow.png` |
| **尺寸** | 512×512 px |
| **格式** | PNG，32-bit RGBA |
| **透明度** | 中心高亮区域 80% 不透明，向外渐变至完全透明 |

### 视觉描述

**效果**: 模拟窗口另一侧世界"亮起"的光晕效果

**结构**:
- 中心：柔和的光晕，色彩 `#A8C5DD`（柔和天蓝）+ `#F4C2A8`（淡雅粉橙）混合
- 外围：径向渐变至透明
- 动画：通过 Godot Tween 控制 `modulate.a` 从 0 到 1（0.3s），资产本身为静态图

### AI 生成提示词模板

```
A soft glowing light effect for game window startup, 512x512px, radial gradient from center to transparent edges, warm color blend of sky blue (#A8C5DD) and soft peach (#F4C2A8), gentle luminous glow simulating a portal or window lighting up, watercolor-like soft edges, ethereal and welcoming mood, transparent background PNG

Style: watercolor glow, radial gradient, soft luminous effect
Mood: welcoming, magical, gentle awakening
Technical: center 80% opacity fading to 0% at edges, used with Godot Tween for fade-in animation
```

### Godot 使用方式

```gdscript
# 在窗口启动时播放
var glow = Sprite2D.new()
glow.texture = preload("res://assets/vfx/vfx_startup_glow.png")
glow.modulate.a = 0.0
add_child(glow)

var tween = create_tween()
tween.tween_property(glow, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
tween.tween_callback(glow.queue_free)
```

### 验收标准

- [ ] 光晕效果柔和，不刺眼
- [ ] 色彩与窗口边框和背景协调
- [ ] 淡入动画流畅（0.3s）
- [ ] 文件大小 < 150KB

---

## 技术要求总结

### 文件命名规范

所有 F1 资产遵循命名规范：`[category]_[name]_[variant].[ext]`

示例：
- `ui_window_border_normal.png`
- `ui_btn_close_hover.png`
- `icon_tray.png`
- `vfx_startup_glow.png`

### 色彩配置文件

所有资产使用以下色彩常量（与 `art-direction.md` 对齐）：

```gdscript
# 在 Godot 项目中定义色彩常量
const COLOR_WARM_BEIGE = Color("#F5F1E8")
const COLOR_SOFT_BLUE = Color("#A8C5DD")
const COLOR_SOFT_PEACH = Color("#F4C2A8")
const COLOR_NEUTRAL_GRAY_BLUE = Color("#8A9BA8")
const COLOR_ACTIVE_ORANGE = Color("#F4A460")
const COLOR_ERROR_RED = Color("#E57373")
const COLOR_DISABLED_GRAY = Color("#C8C8C8")
```

### 导出设置

所有资产在导出前必须：
1. 转换为 sRGB 色彩空间
2. 移除 EXIF 元数据
3. 优化 PNG 压缩（使用 pngquant 或 TinyPNG）
4. 验证透明通道无意外不透明像素

### 批量生成脚本（可选）

```python
# tools/generate_button_states.py
# 用于批量生成按钮四态变体（基于单一设计修改色彩）

import PIL.Image
import PIL.ImageDraw

def generate_button_states(base_design, output_prefix):
    # 读取基础设计
    # 应用色彩变换生成 hover/pressed/disabled 变体
    # 保存为独立文件
    pass
```

---

## 资产制作优先级

### Phase 1: MVP 必需（P0）

**目标**: 验证窗口系统基本功能

1. `ui_window_border_normal.png` — 窗口边框（normal 状态）
2. `ui_btn_close_normal.png` — 关闭按钮（4 态）
3. `ui_btn_settings_normal.png` — 设置按钮（4 态）
4. `icon_tray.png` — 系统托盘图标

**预估工作量**: 6-8 小时
**验收标准**: 窗口可正常显示、拖拽、关闭，托盘图标可见

### Phase 2: 垂直切片（P1）

**目标**: 完整视觉体验

5. `ui_window_border_focus.png` — 窗口边框（聚焦状态）
6. `ui_btn_minimize_normal.png` — 最小化按钮（4 态）
7. `vfx_startup_glow.png` — 启动淡入特效

**预估工作量**: 4-5 小时
**验收标准**: 窗口状态变化有视觉反馈，启动体验流畅

---

## 外包/协作指南

如需外包资产制作，提供以下信息包：

1. **本文档完整副本**（包含所有提示词和规格）
2. **色彩配置文件**（Photoshop .aco 或 Figma 色板）
3. **参考图**（从 `art-direction.md` 提取的风格参考）
4. **验收检查清单**（每个资产的验收标准）

**交付格式**:
- 源文件（PSD / AI / Figma）+ 导出 PNG
- 所有资产打包为 `.zip`，按类别分文件夹
- 附带资产清单 CSV（文件名、尺寸、用途）

---

## 已知问题与待定事项

### 待定

- [ ] 窗口边框的纸质纹理强度需实际测试后调整（当前暂定 30%）
- [ ] 托盘图标在 macOS 系统托盘的适配（macOS 托盘图标为单色模板图）
- [ ] 高 DPI 屏幕（2x / 3x）资产是否需要独立导出（Godot 4.6 支持自动缩放）

### 阻塞

- 无阻塞项（F1 资产独立于其他系统）

---

*本文档为 F1 桌面窗口系统的完整资产规格。所有资产制作需与 `design/art/art-direction.md` 保持一致。*
