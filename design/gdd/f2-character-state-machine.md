# F2 — 角色状态机（Character State Machine）

> **Status**: Approved
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-26
> **Implements Pillar**: 真实存在感 / 陪伴不打扰

## Overview

F2 角色状态机是游戏中桌宠角色的行为核心。它定义并管理角色在任意时刻所处的状态（待机、互动、外出、归来等），驱动所有依赖状态的子系统——动画播放（C1）、外出循环（C2）、性格表达（C5）、声音（Fe5）。状态机本身不包含游戏逻辑的具体实现，只负责状态的维护、转换条件的判断、以及状态变更信号的广播。它是角色「有自己的生活」这一核心体验的技术基础。

## Player Fantasy

玩家不需要感知到「状态机」的存在——他们感知到的是角色的「生命感」。角色有时在发呆，有时突然抬头看向玩家，有时不见了（出门了），有时带着什么东西回来。这种自然的节奏感让玩家相信：屏幕角落的这个小东西有自己的意志和生活，不是在等待被操作，而是在真实地存在着。状态机是这种「活着的感觉」的幕后引擎。

## Detailed Design

### Core Rules

#### 状态机基础规则

1. 角色在任意时刻**有且只有一个**激活状态
2. 状态变更通过信号 `state_changed(old_state: CharacterState, new_state: CharacterState)` 广播给所有订阅系统
3. 状态机不直接控制动画、声音或对话内容——只广播状态，由对应系统响应
4. 所有状态转换必须经过状态机，**禁止外部系统直接修改状态**

#### 状态优先级（高优先级可打断低优先级）

```
Returning > Performing > Talking > Reacting > Interacting > Attentive > Idle
Away 状态不可被打断（外出期间拒绝所有非 C2 的状态变更请求）
```

#### 各状态规则

**Idle（待机）**
- 入口：其他状态自然结束后回落到 Idle
- 行为：播放循环待机动画，无逻辑处理
- 自动行为：在 Idle 持续超过 `IDLE_FIDGET_INTERVAL`（默认 45 秒）时，触发一次随机的 Reacting（小动作/情绪），然后回到 Idle

**Attentive（注意）**
- 入口：鼠标在窗口内悬停超过 `ATTENTIVE_HOVER_DELAY`（默认 1.5 秒）
- 退出：鼠标离开窗口，或超过 `ATTENTIVE_TIMEOUT`（默认 8 秒）无进一步互动
- 行为：播放注意动画，不阻塞其他事件

**Interacting（互动）**
- 入口：玩家左键点击角色区域
- 退出：交互菜单关闭 / 对话触发（转入 Talking）
- 行为：展示互动菜单或即时反馈动画

**Talking（对话中）**
- 入口：对话系统（Fe1）发起对话请求
- 退出：Fe1 发出 `dialogue_ended` 信号
- 行为：角色进入对话动画循环，等待 Fe1 驱动

**Reacting（反应）**
- 入口 A（事件反应）：游戏事件系统发送 `trigger_reaction(reaction_type)` 信号
- 入口 B（语音确认）：Aria 接口层发送 `voice_input_detected` 信号
- 退出 A：反应动画播完（时长由动画决定，通常 < 2 秒）自动回到 Idle
- 退出 B：Aria 接口层发送 `aria_response_ready` 信号，转入 Performing
- 行为：播放对应反应动画；语音确认的具体动画形式（侧耳倾听、记录、场景亮光等）由美术方向决定，状态机只负责进出控制

**Performing（演出）**
- 入口：系统发送 `trigger_performance(performance_id)` 信号（来源：Aria 完成任务 / 事件线节点）
- 退出：演出序列播放完毕，发出 `performance_ended` 信号，转入 Talking 或 Idle
- 行为：按剧本顺序执行演出序列（动画 + 对话 + 情绪），不可被低优先级事件打断

**Away（外出）**
- 入口：C2 外出-归来循环发出 `departure_triggered` 信号
- **延迟出发机制**：收到 `departure_triggered` 时检查当前状态：
  - 可立即出发（Idle / Attentive / Reacting(A)）：直接进入 Away，通知 C2 `departure_accepted`
  - 需延迟出发（Interacting / Talking / Reacting(B) / Performing / Returning）：通知 C2 `departure_declined`，由 C2 自行管理概率积累和下次重试时机
- 退出：C2 发出 `return_triggered` 信号，转入 Returning
- 行为：切换窗口到外出视觉状态；拒绝所有来自玩家互动的状态变更请求
- **泄漏事件 + Aria 响应（并行层）**：Away 期间，以下两种来源均通过 Fe2 叠加演出层处理，不改变状态机状态：
  - 外出遭遇事件（文字/特效）
  - Aria 语音指令响应（弱响应，文字/特效，与遭遇事件共享叠加演出机制）

**Returning（归来）**
- 入口：Away 状态收到 `return_triggered`
- 退出：归来演出序列播放完毕，转入 Talking 或 Idle
- 行为：播放归来动画序列，准备碎片对话内容

### States and Transitions

| 当前状态 | 触发条件 | 目标状态 | 说明 |
|---------|---------|---------|------|
| 任意（非Away） | C2 发出 `departure_triggered` | Away 或 departure_declined | 可立即出发状态→Away（回应 `departure_accepted`）；需延迟状态→回应 `departure_declined`，C2 管理重试 |
| 任意（非Away） | Fe1 发出对话请求 | Talking | 需 ≥ Talking 优先级 |
| 任意（非Away） | `trigger_performance(id)` | Performing | 需 ≥ Performing 优先级 |
| 任意（非Away） | `trigger_reaction(type)` | Reacting | 需 ≥ Reacting 优先级 |
| 任意（非Away） | `voice_input_detected` | Reacting(B) | 需 ≥ Reacting 优先级 |
| Idle | `pending_departure == true` | Away | 延迟出发触发 |
| Idle | 鼠标悬停 > `ATTENTIVE_HOVER_DELAY` | Attentive | 自动 |
| Idle | `IDLE_FIDGET_INTERVAL` 超时 | Reacting | 自动，随机 reaction_type |
| Idle | 玩家左键点击 | Interacting | 自动 |
| Attentive | 鼠标离开 / 超时 `ATTENTIVE_TIMEOUT` | Idle | 自动 |
| Attentive | 玩家左键点击 | Interacting | 自动 |
| Interacting | 菜单关闭 | Idle | 自动 |
| Interacting | Fe1 发起对话 | Talking | 自动 |
| Talking | `dialogue_ended` | Idle | 自动 |
| Reacting(A) | 反应动画播完 | Idle | 自动 |
| Reacting(B) | `aria_response_ready` | Performing | Aria 正常响应 |
| Reacting(B) | 超时 `ARIA_RESPONSE_TIMEOUT`（默认 30s） | Reacting(reaction_type=ARIA_TIMEOUT) → Idle | 播放失败动画后回 Idle |
| Performing | `performance_ended` | Talking | 有碎片内容时 |
| Performing | `performance_ended` | Idle | 无碎片内容时 |
| Away | `return_triggered` | Returning | C2 专属，强制 |
| Returning | 归来演出完毕 | Talking | 有碎片内容时 |
| Returning | 归来演出完毕 | Idle | 无碎片内容时 |

**特殊规则**：
- Away 状态期间，所有来自玩家互动的转换请求（Attentive/Interacting/Reacting）被静默丢弃
- Returning 和 Performing 状态期间，低优先级请求（Attentive/Interacting）被静默丢弃
- `ARIA_TIMEOUT` reaction_type 的失败动画形式（困惑/无奈/耸肩等）由美术方向决定

### Interactions with Other Systems

| 交互系统 | 数据流向 | F2 提供什么 | F2 需要什么 |
|---------|---------|------------|------------|
| **F1 桌面窗口系统** | F1 → F2 | — | 监听 `window_visibility_changed`；Hidden 时游戏逻辑继续，不暂停状态机 |
| **C1 角色动画系统** | F2 → C1 | `state_changed(old, new)` 信号 | — |
| **C2 外出-归来循环** | C2 ↔ F2 | 接收 `departure_triggered` / `return_triggered`；提供当前状态供 C2 判断是否可以出发 | `departure_triggered`、`return_triggered` 信号 |
| **C5 性格变量系统** | C5 → F2 | — | 读取性格特质以调制 reaction_type 的选择（例如开朗性格偏向正向反应） |
| **Fe1 对话系统** | Fe1 ↔ F2 | 接收对话请求，转入 Talking；广播 `state_changed` | `dialogue_ended` 信号 |
| **Fe2 泄漏内容系统** | F2 → Fe2 | 广播 Away 状态进入信号，允许 Fe2 叠加演出 | — |
| **Fe5 声音系统** | F2 → Fe5 | `state_changed` 信号（Fe5 依据状态播放对应音效） | — |
| **F5 Aria 接口层** | F5 ↔ F2 | 接收 `voice_input_detected` / `aria_response_ready` / 超时信号 | Aria 接口层的语音事件信号 |

**接口约定**：
- F2 暴露方法 `request_state_change(new_state, requester)` — 统一入口，内部做优先级检查
- F2 暴露只读属性 `current_state: CharacterState`
- F2 暴露信号 `state_changed(old_state: CharacterState, new_state: CharacterState)`
- F2 暴露方法 `is_available_for(state: CharacterState) -> bool` — 供外部系统查询是否可接受该状态请求

## Formulas

本系统为状态管理系统，无数学公式。

## Edge Cases

**1. 同优先级状态的并发请求**
- 条件：两个系统同时发送相同优先级的状态变更请求
- 处理：先到先得，后到的请求被静默丢弃
- 不报错，不排队

**2. Away 期间收到外出请求**
- 条件：C2 在角色已处于 Away 状态时再次发送 `departure_triggered`
- 处理：静默忽略，状态机保持 Away

**3. 状态机初始化前收到信号**
- 条件：其他系统在 F2 完成初始化前发送状态变更请求
- 处理：请求被丢弃，F2 初始化完成后默认进入 Idle

**4. Reacting(B) 期间 Aria 连接断开**
- 条件：语音确认状态下 Aria 进程崩溃或断连（非正常超时）
- 处理：等同超时处理——触发 `ARIA_TIMEOUT` reaction，播放失败动画后回 Idle

**5. Performing 演出序列数据缺失**
- 条件：`trigger_performance(id)` 中的 `performance_id` 在数据库中不存在
- 处理：记录错误日志，直接转入 Idle，不播放任何动画，不崩溃

**6. Returning 演出期间收到新的 departure_triggered**
- 条件：C2 在角色归来演出未完成时触发新的外出（极端情况）
- 处理：等待 Returning 演出完毕后再处理外出请求（Returning 不可被打断）

**7. 窗口 Hidden 期间的状态变更**
- 条件：F1 发出 `window_visibility_changed(false)`，此时有状态变更请求进来
- 处理：状态机继续正常运作，Hidden 不暂停状态机；C1 动画系统负责在 Hidden 时不渲染

## Dependencies

**上游依赖（F2 依赖的系统）**
- **F1 桌面窗口系统**（已设计 ✅）：F2 监听 `window_visibility_changed` 信号；F1 的窗口生命周期决定 F2 的初始化时机

**下游依赖（依赖 F2 的系统）**
- **C1 角色动画系统**（未设计）：依赖 `state_changed` 信号驱动动画播放
- **C2 外出-归来循环**（未设计）：依赖 `is_available_for(Away)` 判断出发条件；通过 `departure_triggered` / `return_triggered` 控制状态转换
- **C5 性格变量系统**（未设计）：F2 读取 C5 的性格特质来调制 reaction_type 选择
- **Fe1 对话系统**（未设计）：通过 `request_state_change(Talking)` 请求进入对话状态
- **Fe2 泄漏内容系统**（未设计）：订阅 Away 状态信号以激活叠加演出
- **Fe5 声音系统**（未设计）：订阅 `state_changed` 信号播放对应音效
- **F5 Aria 接口层**（未设计）：发送语音事件信号（`voice_input_detected` / `aria_response_ready`）给 F2

**外部依赖**
- 无（纯 GDScript 状态机，无外部库依赖）

## Tuning Knobs

| 参数 | 当前值 | 安全范围 | 增大效果 | 减小效果 |
|------|--------|---------|---------|----------|
| `IDLE_FIDGET_INTERVAL` | 45 秒 | 20s 到 120s | 角色更安静，更少自发动作 | 角色更活跃，自发动作更频繁 |
| `ATTENTIVE_HOVER_DELAY` | 1.5 秒 | 0.5s 到 3s | 需要更长悬停才触发注意 | 鼠标一靠近就注意到玩家 |
| `ATTENTIVE_TIMEOUT` | 8 秒 | 4s 到 20s | 角色保持注意状态更久 | 注意状态更快结束回到 Idle |
| `ARIA_RESPONSE_TIMEOUT` | 30 秒 | 10s 到 60s | 等待 Aria 更久才判定超时 | 更快判定超时，播放失败动画 |

## Visual/Audio Requirements

本系统为纯状态管理系统，自身不产生任何视觉或音频输出——所有视觉/音频响应均由订阅 `state_changed` 信号的下游系统负责。

| 状态变更 | 视觉响应负责方 | 音频响应负责方 |
|---------|--------------|---------------|
| → Idle | C1 角色动画系统 | Fe5 声音系统 |
| → Attentive | C1 角色动画系统 | Fe5 声音系统 |
| → Interacting | C1 + P1 主界面UI | Fe5 声音系统 |
| → Talking | C1 + Fe1 对话系统 | Fe5 声音系统 |
| → Reacting | C1 角色动画系统 | Fe5 声音系统 |
| → Performing | C1 + Fe1 对话系统 | Fe5 声音系统 |
| → Away | C1 + P1 主界面UI | Fe5 声音系统 |
| → Returning | C1 角色动画系统 | Fe5 声音系统 |

**设计说明**：F2 只广播信号，不直接调用任何视觉/音频 API。这保证了状态机与表现层的完全解耦。

## UI Requirements

本系统为纯逻辑系统，不直接渲染任何 UI 元素。但状态机的当前状态需要在以下场景中被 UI 系统查询：

| 查询场景 | 查询方 | 查询接口 | 用途 |
|---------|--------|---------|------|
| 是否显示互动菜单 | P1 主界面 UI | `current_state` | 只在 Interacting 状态显示菜单 |
| 是否显示对话气泡 | P1 主界面 UI | `current_state` | 只在 Talking 状态显示气泡 |
| Away 状态视觉切换 | P1 主界面 UI | `state_changed` 信号 | 切换到外出视觉状态 |
| 设置界面状态显示 | P3 设置 UI | `current_state` | 调试用，显示当前状态（可选） |

**设计说明**：UI 系统订阅 `state_changed` 信号或主动查询 `current_state`，F2 不主动通知 UI。

## Acceptance Criteria

- [ ] 游戏启动后角色自动进入 Idle 状态
- [ ] 鼠标悬停窗口 1.5 秒后角色进入 Attentive 状态，离开后回到 Idle
- [ ] 左键点击角色区域触发 Interacting 状态
- [ ] Away 状态期间，左键点击和鼠标悬停均无法触发状态变更
- [ ] C2 发出 `departure_triggered` 时，若当前为 Idle/Attentive/Reacting(A)，立即进入 Away
- [ ] C2 发出 `departure_triggered` 时，若当前为 Interacting/Talking/Reacting(B)/Performing/Returning，设置 `pending_departure=true`，当前状态结束回 Idle 后自动进入 Away
- [ ] Reacting(B) 状态下，30 秒内无 Aria 响应时播放失败动画并回到 Idle
- [ ] Reacting(B) 状态下，收到 `aria_response_ready` 时正确转入 Performing
- [ ] Idle 状态持续 45 秒后自动触发一次随机 Reacting
- [ ] 所有状态转换均广播 `state_changed(old, new)` 信号
- [ ] `is_available_for(state)` 在 Away 状态下对所有非 C2 请求返回 false
- [ ] Performing 和 Returning 状态期间，低优先级请求被正确丢弃
- [ ] 演出数据缺失时状态机不崩溃，直接回到 Idle 并记录日志
- [ ] 窗口 Hidden 期间状态机继续正常运作，时间计数不暂停
- [ ] 玩家正在交互（Interacting/Talking/Reacting(B)/Performing）时不会被强制中断进入 Away

## Open Questions

| 问题 | 负责人 | 截止 | 解决方案 |
|------|--------|------|----------|
| Reacting(A) 的 reaction_type 列表由谁维护？是枚举还是数据驱动？ | 开发者 | C5 设计阶段 | 待定 |
| `IDLE_FIDGET_INTERVAL` 是固定时长还是随机范围（如 30-60 秒）？ | 设计者 | 原型阶段 | 待定 |
| Away 状态下 Aria 叠加演出与 Fe2 泄漏演出是否共享同一个演出队列？并发时如何排序？ | 开发者 | Fe2 设计阶段 | 待定 |
| `departure_declined` 后 C2 的概率积累上限是多少？是否有最大强制出发时间？ | 设计者 | C2 设计阶段 | 待定 |
