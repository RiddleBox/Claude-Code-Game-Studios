# C1 — 角色动画系统（Character Animation System）

> **Status**: Approved
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-27
> **Implements Pillar**: 真实存在感（角色生命感的视觉表现层）

## Overview

C1 角色动画系统是游戏的视觉表现核心。它订阅 F2 角色状态机的 `state_changed` 信号，将抽象状态转译为具体的帧动画序列。系统管理两种核心构图模式：**洞口内模式**（角色在窗口内侧，玩家从外往里看，呈现上半身或局部）与**探出模式**（角色主动越过洞口边缘探向玩家侧），在不同状态下切换。C1 不包含任何游戏逻辑，只负责「此刻应该播放什么动画、以何种构图呈现、如何在帧之间过渡」。视觉风格暂定为插画质感 NPR 风格（清晰轮廓线+分层阴影，「会动的插画」感），待美术方向深化调研后确认。角色比例为 2-3 头身，画面始终在 320×320px 的透明悬浮窗内渲染。

## Player Fantasy

玩家从不觉得自己在「运行一个动画系统」——他们感知到的是：屏幕角落有个小东西，它在喘气，在发呆，在好奇地看着你。当你靠近时，它抬起头；当它兴奋时，它越过那扇窗口的边缘探向你这侧，好像距离真的缩短了。这种「活着的感觉」不来自精细的渲染，而来自动作的节奏——它会犹豫，会加速，会慢慢回落。玩家相信：那个小东西有自己的重量，有自己的情绪，不是在播放动画，而是在呼吸。

## Detailed Design

### Core Rules

#### 动画架构

1. C1 作为 Godot `Node` 挂载在角色场景下，使用 **`AnimationPlayer`** 播放帧动画，通过 **`AnimationTree`** 管理状态间的过渡混合
2. C1 订阅 F2 的 `state_changed(old_state, new_state)` 信号，收到信号后查表决定目标动画，不轮询状态
3. 帧动画资源以 **SpriteFrames** 格式组织，每个角色一个资源文件，按状态分组
4. 动画帧率：**默认 8 fps**（保持手绘帧动画感，降低 AI 生成成本）；关键情绪峰值帧可局部提升至 12 fps

#### 构图模式

5. C1 维护两种构图模式，通过角色节点的位置偏移实现切换：
   - **INSIDE**（洞口内）：角色 Y 轴偏移使下半身被窗口底边遮挡，呈现上半身+头部
   - **LEANING_OUT**（探出）：角色 Y 轴向上偏移，头部和上身越出窗口顶边，脚部/下身不可见

6. 构图模式切换规则：

| F2 状态 | 构图模式 | 说明 |
|---------|---------|------|
| Idle | INSIDE | 静静待在里面 |
| Attentive | INSIDE → 轻微前倾 | 抬头靠近窗口但不探出 |
| Interacting | LEANING_OUT | 主动探出迎接玩家 |
| Talking | LEANING_OUT | 对话时探出，拉近感 |
| Reacting(A) | INSIDE | 对内部事件反应，不探出 |
| Reacting(B) | INSIDE | 听到语音，专注内部 |
| Performing | 由演出数据决定 | 每个 performance 单独指定 |
| Away | 不显示 | 角色不在画面中 |
| Returning | LEANING_OUT | 归来时从洞口探入 |

7. 构图模式切换使用 **Tween 动画**（0.2s ease-in-out），不硬切

#### 各状态动画集

8. 每个状态对应以下动画（最小集）：

| F2 状态 | 必须动画 | 可选变体 |
|---------|---------|----------|
| Idle | `idle_loop`（循环） | `idle_blink`、`idle_look_around`、`idle_fidget_A/B/C`（随机小动作池） |
| Attentive | `attentive_loop`（循环） | — |
| Interacting | `interact_in`（进入）、`interact_loop`（循环） | — |
| Talking | `talk_loop`（循环，嘴动） | `talk_happy`、`talk_thinking`（可选情绪变体） |
| Reacting(A) | 由 `reaction_type` 决定，每种 reaction 一条动画 | — |
| Reacting(B) | `react_listening`（听语音） | — |
| Performing | 由 performance 数据包提供 | — |
| Away | 无（角色隐藏） | — |
| Returning | `return_in`（归来进场动画） | — |

9. Idle 小动作池（`idle_fidget_*`）至少提供 **3 个变体**，F2 触发 Reacting 时由 C1 随机选择一个播放

#### 动画过渡规则

10. 高优先级状态（Performing、Returning）打断低优先级时，使用 **0.1s 快速淡出** 当前动画
11. 正常状态切换使用 **0.15s 交叉淡入淡出**
12. Away 状态的进出使用 **0.3s 淡出/淡入**（角色消失/出现）

### States and Transitions

C1 内部维护两个独立的状态维度：

#### 动画播放状态

| 状态 | 描述 |
|------|------|
| **Playing**（播放中） | 正在播放某个动画序列（循环或单次） |
| **Transitioning**（过渡中） | 两个动画之间的交叉淡入淡出，持续 0.1–0.15s |
| **Hidden**（隐藏） | Away 状态，角色不可见，AnimationPlayer 暂停 |

#### 构图模式状态

| 状态 | 描述 |
|------|------|
| **INSIDE** | 角色在洞口内，下半身被遮挡 |
| **LEANING_OUT** | 角色探出洞口，头部越出窗口上边缘 |
| **MOVING**（过渡中） | 两种构图模式之间的 Tween 移动，持续 0.2s |

#### 状态转换图

```
F2 广播 state_changed
        │
        ▼
C1 查动画映射表
        │
   ┌────┴────┐
   │         │
构图变化？   无构图变化
   │         │
   ▼         ▼
启动 Tween  直接进入 Transitioning
(0.2s)          │
   │            ▼
   └──► Playing（目标动画）
```

**关键规则**：
- 构图 Tween 和动画 Transitioning **并行执行**，不互相等待
- Hidden → Playing 的过渡：先淡入角色（0.3s），淡入完成后开始播放 `return_in` 动画
- Playing → Hidden 的过渡：动画立即停止，角色 0.3s 淡出

### Interactions with Other Systems

| 交互系统 | 数据流向 | C1 提供什么 | C1 需要什么 |
|---------|---------|------------|------------|
| **F2 角色状态机** | F2 → C1 | — | `state_changed(old, new)` 信号，驱动动画切换 |
| **F1 桌面窗口系统** | F1 → C1 | — | `window_hidden` / `window_shown` 信号，Hidden 时暂停渲染 |
| **F4 存档系统** | 无交互 | — | — |
| **C2 外出-归来循环** | C2 → C1（间接，经由 F2） | — | C2 触发 F2 状态变更，C1 响应 F2 信号即可，无需直接监听 C2 |
| **Fe1 对话系统** | Fe1 → C1（可选直接） | — | `dialogue_emotion(emotion_type)` 信号（可选），用于切换 Talking 情绪变体动画 |
| **Fe5 声音系统** | C1 → Fe5 | `animation_event(event_name)` 信号 | — |
| **P1 主界面 UI** | 双向 | 角色节点位置/尺寸（供 UI 避让布局） | `window_resize` 信号（Post-MVP） |

**接口约定**：
- C1 暴露信号 `animation_event(event_name: String)`，用于在动画关键帧触发声音事件（如脚步落地、翅膀拍打），Fe5 订阅此信号播放对应音效
- C1 暴露方法 `get_character_bounds() -> Rect2`，供 P1 查询角色当前占用区域用于 UI 避让
- C1 不暴露 `play_animation()` 等公开方法——动画播放完全由 F2 状态信号驱动，外部系统不直接控制动画

## Formulas

C1 为纯表现系统，无游戏逻辑公式。以下为构图模式的位置计算规则：

#### 构图偏移计算

角色节点的垂直偏移（`position.y`）决定构图模式，基准为角色精灵的锚点在窗口中心：

```
INSIDE 模式目标 Y：
  target_y = WINDOW_HEIGHT / 2 + CHARACTER_HEIGHT * INSIDE_OFFSET_RATIO
  默认值：320/2 + character_height * 0.15
  效果：角色下移，头顶约在窗口上 1/3 处，下身被窗口底边遮挡

LEANING_OUT 模式目标 Y：
  target_y = WINDOW_HEIGHT / 2 - CHARACTER_HEIGHT * LEANING_OFFSET_RATIO
  默认值：320/2 - character_height * 0.20
  效果：角色上移，头部越出窗口顶边约 CHARACTER_HEIGHT * 0.20
```

**变量定义**：
| 变量 | 说明 | 默认值 |
|------|------|--------|
| `WINDOW_HEIGHT` | 窗口高度（px） | 320 |
| `CHARACTER_HEIGHT` | 角色精灵高度（px） | 待定（美术确认后填入） |
| `INSIDE_OFFSET_RATIO` | INSIDE 模式下移比例 | 0.15 |
| `LEANING_OFFSET_RATIO` | LEANING_OUT 模式上移比例 | 0.20 |

**示例**（假设 `CHARACTER_HEIGHT = 240px`）：
- INSIDE：`target_y = 160 + 240 * 0.15 = 196`（角色中心在 y=196，头顶约 y=76）
- LEANING_OUT：`target_y = 160 - 240 * 0.20 = 112`（头部约越出窗口顶边 48px）

## Edge Cases

**1. `state_changed` 信号携带的状态无对应动画映射**
- 条件：F2 发出新的状态值，C1 映射表中无对应动画
- 处理：保持当前动画继续播放，记录警告日志，不崩溃

**2. 动画资源文件缺失（SpriteFrames 未加载）**
- 条件：角色 SpriteFrames 资源加载失败
- 处理：显示占位色块（纯色矩形），广播 `animation_error("missing_resource")` 信号，游戏继续运行

**3. 构图 Tween 进行中收到新的状态变更**
- 条件：Tween 移动到 LEANING_OUT 途中，F2 又切回 Idle（应回到 INSIDE）
- 处理：立即取消当前 Tween，以当前位置为起点启动新 Tween 到目标位置，不跳变

**4. 窗口尺寸与设计尺寸不符（Post-MVP 缩放场景）**
- 条件：窗口不是 320×320px
- 处理：MVP 阶段窗口固定尺寸，此情况不发生；Post-MVP 阶段构图偏移公式使用实际 `WINDOW_HEIGHT` 重新计算

**5. Performing 状态的演出数据未指定构图模式**
- 条件：performance 数据包中缺少 `composition_mode` 字段
- 处理：默认使用 LEANING_OUT，记录警告日志

**6. F1 窗口 Hidden 时收到 `state_changed` 信号**
- 条件：窗口隐藏期间 F2 状态发生变化（如外出触发）
- 处理：正常更新内部状态和目标动画，但不渲染（AnimationPlayer 暂停）；窗口重新显示时从当前正确状态恢复

**7. Idle 小动作池耗尽（连续随机选到相同变体）**
- 条件：随机算法连续选出同一个 `idle_fidget` 变体
- 处理：使用「排除上次」的随机逻辑（从池中移除上次结果再随机），保证变体多样性

## Dependencies

**上游依赖（C1 依赖的系统）**

| 系统 | 状态 | 接口说明 |
|------|------|----------|
| **F1 桌面窗口系统** | ✅ 已设计 | 提供 `WINDOW_SIZE` 常量（320×320px）；C1 监听 `window_visibility_changed` 信号控制渲染暂停 |
| **F2 角色状态机** | ✅ 已设计 | 提供 `state_changed(old, new)` 信号，C1 订阅此信号驱动动画切换 |

**下游依赖（依赖 C1 的系统）**

| 系统 | 状态 | 接口说明 |
|------|------|----------|
| **Fe5 声音系统** | 🔴 未设计 | 订阅 C1 的 `animation_event(event_name)` 信号播放音效 |
| **P1 主界面 UI** | 🔴 未设计 | 调用 `get_character_bounds()` 查询角色区域用于 UI 避让 |

**外部依赖**

- **Godot 4.6.1 `AnimatedSprite2D`**：帧动画渲染
- **Godot 4.6.1 `AnimationPlayer`**：动画序列播放
- **Godot 4.6.1 `AnimationTree`**：状态过渡混合
- **Godot 4.6.1 `Tween`**：构图模式平滑切换

## Tuning Knobs

| 参数 | 当前值 | 安全范围 | 增大效果 | 减小效果 |
|------|--------|---------|---------|----------|
| `DEFAULT_FPS` | 8 fps | 6 到 12 fps | 动画更流畅，AI生成成本增加 | 更明显的「逐帧」手绘感，成本降低 |
| `PEAK_FPS` | 12 fps | 10 到 15 fps | 情绪峰值更生动 | 与默认帧率差异变小，峰值感减弱 |
| `TRANSITION_NORMAL` | 0.15s | 0.1s 到 0.3s | 状态切换更平滑 | 切换更快，更敏锐 |
| `TRANSITION_PRIORITY` | 0.1s | 0.05s 到 0.15s | 高优先级打断更快 | 打断响应变慢 |
| `FADE_AWAY` | 0.3s | 0.2s 到 0.5s | 消失/出现更柔和 | 切换更快 |
| `COMPOSITION_TWEEN` | 0.2s | 0.15s 到 0.4s | 构图切换更柔和 | 切换更快，更直接 |
| `INSIDE_OFFSET_RATIO` | 0.15 | 0.1 到 0.25 | 角色更靠下，洞口感更强 | 角色更靠上，可见更多身体 |
| `LEANING_OFFSET_RATIO` | 0.20 | 0.15 到 0.30 | 探出更多，亲近感更强 | 探出较少，保守感 |

**注**：所有参数均为开发者调优参数，不对玩家开放。`CHARACTER_HEIGHT` 需美术确认后填入构图公式。

## Visual/Audio Requirements

#### 视觉需求

**风格方向（暂定，待深化调研确认）**：
- 方向：**插画质感 NPR 风格**（Illustration-Quality NPR）
- 关键词：清晰轮廓线（线宽有变化）、2-3层饱和色分层阴影、体积感+2D表现语言
- 感觉目标：「会动的插画」，不是3D渲染，不是像素风
- 参考标杆：Pixar短片（Kitbull/Bao）概念艺术阶段质感、蜘蛛侠纵横宇宙 NPR 笔触语言、Hoppers 概念图中的角色性格张力

**角色规格**：
- 比例：2-3头身（超变形/Chibi）
- 精灵尺寸：待美术确认（预估 200–280px 高，`CHARACTER_HEIGHT` 填入公式后更新）
- 画面呈现：始终在 320×320px 透明悬浮窗内，不全身呈现

**动画视觉要求**：
- 帧率：8 fps 基础，关键帧可至 12 fps
- Idle 小动作需体现「呼吸感」——轻微的上下浮动、偶尔眨眼、随机小手势
- LEANING_OUT 探出动作需有「重量感」——加速进入，轻微弹性回落
- Away 状态淡出建议配合轻微缩小（scale 0.95）再淡出，强化「退入另一侧」感

**洞口/窗口视觉设计**：
- 洞口边框的视觉设计由 P1 主界面 UI 负责，C1 不渲染窗框
- C1 只负责角色在窗口内的位置和动画；窗框的阴影、光晕等由 P1 叠加

#### 音频需求

- C1 通过 `animation_event(event_name)` 信号触发音效，由 Fe5 声音系统响应
- 建议音效触发点：探出动作落定帧、Reacting 情绪峰值帧、Returning 进场落地帧
- 具体音效内容由 Fe5 设计，C1 只定义触发时机

## UI Requirements

C1 本身不渲染任何 UI 元素，但提供以下接口供 P1 主界面 UI 使用：

| 数据/接口 | 提供方 | 用途 |
|-----------|--------|------|
| `get_character_bounds() -> Rect2` | C1 | P1 查询角色当前占用区域，用于 UI 元素避让（如对话气泡位置计算） |
| `get_composition_mode() -> String` | C1 | P1 查询当前构图模式，用于调整窗框光效/阴影（INSIDE 时窗框内侧暗，LEANING_OUT 时角色侧亮） |
| `animation_event` 信号 | C1 | P1 可选订阅，用于 UI 特效同步（如探出时触发窗口边缘光晕脉冲） |

**协作说明**：
- 窗框/洞口边框的视觉设计、阴影、光晕由 P1 负责
- C1 只负责角色精灵；角色与窗框的遮挡关系由节点层级决定（角色在窗框节点之上或之下由 P1 控制）
- MVP 阶段角色始终在窗框之上（无真实遮挡）；Post-MVP 若实现窗框前景层，需协调层级

## Acceptance Criteria

- [ ] F2 发出 `state_changed(Idle, Attentive)` 后，C1 在 0.15s 内完成动画过渡，角色从 INSIDE 构图轻微前移
- [ ] F2 发出 `state_changed(Idle, Interacting)` 后，C1 在 0.2s 内完成构图 Tween 到 LEANING_OUT，角色探出窗口上边缘
- [ ] Idle 状态持续时，`idle_loop` 循环播放，每 `IDLE_FIDGET_INTERVAL` 随机穿插 `idle_fidget_*` 变体之一
- [ ] Away 状态进入时，角色 0.3s 淡出消失；Away 状态退出时，0.3s 淡入后播放 `return_in` 动画
- [ ] F1 窗口 Hidden 期间，C1 暂停渲染但不丢失状态；窗口重新显示时从正确状态恢复
- [ ] `animation_event` 信号在动画关键帧正确触发（如探出动作落定帧）
- [ ] `get_character_bounds()` 返回的 Rect2 准确反映角色当前精灵的屏幕占用区域
- [ ] 动画资源缺失时，显示占位色块，广播 `animation_error` 信号，游戏不崩溃
- [ ] 状态无对应动画映射时，保持当前动画，记录警告，不崩溃
- [ ] Performance：单帧动画切换完成时间 < 5ms（不含磁盘 I/O）

## Open Questions

| 问题 | 负责人 | 截止 | 解决方案 |
|------|--------|------|----------|
| 视觉风格最终确认：插画质感 NPR 风格是否可行？需要更多参考图和 AI 生成测试验证 | 美术方向 | 原型阶段 | 待定——需生成测试帧验证一致性和质感 |
| `CHARACTER_HEIGHT` 具体数值：待角色设计定稿后填入构图公式 | 美术方向 | 角色设计完成时 | 待定 |
| Idle 小动作池具体数量和类型：当前暂定 3 个变体，是否足够？是否需要按性格区分？ | 设计者 | C5 性格变量系统设计阶段 | 待定 |
| Reacting(A) 的 reaction_type 列表：由 C1 维护动画映射，还是由 C5 提供性格相关的反应类型？ | 设计者 | C5 设计阶段 | 待定 |
| Performing 演出动画的数据格式：是 SpriteFrames 资源引用，还是包含构图模式、音效触发点等的结构化数据？ | 开发者 | Fe1 对话系统设计阶段 | 待定 |
| 角色精灵的锚点位置：中心点、脚底，还是其他？影响构图公式计算 | 开发者 | 实现阶段 | 待定 |
