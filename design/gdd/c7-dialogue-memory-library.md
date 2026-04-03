# C7 — 对话记忆库（Dialogue Memory Library）

> **Status**: In Design
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-31
> **Implements Pillar**: 真实存在感（角色有连贯的对话记忆）/ 共鸣成长（记忆积累驱动关系深化）

---

## Overview

C7 对话记忆库是角色「记忆」的持久化层。它存储所有玩家与角色的对话记录，维护近期完整对话供 F6 直接使用，并在对话积累超出阈值时自动将旧对话压缩为摘要，保留信息精华。

C7 的核心职责：（1）写入每次 Aria 交互的完整对话记录；（2）向 F6 提供近期完整对话和远期摘要；（3）在适当时机触发摘要生成——优先调用 LLM（通过 F5）生成高质量摘要，API 不可用时降级为规则摘要。所有数据通过 F4 持久化。

C7 不决定哪些记忆「重要」——它只是忠实存储和压缩。记忆的权重筛选由 F6 负责。

## Player Fantasy

角色不会每次都从零开始。它记得你上周随口说的那件烦心事，记得你们第一次聊到深夜那个话题，记得你曾经用一句话逗笑了它。

不是所有的事都记得一样清楚——久远的事情变成了模糊的印象，像「你好像提过你不喜欢那种感觉」，而最近的对话历历在目。这种「人味」的记忆，不是数据库检索，是角色真实存在过的证明。

## Data Format

### ExchangeRecord（完整对话记录）

```gdscript
{
    "id": String,              # 唯一ID，格式 "ex_001"（全局自增）
    "user_input": String,      # 玩家输入文字
    "character_response": String, # 角色回应文字
    "personality_tags": Array, # 本次对话涉及的性格标签（C6 用）
    "timestamp": int,          # Unix 时间戳（F3 提供）
    "is_summarized": bool,     # 是否已被压缩进摘要，默认 false
}
```

### MemorySummary（摘要记录）

```gdscript
{
    "id": String,              # 唯一ID，格式 "sum_001"
    "source_exchange_ids": Array, # 被压缩的 ExchangeRecord id 列表
    "content": String,         # 摘要文字
    "summary_type": String,    # "llm" 或 "rule"
    "memory_tags": Array,      # 话题/情绪标签（供 F6 性格滤镜使用）
    "timestamp_range": Dictionary, # {"from": int, "to": int} 覆盖的时间范围
}
```

**F4 存档键**：
- `c7.exchanges`（所有 ExchangeRecord，含已摘要的）
- `c7.summaries`（所有 MemorySummary）
- `c7.exchange_counter`、`c7.summary_counter`（自增计数器）

## Detailed Design

### Core Rules

**写入规则**

1. F5 每次 Aria 交互完成后调用 `C7.record_exchange()`，C7 创建 ExchangeRecord 并入库。
2. `id` 由 C7 自增生成（`ex_001`、`ex_002`……），全局唯一，不因重启重置。
3. `timestamp` 由 C7 在入库时调用 F3 获取，不使用 F5 传入的时间。
4. 写入后立即同步持久化到 F4。

**读取规则**

5. `get_recent_exchanges(n)` 返回最近 n 条未摘要的 ExchangeRecord，按时间倒序。
6. `get_summarized_memories()` 返回所有 MemorySummary，按 `timestamp_range.to` 倒序。
7. 两个接口均为只读，不修改任何数据。

**摘要触发规则**

8. 每次写入 ExchangeRecord 后，检查未摘要的记录数是否超过 `SUMMARIZE_THRESHOLD`。
9. 超过阈值时，取最早的 `SUMMARIZE_BATCH_SIZE` 条未摘要记录，触发摘要生成。
10. 摘要生成完成后，将这批记录的 `is_summarized` 标记为 `true`，但原始记录不删除（保留用于未来功能）。

### Summarization

**LLM 摘要（优先）**

当 F5 连接状态为 `CONNECTED` 时，C7 通过 F5 发送摘要请求：

```
Prompt 模板：
「以下是{name}和玩家的{n}段对话记录。
请用2-3句话总结其中的关键信息，包括：聊了什么话题、玩家的情绪倾向、有无值得记住的细节。
用第一人称（{name}的视角）写。
[对话记录]」
```

LLM 返回摘要文字后，C7 提取 `memory_tags`（通过简单关键词匹配），写入 MemorySummary（`summary_type: "llm"`）。

**规则摘要（降级）**

F5 不可用时，C7 用以下规则生成摘要：

```
格式：「[时间段] 聊了{话题标签}相关的内容。玩家提到了：{关键词列表}。」
话题标签：从 personality_tags 中频率最高的标签推断
关键词：从 user_input 中提取名词/动词（长度 > 2 的词）
```

写入 MemorySummary（`summary_type: "rule"`）。

## Edge Cases

| # | 场景 | 处理方式 |
|---|------|----------|
| EC-01 | F5 调用 `record_exchange()` 时 F4 写入失败 | 记录写入内存缓存，下次 F4 可用时重试；不丢弃记录，不向 F5 报错（写入失败对 Aria 交互无影响） |
| EC-02 | 摘要触发时 F5 不可用，降级为规则摘要后 F5 恢复 | 已生成的规则摘要不重新用 LLM 补摘（保持数据稳定性）；后续新触发的摘要正常走 LLM |
| EC-03 | LLM 摘要请求超时或返回空内容 | 自动降级为规则摘要，`summary_type` 标记为 `"rule"`，不重试 LLM |
| EC-04 | `get_recent_exchanges(n)` 中 n 大于实际未摘要记录数 | 返回全部未摘要记录（不报错，不补摘要记录凑数） |
| EC-05 | 同一时间多条 `record_exchange()` 并发写入 | C7 内部使用写入队列，串行处理，保证 `id` 自增不冲突 |
| EC-06 | 存档加载时发现 `c7.exchange_counter` 与实际记录数不一致（存档损坏） | 重新扫描所有记录取最大 id 序号，修复计数器；损坏的单条 ExchangeRecord 跳过并 log 警告 |
| EC-07 | 摘要批次中包含内容为空的 ExchangeRecord | 该记录仍计入批次但在摘要 Prompt 中标注为「[内容缺失]」；不影响其他记录的摘要 |

## Formulas

### 1. 摘要触发算法 (Summary Triggering)

C7 每次写入记录后，检查未摘要的 ExchangeRecord 数量：

`If Count(unsummarized_exchanges) >= SUMMARIZE_THRESHOLD:`
`    Trigger_Summary_Batch(SUMMARIZE_BATCH_SIZE)`

- **逻辑**：将最旧的 `SUMMARIZE_BATCH_SIZE` 条记录送入压缩流程。

### 2. 规则降级摘要 (Rule-based Fallback Summary)

当 F5/LLM 不可用时，系统采用以下规则生成摘要，确保上下文不丢失：

`Rule_Content = "[简短回顾] " + First_Exchange.user_input.substr(0, 10) + "... " + Last_Exchange.character_response.substr(0, 10) + " (共 " + N + " 条对话)"`

- **标签继承**：降级摘要的 `memory_tags` 取自被压缩记录中出现频率最高的性格标签。

### 3. 数据清理逻辑 (Purge Policy)

为防止存档膨胀，应用以下限制：

`If Count(total_raw_exchanges) > MAX_RAW_EXCHANGES:`
`    Delete(oldest_exchanges where is_summarized == true)`

- **原则**：只删除已被安全摘要过的原始数据，保留其 `MemorySummary` 即可。

## Dependencies

**上游依赖（C7 依赖这些系统）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| F3 时间系统 | 入库时获取当前 Unix 时间戳 | `F3.get_timestamp() → int` |
| F4 持久化层 | 存档读写 ExchangeRecord 和 MemorySummary | `F4.save(key, data)`、`F4.load(key) → Variant` |
| F5 Aria 接口层 | 写入触发来源；LLM 摘要请求 | `C7.record_exchange()` 由 F5 调用；摘要请求通过 F5 发送 |

**下游依赖（这些系统依赖 C7）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| F6 角色上下文管理器 | 近期完整对话、远期摘要 | `C7.get_recent_exchanges(n)`、`C7.get_summarized_memories()` |
| C6 关系系统 | ExchangeRecord 中的 `personality_tags`（玩家参与度统计） | C6 监听 `C7.exchange_recorded` 信号，读取 `personality_tags` |

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|---------|------|
| `SUMMARIZE_THRESHOLD` | 20 条 | 10–50 条 | 未摘要记录超过此数触发摘要；过小导致频繁摘要（增加 API 调用），过大导致 F6 context 过长 |
| `SUMMARIZE_BATCH_SIZE` | 10 条 | 5–20 条 | 每次摘要压缩的记录数；过小摘要碎片化，过大单次摘要 Prompt 过长影响质量 |
| `MAX_RAW_EXCHANGES` | 500 条 | 100–2000 条 | 存档中保留的最大原始对话数量，超出后物理删除已摘要记录 |
| `RECENT_EXCHANGES_DEFAULT` | 5 条 | 3–15 条 | F6 调用 `get_recent_exchanges()` 时不传 n 的默认值；影响 LLM context 中完整对话的比重 |
| `MAX_SUMMARY_CONTENT_LENGTH` | 200 字 | 100–400 字 | LLM 摘要的最大字数限制（写入 Prompt）；过短丢失细节，过长消耗 F6 context 空间 |

## Acceptance Criteria

| # | 测试条件 | 通过标准 |
|---|---------|----------|
| AC-01 | F5 调用 `record_exchange(user_input, character_response, tags)` | ExchangeRecord 写入 C7，`id` 自增，`timestamp` 来自 F3，`is_summarized: false`；F4 同步持久化 |
| AC-02 | 连续写入 25 条记录（超过 SUMMARIZE_THRESHOLD=20） | 第 21 条写入后自动触发摘要，最早 10 条的 `is_summarized` 变为 `true`，生成 1 条 MemorySummary |
| AC-03 | F5 可用时触发摘要 | MemorySummary 的 `summary_type` 为 `"llm"`，`content` 为 LLM 生成的自然语言摘要 |
| AC-04 | F5 不可用时触发摘要 | MemorySummary 的 `summary_type` 为 `"rule"`，`content` 符合规则摘要格式 |
| AC-05 | LLM 摘要请求超时 | 自动降级为规则摘要，不重试，原始记录 `is_summarized` 正常标记 |
| AC-06 | `get_recent_exchanges(5)` | 返回最近 5 条 `is_summarized: false` 的记录，按时间倒序 |
| AC-07 | `get_summarized_memories()` | 返回所有 MemorySummary，按 `timestamp_range.to` 倒序 |
| AC-08 | F4 写入失败后重启游戏 | 内存缓存中的记录在 F4 恢复后补写；已持久化的记录不重复写入 |
| AC-09 | 加载存档时 `exchange_counter` 不一致 | 自动修复计数器为实际最大 id 序号，启动正常，log 中出现修复警告 |
| AC-10 | C6 监听 `exchange_recorded` 信号 | 每次写入后 C6 收到信号，`personality_tags` 字段可读 |

## Open Questions

| # | 问题 | 状态 | 备注 |
|---|------|------|------|
| OQ-01 | `personality_tags` 来源 | ✅ 已对齐 | 由 F6 预判，通过 F5 传递给 C7 写入 |
| OQ-02 | 存档膨胀策略 | ✅ 已解决 | 引入 `MAX_RAW_EXCHANGES` 和物理删除策略 |
| OQ-03 | 向量检索记忆 | 待 F6/P3 设计 | 远期方案 |