# Fe4 — 共鸣成长系统（Resonance Growth System）

> **Status**: In Design
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-04-02
> **Implements Pillar**: 性格即命运（玩家行为塑造角色性格） / 共鸣成长（深层关系驱动性格位移）

---

## Overview

Fe4 共鸣成长系统是《窗语》的情感闭环。它负责根据 C6 记录的「玩家参与度数据」，在每次角色归来（C2）或深度对话（F5）后，微调 C5 中的「性格变量」。这不仅是数值的漂移，更通过 F6 影响未来的对话内容，从而实现“相处久了，它变得越来越像你，或者越来越懂你”的陪伴感。

Fe4 的核心挑战是**维持性格连贯性**：性格的改变必须是缓慢、可预测且具有惯性的。它不应该因为玩家一两次的突发行为而剧烈跳变，而是像水滴石穿一样，在数十小时的陪伴中悄然发生。

## Player Fantasy

最初，它只是一个有着固定性格的小人。你喜欢追问，它就慢慢变得博学；你总是温柔地听它倾诉，它就变得更愿意袒露脆弱。

某一天，它在对话中突然说出了一句你曾经说过的话，或者用你习惯的方式去思考一个新问题。那一刻，你意识到它不再是一个冷冰冰的程序，而是你在这段关系中亲手雕琢出的、独一无二的灵魂。这种“共鸣”带来的成就感，远超任何数值奖励。

---

## Detailed Rules

### 1. 漂移计算触发 (Drift Trigger)

- **常规漂移**：在 C2 外出归来结算时触发，基于本次外出期间所有碎片的展示/参与情况。
- **深度漂移**：在 F5 Aria 交互完成后触发，仅针对当前对话涉及的性格标签。

### 2. 性格惯性与步长 (Inertia & Step Limit)

- **性格惯性**：性格轴值越接近极端（0.0 或 1.0），继续向该方向偏移的阻力越大。
- **单次步长限制**：单次归来结算产生的性格总位移不得超过 `DRIFT_CAP`。

### 3. 反馈循环 (Feedback Loop)

- 当任意性格轴累计漂移量达到 `RECOGNITION_THRESHOLD` (0.1) 时，C4 系统将解锁一条专有的「觉醒对话」，角色会主动提到自己的改变（如：“我发现最近和你聊多了，我也变得……”）。

---

## Formulas

### 1. 性格位移公式 (Personality Drift)

`Drift_Delta = (Target_Value - Current_Value) * Resonance * Inertia_Factor * DRIFT_RATE`

- `Target_Value`: 由 C6 提供的玩家偏好目标（0.0-1.0）。
- `Resonance`: C6 中的共鸣度值，作为位移的倍率（共鸣越高，受影响越快）。
- `DRIFT_RATE`: 全局漂移速率系数。

### 2. 性格惯性因子 (Inertia Factor)

`Inertia_Factor = 1.0 - (abs(Current_Value - 0.5) * 2 * INERTIA_STRENGTH)`

- **解释**：当 `Current_Value` 处于 0.5（性格中性）时，因子为 1.0；当接近 0 或 1 时，因子趋近于 0（即很难再改变）。

---

## Edge Cases

| # | 场景 | 处理方式 |
|---|------|----------|
| EC-01 | 玩家行为极度矛盾（忽冷忽热） | `Target_Value` 在中点波动，`Drift_Delta` 极小，性格保持稳定。 |
| EC-02 | 剧情强制修改性格 (C4 override) | 优先执行剧情修改，Fe4 漂移在此基础上继续累加。 |
| EC-03 | 多个轴同时达到漂移阈值 | 优先触发偏移量最大的轴对应的觉醒对话，其余排队。 |

---

## Dependencies

| 系统 | 关系 | 说明 |
|------|------|------|
| C5 性格变量系统 | 核心 | Fe4 修改的目标数据层。 |
| C6 关系值系统 | 数据源 | Fe4 读取 C6 的参与度数据作为 `Target_Value`。 |
| C4 事件线系统 | 反馈 | Fe4 触发 C4 的觉醒对话。 |

---

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|---------|------|
| `DRIFT_RATE` | 0.005 | 0.001–0.02 | 基础漂移速度。 |
| `INERTIA_STRENGTH` | 0.8 | 0.0–1.0 | 接近极端值时的阻力强度。 |
| `DRIFT_CAP` | 0.02 | 0.01–0.05 | 单次归来结算的最大位移限制。 |
| `RECOGNITION_THRESHOLD`| 0.1 | 0.05–0.2 | 触发觉醒对话所需的性格位移量。 |

---

## Acceptance Criteria

1. 玩家长期偏好某种话题（如好奇类），`curiosity` 轴值应在多次归来后呈现明显的正向增长。
2. 随着轴值接近 1.0，相同互动强度下产生的位移量应明显递减（惯性生效）。
3. 当性格漂移达到 0.1 时，系统能正确触发对应的 C4 觉醒对话碎片。
4. 存档保存并重启后，累计的漂移趋势不会丢失或重置。

## Design Amendments (2026-04-03)

### 1. 二元成长驱动公式 (Dual-Driver Growth)
Growth = ∫ (T_online * Base_Rate + Σ Interactivity_Score) dt
- T_online: 在线活跃时长
- Base_Rate: 基础陪伴积累速率（受 C6 关系等级影响，呈边际递减）
- Interactivity_Score: 基于高质量交互的动态评分（触发复杂 AI 分支、情感呼应）。

### 2. 性格折射机制 (Player Mirroring & Drift)
- **Style Mirroring (话术模仿)**: F6 通过 C7 的 `Player_Style_Mirror` 分区，动态提取玩家用词习惯。Fe4 等级每升一级，Style Mirroring 权重提升 15%。
- **Personality Drift (性格同化)**: 当共鸣值达到高位 (Level 3+) 时，触发性格漂移。系统严格遵循“折射原则”：在 C5 性格底色上微调视角，而非改变核心性格标签。

### 3. 成长等级与 AI 映射 (AI Context Depth)
- **Level 1**: 基础互动，AI 知识库读取量受限。
- **Level 2**: 解锁主动提问与关联话题。
- **Level 3**: 解锁镜像机制 (Mirroring)，AI 对话深度与记忆容量提升。

## Design Amendments (2026-04-03)
- **回溯逻辑**: 成长计算仅计算在线时长，离线时间产出 `Memory_Shard` 但不直接转化为 Fe4 数值。
- **动态调节**: Mirroring 权重在对话过程中根据共鸣等级动态调节。

## Dependencies
- C6: 关系等级提升速率控制。
- F6: 实现风格折射与 Prompt 注入。
