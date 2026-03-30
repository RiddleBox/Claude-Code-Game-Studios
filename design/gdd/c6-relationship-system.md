# C6 — 关系值系统（Relationship System）

> **Status**: In Design
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-30
> **Implements Pillar**: 共鸣成长（关系深度驱动叙事解锁与性格漂移）/ 真实存在感（关系是真实互动的积累）

---

## Overview

C6 关系值系统是窗语游戏中「玩家与角色之间历史」的量化层。它用三条独立的关系轴描述这段关系走到了哪里：熟悉感（`familiarity`）——相处时长带来的自然亲近；信任感（`trust`）——角色愿意分享、玩家认真倾听的积累；共鸣度（`resonance`）——深层对话带来的心灵连接。

C6 的核心职责有两个：（1）追踪玩家对不同性格标签内容的参与比例（`engagement_ratio`），作为 Fe4 共鸣成长系统计算性格漂移方向的原始数据；（2）向 C4 事件线系统暴露当前关系值，作为叙事内容解锁的门控条件。C6 本身不计算性格如何变化，那是 Fe4 的职责——C6 只诚实记录「玩家做了什么」。

三条轴的值均从外部配置文件读取初始定义，数据驱动设计允许未来新增关系维度而无需修改系统代码。

## Player Fantasy

玩家不会看到一个「关系值：47/100」的进度条。

他们感知到的是：某一天，角色带回来的故事开始变得不一样了——不再是走马观花的见闻，而是「我今天碰到一件事，突然想到你，你上次说的那句话……」。内容变了，不是因为解锁了什么成就，而是因为关系走到了那里。

还有一种更细微的感知：角色慢慢变得有点像你。不是刻意模仿，而是相处久了自然发生的那种——你总爱追问奇怪问题，它也开始变得更爱问；你总是很平静地听完，它也越来越愿意把话说完整。玩家不知道这是算法，只感觉「它懂我了」。

## Data Format

### 关系轴配置文件 `data/relationship_axes.json`

```json
[
  {
    "id": "familiarity",
    "display_name": "熟悉感",
    "default": 0.0,
    "description": "相处时长带来的自然亲近"
  },
  {
    "id": "trust",
    "display_name": "信任感",
    "default": 0.0,
    "description": "角色分享、玩家倾听的积累"
  },
  {
    "id": "resonance",
    "display_name": "共鸣度",
    "default": 0.0,
    "description": "深层对话带来的心灵连接"
  }
]
```

*新增关系维度只需在此文件添加条目，系统自动支持。*

### C6 运行时数据结构

```gdscript
# 关系轴当前值（Dictionary，键为轴 id）
relationship: {
    "familiarity": float,   # 0.0 – 1.0
    "trust":       float,
    "resonance":   float,
}

# 玩家参与度追踪（用于 Fe4 计算漂移方向）
# 键为 C5 性格轴 id，值为 {shown: int, completed: int}
engagement: {
    "curiosity":  {"shown": int, "completed": int},
    "warmth":     {"shown": int, "completed": int},
    "boldness":   {"shown": int, "completed": int},
    "melancholy": {"shown": int, "completed": int},
}
```

**F4 存档键**：
- `c6.relationship`（关系轴当前值）
- `c6.engagement`（参与度追踪数据）

## Detailed Design

### Core Rules

> ⚠️ **待深入研究**：本节数值和机制为初稿，需在原型阶段结合实际游戏体验仔细调校。

**基本职责**

1. C6 是关系值和参与度数据的唯一持有者，不允许其他系统直接修改这两份数据。
2. C6 不计算性格漂移，不直接修改 C5——它只暴露数据接口，Fe4 负责消费。
3. 关系轴值范围严格限制在 [0.0, 1.0]，超出范围时钳制，不报错。
4. 参与度数据（`engagement`）只增不减——`shown` 和 `completed` 均为累计计数，不随时间衰减。
5. 关系轴值同样只增不减——关系不会因为玩家不在线而衰减（MVP 阶段；未来可配置衰减）。
6. 所有写入操作完成后立即同步持久化到 F4。

**关系轴积累**

7. `familiarity` 通过 F3 tick 和日常互动点击积累。
8. `trust` 通过 Fe1 碎片完整展示后积累（玩家读完整个序列，不中途关闭）。
9. `resonance` 通过 F5 Aria 互动积累（每次完整的 Aria 交互结束后）。
10. 日常互动点击（P1 角色点击）积累 `familiarity`，但每日上限为 `DAILY_CLICK_CAP` 次（防止刷点击）。

**参与度追踪**

11. 每次 Fe1 展示一条碎片时，C6 将对应碎片的 `personality_tag` 的 `shown` 计数 +1。
12. 玩家完整读完该碎片（Fe1 发出 `fragment_completed` 信号）时，`completed` 计数 +1。
13. Aria 互动结束时，F5 传递本次对话涉及的 `personality_tags` 列表，C6 将这些标签的 `completed` 各 +1（Aria 互动不区分 shown/completed，直接计入 completed）。

### Accumulation Rules

> ⚠️ **待深入研究**：下表所有数值为占位初稿，需原型验证后调整。

| 行为 | 影响轴 | 单次增量 | 上限/节奏 |
|------|--------|---------|----------|
| F3 每分钟 tick | `familiarity` | `FAMILIARITY_TICK_RATE`（默认 0.0001） | 无单次上限，自然积累 |
| 玩家点击角色 | `familiarity` | `FAMILIARITY_CLICK_RATE`（默认 0.001） | 每日上限 `DAILY_CLICK_CAP`（默认 20次） |
| Fe1 碎片序列完整读完 | `trust` | `TRUST_FRAGMENT_RATE`（默认 0.005） | 每次归来最多计算一次 |
| F5 Aria 交互完成 | `resonance` | `RESONANCE_ARIA_RATE`（默认 0.01） | 每次 Aria 交互计算一次 |

## Formulas

> ⚠️ **待深入研究**：以下公式为初稿框架，系数需原型验证后调整。

### 公式一：参与比例计算

```
engagement_ratio(axis) = completed(axis) / max(shown(axis), 1)
```

| 变量 | 含义 | 范围 |
|------|------|------|
| `completed(axis)` | 玩家完整参与该性格标签内容的次数 | ≥ 0 |
| `shown(axis)` | 该标签内容被展示的总次数 | ≥ 0 |
| `engagement_ratio` | 参与比例 | 0.0–1.0 |

**示例**：curiosity 标签内容展示了 15 次，玩家完整读完 12 次：
`engagement_ratio("curiosity") = 12 / 15 = 0.80`

---

### 公式二：关系轴积累（familiarity，tick 驱动）

```
familiarity += FAMILIARITY_TICK_RATE × delta_minutes
familiarity = clamp(familiarity, 0.0, 1.0)
```

**示例**：在线 100 分钟，FAMILIARITY_TICK_RATE = 0.0001：
`familiarity += 0.0001 × 100 = 0.01`
→ 满值（1.0）需约 10,000 分钟在线（约 167 小时）

---

### 公式三：Fe4 使用的漂移方向向量（C6 暴露接口，Fe4 计算）

```
drift_target(axis) = engagement_ratio(axis)
drift_delta(axis)  = (drift_target - current_personality(axis))
                     × resonance
                     × DRIFT_RATE
```

| 变量 | 含义 | 范围 |
|------|------|------|
| `drift_target` | 玩家行为偏好指向的性格目标值 | 0.0–1.0 |
| `current_personality(axis)` | C5 当前性格轴值 | 0.0–1.0 |
| `resonance` | C6 共鸣度，越高漂移越快 | 0.0–1.0 |
| `DRIFT_RATE` | 全局漂移速率系数（待定） | 建议 0.001–0.01 |
| `drift_delta` | 本次漂移量（由 Fe4 应用到 C5） | 小数值 |

**示例**：curiosity 参与率 0.80，当前性格值 0.42，resonance 0.6，DRIFT_RATE 0.005：
`drift_delta = (0.80 - 0.42) × 0.6 × 0.005 = 0.00114`

## Edge Cases

| # | 场景 | 处理方式 |
|---|------|----------|
| EC-01 | 某性格标签从未展示过（`shown == 0`） | `engagement_ratio` 返回 0.0（分母用 `max(shown, 1)` 防止除零）；Fe4 不对该轴产生漂移 |
| EC-02 | `completed > shown`（异常数据） | 钳制 `engagement_ratio` 到 1.0，不报错；记录警告日志 |
| EC-03 | 关系轴值已达 1.0，继续积累 | 钳制在 1.0，不溢出；积累行为仍照常发生（不影响参与度追踪） |
| EC-04 | 玩家同一天点击角色超过 `DAILY_CLICK_CAP` 次 | 超出部分不计入 `familiarity` 积累，静默忽略 |
| EC-05 | F4 读取 engagement 数据失败 | 重置为全零，从头开始追踪；关系轴值同样重置（存档损坏时的安全降级） |
| EC-06 | C5 新增性格轴但 C6 engagement 无对应键 | C6 在下次写入时自动补全新轴的 `{shown:0, completed:0}`，不崩溃 |

## Dependencies

**上游依赖（C6 依赖这些系统）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| F3 时间/节奏系统 | 每分钟 tick 驱动 familiarity 积累 | 信号 `tick(current_timestamp, delta_minutes)` |
| F4 存档系统 | 关系值与参与度数据读写 | `F4.get/set("c6.relationship")`、`F4.get/set("c6.engagement")` |
| Fe1 对话系统 | 碎片展示/完成事件 | 信号 `fragment_shown(fragment_id, personality_tag)`、`fragment_completed(fragment_id, personality_tag)` |
| F5 Aria 接口层 | Aria 交互完成事件及涉及的性格标签 | 信号 `aria_interaction_completed(personality_tags: Array)` |
| P1 主界面 UI | 角色点击事件 | 信号 `character_clicked` |

**下游依赖（这些系统依赖 C6）**

| 系统 | 依赖内容 | 接口 |
|------|---------|------|
| C4 事件线系统 | 读取关系轴值作为内容解锁门控 | 方法 `C6.get_relationship(axis) → float`、`C6.get_all_relationships() → Dictionary` |
| Fe4 共鸣成长系统 | 读取参与比例和共鸣度计算性格漂移 | 方法 `C6.get_engagement_ratio(axis) → float`、`C6.get_relationship("resonance") → float` |

## Tuning Knobs

> ⚠️ 所有数值为待研究的占位初稿。

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|---------|------|
| `FAMILIARITY_TICK_RATE` | 0.0001 / 分钟 | 0.00005–0.001 | familiarity 满值所需在线时长（默认约 167 小时） |
| `FAMILIARITY_CLICK_RATE` | 0.001 / 次 | 0.0005–0.005 | 点击互动对 familiarity 的贡献 |
| `DAILY_CLICK_CAP` | 20 次 | 10–50 | 防止点击刷关系值的每日上限 |
| `TRUST_FRAGMENT_RATE` | 0.005 / 次归来 | 0.001–0.02 | 碎片完整展示对 trust 的贡献 |
| `RESONANCE_ARIA_RATE` | 0.01 / 次交互 | 0.005–0.05 | Aria 交互对 resonance 的贡献 |
| `DRIFT_RATE` | 0.005 | 0.001–0.01 | Fe4 计算性格漂移的全局速率系数 |

## Acceptance Criteria

| # | 测试条件 | 通过标准 |
|---|---------|----------|
| AC-01 | 游戏在线 100 分钟 | `familiarity` 增加约 0.01（±10% 误差以内） |
| AC-02 | 玩家点击角色 20 次（当日上限） | `familiarity` 增加 0.02；第 21 次点击无效果 |
| AC-03 | Fe1 完整展示一次归来碎片序列 | `trust` 增加 0.005；engagement 对应标签 `completed` +1 |
| AC-04 | Fe1 展示碎片但玩家中途关闭 | `trust` 不增加；`shown` +1，`completed` 不变 |
| AC-05 | F5 完成一次 Aria 交互，涉及 curiosity 标签 | `resonance` 增加 0.01；engagement `curiosity.completed` +1 |
| AC-06 | 关系轴值达到 1.0 后继续触发积累行为 | 轴值保持 1.0，不溢出 |
| AC-07 | F4 读取失败（模拟损坏） | 所有关系值和参与度重置为 0，不崩溃 |
| AC-08 | C5 新增一个性格轴后首次启动 | C6 engagement 自动补全新轴条目，值为 `{shown:0, completed:0}` |

## Open Questions

| # | 问题 | 状态 |
|---|------|------|
| OQ-01 | 所有积累速率数值需原型阶段实际游玩后调校 | 待研究 |
| OQ-02 | 关系值是否应该随长期不活跃缓慢衰减？衰减速率如何设计？ | 待定 |
| OQ-03 | C4 解锁门控的具体阈值（如 trust ≥ 0.3 才解锁某事件线）在 C4 文档中定义，C6 不持有 | 待 C4 扩展 |
| OQ-04 | 是否需要向玩家以某种隐晦方式呈现关系深度（如角色表情微变化、背景细节变化） | 待美术/叙事方向确认 |