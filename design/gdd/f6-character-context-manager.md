# F6 — 角色上下文管理器（Character Context Manager）

> **Status**: In Design
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-31
> **Implements Pillar**: 真实存在感（角色有连贯的记忆与视角）/ 性格即命运（记忆筛选带性格滤镜）

---

## Overview

F6 角色上下文管理器是连接「游戏数据层」与「AI 能力层」的翻译官。它负责在每次 LLM 调用前，从 C5（性格变量）、C7（对话记忆库）、C6（关系值）收集数据，组装成一份完整的 LLM context——包括 System Prompt（角色设定）、对话历史（近期记忆）、当前情境（玩家输入、关系状态）。

F6 的核心挑战是「信息压缩」：LLM 有上下文长度限制，但角色的记忆和经历理论上无限。F6 需要决定哪些记忆进入当前对话、哪些被摘要、哪些暂时遗忘。这种「选择性记忆」本身就是角色性格的体现——一个温暖型角色可能更记得玩家的情绪细节，一个好奇型角色可能更记得玩家分享的知识。

F6 不直接调用任何 API，只产出 context 数据结构，交给 F5 发送。

## Player Fantasy

玩家不会知道 F6 的存在，但会感受到一种奇妙的连贯性——角色记得三天前随口说过的小事，记得你上次心情不好时它安慰你的方式，甚至会在某个时刻突然提起「你之前说过……」。

这种记忆不是机械的「数据库查询」，而是有选择性的、带着角色滤镜的。有时候它记得的和你记得的不完全一样——但那就是它的视角，它的版本的故事。这种「被记住」的感觉，让陪伴感从「程序响应」跃升为「关系」。

## Detailed Design

### Core Rules

**基本职责**

1. F6 是 LLM context 的唯一组装者，F5 不得自行构建或修改 context。
2. F6 不持有任何持久化数据——所有数据从 C5/C6/C7 实时读取，每次调用重新组装。
3. F6 的输出是一份可直接发送给 LLM 的完整 context，包含 system prompt、对话历史、当前情境。
4. F6 必须在 LLM 上下文长度限制内完成组装，超出时按优先级舍弃低权重内容。

**数据来源**

5. **System Prompt 基础模板**：从 `data/character_prompts.json` 读取，包含角色基础设定、世界观、说话风格。
6. **性格注入**：从 C5 读取当前性格值，填充到 prompt 中的 `{personality}` 占位符。
7. **关系状态注入**：从 C6 读取三轴关系值，作为情境变量注入（如「你们已经相处了 X 小时」）。
8. **对话历史**：从 C7 读取近期对话记录，按时间倒序排列。
9. **当前输入**：由 F5 传入的玩家 STT 文字。

**记忆权重与筛选**

10. F6 按「近期完整、远期摘要」分层组装 context。
11. 近期层：保留最近 `RECENT_EXCHANGES` 轮完整对话（玩家输入 + 角色回应）。
12. 远期层：从 C7 读取记忆摘要，按与当前话题的相关性排序选取。
13. **性格滤镜（记忆权重）**：F6 根据 C5 性格变量调整远期记忆的选取权重——高 `curiosity` 角色优先选取知识类记忆，高 `warmth` 角色优先选取情绪类记忆。
14. 若 context 总长度超出 `MAX_CONTEXT_TOKENS`，按「远期摘要 → 早期近期对话」的顺序舍弃，保留 system prompt 和最新一轮对话。

**输出格式**

15. F6 返回标准格式的 context 对象，F5 直接序列化后发送给 LLM API。

### Context Structure

F6 输出的 context 是一个结构化对象，F5 将其转换为 LLM API 所需的格式（如 OpenAI 的 messages 数组）。

```gdscript
{
    "system_prompt": String,           # 完整的 system prompt，已填充所有变量
    "messages": Array[Dictionary],     # 对话历史，每条包含 role 和 content
    "current_input": String,           # 玩家当前输入（最后一条 user 消息）
    "metadata": {                      # 供 F5 使用的元数据
        "personality_tags": Array,     # 本次对话涉及的性格标签，供 C6 更新参与度
        "context_tokens": int,         # 估算的 token 数
    }
}
```

**System Prompt 模板示例**（`data/character_prompts.json`）：

```json
{
  "base_template": "你是{name}，来自{world}。你的性格是{personality_description}。你和玩家的关系目前处于{relationship_stage}。记住：你说话的方式是{speech_style}。",
  "variables": {
    "name": "从配置读取",
    "world": "从配置读取",
    "personality_description": "由 F6 根据 C5 动态生成",
    "relationship_stage": "由 F6 根据 C6 动态生成",
    "speech_style": "从配置读取"
  }
}
```

**Messages 数组结构**：

```gdscript
[
    {"role": "system", "content": "..."},           # system prompt（F6 组装）
    {"role": "assistant", "content": "..."},       # 角色远期记忆摘要（C7 提供）
    {"role": "user", "content": "..."},            # 玩家输入（历史）
    {"role": "assistant", "content": "..."},       # 角色回应（历史）
    # ... 近期对话历史
    {"role": "user", "content": "当前输入"},        # 当前玩家输入
]
```

### Memory Compression

F6 采用「分层存储 + 性格加权筛选」策略，在 LLM 上下文长度限制内最大化记忆价值。

**分层结构**

| 层级 | 内容 | 来源 | 保留策略 |
|------|------|------|----------|
| **L0 System** | System Prompt | `data/character_prompts.json` + C5/C6 动态填充 | 永不丢弃 |
| **L1 Recent** | 最近 `RECENT_EXCHANGES` 轮完整对话 | C7 实时查询 | 优先保留，超出时从最早开始丢弃 |
| **L2 Summarized** | 远期记忆摘要，按话题分类 | C7 维护的摘要库 | 按性格权重和相关性排序选取 |
| **L3 Current** | 玩家当前输入 | F5 传入 | 永不丢弃 |

**压缩流程**

```
1. 组装 L0（System Prompt）
2. 查询 C7 获取 L1（近期完整对话）
3. 查询 C7 获取 L2 候选（所有远期摘要）
4. 应用性格滤镜对 L2 排序
5. 从 L2 顶部开始选取，直到总长度接近 MAX_CONTEXT_TOKENS
6. 若仍超出，从 L1 的最早对话开始丢弃
7. 追加 L3（当前输入）
```

**性格滤镜算法**

```
memory_weight(memory) = base_relevance(memory, current_topic)
                        × personality_multiplier(memory.type, current_personality)

personality_multiplier 规则：
- curiosity 高 → knowledge 类记忆权重 ×1.5
- warmth 高 → emotion 类记忆权重 ×1.5
- boldness 高 → adventure 类记忆权重 ×1.5
- melancholy 高 → introspection 类记忆权重 ×1.5
```

**与 C7 的接口约定**（待 C7 设计时细化）：
- `C7.get_recent_exchanges(n) → Array[Exchange]` — 获取最近 n 轮完整对话
- `C7.get_summarized_memories() → Array[MemorySummary]` — 获取所有远期摘要
- `C7.record_exchange(user_input, character_response, personality_tags)` — 写入新对话（由 F5 调用后通知 C7）

## Edge Cases

| # | 场景 | 处理方式 |
|---|------|----------|
| EC-01 | C7 返回空记忆（首次对话） | L1/L2 为空，context 只包含 System Prompt + 当前输入 |
| EC-02 | 单条记忆超长（如玩家粘贴大段文字） | 截断至 `MAX_SINGLE_MESSAGE_LENGTH`，末尾加「…」标记 |
| EC-03 | 即使只保留 L0 + L3 仍超出 token 限制 | 压缩 System Prompt（移除非核心描述），极端情况返回错误信号给 F5 |
| EC-04 | C5 性格值在对话中途变化 | 下次组装 context 时自动采用新值，不中断当前对话 |
| EC-05 | C7 查询超时或失败 | 降级为仅使用 L0 + 当前输入，记录警告日志，不阻塞对话 |
| EC-06 | 玩家当前输入包含与角色记忆矛盾的信息 | F6 不处理矛盾检测，交给 LLM 自行应对 |

## Dependencies

**上游依赖（F6 依赖这些系统）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| C5 性格变量系统 | 当前性格值、性格描述生成 | `C5.get_personality() → Dictionary`、`C5.get_personality_description() → String` |
| C6 关系值系统 | 三轴关系值、关系阶段描述 | `C6.get_relationship(axis) → float`、`C6.get_relationship_stage() → String` |
| C7 对话记忆库 | 近期完整对话、远期摘要 | `C7.get_recent_exchanges(n)`、`C7.get_summarized_memories()` |
| F5 Aria 接口层 | 当前玩家输入 | F5 调用 `F6.build_context(user_input) → Dictionary` |

**下游依赖（这些系统依赖 F6）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| F5 Aria 接口层 | 接收完整 context 发送给 LLM | 方法 `F6.build_context(user_input) → Dictionary` |

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|---------|------|
| `RECENT_EXCHANGES` | 10 轮 | 5–20 轮 | 保留的完整对话轮数；过多消耗 token，过少丢失上下文 |
| `MAX_CONTEXT_TOKENS` | 3000 | 2000–4000 | LLM 上下文总长度限制；需为 system prompt 和响应预留空间 |
| `MAX_SINGLE_MESSAGE_LENGTH` | 500 字 | 300–1000 字 | 单条消息截断长度；过长消息影响上下文多样性 |
| `PERSONALITY_FILTER_STRENGTH` | 1.5 | 1.0–2.0 | 性格滤镜的权重乘数；越高性格对记忆选择影响越大 |

## Formulas

### 1. Token 启发式估算 (Conservative Token Heuristic)

由于 GDScript 缺乏原生 Tiktoken，使用以下公式进行保守估算以防止 API 超载：

`Estimated_Tokens = (CJK_Chars * 1.5) + (ASCII_Words * 0.7)`

- `CJK_Chars`: 中日韩文字符数。
- `ASCII_Words`: 单词数（非空格字符块）。
- **安全边际**：计算结果向上取整，并额外保留 20% 的空白缓冲区供 LLM 生成回复。

### 2. 远期记忆权重评分 (Long-term Memory Scoring)

F6 从 C7 获取摘要后，按以下公式对摘要进行排序，决定哪些进入 Context：

`Score = (Recency_Weight * 0.4) + (Personality_Fit * 0.6)`

- `Recency_Weight`: `1.0 / (Days_Passed + 1)` (时间越近，分越高)。
- `Personality_Fit`: `1.0 + (Matching_Tags_Count * PERSONALITY_FILTER_STRENGTH)`。
- `Matching_Tags_Count`: 该记忆摘要的 `memory_tags` 与当前 C5 性格主导标签的匹配数量。

### 3. 上下文预算分配 (Context Budgeting)

在 `MAX_CONTEXT_TOKENS` 限制下，分配优先级如下：

1. **System Prompt**: 优先级 1 (必须完整保留，预计占 20-30%)
2. **当前输入 (Current Input)**: 优先级 1 (必须完整保留)
3. **近期历史 (L1 Recent)**: 优先级 2 (保留最近 `RECENT_EXCHANGES` 轮)
4. **远期摘要 (L2 Summaries)**: 优先级 3 (根据 Score 排序填充剩余空间)

### 4. 社交知识注入 (Social Knowledge Injection)

F6 根据 C8 的 Active List 注入 NPC 档案，控制 Token 消耗：

- **活跃 NPC (Full Profile)**: 注入 `[Name, Tags, Relationship_Description]`，每个 NPC 限 100 字符。角色能进行深度讨论。
- **非活跃 NPC (Snapshot)**: 仅在 System Prompt 补充一条：“除了好友，你还记得旧识 [Name]，但他最近出远门了/很久没联系了。”
- **话题拦截**: 若玩家询问未知 NPC，引导角色回应：“这名字听起来有点陌生，是我不认识的人吗？”

## Acceptance Criteria

| # | 测试条件 | 通过标准 |
|---|---------|----------|
| AC-01 | F5 调用 `build_context("你好")` | 返回包含 system prompt、空 messages 数组、当前输入的完整 context |
| AC-02 | C7 有 15 轮历史对话 | context 中 messages 包含最近 10 轮（`RECENT_EXCHANGES`），更早的以摘要形式出现在前面 |
| AC-03 | 高 `curiosity` 角色，C7 有知识类和情绪类摘要 | context 中知识类摘要排在情绪类之前（性格滤镜生效） |
| AC-04 | 总 token 数超出 `MAX_CONTEXT_TOKENS` | 从最早的历史对话开始丢弃，保留 system prompt 和当前输入 |
| AC-05 | C7 查询失败 | 返回仅包含 system prompt + 当前输入的降级 context，记录警告日志 |
| AC-06 | 玩家输入 1000 字 | 截断至 `MAX_SINGLE_MESSAGE_LENGTH`，末尾加「…」 |
| AC-07 | C5 性格值变化后 | 下次 `build_context` 自动采用新值 |

## Open Questions

| # | 问题 | 状态 | 备注 |
|---|------|------|------|
| OQ-01 | C7 的记忆摘要格式与生成策略 | ✅ 已对齐 | 详见 C7 设计文档 |
| OQ-02 | System Prompt 模板的完整内容 | 待叙事设计 | — |
| OQ-03 | token 计算方式 | ✅ 已解决 | 采用保守字符启发式算法 |
| OQ-04 | **[未来探索]** 向量检索记忆 | 远期 | — |
| OQ-05 | **[未来探索]** 时间衰减记忆 | 远期 | — |
| OQ-06 | **[未来探索]** 情绪标记优先 | 远期 | — |