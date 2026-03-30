# F4 — 存档系统（Save System）

> **Status**: Approved
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-27
> **Implements Pillar**: 真实存在感（持久化角色生活状态）

## Overview

F4 存档系统负责所有游戏状态的持久化。它以 JSON 格式将数据写入本地文件（`user://save.json`），并在游戏启动时读取恢复。所有其他系统通过统一的键值接口（`save(key, value)` / `load(key, default)`）与 F4 交互，不直接操作文件。存档格式对外部系统完全透明——将来可在不影响其他系统的前提下切换格式。F4 还负责存档文件的完整性校验、损坏恢复、以及版本迁移（当游戏更新导致存档结构变化时）。

## Player Fantasy

玩家感知不到存档系统的存在——他们感知到的是「一切都还在」。关机重开，桌宠还在屏幕的同一个角落；离开一段时间回来，角色的状态、故事进度、和玩家的羁绊都完好无损。存档系统是「这个世界是真实的」这一感知的无声守护者。

## Detailed Design

### Core Rules

#### 存档格式与位置

1. 存档文件路径：`user://save.json`（Godot 标准用户数据目录）
2. 格式：UTF-8 编码的 JSON，顶层为键值对字典
3. 存档结构包含 `_meta` 节点记录版本和时间戳：
```json
{
  "_meta": {
    "save_version": 1,
    "last_saved": 1234567890
  },
  "f1.window_position": {"x": 1200, "y": 800},
  "f3.last_online_timestamp": 1234567890
}
```

#### 读写接口

4. F4 暴露以下接口，所有系统通过此接口操作存档，**禁止直接读写文件**：
   - `save(key: String, value: Variant) -> void` — 写入单个键值，立即写入文件
   - `load(key: String, default: Variant = null) -> Variant` — 读取键值，不存在时返回 default
   - `save_batch(data: Dictionary) -> void` — 批量写入多个键值，只写一次文件
   - `delete(key: String) -> void` — 删除单个键

5. 写入时机：
   - **即时写入**：F1 窗口位置（拖拽结束时）、F3 时间戳（退出时）
   - **事件触发写入**：重要游戏状态变更（碎片解锁、事件节点完成、性格变化）
   - **定时写入**：每 `AUTO_SAVE_INTERVAL`（默认 5 分钟）自动保存全量快照

#### 版本迁移

6. 每次游戏更新可能改变存档结构，F4 通过 `save_version` 字段管理迁移
7. 启动时若检测到旧版本存档，自动执行迁移脚本，升级到当前版本
8. 迁移失败时保留原文件（重命名为 `save.json.bak`），使用默认值启动

#### 数据键命名规范

9. 所有键使用命名空间前缀，格式为 `[系统ID].[键名]`，例如：
   - `f1.window_position`
   - `f3.last_online_timestamp`
   - `c5.personality_traits`

### States and Transitions

| 模式 | 描述 | 持续时间 |
|------|------|----------|
| **Loading**（启动读取） | 游戏启动时读取存档文件、校验完整性、执行版本迁移 | 启动后短暂 |
| **Ready**（就绪） | 正常运行，响应读写请求，定时自动保存 | 游戏运行期间持续 |

**转换**：`Loading` → （存档加载完成 / 迁移完成 / 使用默认值）→ `Ready`

**关键规则**：F4 在 `Loading` 完成前不响应任何读写请求。其他系统必须等待 `save_system_ready` 信号后才能调用 F4 接口。

### Interactions with Other Systems

| 交互系统 | 数据流向 | F4 提供什么 | F4 需要什么 |
|---------|---------|------------|------------|
| **F1 桌面窗口系统** | 双向 | `load("f1.window_position")` | 拖拽结束时 `save("f1.window_position", pos)` |
| **F2 角色状态机** | F2 → F4 | — | 退出时写入 `pending_departure` 状态（若需持久化，待定） |
| **F3 时间/节奏系统** | 双向 | `load("f3.last_online_timestamp")` | 退出时 `save("f3.last_online_timestamp", ts)` |
| **C3 碎片系统** | 双向 | 碎片收集状态的读写 | 碎片解锁时写入 |
| **C4 事件线系统** | 双向 | 事件线进度的读写 | 事件节点完成时写入 |
| **C5 性格变量系统** | 双向 | 性格特质数据的读写 | 性格变化时写入 |
| **C6 关系值系统** | 双向 | 关系值数据的读写 | 定期或关键节点写入 |
| **C7 对话记忆库** | 双向 | 对话历史摘要的读写 | 对话结束时写入 |
| **所有系统** | F4 → 所有 | `save_system_ready` 信号 | — |

**接口约定**：
- F4 作为 Godot **Autoload 单例**存在，全局可访问
- 所有系统在 `_ready()` 中等待 `save_system_ready` 信号后再调用 F4 接口
- F4 暴露信号 `save_system_ready`、`save_completed`、`load_failed(reason: String)`

## Formulas

本系统为纯数据持久化系统，无数学公式。

## Edge Cases

**1. 存档文件不存在（首次启动）**
- 条件：`user://save.json` 文件不存在
- 处理：所有 `load()` 调用返回传入的 `default` 值，游戏以默认状态启动，不报错

**2. 存档文件损坏（JSON 解析失败）**
- 条件：文件存在但内容不是合法 JSON
- 处理：将损坏文件重命名为 `save.json.bak`，以默认值启动，广播 `load_failed("corrupted")` 信号

**3. 版本迁移失败**
- 条件：迁移脚本执行出错（如字段缺失、类型不匹配）
- 处理：保留原文件（`save.json.bak`），以默认值启动，记录详细错误日志

**4. 写入磁盘失败（磁盘满/权限问题）**
- 条件：`FileAccess.open()` 返回错误
- 处理：记录错误日志，游戏继续运行（内存中数据仍有效），下次写入时重试

**5. 并发写入（多个系统同一帧调用 save()）**
- 条件：同一帧内多个系统调用 `save()`
- 处理：F4 内部队列化写入，合并为单次文件操作，避免频繁 I/O

**6. 存档键值类型变更（版本迁移场景）**
- 条件：旧存档中某键的类型与新代码期望类型不符
- 处理：迁移脚本负责类型转换；若无迁移脚本，`load()` 返回 `default` 值

**7. `save_system_ready` 前的调用**
- 条件：某系统在 Loading 完成前调用 `save()` 或 `load()`
- 处理：`load()` 返回 `default`，`save()` 调用被忽略并记录警告日志

## Dependencies

**上游依赖（F4 依赖的系统）**
- 无——F4 是最底层的 Foundation 系统，不依赖任何其他游戏系统

**下游依赖（依赖 F4 的系统）**
- **F1 桌面窗口系统**（已设计 ✅）：读写窗口位置
- **F2 角色状态机**（已设计 ✅）：退出时写入状态快照（待确认是否需要）
- **F3 时间/节奏系统**（已设计 ✅）：读写 `last_online_timestamp`
- **C3 碎片系统**（未设计）：读写碎片收集状态
- **C4 事件线系统**（未设计）：读写事件线进度
- **C5 性格变量系统**（未设计）：读写性格特质数据
- **C6 关系值系统**（未设计）：读写关系值
- **C7 对话记忆库**（未设计）：读写对话历史摘要

**外部依赖**
- **Godot 4.6.1 `FileAccess`**：文件读写
- **Godot 4.6.1 `JSON`**：序列化/反序列化
- **Godot 4.6.1 Autoload 机制**：全局单例注册

## Tuning Knobs

| 参数 | 当前值 | 安全范围 | 增大效果 | 减小效果 |
|------|--------|---------|---------|----------|
| `AUTO_SAVE_INTERVAL` | 10 分钟 | 5 到 60 分钟 | 自动保存更少，I/O 更少 | 自动保存更频繁，数据更安全 |
| `save_version` | 1 | 只增不减 | — | — |

**注**：`AUTO_SAVE_INTERVAL` 为开发者调优参数，不对玩家开放。对于本游戏，关键状态变更已由事件触发写入覆盖，自动保存仅作安全网，优先级低，间隔可适当延长。

## Visual/Audio Requirements

本系统为纯数据持久化系统，无任何视觉或音频输出。

## UI Requirements

本系统不直接渲染任何 UI 元素。存档相关的用户反馈（如「存档失败」提示）由 Fe6 通知系统负责，F4 只广播信号。

## Acceptance Criteria

- [ ] 首次启动（无 save.json）时，所有 `load()` 调用返回传入的 `default` 值，无报错，游戏正常启动
- [ ] `save_system_ready` 信号在 Loading 完成后广播；Loading 完成前调用 `load()` 返回 `default`，调用 `save()` 被忽略并输出警告日志
- [ ] 调用 `save("key", value)` 后重启游戏，`load("key")` 返回相同的值（±类型一致）
- [ ] `save_batch(data)` 对多个键仅触发一次文件写入，不产生多次 I/O
- [ ] 同一帧内多次调用 `save()` 被合并为单次文件操作
- [ ] `delete("key")` 后，`load("key")` 返回传入的 `default` 值
- [ ] 存档文件损坏（非合法 JSON）时：重命名为 `save.json.bak`，以默认值启动，广播 `load_failed("corrupted")` 信号
- [ ] `_meta.save_version` 字段在每次写入时正确包含在存档中
- [ ] 检测到旧版本存档时，迁移脚本自动执行，升级到当前 `save_version`
- [ ] 版本迁移失败时：保留原文件为 `save.json.bak`，以默认值启动，记录详细错误日志
- [ ] 磁盘写入失败（磁盘满/权限问题）时：游戏继续运行，记录错误日志，不崩溃
- [ ] 自动保存每 `AUTO_SAVE_INTERVAL`（默认 10 分钟）触发一次全量快照
- [ ] F4 作为 Autoload 单例正确注册，全局可通过 `SaveSystem.save()` / `SaveSystem.load()` 访问
- [ ] Performance：`load()` 单次调用（内存查询）完成时间 < 1ms；`save()` 文件写入完成时间 < 10ms

## Open Questions

| 问题 | 负责人 | 截止 | 解决方案 |
|------|--------|------|----------|
| F2 的 `pending_departure` 状态是否需要持久化到 F4？当前倾向：不需要（应用内存状态，重启后重置合理） | 设计者 | F2/C2 实现阶段 | 待定 |
| 自动保存是否应写入增量快照（仅变更键）还是全量快照？当前倾向：全量（实现简单，数据量小） | 开发者 | 实现阶段 | 待定 |
| `save_completed` 信号是否需要携带被写入的 key 列表，供调试用？当前倾向：不需要，保持接口简洁 | 开发者 | 实现阶段 | 待定 |
