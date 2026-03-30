# C4 — 事件线系统（Event Line System）

> **Status**: Approved
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-29
> **Implements Pillar**: 真实存在感（角色有自己的故事）/ 窥视感（世界在向前推进）

## Overview

C4 事件线系统是游戏叙事内容的结构层。它管理两类事件：**主干事件线**（Main Line）和**分支事件**（Branch Events）。主干事件线是一条线性推进的故事主轴，由若干节点组成，每个节点在玩家满足双条件（累计碎片数 + 在线时长）后解锁，通过 C2 外出循环将对应叙事内容带给玩家，让玩家感知「世界在向前推进」。分支事件是一个并行运转的小事件池，在外出期间以概率随机触发，制造日常感和角色形象的立体感。两类事件的内容均为数据驱动（JSON 文件），C4 不生产内容，只负责：判断触发条件、选择事件、将事件数据传递给 C2、记录推进状态并持久化。所有事件内容针对 C5 性格轴设计多套变体，C4 通过 `C5.score_content()` 选出最匹配当前角色性格的变体，确保同一事件在不同性格角色身上产生不同的叙事表现。

## Player Fantasy

玩家有两种截然不同的叙事感受，都由 C4 驱动：

其一是「世界感」——角色带回的碎片开始有了联系。某个名字出现了第二次，某件之前提过的事有了后续，某个地方发生了变化。玩家不需要主动追踪，但当这种连续感出现时，会有一种「哦，原来上次那件事是这样的」的惊喜感。世界不是静态的背景板，它有自己的时间轴，在玩家看与不看之间继续运转。

其二是「日常感」——除了大事件，还有无数小插曲。今天碰到了一个奇怪的人，昨天走错了路，发现了一个意外的地方。这些小事和角色的性格配合，让玩家慢慢读出：「它就是这样的一个家伙」——不是通过角色介绍，而是通过它做了什么、怎么反应、留下了什么只言片语。

## Data Format

### 主干事件节点 `data/main_line.json`

```json
{
  "line_id": "main_001",
  "nodes": [
    {
      "node_id": "ml_001_n1",
      "unlock_conditions": {
        "min_fragments": 3,
        "min_online_minutes": 30
      },
      "variants": [
        {
          "variant_id": "ml_001_n1_v1",
          "personality_weights": { "curiosity": 0.8, "boldness": 0.2 },
          "fragments": [
            {
              "content_id": "ml_001_n1_v1_f1",
              "type": "scene",
              "text": "它回来时神情有些飘忽，说在某条巷子里看见了一扇从来没开过的门，今天开着。",
              "emotion_tag": "mystery",
              "ref_id": ""
            }
          ]
        },
        {
          "variant_id": "ml_001_n1_v2",
          "personality_weights": { "warmth": 0.8, "melancholy": 0.3 },
          "fragments": [
            {
              "content_id": "ml_001_n1_v2_f1",
              "type": "dialogue",
              "text": "「那里的人今天都在说同一件事，」它停顿了一下，「但我没听完。」",
              "emotion_tag": "mystery",
              "ref_id": ""
            }
          ]
        }
      ]
    }
  ]
}
```

### 分支事件 `data/branch_events.json`

```json
[
  {
    "event_id": "br_001",
    "trigger_weight": 1.0,
    "personality_weights": { "curiosity": 0.7, "boldness": 0.5 },
    "variants": [
      {
        "variant_id": "br_001_v1",
        "personality_weights": { "boldness": 0.9 },
        "fragments": [
          {
            "content_id": "br_001_v1_f1",
            "type": "scene",
            "text": "它说它插手了一件本来跟它没关系的事。说完补了一句：「但那时候不插手的话，后来会后悔的。」",
            "emotion_tag": "combat",
            "ref_id": ""
          }
        ]
      },
      {
        "variant_id": "br_001_v2",
        "personality_weights": { "melancholy": 0.8, "warmth": 0.4 },
        "fragments": [
          {
            "content_id": "br_001_v2_f1",
            "type": "emotion",
            "text": "它看起来有点心不在焉。问它怎么了，它说没事，就是在想某件很久以前的事。",
            "emotion_tag": "peaceful",
            "ref_id": ""
          }
        ]
      }
    ]
  }
]
```

### C4 运行时状态（F4 存档键）

```gdscript
{
  "c4.main_line_progress": {
    "current_node_index": int,   # 当前已解锁到第几个节点（0-based）
    "completed": bool            # 主干事件线是否全部完成
  },
  "c4.branch_cooldown": int,     # 上次分支事件触发的时间戳
  "c4.used_branch_events": Array[String]  # 已触发过的 event_id（防短期重复）
}
```

## Detailed Design

### Core Rules

1. C4 在 `_ready()` 时从 F4 加载运行时状态，并从数据文件加载 `main_line.json`、`branch_events.json` 和 `general_fragments.json`。
2. C4 不主动驱动任何循环——它只响应 C2 的请求。C2 在决定外出前调用 C4 的 `get_outing_content() -> Array[FragmentPayload]` 接口获取本次外出内容。
3. C4 采用**三层互斥**内容选取逻辑，优先级从高到低：主干事件 → 分支事件 → 通用碎片池。每次外出恰好由一个来源产出碎片，不叠加。
4. 变体选择统一使用 `C5.score_content(weights)` 打分，取最高分变体。若所有变体得分相同（性格全平衡），取第一个变体。
5. C4 在每次内容选取结束后，将运行时状态持久化到 F4。

### Main Line Events

6. C4 维护 `current_node_index`，表示当前待触发的主干节点索引（从 0 开始）。
7. 每次 `get_outing_content()` 调用时，C4 首先检查主干条件（主干未完成时）：
   - `C3.get_all().size() >= node.unlock_conditions.min_fragments`
   - `F3.get_total_online_minutes() >= node.unlock_conditions.min_online_minutes`
8. 双条件均满足时，**触发主干节点**：用 `C5.score_content` 从节点 variants 中选最佳变体，返回其碎片数组。`current_node_index += 1`，若已超出节点总数则 `completed = true`。
9. 主干触发后，**直接返回**，不检查分支和通用池（互斥规则）。

### Branch Events

10. 主干未触发时，C4 检查分支事件触发条件：
    - 距上次分支事件触发时间超过 `BRANCH_COOLDOWN_MINUTES`（默认 60 分钟）
    - 随机概率 `BRANCH_TRIGGER_CHANCE`（默认 40%）通过
11. 两个条件均满足时，从分支事件池中选取事件：
    - 过滤掉 `used_branch_events` 滚动窗口（最近 `BRANCH_REPEAT_WINDOW` 个，默认 5）中的事件
    - 对剩余候选用 `C5.score_content(event.personality_weights)` 打分，取最高分事件
    - 再从该事件的 variants 中用 `C5.score_content` 选最佳变体
12. 分支触发后，更新 `used_branch_events` 和 `branch_cooldown`，**直接返回**，不检查通用池（互斥规则）。
13. 分支候选全部在窗口内被过滤时，跳过分支，继续检查通用池。

### General Fragment Pool

14. 主干和分支均未触发时，C4 从通用碎片池（`general_fragments.json`）中选取 1 条：
    - 用 `C5.score_content(fragment.personality_weights)` 打分，取最高分
    - 通用碎片无冷却、无条件，**必定成功**（保底）
15. 通用碎片池是无叙事依赖的日常碎片，不推进任何故事状态，不记录使用历史（允许重复，日常感即来自于此）。

### Event Resolution

`get_outing_content()` 完整执行流程：

```
1. 检查主干条件
   ├─ 满足 → 选最佳主干变体 → 返回碎片数组（结束）
   └─ 不满足 ↓

2. 检查分支条件（冷却 + 概率）
   ├─ 满足 → 过滤已用 → 选最佳分支事件 + 变体 → 返回碎片数组（结束）
   └─ 不满足（或候选被全部过滤）↓

3. 通用池保底
   └─ 选最高分通用碎片 → 返回单条碎片数组（结束）
```

返回格式统一为 `Array[FragmentPayload]`，C2 不需要感知来源层级，直接将数组传递给 C3 的 `return_completed` 信号。

### Interactions with Other Systems

| 系统 | 方向 | 交互方式 | 说明 |
|------|------|----------|------|
| **C2** 外出-归来循环 | C2 → C4 | 调用 `get_outing_content() -> Array[FragmentPayload]` | C2 每次外出前询问内容；C4 是 C2 的内容提供者 |
| **C3** 碎片系统 | C4 → C3 | 通过 C2 间接传递（C2 将 C4 返回的数组放入 `return_completed` 信号） | C4 不直接调用 C3；数据流：C4 → C2 → C3 |
| **C5** 性格变量系统 | C4 → C5 | 调用 `C5.score_content(weights)` | 选取主干变体、分支事件、分支变体、通用碎片均使用此接口 |
| **F3** 时间/节奏系统 | C4 → F3 | 调用 `F3.get_total_online_minutes()` | 检查主干节点时间解锁条件 |
| **F4** 存档系统 | C4 ↔ F4 | `load` / `save_batch` | 启动时加载运行时状态，每次内容选取后持久化 |

**初始化顺序约束**：C4 必须在 F4、C3、C5 均就绪后才能响应 C2 的请求。C2 在外出触发前调用 C4，故 C4 的就绪时机早于第一次外出触发即可。

## Edge Cases

1. **通用池为空**：C4 记录错误日志，返回空数组。C2 收到空数组时进行无内容外出（角色外出归来无碎片）。这是内容配置错误，不应在正式版出现。
2. **主干节点数据文件缺失或格式错误**：跳过主干检查，记录错误日志，继续检查分支和通用池。不崩溃。
3. **主干所有节点均已完成（`completed = true`）**：跳过主干检查，正常执行分支/通用逻辑。主干完成后游戏继续，靠分支和通用池维持日常循环。
4. **C5 未就绪时 `score_content` 调用失败**：降级为取第一个变体（index 0），记录警告日志。
5. **分支事件 variants 只有一个**：`score_content` 正常执行，取唯一变体。无问题。
6. **主干解锁条件设置为 `min_fragments: 0, min_online_minutes: 0`**：游戏启动后第一次外出即触发主干第一节点。合法（适用于调试或特殊设计意图）。
7. **F4 存档中 `current_node_index` 超出当前 `main_line.json` 节点总数**（内容更新后节点减少）：C4 将 `completed` 设为 `true`，记录警告日志，不崩溃。

## Dependencies

| 系统 | 类型 | 说明 |
|------|------|------|
| F4 存档系统 | 硬依赖 | 运行时状态持久化 |
| F3 时间/节奏系统 | 硬依赖 | 主干时间解锁条件 |
| C3 碎片系统 | 软依赖 | 读取碎片总数用于主干解锁条件；C3 未就绪时降级为仅检查时间条件 |
| C5 性格变量系统 | 软依赖 | 内容选取评分；C5 未就绪时降级为取第一变体 |

## Tuning Knobs

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `BRANCH_TRIGGER_CHANCE` | 0.40 | 分支事件触发概率（每次外出，主干未触发时） |
| `BRANCH_COOLDOWN_MINUTES` | 60 | 分支事件最短触发间隔（分钟） |
| `BRANCH_REPEAT_WINDOW` | 5 | 滚动窗口大小，防止分支事件短期重复 |
| 主干各节点 `unlock_conditions` | 见数据文件 | 碎片数和在线时长双阈值，在 `main_line.json` 中配置 |

## Acceptance Criteria

- [ ] 首次运行时主干从第 0 个节点开始，双条件满足后第一次外出触发主干节点
- [ ] 主干触发时不触发分支和通用池（互斥）
- [ ] 分支触发时不触发通用池（互斥）
- [ ] 主干和分支均未触发时，通用池必定返回 1 条碎片
- [ ] `C5.score_content` 评分最高的变体被选中（手算验证）
- [ ] 主干推进状态重启后正确恢复（F4 持久化正常）
- [ ] 分支冷却和已用列表重启后正确恢复
- [ ] 主干全部完成后，后续外出走分支/通用逻辑，不崩溃
- [ ] 分支候选全部在滚动窗口内时，跳过分支走通用池

## Open Questions

- [ ] **玩家互动记忆**：玩家对分支事件的评价/对话形成「独属记忆」，这部分功能由 C7 对话记忆库实现。C4 的分支事件数据格式是否需要预留 `interaction_hook` 字段供未来接入？建议 C7 设计时反向确认。
- [ ] **主干事件线内容**：MVP 阶段需要设计 1 条完整主干事件线（5-8 个节点），内容创作不在 C4 系统设计范围内，需单独规划叙事创作任务。
- [ ] **通用碎片池容量**：MVP 阶段建议至少 20 条通用碎片，覆盖四种 emotion_tag，避免高频重复感。
- [ ] **主干完成后的体验**：主干全部完成后游戏依赖分支和通用池维持，长期体验是否足够？DLC 扩展新事件线是预设方向，但需评估单条主干的内容量是否支撑足够的初始游戏时长。
