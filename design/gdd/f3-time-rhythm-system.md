# F3 — 时间/节奏系统（Time & Rhythm System）

> **Status**: Approved
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-26
> **Implements Pillar**: 真实存在感 / 陪伴不打扰

## Overview

F3 时间/节奏系统是游戏所有时间相关逻辑的基础设施。它以**真实世界时间**为基准，追踪游戏累计运行时长和离线时长，为上层系统（外出循环、事件线、关系值、角色自发行为）提供统一的时间查询接口和周期性心跳信号。游戏关闭期间时间继续流逝（离线进度），重新打开时系统计算离线时长并分发给各订阅系统处理。该系统不包含任何游戏逻辑，只负责时间的计量、持久化和广播。

## Player Fantasy

玩家不会直接感知到时间系统的存在——他们感知到的是「世界在继续」。早上打开电脑，角色已经经历了一夜；出去吃个饭回来，也许带回了什么新鲜事。这种「哪怕我不在，它的生活也没有停止」的感觉，是「真实存在感」柱的核心体现。时间系统让这个异世界的小窗口不只是一个程序，而是一个真实在流逝的存在。

## Detailed Design

### Core Rules

#### 时间基准

1. 所有时间以**真实世界时间（UTC）**为基准，单位为**分钟**
2. 内部使用 Unix 时间戳（秒精度）存储，对外接口换算为分钟
3. 游戏时间不可加速、不可暂停——时间永远以真实速率流逝

#### 在线计时

4. 游戏运行时，每隔 60 秒广播一次 `tick(current_timestamp: int, delta_minutes: float)` 信号
5. `delta_minutes` 通常为 1.0，但首次启动补算离线进度时可能为更大值（见离线进度规则）
6. 所有需要**分钟级**定期处理的系统订阅 `tick` 信号，不得自行创建独立 Timer 节点
   - **例外**：秒级动画/交互行为计时（如 F2 的待机抖动、Attentive 超时）使用本地 `Timer` 节点，不依赖 F3 tick

#### 离线进度

7. 游戏退出时记录 `last_online_timestamp`（Unix 时间戳）到 F4 存档
8. 游戏启动时计算 `offline_minutes = (current_timestamp - last_online_timestamp) / 60`
9. 离线时长上限：默认 **1440 分钟（24 小时）**，超出部分丢弃
10. 离线时长上限为开发者调优参数，默认 **1440 分钟（24 小时）**，不对玩家开放配置
11. 离线进度通过**补发 tick**的方式分发：将 `offline_minutes` 分成若干批次，每批次发出一个 `tick` 信号，批次大小为 `OFFLINE_TICK_BATCH_SIZE`（默认 60 分钟/批）
12. 补发 tick 在游戏启动时同步完成（非实时），完成后才进入正常每分钟 tick 节奏

#### 时间查询接口

13. F3 暴露以下只读接口：
    - `get_current_timestamp() -> int` — 当前 Unix 时间戳
    - `get_total_minutes_played() -> float` — 游戏总在线分钟数（不含离线）
    - `get_total_minutes_elapsed() -> float` — 游戏总流逝分钟数（含离线）

### States and Transitions

| 模式 | 描述 | 持续时间 |
|------|------|----------|
| **Catching Up**（补算离线） | 启动时批量补发离线 tick，每批 `OFFLINE_TICK_BATCH_SIZE` 分钟 | 启动后短暂，取决于离线时长 |
| **Running**（正常运行） | 每分钟广播一次 tick | 游戏运行期间持续 |

**转换**：`Catching Up` → （离线 tick 全部补发完毕）→ `Running`

**注**：两种模式下 tick 信号格式完全相同，订阅系统无需区分来源。

### Interactions with Other Systems

| 交互系统 | 数据流向 | F3 提供什么 | F3 需要什么 |
|---------|---------|------------|------------|
| **F4 存档系统** | 双向 | 读取/写入 `last_online_timestamp` | 存档读写接口 |
| **C2 外出-归来循环** | F3 → C2 | `tick` 信号（C2 用于外出计时和概率积累） | — |
| **C4 事件线系统** | F3 → C4 | `tick` 信号（C4 用于检查事件触发条件） | — |
| **C6 关系值系统** | F3 → C6 | `tick` 信号（C6 用于累加在线/流逝时长） | — |
| **P3 设置 UI** | F3 → P3 | 提供 `get_total_minutes_elapsed()` 供显示 | — |

**接口约定**：
- F3 暴露信号 `tick(current_timestamp: int, delta_minutes: float)`
- F3 暴露信号 `catching_up_completed(total_offline_minutes: float)` — 离线补算完成通知
- F3 暴露只读接口 `get_current_timestamp()`, `get_total_minutes_played()`, `get_total_minutes_elapsed()`
- F3 不订阅任何其他系统的信号，是纯输出系统
- F2 角色状态机的秒级计时（待机抖动、Attentive 超时等）使用本地 Timer 节点，不依赖 F3

## Formulas

### 离线时长计算

```
offline_minutes = clamp(
    (current_timestamp - last_online_timestamp) / 60,
    0,
    MAX_OFFLINE_MINUTES
)
```

| 变量 | 类型 | 范围 | 来源 | 说明 |
|------|------|------|------|------|
| `current_timestamp` | int | Unix 时间戳 | 系统时钟 | 游戏启动时读取 |
| `last_online_timestamp` | int | Unix 时间戳 | F4 存档 | 上次退出时保存 |
| `MAX_OFFLINE_MINUTES` | float | 60 到 10080 | 玩家设置（默认 1440） | 离线进度上限 |

**期望输出范围**：0 到 10080 分钟
**边界情况**：若 `current_timestamp < last_online_timestamp`（系统时钟被调回），结果为 0，不补算

---

### 离线 tick 批次数

```
batch_count = ceil(offline_minutes / OFFLINE_TICK_BATCH_SIZE)
```

| 变量 | 类型 | 范围 | 来源 | 说明 |
|------|------|------|------|------|
| `offline_minutes` | float | 0 到 MAX_OFFLINE_MINUTES | 上方公式 | 实际补算时长 |
| `OFFLINE_TICK_BATCH_SIZE` | float | 10 到 120 | 调优参数（默认 60） | 每批 tick 的分钟数 |

**期望输出范围**：0 到 24 批（默认设置下）

## Edge Cases

**1. 系统时钟被调回（反作弊）**
- 条件：`current_timestamp < last_online_timestamp`
- 处理：`offline_minutes = 0`，不补算任何进度，不报错
- 注意：这也会影响正常用户（如手动调时区），但对 Idle 游戏影响轻微，可接受

**2. 首次启动（无存档）**
- 条件：F4 存档中无 `last_online_timestamp`
- 处理：`offline_minutes = 0`，直接进入 Running 模式，不补算

**3. 离线时长超过上限**
- 条件：`(current_timestamp - last_online_timestamp) / 60 > MAX_OFFLINE_MINUTES`
- 处理：截断至 `MAX_OFFLINE_MINUTES`，超出部分丢弃，静默处理

**4. 补算期间游戏被关闭**
- 条件：玩家在 Catching Up 阶段关闭游戏
- 处理：已补算的 tick 已触发对应逻辑并写入存档；下次启动时重新计算离线时长，不会重复补算

**5. 系统时钟跨时区/夏令时**
- 条件：跨时区、夏令时切换导致本地时间跳变
- 处理：使用 UTC 时间戳，不受时区和夏令时影响

**6. 补算 tick 触发大量事件**
- 条件：24小时离线后一次性触发 24 个 tick，C2/C4 可能产生大量事件
- 处理：F3 只负责发出 tick，由各订阅系统自行限制单次处理的最大事件数（不在 F3 层限制）

## Dependencies

**上游依赖（F3 依赖的系统）**
- **F4 存档系统**（未设计）：F3 需要 F4 提供 `last_online_timestamp` 的读写接口。接口待定（provisional）。

**下游依赖（依赖 F3 的系统）**
- **C2 外出-归来循环**（未设计）：订阅 `tick` 信号管理外出计时和概率积累
- **C4 事件线系统**（未设计）：订阅 `tick` 信号检查事件触发条件
- **C6 关系值系统**（未设计）：订阅 `tick` 信号累加时长
- **P3 设置 UI**（未设计）：查询总流逝时长；提供离线上限配置

**外部依赖**
- **Godot 4.6.1 `Time` 单例**：提供 `Time.get_unix_time_from_system()` 获取 UTC 时间戳
- **Godot 4.6.1 `Timer` 节点**：驱动每分钟 tick 的在线计时

## Tuning Knobs

| 参数 | 当前值 | 安全范围 | 增大效果 | 减小效果 |
|------|--------|---------|---------|----------|
| `MAX_OFFLINE_MINUTES` | 1440（24小时） | 60 到 10080（7天） | 离线更久也能补更多进度 | 离线进度更快到顶，超出丢弃 |
| `OFFLINE_TICK_BATCH_SIZE` | 60 分钟/批 | 10 到 120 | 每批处理更多时间，补算更快完成 | 每批更细粒度，补算更慢但更精确 |

**注**：两个参数均为开发者调优参数，不对玩家开放。

## Visual/Audio Requirements

本系统为纯时间基础设施，自身不产生任何视觉或音频输出。

唯一的例外是补算离线进度完成后的通知——但这属于 Fe6 通知/提醒系统的职责，F3 只广播 `catching_up_completed` 信号，由 Fe6 决定是否显示提示。

| 事件 | 视觉响应负责方 | 音频响应负责方 |
|------|--------------|---------------|
| 离线补算完成 | Fe6 通知系统（可选） | Fe5 声音系统（可选） |

## UI Requirements

本系统不直接渲染任何 UI 元素。时间相关数据通过查询接口供其他系统使用：

| 数据 | 查询接口 | 使用方 | 用途 |
|------|---------|--------|------|
| 当前时间戳 | `get_current_timestamp()` | C2、C4 | 事件触发判断 |
| 总在线时长 | `get_total_minutes_played()` | P3 设置 UI | 统计显示（可选） |
| 总流逝时长 | `get_total_minutes_elapsed()` | P3 设置 UI、C6 | 统计显示、关系值计算 |

## Acceptance Criteria

- [ ] 游戏启动时正确读取 `last_online_timestamp` 并计算离线时长
- [ ] 离线时长超过 `MAX_OFFLINE_MINUTES`（1440分钟）时截断，不超出
- [ ] 系统时钟被调回时，`offline_minutes = 0`，不补算，不崩溃
- [ ] 首次启动无存档时，直接进入 Running 模式，不报错
- [ ] Catching Up 阶段按批次正确补发 tick，每批 `delta_minutes = OFFLINE_TICK_BATCH_SIZE`
- [ ] Catching Up 完成后广播 `catching_up_completed` 信号
- [ ] Running 模式下每 60 秒广播一次 `tick`，`delta_minutes = 1.0`
- [ ] 所有 tick 信号包含正确的 `current_timestamp` 和 `delta_minutes`
- [ ] 游戏退出时正确写入 `last_online_timestamp` 到 F4 存档
- [ ] 补算期间游戏关闭后，下次启动不重复补算已处理的时段
- [ ] UTC 时间戳不受本地时区或夏令时影响
- [ ] Performance：单次 tick 广播完成时间 < 1ms（F3 自身，不含订阅系统处理时间）

## Open Questions

| 问题 | 负责人 | 截止 | 解决方案 |
|------|--------|------|----------|
| 离线进度机制是否需要逐分钟补算 tick？当前倾向：简化为「离线时长 → 单次触发类归来事件」，超过阈值（如 30 分钟）才触发，不逐分钟补算 | 设计者 | C2 设计阶段 | 待定——在 C2 外出-归来循环 GDD 中最终决定 |
| 若采用简化机制，F3 的 `OFFLINE_TICK_BATCH_SIZE` 和补算逻辑可大幅简化甚至移除，届时需更新本 GDD | 开发者 | C2 设计阶段 | 待 C2 设计结论后修订 |
| `get_total_minutes_played()` 是否需要精确到秒？分钟精度是否足够？ | 设计者 | C6 设计阶段 | 待定 |
