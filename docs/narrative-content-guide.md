# 叙事内容配置指南

> **Created**: 2026-04-13  
> **For**: 窗语（Window Whisper）Sprint 4  
> **Purpose**: 指导叙事创作者配置事件线、分支事件和通用碎片

---

## 目录

1. [概述](#概述)
2. [文件结构](#文件结构)
3. [主干事件线配置](#主干事件线配置)
4. [分支事件配置](#分支事件配置)
5. [通用碎片配置](#通用碎片配置)
6. [性格权重说明](#性格权重说明)
7. [完整示例](#完整示例)

---

## 概述

窗语的叙事内容完全数据驱动，无需修改代码即可添加新内容。叙事系统由三层组成：

| 层级 | 用途 | 触发条件 |
|------|------|----------|
| **主干事件线** | 推进主线故事 | 碎片数 + 在线时长双条件 |
| **分支事件** | 日常小插曲 | 概率 + 冷却时间 |
| **通用碎片池** | 保底日常内容 | 始终可用 |

所有内容均支持**性格变体**，不同性格的角色会看到不同的叙事内容。

---

## 文件结构

叙事内容文件位于 `data/config/` 目录：

```
data/config/
├── personality_axes.json      # 性格轴定义（C5使用）
├── main_line.json             # 主干事件线
├── branch_events.json         # 分支事件池
└── general_fragments.json     # 通用碎片池
```

---

## 主干事件线配置

### 文件格式

`main_line.json` 定义线性推进的主线故事。

```json
{
  "line_id": "main_001",
  "nodes": [
    {
      "node_id": "ml_001_n1",
      "unlock_conditions": {
        "min_fragments": 0,
        "min_online_minutes": 0
      },
      "variants": [
        {
          "variant_id": "ml_001_n1_v1",
          "personality_weights": {
            "curiosity": 0.8,
            "boldness": 0.2
          },
          "fragments": [
            {
              "content_id": "ml_001_n1_v1_f1",
              "type": "dialogue",
              "text": "对话内容文本",
              "emotion_tag": "peaceful",
              "ref_id": ""
            }
          ]
        }
      ]
    }
  ]
}
```

### 字段说明

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `line_id` | String | 是 | 事件线唯一标识 |
| `nodes` | Array | 是 | 事件节点数组，按顺序推进 |
| `node_id` | String | 是 | 节点唯一标识 |
| `unlock_conditions` | Object | 是 | 解锁条件 |
| `min_fragments` | Int | 是 | 需要的最小碎片数 |
| `min_online_minutes` | Int | 是 | 需要的最小在线分钟数 |
| `variants` | Array | 是 | 性格变体数组 |
| `variant_id` | String | 是 | 变体唯一标识 |
| `personality_weights` | Object | 否 | 性格权重（见下文） |
| `fragments` | Array | 是 | 碎片数组 |
| `content_id` | String | 是 | 碎片唯一标识 |
| `type` | String | 是 | 碎片类型：dialogue/scene/object/emotion |
| `text` | String | 是 | 碎片文本内容 |
| `emotion_tag` | String | 是 | 情绪标签：peaceful/mystery/combat |
| `ref_id` | String | 否 | 引用其他碎片的ID（用于关联） |

### 添加新节点

在 `nodes` 数组末尾添加新节点：

```json
{
  "node_id": "ml_001_n3",
  "unlock_conditions": {
    "min_fragments": 10,
    "min_online_minutes": 120
  },
  "variants": [...]
}
```

---

## 分支事件配置

### 文件格式

`branch_events.json` 定义随机触发的日常小插曲。

```json
[
  {
    "event_id": "br_001",
    "trigger_weight": 1.0,
    "personality_weights": {
      "curiosity": 0.7,
      "boldness": 0.5
    },
    "variants": [...]
  }
]
```

### 字段说明

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `event_id` | String | 是 | 事件唯一标识 |
| `trigger_weight` | Float | 否 | 触发权重（默认1.0） |
| `variants` | Array | 是 | 同主干事件线的变体格式 |

### 触发权重

- `1.0` = 标准概率
- `>1.0` = 更易触发
- `<1.0` = 更难触发

### 冷却机制

- 分支事件触发后有 **60分钟冷却**
- 最近 **5个** 触发过的事件不会重复
- 滚动窗口，超过5个后旧事件重新可用

---

## 通用碎片配置

### 文件格式

`general_fragments.json` 定义保底的日常碎片。

```json
[
  {
    "content_id": "general_001",
    "type": "dialogue",
    "text": "碎片文本",
    "emotion_tag": "peaceful",
    "personality_weights": {}
  }
]
```

### 字段说明

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `content_id` | String | 是 | 碎片唯一标识 |
| `type` | String | 是 | 碎片类型 |
| `text` | String | 是 | 碎片文本 |
| `emotion_tag` | String | 是 | 情绪标签 |
| `personality_weights` | Object | 否 | 性格权重 |

### 使用建议

- 至少准备 **20条** 通用碎片
- 覆盖所有 `emotion_tag` 类型
- 内容应中立，不推进主线
- 允许重复出现（日常感来源）

---

## 性格权重说明

### 性格轴

| 轴ID | 0.0端 | 1.0端 | 默认值 |
|------|-------|-------|--------|
| `curiosity` | 淡漠 | 好奇 | 0.5 |
| `warmth` | 冷静 | 温暖 | 0.5 |
| `boldness` | 谨慎 | 大胆 | 0.5 |
| `melancholy` | 乐观 | 忧郁 | 0.5 |

### 权重规则

- 权重范围：`0.0` – `1.0`
- `0.0` = 此性格与该内容无关
- `1.0` = 此性格与该内容完全匹配
- 空对象 `{}` = 所有性格均匹配

### 评分公式

```
score = Σ ( personality[axis] × weight[axis] )
```

得分最高的变体被选中。

### 示例

**好奇型角色内容**：
```json
{
  "curiosity": 0.9,
  "boldness": 0.3
}
```

**温暖型角色内容**：
```json
{
  "warmth": 0.9,
  "melancholy": 0.1
}
```

---

## 完整示例

### 主干事件节点示例

```json
{
  "node_id": "ml_001_n2",
  "unlock_conditions": {
    "min_fragments": 3,
    "min_online_minutes": 30
  },
  "variants": [
    {
      "variant_id": "ml_001_n2_curious",
      "personality_weights": { "curiosity": 0.9 },
      "fragments": [
        {
          "content_id": "ml_001_n2_curious_f1",
          "type": "dialogue",
          "text": "「我又去了那条巷子，」它眼睛发亮，「门又关上了，但这次我在门口捡到了这个。」",
          "emotion_tag": "mystery",
          "ref_id": "ml_001_n1"
        }
      ]
    },
    {
      "variant_id": "ml_001_n2_warm",
      "personality_weights": { "warmth": 0.9 },
      "fragments": [
        {
          "content_id": "ml_001_n2_warm_f1",
          "type": "emotion",
          "text": "它犹豫了一下，说昨天路过那里的时候，好像听见有人在叫它的名字。",
          "emotion_tag": "peaceful",
          "ref_id": "ml_001_n1"
        }
      ]
    }
  ]
}
```

### 分支事件示例

```json
{
  "event_id": "br_stranger_encounter",
  "trigger_weight": 0.8,
  "personality_weights": { "boldness": 0.6 },
  "variants": [
    {
      "variant_id": "br_stranger_encounter_bold",
      "personality_weights": { "boldness": 0.9 },
      "fragments": [
        {
          "content_id": "br_stranger_encounter_bold_f1",
          "type": "scene",
          "text": "它说它插手了一件本来跟它没关系的事。说完补了一句：「但那时候不插手的话，后来会后悔的。」",
          "emotion_tag": "combat",
          "ref_id": ""
        }
      ]
    },
    {
      "variant_id": "br_stranger_encounter_cautious",
      "personality_weights": { "boldness": 0.1 },
      "fragments": [
        {
          "content_id": "br_stranger_encounter_cautious_f1",
          "type": "dialogue",
          "text": "「今天看到了一些不太好的事，」它摇摇头，「还好我绕开了。」",
          "emotion_tag": "peaceful",
          "ref_id": ""
        }
      ]
    }
  ]
}
```

---

## 创作建议

### 主线叙事

1. **节奏控制**：节点间隔建议 30-60 分钟
2. **碎片要求**：第一个节点设为 0，让玩家立即体验
3. **变体设计**：每个节点至少 2 个性格变体
4. **引用关联**：使用 `ref_id` 关联之前的碎片

### 分支事件

1. **数量**：至少 10 个分支事件
2. **多样性**：覆盖不同性格类型
3. **权重**：特别喜欢的事件可设为 1.5-2.0
4. **独立性**：分支事件不应依赖主线进度

### 通用碎片

1. **数量**：至少 20 条
2. **中立性**：内容不应推进故事
3. **覆盖面**：所有情绪标签都要有
4. **重复性**：允许重复出现（日常感）

---

## 验证清单

添加新内容后检查：

- [ ] 所有 `content_id` / `node_id` / `variant_id` 唯一
- [ ] JSON 格式正确（可用在线工具验证）
- [ ] 所有必需字段已填写
- [ ] 性格权重在 0.0-1.0 范围内
- [ ] 引用的 `ref_id` 确实存在（或为空）
- [ ] 文本没有硬编码的角色名（如有需要使用占位符）

---

## 下一步

- 阅读 [C3 碎片系统 GDD](../design/gdd/c3-fragment-system.md)
- 阅读 [C4 事件线系统 GDD](../design/gdd/c4-event-line-system.md)
- 阅读 [C5 性格变量系统 GDD](../design/gdd/c5-personality-variable-system.md)
