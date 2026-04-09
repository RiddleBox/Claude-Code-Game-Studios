# Fe4 — 共鸣成长系统（Resonance Growth System）

> **Status**: ✅ 已设计
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-04-07
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

- 当任意性格轴累计漂移量达到 `RECOGNITION_THRESHOLD` (0.1) 时，C4 系统将解锁一条专有的「觉醒对话」，角色会主动提到自己的改变（如：”我发现最近和你聊多了，我也变得……”）。

### 4. 共鸣成长的价值体现 (Value of Resonance Growth)

共鸣成长值 (Resonance Level) 直接影响角色的交互深度和行为复杂度：

1. **认知升级 (Cognitive Upgrade)**：共鸣等级越高，F6 系统提示词 (System Prompt) 的深度和广度越大。等级 1 可能仅能记住最近 5 条对话，等级 3 可以关联 30 天内的记忆碎片。
   
2. **动作响应集 (Action Unlock)**：
   - Level 1：基础状态动作（发呆、微笑、打哈欠）
   - Level 2：解锁环境互动（根据天气/时间做动作，如雨天看窗外）
   - Level 3：解锁主动关怀动作（玩家长时间不操作时主动问候）
   
3. **归来反应强度 (Return Sensitivity)**：共鸣等级越高，角色对玩家归来的感知越敏锐，反应差异度越大。内敛角色可能表现为眼神更亮，外向角色则可能直接欢呼。

4. **AI 对话深度映射 (AI Context Depth Mapping)**：
   | 等级 | 话题范围 | 记忆容量 | 主动提问 | 风格模仿 |
   |------|----------|----------|----------|----------|
   | 1 | 基础日常 | 5 条对话 | 从不 | 无 |
   | 2 | 扩展社交 | 20 条对话 | 偶尔 | 10% 权重 |
   | 3 | 深度情感 | 50+ 条对话 | 频繁 | 25% 权重 |

5. **性格轴漂移加速 (Personality Drift Acceleration)**：共鸣等级作为倍率因子参与性格漂移公式，等级越高，相同互动质量下性格变化越快（但仍受惯性保护）。

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

### 3. 归来反应强度公式 (Return Reactivity Formula)

`Intensity = Resonance_Level * (1 + ln(Idle_Time_Hours / 24)) * Character_Sentiment_Weight`

- `Resonance_Level`：共鸣成长等级（1-3+），等级越高对玩家归来越敏感
- `Idle_Time_Hours`：离线时长（小时），对数函数防止超长离线时间过度影响
- `Character_Sentiment_Weight`：性格情感权重（内敛角色≈0.7，外向角色≈1.3）
- **结果应用**：`Intensity > 2.0` 触发热情反应，`1.0 < Intensity ≤ 2.0` 触发中性反应，`Intensity ≤ 1.0` 触发疏远反应

### 4. 离线时间与角色独立演化 (Offline Evolution)

离线时间产生 **角色独立演化**，与 **共鸣成长** 严格区分：

`Offline_Event_Count = floor(min(Idle_Time_Days, Max_Evolution_Cap) * Generation_Factor)`

- `Max_Evolution_Cap`：最大演化事件数（默认 3），防止信息过载
- `Generation_Factor`：生成因子（默认 0.5，每 2 天可能产生 1 个经历）
- **产出**：`Offline_Event_Count` 个"离线经历"存入 C7 的 `Offline_Narrative_History` 分区
- **与共鸣成长关系**：离线经历**不直接**贡献共鸣值，但提供日常对话素材，增加世界真实感

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
| F6 角色上下文管理器 | 实现 | Fe4 通过 F6 实现风格模仿和 AI 深度控制。 |
| C7 对话记忆库 | 存储 | Fe4 离线经历存储在 `Offline_Narrative_History` 分区。 |

---

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|---------|------|
| `DRIFT_RATE` | 0.005 | 0.001–0.02 | 基础漂移速度。 |
| `INERTIA_STRENGTH` | 0.8 | 0.0–1.0 | 接近极端值时的阻力强度。 |
| `DRIFT_CAP` | 0.02 | 0.01–0.05 | 单次归来结算的最大位移限制。 |
| `RECOGNITION_THRESHOLD`| 0.1 | 0.05–0.2 | 触发觉醒对话所需的性格位移量。 |
| `MAX_EVOLUTION_CAP` | 3 | 1–5 | 单次归来最大离线经历生成数量。 |
| `GENERATION_FACTOR` | 0.5 | 0.1–1.0 | 离线经历生成频率（事件/天）。 |
| `CHAR_SENTIMENT_INTERNAL` | 0.7 | 0.5–0.9 | 内敛角色的归来反应权重。 |
| `CHAR_SENTIMENT_EXTROVERT` | 1.3 | 1.1–1.5 | 外向角色的归来反应权重。 |

---

## Acceptance Criteria

1. 玩家长期偏好某种话题（如好奇类），`curiosity` 轴值应在多次归来后呈现明显的正向增长。
2. 随着轴值接近 1.0，相同互动强度下产生的位移量应明显递减（惯性生效）。
3. 当性格漂移达到 0.1 时，系统能正确触发对应的 C4 觉醒对话碎片。
4. 存档保存并重启后，累计的漂移趋势不会丢失或重置。
5. 共鸣成长等级应正确解锁对应的 AI 认知深度、动作集和记忆容量（见 AI 能力映射表）。
6. 归来反应强度应随共鸣等级、离线时长、性格权重正确计算，内敛和外向角色表现出差异化反应。
7. 离线时间应生成 `Offline_Event_Count` 个经历存储到 C7 的 `Offline_Narrative_History`，但不贡献共鸣成长值。
8. 风格模仿权重应随成长等级提升（每级 +15%），并在对话中体现"折射而非拷贝"原则。

## Design Amendments (2026-04-07)

### 1. 二元成长驱动公式 (Dual-Driver Growth)
`Growth = ∫ (T_online × Base_Rate + Σ Interactivity_Score) dt`

- `T_online`: 在线活跃时长（挂机时间）
- `Base_Rate`: 基础陪伴积累速率（受 C6 关系等级影响，呈边际递减）
- `Interactivity_Score`: 交互质量评分（高质量交互如情感共鸣、复杂话题得高分）
- **设计原则**：区分"挂机时长"和"高质量互动"，鼓励深度交流

### 2. 性格变化的三层体现 (Three-Layer Personality Change)

#### 表层：语言风格模仿 (Surface: Style Mirroring)
- **机制**：F6 通过 C7 的 `Player_Style_Mirror` 分区提取玩家用词习惯
- **权重**：Fe4 每升一级，模仿权重提升 15%
- **折射原则**：在角色性格底色 (C5) 上过滤和折射，非简单复制

#### 中层：行为模式调整 (Middle: Behavior Pattern Adjustment)
- **机制**：Fe4 成长等级解锁行为复杂度
- **体现**：Level 1→基础动作，Level 2→环境互动，Level 3→主动关怀
- **性格轴影响**：`外向性`高的角色解锁更多社交动作

#### 深层：性格内核漂移 (Deep: Personality Core Drift)
- **机制**：Fe4 漂移公式 `Drift_Delta = (Target_Value - Current_Value) × Resonance × Inertia_Factor × DRIFT_RATE`
- **变化幅度**：害羞角色 `外向性` 可从 0.2→0.6（适度开朗）
- **惯性保护**：防止角色失去核心特质（极端值变化阻力大）

### 3. 离线时间与角色独立演化 (Offline Time & Autonomous Evolution)
- **离线产出**：`Offline_Event_Count` 个"经历"存入 C7 `Offline_Narrative_History`
- **与共鸣成长区分**：离线经历**不贡献**共鸣值，但提供对话素材
- **归来反应**：通过 `归来反应强度公式` 计算上线时的情绪反应

### 4. 成长等级与 AI 能力映射 (AI Capability Mapping)
| 等级 | 认知升级 | 动作解锁 | 记忆容量 | 风格模仿 |
|------|----------|----------|----------|----------|
| 1 | 基础日常话题 | 基础状态动作 | 5 条对话 | 无 |
| 2 | 扩展社交话题 | 环境互动动作 | 20 条对话 | 10% 权重 |
| 3 | 深度情感话题 | 主动关怀动作 | 50+ 条对话 | 25% 权重 |

### 5. 归来反应差异化 (Differentiated Return Reactions)
- **公式**：`Intensity = Resonance_Level × (1 + ln(Idle_Time/24)) × Character_Sentiment_Weight`
- **性格影响**：内敛角色（权重≈0.7）表现为眼神变化，外向角色（权重≈1.3）可能直接欢呼
- **共鸣等级影响**：等级越高，对玩家归来越敏感，反应差异越大

