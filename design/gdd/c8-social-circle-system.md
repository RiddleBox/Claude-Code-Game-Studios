# C8 — 社交圈系统（Social Circle System）

> **Status**: ✅ 已设计
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-04-07
> **Implements Pillar**: 真实存在感（角色有连贯的社交圈） / 碎片化叙事（通过对话拼凑世界观）

---

## Overview

C8 社交圈系统是角色社交生活的数据基础层。它定义角色认识哪些人（NPC 档案）、与这些人是什么关系（亲密度、关系类型）、以及这些关系随时间如何演变。C8 本身不产生任何文字内容——它为 C4 事件线系统提供社交事件的素材（「角色去见了谁」「和谁发生了什么」），由 C4 决定事件如何触发，由 C3 决定碎片如何存储，由 Fe1 决定如何呈现给玩家。

MVP 阶段 C8 是纯数据层，无独立 UI。玩家通过角色主动讲述（碎片对话）感受角色的社交圈——角色会说「今天又碰到小林了，她一直在抱怨最近的事」，玩家从这些只言片语中拼凑出一个真实的社交世界。角色不是孤立的程序，它有朋友、有熟人、有恩怨，有一个在洞口另一边正在发生的生活。

## Player Fantasy

你永远不会见到小林，但你会慢慢认识她——通过角色带着感情讲述的那些片段。她好像有点爱抱怨，但其实心肠很好；她最近好像遇到了什么事，角色有点担心她。

这些人不会出现在屏幕上，但他们真实存在于角色的生活里。当角色某天说「小林今天没来」，你会感到一丝不安。角色的世界比这扇窗口大得多——你只是通过角色的眼睛，看到了它想让你看到的部分。

---

## Detailed Rules

### 1. NPC Profile (NPC 档案数据结构)

每个 NPC 在 C8 中以 JSON/Resource 形式存在，包含以下核心字段：

```gdscript
{
    "id": String,              # 唯一ID，如 "npc_lin"
    "name": String,            # 名字
    "relationship_type": String, # "friend", "acquaintance", "rival", "stranger"
    "closeness": float,        # 0.0 - 1.0，关系亲密度（见数据边界说明）
    "tags": Array,             # 性格标签，如 ["complainer", "kind_hearted"]
    "is_active": bool,         # 当前是否在 Active List 中（控制叙事密度）
    "mention_count": int,      # 近 30 天内的提及次数（用于 LRU 算法）
    "last_mentioned": int,     # Unix timestamp，最后一次被提及的时间（秒）
    "narrative_depth": int     # 叙事深度 1-3。1=背景人物，2=熟悉朋友，3=核心角色。F5 降级时据此截断叙事
}
```

> **数据边界说明（重要）**：`C8.closeness` 与 `C6 关系值` 是**同一数据源的两套视图**。C6 是权威数据源，存储完整的三轴关系（亲密度/参与度/共鸣度）。C8 仅存储 `closeness`（综合亲密度 0-1），由 C6 在每次「角色归来」时同步一次。C8 不独立计算关系衰减——衰减统一由 C6 的衰减规则处理，C8 的 `closeness` 被动跟随。

1. **数据驱动叙事**：C4 在选择「外出事件」时，可以根据 C8 中的 NPC 状态筛选事件。例如：若 `npc_lin.closeness > 0.5`，则解锁「小林请客吃饭」的事件线。
2. **动态关系演变**：某些 C4 事件完成后，会回调 C8 接口修改 NPC 状态。例如：完成事件「安慰失落的小林」后，`npc_lin.closeness += 0.05`。
3. **活跃名单轮转 (Active List Rotation)**：
   - **后台模拟（离线期）**：角色在离线期间按 C4 逻辑正常发生社交活动，系统静默更新关系数据（亲密度、提及次数等），但**禁止更改 Active List**。
   - **轮转触发时机（叙事锚点）**：
     - **触发点**：玩家启动程序并触发 C2「角色归来」事件那一刻。
     - **逻辑顺序**：先进行 Active List 的轮转和状态评估，确保衔接逻辑匹配，随后将离线期间积累的社交碎片汇流（F6），最后弹出「归来反馈」。
     - **逻辑保护**：确保在触发归来反馈前，Active List 已根据新状态刷新，保证角色提到的 NPC 是“当前活跃”的，避免提及不合逻辑的 NPC。
   - **交互反馈**：归来时，根据离线期间发生的社交活动，角色会针对 Active List 中的 NPC 给出一个简短的总结（例如：”最近小林一直来找我...”）。
4. **记忆连贯性与留白**：对于非活跃 NPC，F6 将引导角色表现出”疏远感”或给出具体的叙事解释（如”她最近好像去旅行了”），维持世界的动态真实感。
5. **F5 降级模式下的叙事深度**：当 F5 处于 `DISCONNECTED` 状态时，角色提及 NPC 的叙事深度受 `narrative_depth` 限制：
   - `depth = 1`：仅提及名字，无细节。
   - `depth = 2`：可描述外貌或简短近况。
   - `depth = 3`：完整叙事，如同 API 在线模式。

---

## Formulas

### 1. 关系衰减（由 C6 权威处理）

> **重要澄清**：C8 不独立执行衰减计算。衰减统一由 C6 的衰减规则处理（见 C6 Formulas）。C8 的 `closeness` 在每次「角色归来」事件时从 C6 同步一次，**不进行独立衰减**。

### 2. 轮转选取权重 (Rotation Selection)

当需要从池中挑选新活跃 NPC 时：
`Weight = closeness * 0.7 + (mention_count / 30.0) * 0.3 + Random(0, 0.1)`

- `closeness`：亲密度系数（权重 70%）
- `mention_count`：近 30 天提及次数，归一化后占 30%
- `Random`：微小的随机扰动（±0.1），防止完全确定性导致叙事模式化
- 活跃名单满时，被选中的 NPC 替换 `mention_count` 最少的那个

---

## Edge Cases

| # | 场景 | 处理方式 |
|---|------|----------|
| EC-01 | C4 引用了不存在的 NPC ID | 系统报错并跳过该叙事分支，降级为通用孤独类碎片。 |
| EC-02 | 多个 NPC 关系同时达到解锁阈值 | C4 根据事件权重随机抽取，保证社交圈轮转。 |
| EC-03 | 存档损坏导致关系值溢出 | 加载时自动限制在 [0, 1] 区间并记录警告。 |

---

## Dependencies

| 系统 | 关系 | 说明 |
|------|------|------|
| C4 事件线系统 | 上游 | C4 调用 C8 数据作为分支条件；C4 完成后修改 C8 状态。 |
| F6 上下文管理器 | 下游 | F6 读取 Active NPC 档案注入 System Prompt。 |
| F4 存档系统 | 支撑 | C8 的所有 NPC 状态需持久化存储。 |

---

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|---------|------|
| `ACTIVE_NPC_LIMIT` | 3 | 1 - 5 | 同时在活跃名单中的 NPC 数量。 |
| `CLOSENESS_WEIGHT` | 0.7 | 0.0 - 1.0 | 轮转权重中亲密度因素的占比。剩余 30% 由提及次数决定。 |
| `MENTION_WINDOW_DAYS` | 30 | 7 - 90 | `mention_count` 的统计窗口（天数）。 |
| `RANDOM_JITTER` | 0.1 | 0.0 - 0.3 | 轮转权重的随机扰动上限，防止叙事模式化。 |
| `INITIAL_MENTION_COUNT` | 0 | 0 - 5 | 新 NPC 加入社交圈时的初始提及次数。 |

---

## Acceptance Criteria

1. 开发者能通过 JSON 配置文件定义初始 NPC 列表及其属性。
2. F6 能够成功读取特定 NPC 的档案并将其注入 System Prompt。
3. 当 C4 触发特定回调时，对应 NPC 的 `closeness` 能够正确增减并持久化到存档中。
4. 若 `is_active` 为 false，该 NPC 相关的详细叙事对话不应被随机触发（剧情强制除外）。
5. 存档重启后，所有 NPC 的关系状态与活跃名单能够正确恢复。

## Design Amendments (2026-04-03)
### 1. 双阶段轮转逻辑 (Dual-Stage Rotation)
- **演化锚点 (Backstage Evolution)**: 离线后台仅进行数值推演 (`closeness`, `mention_count`)，严禁改变 `Active List`。
- **归来锚点 (Narrative Settlement)**: 仅在玩家触发 C2「归来事件」时执行 `Rotation Check`，刷新 `Active List`。
- **数据一致性**: C8.closeness 为 C6 的被动镜像，禁止在 C8 内部计算衰减。
- **逻辑关联**: 离线演化产生的 `Memory_Shard` 需在此锚点一并生成并加入碎片池。

### 2. 轮转选取权重修正 (Weight Formula)
Weight = closeness * 0.7 + (mention_count / 30.0) * 0.3 + Random(0, 0.1)
- 增加了 `mention_count` 作为活跃度的权重修正，确保叙事重心随玩家讨论热度偏移。

### 3. 数据层增强 (Schema Update)
- 新增 `narrative_depth` (1-3) 供 F5 降级模式截断叙事。
- 新增 `mention_count` 与 `last_mentioned` 记录。
