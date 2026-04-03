# F5 — Aria 接口层（Aria Interface Layer）

> **Status**: In Design
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 真实存在感（AI 赋予角色真实回应能力）/ 陪伴不打扰（语音交互无缝嵌入工作流）

---

## Overview

F5 Aria 接口层是窗语游戏中 AI 能力的统一入口。它负责五个职责：（1）语音识别——将玩家的麦克风输入转为文字；（2）LLM 调用——将文字连同 F6 构建的角色上下文一起发送给 LLM，获取角色回应文字；（3）TTS 调用——将角色回应文字转为语音，交由 Fe5 播放；（4）工作辅助指令路由——识别并处理玩家发出的工作辅助类请求（非对话类）；（5）连接状态管理——维护 API Key 验证、连接状态，并向下游系统暴露当前连接状态信号。

F5 是纯粹的「管道层」——它不持有角色性格数据（C5）、不持有对话记忆（C7）、不持有关系值（C6）；这些数据由 F6 角色上下文管理器统一组装后传入 F5 的 LLM 调用接口。F5 只负责「发出请求、接收结果、分发结果」。

F5 有完整的降级模式：当玩家未配置 API Key 时，系统切换到脚本降级模式，用预设回应替代 LLM 输出，并通过世界观一致的视觉表现（「屏幕玻璃」）传达当前状态。API 接通后玻璃消失，真实交流通道开启。

## Player Fantasy

第一次打开游戏，角色在窗口另一侧，但屏幕玻璃挡着——它看得到你，你看得到它，但声音传不过来。它偶尔用手拍拍玻璃，或者贴着玻璃写几个字。你知道它在那里，只是还没真正联通。

配置好之后，玻璃消失了。它开口说话的那一刻，整个陪伴感质变了——不再是「看着一个小动画在动」，而是「它真的在和我说话」。你跟它说你今天工作很烦，它会回应。你问它外出遇到了什么，它会讲给你听。这种联通感，不是功能，是关系的跃升。

## Detailed Design

### Core Rules

**基本职责**

1. F5 是所有 AI 能力的唯一入口，其他系统不得直接调用 LLM/STT/TTS API。
2. F5 不持有任何角色数据——上下文由 F6 构建后注入，F5 只负责发送和接收。
3. F5 的所有网络调用均为异步，不阻塞主线程。
4. F5 向下游系统暴露连接状态信号，不由下游系统主动查询。

**语音识别（STT）**

5. 玩家按住对话键（具体按键由 P3 设置）时，F5 开始录音；释放时停止并发送 STT 请求。
6. STT 结果（文字）立即推送给 Fe1 显示（玩家气泡），同时进入 LLM 调用流程。
7. STT 失败或识别结果为空时，静默忽略，不触发 LLM 调用。

**LLM 调用**

8. F5 接收 F6 构建的完整 context（system prompt + 对话历史 + 当前输入），发送给 LLM。
9. LLM 回应以流式（streaming）方式接收，实时推送给 Fe1 显示（打字机效果数据源）。
10. LLM 回应完成后，完整文字传给 TTS 调用流程，同时发出 `aria_interaction_completed(personality_tags)` 信号供 C6 更新参与度。

**TTS 调用**

11. F5 将 LLM 回应文字发送给 TTS API，获取音频数据后通过信号传给 Fe5 播放。
12. TTS 失败时降级为静默（只显示文字，不播放语音），不影响对话流程。

**工作辅助指令**

13. F5 在 STT 结果进入 LLM 前，先进行意图识别（通过关键词或轻量分类）判断是否为工作辅助指令。
14. 工作辅助指令（如「帮我查…」「提醒我…」）路由到对应的辅助模块处理，不进入角色对话流程。
15. 工作辅助指令的具体模块在 Alpha 阶段设计，F5 首版只预留路由接口。

### Connection States

| 状态 | 含义 | 视觉表现（C1/P1 响应） |
|------|------|----------------------|
| `DISCONNECTED` | 无 API Key 或未配置 | 屏幕玻璃显示，角色被隔在另一侧 |
| `CONNECTING` | API Key 存在，正在验证 | 玻璃出现连接动画（如电流/光纹） |
| `CONNECTED` | API 验证成功，可正常使用 | 玻璃消失，完整交流通道开启 |
| `ERROR` | API 调用失败（网络错误/超时） | 玻璃重新出现（半透明），显示故障状态 |
| `DEGRADED` | API Key 无效或额度耗尽 | 玻璃显示，预设脚本回应模式激活 |

F5 在状态变化时发出 `connection_state_changed(state: ConnectionState)` 信号，C1、P1 订阅并响应对应视觉变化。

### Degraded Mode (降级/断连模式)

降级模式在以下情况激活：API Key 未配置 (`DISCONNECTED`)、Key 无效或额度耗尽 (`DEGRADED`)、网络超时或故障 (`ERROR`)。

**核心设定：隔断与单向**

1. **交互截断**：玩家的麦克风/文字输入无法传达给角色。Fe1 会显示玩家发声的视觉动效，但最终气泡显示为 `[...]`，暗示声音被玻璃隔断。
2. **单向反馈**：角色不会针对玩家的具体话语产生逻辑回应，而是通过本地预设脚本库（`data/fallback_scripts.json`）触发一次随机的隔窗行为或单向叙事。
3. **行为池化**：回应库优先选择“动作语言”（如敲玻璃、写字、发呆）和“独立感想”（如“今天的阳光照得有点暖...”），避免产生双向对话的错觉。
4. **收益差异**：降级交互**不增加** `resonance` (共鸣度)，但能以 `FAMILIARITY_TICK_RATE` 的 50% 效率增加 `familiarity` (熟悉感)，模拟长期的无声陪伴感。
5. **视觉锁定**：降级模式下「屏幕玻璃」视觉持续显示，直至 API 连接成功。

### Formulas

#### 1. 降级脚本选择算法 (Fallback Selection Logic)

当触发降级交互时，采用以下权重从本地库筛选：

- **动作行为类** (Action Only): 权重 0.7
- **简短感叹类** (Short Monologue): 权重 0.3

`Selection_Pool = Filter(fallback_scripts, context==current_state && personality_match)`
`Final_Script = Random_Weight(Selection_Pool - Recent_3_Used)`

#### 2. 超时与重试控制

- **自动恢复检查**: 处于 `ERROR` 状态后，每隔 `RECONNECT_INTERVAL` 分钟尝试一次静默心跳包连接，成功则自动切回 `CONNECTED`。

---

### Request Pipeline

```
玩家按住对话键
    │
    ▼
[STT] 录音 → API → 文字
    │  失败 → 静默忽略
    ▼
[意图识别] 工作辅助？
    ├─ 是 → 路由到辅助模块（首版预留接口）
    └─ 否 ↓
    ▼
[F6] 构建完整 context
（system prompt + C7记忆 + C5性格 + 当前输入）
    │
    ▼
[LLM] 流式调用
    │  → 实时推送文字流给 Fe1（打字机效果数据源）
    │  失败 → 降级为预设脚本
    ▼
[TTS] 文字 → 音频
    │  → 发送给 Fe5 播放
    │  失败 → 静默（只显示文字）
    ▼
发出 aria_interaction_completed(personality_tags)
    │
    ▼
C6 更新参与度 / C7 写入对话记录
```

## Edge Cases

| # | 场景 | 处理方式 |
|---|------|----------|
| EC-01 | 玩家按住对话键但不说话（静音输入） | STT 返回空字符串，静默忽略，不触发 LLM |
| EC-02 | LLM 调用超时（网络慢） | 超过 `LLM_TIMEOUT` 后中断请求，显示一条预设脚本回应；发出 `ERROR` 状态信号 |
| EC-03 | 流式输出中途断开 | 已推送的文字保留在 Fe1 显示，补充「…（信号断了）」结尾；不触发 TTS |
| EC-04 | TTS 调用失败 | 静默降级为纯文字，Fe1 正常显示，Fe5 不播放语音；不影响对话流程 |
| EC-05 | 玩家在 LLM 流式推送中再次按下对话键 | 中断当前流式输出，Fe1 停止打字机，开始新一轮 STT 录音 |
| EC-06 | API Key 在运行中被撤销（额度耗尽） | 下一次 LLM 调用失败后切换到 `DEGRADED` 状态；当前已有流式输出正常完成 |
| EC-07 | 游戏窗口隐藏时玩家触发对话键 | 不响应，窗口隐藏时 F5 不监听对话键输入 |

## Dependencies

**上游依赖（F5 依赖这些系统）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| F4 存档系统 | API Key 读写、连接状态持久化 | `F4.get/set("settings.aria_api_key")` |
| F6 角色上下文管理器 | 完整 LLM context 构建 | 方法 `F6.build_context(user_input) → Dictionary` |
| P3 设置 UI | API Key 配置入口、连接状态显示 | F5 发出 `connection_state_changed` 信号，P3 订阅显示 |

**下游依赖（这些系统依赖 F5）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| Fe1 对话系统 | 接收 STT 文字和 LLM 流式回应 | 方法 `Fe1.show_aria_exchange(player_text, character_text)` |
| Fe5 声音系统 | 接收 TTS 音频数据播放 | 信号 `tts_audio_ready(audio_stream)` |
| C1 角色动画系统 | 订阅连接状态变化触发玻璃动画 | 信号 `connection_state_changed(state)` |
| C6 关系值系统 | 接收 Aria 交互完成事件 | 信号 `aria_interaction_completed(personality_tags)` |
| C7 对话记忆库 | 写入本次对话记录 | 方法 `C7.record_exchange(user_input, character_response)` |

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|---------|------|
| `LLM_TIMEOUT` | 15 秒 | 5–30 秒 | LLM 调用超时阈值 |
| `TTS_TIMEOUT` | 10 秒 | 5–20 秒 | TTS 调用超时阈值 |
| `RECONNECT_INTERVAL` | 5 分钟 | 1–30 分钟 | 错误后的自动重连尝试频率 |
| `FALLBACK_SCRIPT_COOLDOWN` | 3 次 | 1–10 次 | 降级脚本的防重复队列长度 |

## Acceptance Criteria

| # | 测试条件 | 通过标准 |
|---|---------|----------|
| AC-01 | 无 API Key 启动游戏 | 连接状态为 `DISCONNECTED`，屏幕玻璃视觉显示 |
| AC-02 | 配置有效 API Key 后 | 状态切换到 `CONNECTED`，玻璃消失 |
| AC-03 | DISCONNECTED 状态下玩家说话 | 玩家气泡显示 `[...]`；角色触发一次随机隔窗动作或单向文字，不产生逻辑回应 |
| AC-04 | LLM 回应完成后 | TTS 音频通过 Fe5 播放；`aria_interaction_completed` 信号发出 |
| AC-05 | TTS 调用失败 | 角色文字正常显示，无语音，不报错 |
| AC-06 | LLM 调用超时 | 超过 `LLM_TIMEOUT` 后显示一条预设脚本回应，状态切换到 `ERROR` |
| AC-07 | 降级模式下的互动 | `familiarity` 微弱增加，`resonance` 保持不变 |
| AC-08 | 碎片归来事件在降级模式下触发 | C2/C3/Fe1 正常运行，不受 F5 状态影响 |
| AC-09 | 流式输出进行中玩家再次按对话键 | 当前流式输出中断，开始新一轮录音 |

## Open Questions

| # | 问题 | 状态 | 备注 |
|---|------|------|------|
| OQ-01 | 具体使用哪个 AI 服务商 | 待技术调研 | — |
| OQ-02 | 工作辅助指令的具体功能 | 待定 | — |
| OQ-03 | 「屏幕玻璃」的具体动画表现 | 待美术 | — |
| OQ-04 | F6 构建的 context 结构 | ✅ 已对齐 | 详见 F6 设计文档 |
| OQ-05 | 预设脚本库的内容编写 | 待叙事设计 | 需区分“动作”与“简短自述” |
| OQ-06 | 降级模式下的关系值收益 | ✅ 已明确 | 只涨熟悉感，不涨共鸣度 |