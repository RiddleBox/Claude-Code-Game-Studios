# Art Direction: 窗语（Window Whisper）

*Created: 2026-04-19*
*Status: Active*

---

## Visual Identity

**核心理念**：温暖、治愈、非侵入性的桌面陪伴体验。视觉风格需要在「存在感」与「不打扰」之间找到平衡——足够吸引人偶尔瞥一眼，但不会抢夺工作注意力。

**风格关键词**：水彩晕染、柔和边缘、纸质温暖、几何简化、半透明层次

---

## Style Breakdown by Layer

### 背景层（Background）
**风格**：水彩晕染风格（Watercolor Wash）

**视觉特征**：
- 柔和的色彩过渡，边缘自然晕开
- 纸质纹理底层，营造手绘温暖感
- 低饱和度，避免视觉疲劳
- 景深模糊，强化「窗口」的空间感

**技术实现（Godot）**：
- 使用 Sprite2D + CanvasItemMaterial 的 blend_mode 实现晕染叠加
- 背景分层：远景（模糊）+ 中景（半透明）+ 近景装饰
- Shader 实现纸质纹理叠加（noise texture + multiply blend）
- 色彩调整通过 ColorRect + CanvasModulate 全局控制

**资产规格**：
- 分辨率：1024x1024（窗口最大尺寸），PNG 格式
- 色彩空间：sRGB
- 透明度：支持 Alpha 通道
- 命名规范：`bg_[location]_[layer]_[variant].png`
  - 示例：`bg_room_far_01.png`, `bg_garden_mid_spring.png`

---

### 角色层（Character）
**风格**：简化几何风格 + 柔化边缘 + 纸质纹理（Simplified Geometric with Soft Edges）

**视觉特征**：
- 基础形状由简单几何构成（圆形、椭圆、圆角矩形）
- 边缘柔化处理，避免生硬的矢量感
- 叠加纸质纹理，与背景风格统一
- 色块分明但过渡柔和
- 表情简化但富有表现力（大眼睛、简单嘴型）

**技术实现（Godot）**：
- AnimatedSprite2D 实现帧动画
- Shader 实现边缘柔化（distance field + smoothstep）
- 纸质纹理通过 CanvasItemMaterial 叠加
- 表情系统：独立 Sprite2D 节点控制眼睛/嘴巴，支持动态组合

**资产规格**：
- 分辨率：512x512（单帧），PNG 格式
- 帧率：8-12 FPS（idle 动画），24 FPS（快速动作）
- 透明度：完全支持 Alpha
- 命名规范：`char_[name]_[action]_[frame].png`
  - 示例：`char_mochi_idle_01.png`, `char_mochi_wave_03.png`
- 表情资产：`char_[name]_face_[expression].png`
  - 示例：`char_mochi_face_happy.png`, `char_mochi_face_curious.png`

**动画状态清单**（优先级排序）：
1. **P0 MVP**：idle（待机）, blink（眨眼）, wave（挥手）
2. **P1 垂直切片**：walk（行走）, sit（坐下）, sleep（睡觉）
3. **P2 Alpha**：excited（兴奋）, sad（难过）, thinking（思考）

---

### UI层（User Interface）
**风格**：扁平几何 + 半透明（Flat Geometric with Transparency）

**视觉特征**：
- 纯色几何形状，圆角矩形为主
- 半透明背景（60-80% opacity），保持桌面可见性
- 清晰的视觉层次（阴影、描边、高光）
- 高对比度文字，确保可读性
- 最小化装饰，功能优先

**技术实现（Godot）**：
- Control 节点 + StyleBoxFlat 实现圆角和半透明
- 文字使用 Label + 自定义字体，启用阴影增强可读性
- 按钮状态：normal / hover / pressed / disabled（颜色 + 缩放反馈）
- 通知系统：AnimationPlayer 实现淡入淡出 + 滑动

**资产规格**：
- UI 元素：矢量风格，使用 StyleBoxFlat 而非图片（减少资产量）
- 图标：64x64 或 128x128，PNG 格式，单色或双色
- 字体：支持中英文，建议使用 Noto Sans CJK 或思源黑体
- 命名规范：`ui_[component]_[state]_[variant].png`
  - 示例：`ui_btn_primary_normal.png`, `ui_icon_settings_64.png`

**UI 组件清单**（优先级排序）：
1. **P0 MVP**：主窗口边框、关闭按钮、设置按钮
2. **P1 垂直切片**：对话气泡、通知弹窗、日志面板
3. **P2 Alpha**：设置面板、关系值显示、碎片收藏界面

---

## Color Palette

### 主色调（Primary Palette）
**用途**：背景、角色主体色、UI 主要元素

| 色彩名称 | Hex Code | 用途 | 情感关联 |
|---------|----------|------|---------|
| 温暖米白 | `#F5F1E8` | 背景基底、窗口边框 | 纸质、温暖、安全 |
| 柔和天蓝 | `#A8C5DD` | 背景天空、水面 | 平静、开阔、希望 |
| 淡雅粉橙 | `#F4C2A8` | 角色主体色（暖色系角色） | 治愈、亲近、柔软 |
| 清新草绿 | `#B8D4A8` | 植物、自然元素 | 生机、成长、自然 |
| 中性灰蓝 | `#8A9BA8` | UI 次要元素、阴影 | 稳定、不抢眼 |

### 强调色（Accent Palette）
**用途**：交互反馈、重要信息、情绪表达

| 色彩名称 | Hex Code | 用途 | 情感关联 |
|---------|----------|------|---------|
| 活力橙黄 | `#F4A460` | 按钮 hover、新内容提示 | 好奇、活力、吸引注意 |
| 深邃蓝紫 | `#6B7FA8` | 夜晚场景、神秘元素 | 深度、神秘、安静 |
| 温柔粉红 | `#E8B4C8` | 正向情绪、亲密时刻 | 温柔、关怀、亲密 |

### 功能色（Functional Palette）
**用途**：系统反馈、状态指示

| 色彩名称 | Hex Code | 用途 |
|---------|----------|------|
| 成功绿 | `#88C070` | 操作成功、正向反馈 |
| 警告黄 | `#F4D03F` | 需要注意的信息 |
| 错误红 | `#E57373` | 错误提示（极少使用，避免破坏治愈感） |
| 禁用灰 | `#C8C8C8` | 不可用状态 |

### 色彩使用原则
1. **60-30-10 法则**：主色调 60%，强调色 30%，功能色 10%
2. **低饱和度优先**：避免高饱和度色彩造成视觉疲劳
3. **情绪色彩映射**：
   - 快乐/兴奋 → 暖色调（粉橙、橙黄）
   - 平静/思考 → 冷色调（天蓝、灰蓝）
   - 神秘/夜晚 → 深色调（蓝紫、深灰）
4. **可访问性**：文字与背景对比度 ≥ 4.5:1（WCAG AA 标准）

---

## Lighting & Atmosphere

### 光照方向
**统一光源**：左上方 45° 入射（模拟自然光）

**实现方式**：
- 角色高光位于左上侧
- 阴影投射至右下方
- 背景元素遵循相同光照逻辑

### 时间段氛围

| 时间段 | 色温 | 饱和度 | 特殊效果 |
|--------|------|--------|---------|
| 清晨（6-9点） | 暖黄 | 中等 | 柔和光晕 |
| 白天（9-17点） | 中性偏冷 | 高 | 清晰明亮 |
| 黄昏（17-19点） | 暖橙 | 高 | 长阴影、逆光 |
| 夜晚（19-6点） | 冷蓝 | 低 | 月光、星光点缀 |

**技术实现**：
- 使用 CanvasModulate 全局调整色温
- 时间段切换通过 Tween 平滑过渡（30秒）
- 特殊天气（雨天、雪天）叠加额外 ColorRect

---

## Visual Hierarchy

**基于**：`design/core/connection-relationship.md` 的"慢变化优先于快动作"原则

### 注意力优先级（从高到低）

**核心理念**：边缘存在感来自低频动态，而非高频动画

1. **慢变化**（最高优先级，低对比度）
   - 光线变化、翻书、蒸汽、写字、调药、风吹窗帘
   - 实现：缓慢Tween（2-4秒/循环），低饱和度
   - 玩家会在余光里感知它
   
2. **角色状态变化**（中优先级）
   - 表情、姿态调整、朝窗边看、在窗边停留
   - 实现：柔和过渡，不用弹跳
   - 不是"看镜头"，而是"朝那个方向看"（不确定感）
   
3. **偶发事件**（低频高对比）
   - 归来、带回碎片
   - 实现：短暂高亮，快速回归平静
   
4. **背景装饰**（最低优先级）
   - 环境细节、氛围元素
   - 实现：低对比度、静态或极慢动画

### 视觉引导原则

- **慢变化吸引余光** — 重要信息用慢动画，次要信息保持静态
- **对比度控制** — 角色 > UI > 背景（对比度递减）
- **尺寸层次** — 重要元素占据更大视觉空间
- **色彩聚焦** — 强调色仅用于需要注意的元素

**不要**：
- 高频动画（会变成"通知"而非陪伴）
- 强高光、高饱和、UI发光
- 大幅度动作作为常态

**核心**：像桌上盆栽、窗外天气、壁炉火焰那样的存在方式

---

## Asset Specifications by Module

### F1 窗口系统（Window System）
**所需资产**：
- 窗口边框（圆角矩形，半透明）
  - `ui_window_border_normal.png` (512x512, 9-slice)
  - `ui_window_border_focus.png` (高亮状态)
- 窗口控制按钮
  - `ui_btn_close_[state].png` (32x32, 4 states)
  - `ui_btn_settings_[state].png` (32x32, 4 states)
  - `ui_btn_minimize_[state].png` (32x32, 4 states)
- 拖拽手柄（可选）
  - `ui_handle_drag.png` (64x16)

**技术要求**：
- 边框使用 NinePatchRect 实现自适应缩放
- 按钮支持 normal / hover / pressed / disabled 四态
- 透明度：边框 70%，按钮 90%

---

### C1 角色动画系统（Character Animation）
**所需资产**（以首个角色 "Mochi" 为例）：
- Idle 动画（4 帧，循环）
  - `char_mochi_idle_01.png` ~ `char_mochi_idle_04.png`
- Blink 动画（3 帧，触发式）
  - `char_mochi_blink_01.png` ~ `char_mochi_blink_03.png`
- Wave 动画（6 帧，触发式）
  - `char_mochi_wave_01.png` ~ `char_mochi_wave_06.png`
- 表情资产（独立图层）
  - `char_mochi_face_neutral.png`
  - `char_mochi_face_happy.png`
  - `char_mochi_face_curious.png`

**技术要求**：
- 所有帧尺寸一致（512x512）
- 角色主体居中，留出 10% 边距
- 透明背景，抗锯齿边缘
- 表情资产与主体分离，支持动态组合

---

### P1 主界面 UI（Main UI）
**所需资产**：
- 对话气泡
  - `ui_bubble_dialogue.png` (256x128, 9-slice)
  - `ui_bubble_tail.png` (32x32, 指向角色)
- 通知弹窗
  - `ui_notification_bg.png` (320x80, 9-slice)
  - `ui_icon_notification.png` (48x48)
- 状态指示器（可选）
  - `ui_indicator_out.png` (外出状态)
  - `ui_indicator_busy.png` (忙碌状态)

**技术要求**：
- 气泡使用 NinePatchRect，支持文字自适应
- 通知弹窗半透明（80%），带轻微阴影
- 图标单色或双色，清晰可辨

---

## Material Language

### 纹理库（Texture Library）
**基础纹理**（所有资产共用）：
- `tex_paper_grain.png` (512x512, tileable) — 纸质颗粒纹理
- `tex_watercolor_edge.png` (256x256) — 水彩边缘遮罩
- `tex_noise_soft.png` (256x256) — 柔和噪声（用于晕染）

**Shader 参数**：
```gdscript
# 纸质纹理叠加 Shader
shader_type canvas_item;

uniform sampler2D paper_texture;
uniform float paper_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    vec4 paper = texture(paper_texture, UV * 2.0);
    COLOR = mix(base_color, base_color * paper, paper_strength);
}
```

### 边缘处理
**柔化边缘 Shader**（用于角色）：
```gdscript
shader_type canvas_item;

uniform float edge_softness : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float alpha = color.a;
    alpha = smoothstep(0.0, edge_softness, alpha);
    COLOR = vec4(color.rgb, alpha);
}
```

---

## Animation Principles

### 运动曲线（Easing）
- **Idle 动画**：ease_in_out（柔和呼吸感）
- **快速动作**：ease_out（有冲击力但不生硬）
- **UI 过渡**：ease_out_back（轻微回弹，增加趣味性）

### 时间节奏
- **Idle 循环**：2-4 秒/循环（避免过于频繁）
- **Blink**：0.2 秒（快速自然）
- **UI 淡入淡出**：0.3 秒（流畅但不拖沓）
- **通知停留**：3-5 秒（足够阅读但不打扰）

### 次级动作（Secondary Motion）
- 角色移动时，身体部件有轻微延迟（follow-through）
- UI 弹出时，背景轻微模糊（景深效果）
- 对话气泡出现时，角色有微小反应动作

---

## Accessibility Considerations

### 色盲友好
- 不依赖颜色单独传达信息（配合图标/文字）
- 红绿色盲测试：功能色使用形状 + 颜色双重编码
- 提供高对比度模式（设置选项）

### 可读性
- 最小字体：14px（1080p 分辨率下）
- 文字阴影/描边：确保在任何背景下可读
- 对话气泡背景：不透明度 ≥ 90%

### 动画敏感性
- 提供「减少动画」选项（设置中）
- 关键信息不依赖动画传达
- 避免快速闪烁（癫痫风险）

---

## Technical Implementation Roadmap

### Phase 1: MVP 资产（P0）
**目标**：验证视觉风格可行性

**资产清单**：
- [ ] 1 个背景场景（角色房间，3 层）
- [ ] 1 个角色（Mochi，3 个基础动画）
- [ ] 窗口 UI（边框 + 3 个按钮）
- [ ] 基础纹理库（纸质、噪声）
- [ ] 2 个 Shader（纸质叠加、边缘柔化）

**验收标准**：
- 窗口在桌面上视觉和谐，不突兀
- 角色动画流畅，符合「治愈」基调
- 色彩搭配通过用户测试（5 人以上反馈）

---

### Phase 2: 垂直切片资产（P1）
**目标**：完整体验一个叙事循环

**资产清单**：
- [ ] 2 个额外背景场景（花园、夜晚房间）
- [ ] 角色完整动画集（6 个动作）
- [ ] 对话气泡 + 通知系统 UI
- [ ] 3 个表情变体
- [ ] 时间段光照系统（4 个时段）

**验收标准**：
- 完整演示「外出-归来-对话」循环
- 不同时间段氛围明显区分
- UI 不干扰工作，但信息清晰可见

---

### Phase 3: Alpha 资产（P2）
**目标**：支持完整游戏系统

**资产清单**：
- [ ] 4+ 背景场景（覆盖主要事件线场景）
- [ ] 2 个额外角色（不同性格/外观）
- [ ] 完整 UI 套件（设置、日志、关系值）
- [ ] 特殊天气效果（雨、雪）
- [ ] 碎片收藏界面资产

**验收标准**：
- 视觉风格一致性检查通过
- 所有 UI 通过可访问性测试
- 性能达标（60fps，低端设备）

---

## Style Guide Enforcement Checklist

每个新资产提交前必须通过以下检查：

### 通用检查
- [ ] 文件命名符合规范（`[category]_[name]_[variant]_[size].[ext]`）
- [ ] 分辨率符合规格
- [ ] 文件格式正确（PNG with Alpha）
- [ ] 色彩空间为 sRGB
- [ ] 文件大小优化（< 500KB per asset）

### 风格一致性
- [ ] 色彩在调色板范围内（±10% 容差）
- [ ] 边缘处理符合层级要求（背景晕染、角色柔化、UI 清晰）
- [ ] 光照方向一致（左上 45°）
- [ ] 纸质纹理强度适中（不过度）

### 技术验证
- [ ] 在 Godot 中导入无错误
- [ ] 透明度正确显示
- [ ] 动画帧对齐（如适用）
- [ ] 性能测试通过（draw call / memory）

---

## Next Steps

### 立即行动（本周）
1. **创建资产规格清单**：
   - 为 F1 窗口系统创建详细资产清单（`design/art/specs/f1-window-assets.md`）
   - 为 C1 角色动画创建详细资产清单（`design/art/specs/c1-character-assets.md`）
   - 为 P1 主界面 UI 创建详细资产清单（`design/art/specs/p1-ui-assets.md`）

2. **建立基础纹理库**：
   - 寻找或生成纸质纹理（tileable）
   - 创建水彩边缘遮罩
   - 准备柔和噪声纹理

3. **Shader 原型**：
   - 实现纸质纹理叠加 Shader
   - 实现边缘柔化 Shader
   - 测试性能影响

### 短期目标（2 周内）
1. **首个角色资产**：
   - 设计 Mochi 角色外观（草图 → 精稿）
   - 制作 3 个基础动画（idle, blink, wave）
   - 在 Godot 中测试动画流畅度

2. **窗口 UI 原型**：
   - 设计窗口边框样式
   - 制作控制按钮（4 态）
   - 测试半透明效果在不同桌面背景下的表现

3. **色彩验证**：
   - 制作色彩样本板
   - 用户测试（5-10 人）
   - 根据反馈微调调色板

### 中期目标（1 个月内）
1. 完成 MVP 资产包（Phase 1）
2. 建立资产审核流程
3. 撰写资产制作指南（供外包或协作者使用）

---

## References & Inspiration

### 视觉参考
- **水彩风格**：Gris, Child of Light
- **几何简化角色**：Monument Valley, Alto's Adventure
- **桌面集成**：Desktop Goose, Shimeji
- **治愈氛围**：A Short Hike, Unpacking

### 技术参考
- Godot Shader 文档：https://docs.godotengine.org/en/stable/tutorials/shaders/
- 2D 光照系统：https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html
- CanvasItem 材质：https://docs.godotengine.org/en/stable/classes/class_canvasitemmaterial.html

---

---

## 最终视觉公式（已收敛）

**基于**：`design/art/visual-generation-spec.md` 和 `design/core/connection-relationship.md`

```
minimalist editorial illustration
+ architectural sketch
+ miniature diorama
+ voyeuristic framing
+ slice-of-life staging
+ fragmented composition
+ negative space
+ restrained palette
+ soft temporal atmosphere
```

### 关键特征

**空间与构图参考**：
- 建筑速写、微缩舞台、剧场剖面、绘本切片

**情绪与时间感参考**：
- 深夜窗户、雨天窗景、小津安二郎、吉卜力生活段落、深夜电台

**观看关系参考**：
- 偷看别人窗户、阁楼裂缝、博物馆箱庭、旧电视广播

### 场景密度标准

**玩家一眼应该看到**：
1. **一级信息**：角色正在做什么
2. **二级信息**：空间情绪（夜晚、下雨、温暖、孤独）
3. **三级信息**：远处世界碎片

**除此之外都应该弱化**

### 核心约束

- **被截取的生活镜头** — 不是完整展示
- **玩家视角有位置** — 不是神视角
- **角色不是表演** — 她在忙自己的事
- **环境叙事优先** — 主角是她的生活，不是她的脸

**详细规范参见**：`design/art/visual-generation-spec.md`

---

*本文档为活文档，随项目进展持续更新。所有视觉决策需与游戏设计支柱对齐，确保「陪伴不打扰」的核心体验。*
