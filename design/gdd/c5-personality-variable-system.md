# C5 — 性格变量系统（Personality Variable System）

> **Status**: Approved
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-29
> **Implements Pillar**: 共鸣成长（角色性格受玩家影响产生内在变化）/ 真实存在感（角色有独特的性格表达）

## Overview

C5 性格变量系统是窗语角色「内在自我」的数学表示。它用一组连续数值轴（默认 4 条，数据驱动可扩展）描述角色当前的性格状态，并向所有需要感知性格的下游系统（Fe1、Fe2、Fe3、Fe4、F6、C7）提供统一的查询接口。C5 本身不产生任何视觉表现，不驱动任何动画或对话——它只是「角色是谁」这件事的数据层，其他系统根据这份数据决定「角色如何表达自己」。C5 也负责处理性格的渐变（共鸣成长触发的轴值变化），确保变化是连续的、不可察觉的微小漂移，而非跳变。所有轴的定义从外部配置文件读取，新增性格维度无需修改系统代码。

## Player Fantasy

玩家不会意识到「性格变量系统」的存在。他们感知到的是：一开始，它说话的方式总是带着点距离感，对什么都不太在意。但相处久了，它回应的语气变了——不是某一天突然变，是某个时刻玩家突然意识到：「它好像比以前更爱问问题了」。再想想，好像确实是，但不知道从什么时候开始的。玩家想不起来一个具体的转折点，因为根本没有——变化一直在发生，只是太慢了，慢到只能在回头看时才察觉。这种「渐渐变成了彼此的样子」的感觉，才是 C5 要制造的体验。玩家不需要知道 `curiosity` 从 0.42 涨到了 0.71，他们只需要感觉到：它变了，因为我们在一起。

## Data Format

### 轴定义配置文件 `data/personality_axes.json`

```json
[
  {
    "id": "curiosity",
    "low_label": "淡漠",
    "high_label": "好奇",
    "default": 0.5,
    "display_name": "好奇心"
  },
  {
    "id": "warmth",
    "low_label": "冷静",
    "high_label": "温暖",
    "default": 0.5,
    "display_name": "温度"
  },
  {
    "id": "boldness",
    "low_label": "谨慎",
    "high_label": "大胆",
    "default": 0.5,
    "display_name": "胆量"
  },
  {
    "id": "melancholy",
    "low_label": "乐观",
    "high_label": "忧郁",
    "default": 0.5,
    "display_name": "情绪底色"
  }
]
```

*新增性格维度只需在此文件添加条目，系统自动支持，代码层无需修改。*

### C5 运行时数据结构

```gdscript
# 性格状态（Dictionary，键为轴 id）
personality: {
    "curiosity":  float,   # 0.0 – 1.0
    "warmth":     float,
    "boldness":   float,
    "melancholy": float,
    # 未来新轴自动加入
}

# 轴元数据（从配置文件加载）
axes_meta: [
    {
        "id": String,
        "low_label": String,
        "high_label": String,
        "default": float,
        "display_name": String,
    },
    ...
]
```

**F4 存档键**：`c5.personality`（存储 personality Dictionary）

### 内容条目的性格权重字段

下游内容数据规范，供 Fe1/Fe2 内容文件使用：

```json
{
  "content_id": "leak_001",
  "text": "...",
  "personality_weights": {
    "curiosity":  0.8,
    "warmth":     0.0,
    "boldness":   0.3,
    "melancholy": 0.0
  }
}
```

权重表示「此内容对高该轴值角色的适配程度」，0.0 = 无关，1.0 = 强匹配。评分公式见 Downstream Interface 节。

## Detailed Design

## Detailed Design

### Core Rules

**初始化**

1. C5 在 `_ready()` 时从配置文件加载轴元数据（`personality_axes.json`），确定轴列表和各轴 `default` 值。
2. 随后从 F4 读取 `c5.personality`。若存档存在，用存档值覆盖默认值；若不存在（首次运行），使用各轴 `default` 值初始化。
3. 存档中存在但配置文件中已删除的轴，静默忽略（向前兼容）。存档中不存在但配置文件新增的轴，使用该轴 `default` 值（向后兼容）。

**数值约束**

4. 所有轴值严格约束在 `[0.0, 1.0]` 闭区间，所有写入操作自动 clamp。
5. 轴值以 `float` 存储，精度保留至小数点后 4 位。

**性格变化（Shift）**

6. 唯一修改轴值的方式是调用 `shift(axis_id: String, delta: float)`。外部系统**禁止直接写入** `personality` 字典。
7. 单次 `shift` 调用的 `delta` 绝对值不得超过 `MAX_SHIFT_PER_CALL`（默认 0.05）。超出时 C5 自动截断至上限并记录警告日志。此规则从系统层面防止性格跳变。
8. MVP 阶段，`shift` 的调用方为 C7（共鸣成长系统）。C7 未就绪时，C5 仍接受 `shift` 调用（供调试和测试使用）。
9. 每次 `shift` 完成后，C5 发出信号 `personality_shifted(axis_id: String, old_val: float, new_val: float, delta: float)`，并将新值持久化到 F4。

**持久化**

10. 每次 `shift` 后立即调用 `F4.save("c5.personality", personality)`（单次写入，性格变化频率低，无需批量）。

### Downstream Interface

C5 暴露以下接口供下游系统调用：

```gdscript
# 读取单轴值
get(axis_id: String) -> float

# 读取全部轴值（返回 Dictionary 副本，禁止直接修改）
get_all() -> Dictionary

# 内容评分（核心接口）
# 传入内容条目的 personality_weights 字典，返回该内容与当前性格的匹配分
score_content(weights: Dictionary) -> float

# 性格变化（唯一写入入口）
shift(axis_id: String, delta: float) -> void

# 展示用软标签（仅供 UI 使用，不参与系统逻辑）
get_display_label() -> String
```

**内容评分公式**（`score_content`）：

```
score = Σ ( personality[axis_id] × weights[axis_id] )
        对所有在 weights 中定义的 axis_id 求和
```

用途：Fe2、Fe1 等系统对候选内容池中每条内容调用此接口，取得 score 后排序，选出最高分内容展示。不同性格的角色因各轴值不同，对同一内容库产生不同的排序结果，从而看到不同的内容。score 的绝对值无意义，仅用于相对排序。

示例（角色 `curiosity=0.8, boldness=0.7`，内容权重 `curiosity=0.9, boldness=0.6`）：
```
score = 0.8 × 0.9 + 0.7 × 0.6 = 0.72 + 0.42 = 1.14
```

### Display Labels

`get_display_label()` 逻辑：找到偏离中值（0.5）最大的轴，按偏离方向返回该轴的 `low_label` 或 `high_label`。全部轴接近 0.5 时返回默认描述「平静」。

```gdscript
func get_display_label() -> String:
    var max_deviation = 0.0
    var label = "平静"
    for axis_id in personality:
        var val = personality[axis_id]
        var deviation = abs(val - 0.5)
        if deviation > max_deviation:
            max_deviation = deviation
            var meta = get_axis_meta(axis_id)
            label = meta.high_label if val > 0.5 else meta.low_label
    return label
```

仅用于 UI 展示（如 P2 碎片日志顶部的角色性格描述），不参与任何游戏逻辑判断。

### Interactions with Other Systems

| 系统 | 方向 | 交互方式 | 说明 |
|------|------|----------|------|
| **F4** 存档系统 | C5 ↔ F4 | `load("c5.personality")` / `save("c5.personality", ...)` | 启动时恢复，每次 shift 后持久化 |
| **C7** 共鸣成长系统 | C7 → C5 | 调用 `shift(axis_id, delta)` | C5 的唯一数据写入来源；MVP 阶段 C7 未就绪时 shift 接口供调试调用 |
| **Fe2** 泄漏内容系统 | Fe2 → C5 | 调用 `score_content(weights)` 对候选内容排序 | Fe2 每次抽取泄漏内容时对候选池打分；C5 未就绪时 Fe2 使用随机选取降级 |
| **Fe1** 对话系统 | Fe1 → C5 | 调用 `score_content(weights)` / `get_all()` | Fe1 根据性格选择对话变体；MVP 阶段 Fe1 未设计，接口预留 |
| **Fe3** 情绪表达系统 | Fe3 → C5 | 调用 `get_all()` | Fe3 根据性格轴值决定情绪表达倾向；未设计，接口预留 |
| **Fe4** 互动反馈系统 | Fe4 → C5 | 调用 `get_all()` | Fe4 根据性格决定互动反馈风格；未设计，接口预留 |
| **F6** Aria 接口层 | F6 → C5 | 调用 `get_all()` 构建 System Prompt | F6 将性格数值转化为角色描述文字注入 Prompt；未设计，接口预留 |
| **C7** 共鸣成长系统 | C5 → C7 | 信号 `personality_shifted` | C7 可订阅此信号做成长记录（可选） |
| **P2/P3** UI 系统 | UI → C5 | 调用 `get_display_label()` / `get_all()` | P2 展示角色性格描述；UI 不参与任何逻辑判断 |

**初始化顺序约束**：C5 必须在 F4 发出 `save_system_ready` 后完成初始化。Fe2 等下游系统在调用 `score_content` 前应确认 C5 已就绪（通过 Godot autoload 顺序保证）。

## Edge Cases

1. **`shift` 传入不存在的 `axis_id`**：静默忽略，写入警告日志。防止未来配置文件删除某轴时旧调用崩溃。
2. **`shift` delta 超过 `MAX_SHIFT_PER_CALL`**：截断至上限，写入警告日志，继续执行（不拒绝调用）。
3. **配置文件 `personality_axes.json` 缺失或格式错误**：使用硬编码的 4 轴默认定义启动，写入错误日志。游戏不崩溃。
4. **`score_content` 传入的 weights 包含不存在的 axis_id**：跳过该轴，只对已知轴求和。不报错。
5. **`score_content` 传入空 weights 字典**：返回 0.0。
6. **所有轴值均为 0.5（全平衡状态）**：`get_display_label()` 返回「平静」，`score_content` 正常工作（全轴中性权重）。
7. **F4 存档中的性格值超出 `[0.0, 1.0]`**（存档损坏）：读取时 clamp 修正，写入警告日志。

## Dependencies

| 系统 | 类型 | 说明 |
|------|------|------|
| F4 存档系统 | 硬依赖 | C5 无法在 F4 就绪前完成初始化 |
| `personality_axes.json` 配置文件 | 硬依赖 | 定义轴结构；缺失时降级为硬编码默认值 |

## Tuning Knobs

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `MAX_SHIFT_PER_CALL` | 0.05 | 单次 shift 最大 delta，防止跳变 |
| 各轴 `default` 值 | 0.5 | 在 `personality_axes.json` 中配置，首次运行初始值 |
| `DISPLAY_LABEL_THRESHOLD` | 0.0 | 偏离中值超过此值才显示非默认标签（默认 0.0 = 任何偏离都显示）；可调高让「平静」范围更大 |

## Acceptance Criteria

- [ ] 首次运行时所有轴初始化为 `personality_axes.json` 中的 `default` 值
- [ ] 重启游戏后性格数值与关闭前一致（F4 持久化正常）
- [ ] `shift("curiosity", 0.1)` 后 `curiosity` 值正确增加，触发 `personality_shifted` 信号
- [ ] `shift` delta 超过 0.05 时自动截断，不崩溃
- [ ] `shift` 后轴值不超出 `[0.0, 1.0]`（clamp 生效）
- [ ] `score_content` 返回值与手算公式结果一致
- [ ] `get_display_label()` 返回偏离最大轴的对应标签
- [ ] `personality_axes.json` 新增一条轴后，C5 自动支持，代码无需修改
- [ ] 配置文件缺失时游戏不崩溃，使用硬编码默认值启动

## Open Questions

- [ ] **初始性格设定**：首次运行时各轴是否全部从 0.5 开始，还是由角色设计决定不同初始值？（建议角色设计阶段在 `personality_axes.json` 的 `default` 字段配置，C5 无需修改）
- [ ] **C7 共鸣成长触发时机**：C7 未设计，C5 只预留 `shift` 接口。C7 设计时需决定：何种玩家行为触发成长，触发频率，每次 shift 的典型 delta 大小。
- [ ] **多角色支持**：当前 C5 只管理单个角色的性格。若未来支持多角色，`personality` 需从单字典改为按角色 ID 索引的嵌套字典。MVP 阶段不考虑，但架构上注意不要硬编码「只有一个角色」。
