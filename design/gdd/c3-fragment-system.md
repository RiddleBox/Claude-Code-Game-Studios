# C3 — 碎片系统（Fragment System）

> **Status**: Approved
> **Author**: Claude Code Game Studios
> **Last Updated**: 2026-03-29
> **Implements Pillar**: 窥视感（叙事碎片化暗示）/ 真实存在感（角色有自己的生活）

## Overview

C3 碎片系统是窗语叙事内容的核心容器。它负责接收、存储和索引角色在外出归来时带回的「碎片」——这些碎片是叙事内容的最小单元，可以是一句话、一个场景片段、一件物件的描述，或一段情绪印象。C3 不产生碎片内容本身（内容由叙事/设计决定），也不负责碎片的展示（Fe1 对话系统负责），它只是碎片的「图书馆」：接收入库、分类存储、按需查询、持久化到 F4 存档。C3 维护每条碎片的元数据（类型、来源事件、获取时间、已读状态），并向 Fe1、P2 等下游系统提供结构化的查询接口。

## Data Format

### FragmentPayload（C2 传入格式）

C2 在 `return_completed` 信号中传递的碎片数组，每个元素为：

```gdscript
{
    "content_id": String,   # 内容标识符，对应叙事内容（MVP 阶段手动编写）
    "type": String,          # 碎片类型："dialogue" / "scene" / "object" / "emotion"
    "text": String,          # 显示文本
    "emotion_tag": String,   # 情绪标签，对应 Fe2："combat" / "funny" / "mystery" / "peaceful"
    "ref_id": String,        # 可选关联 ID，MVP 阶段为 ""，未来关联物品/事件
}
```

### FragmentRecord（C3 内部存储格式）

C3 在 FragmentPayload 基础上追加元数据后存储：

```gdscript
{
    "id": String,            # C3 生成的唯一 ID，格式 "frag_001"（全局自增）
    "content_id": String,   # 来自 FragmentPayload
    "type": String,          # 来自 FragmentPayload
    "text": String,          # 来自 FragmentPayload
    "emotion_tag": String,   # 来自 FragmentPayload
    "ref_id": String,        # 来自 FragmentPayload，MVP 阶段为 ""
    "acquired_at": int,      # Unix 时间戳（F3 提供）
    "outing_id": String,     # 哪次外出带回，格式 "outing_001"（C2 提供）
    "is_read": bool,         # 是否已被玩家查看，默认 false
}
```

### 碎片类型说明

| 类型 | 含义 | 示例文本 |
|------|------|----------|
| `dialogue` | 对话片段，听到或参与的只言片语 | 「他说：等你的人已经不在了。然后就走了。」 |
| `scene` | 场景印象，看到的地方或发生的事 | 「那条街道的尽头有一盏灯，一直亮着，没有人在灯下。」 |
| `object` | 物件描述，找到或见到的东西 | 「一枚硬币，正面是某个陌生人的侧脸，背面什么也没有。」 |
| `emotion` | 情绪印象，难以言说的感受 | 「有一刻我突然觉得，那里的时间和这里流得不一样。」 |

---

## Player Fantasy

玩家感知到的不是「碎片系统」，而是：每次角色归来，都像是朋友出差回来讲故事。不是一篇完整的游记，而是一些零零散散的、讲到一半就停下来的片段——「我今天碰到一个很奇怪的人，他说……算了，反正你不认识他」「那边的天空颜色很奇怪，我试着拍下来但拍不了」。

碎片不是奖励，不是等级提升，不是收集品——它是拼图，但玩家永远不确定这个拼图有没有完整的图案。每一块碎片单独看不完整，但多了之后，玩家会开始在脑子里自动连线，感觉自己正在慢慢理解那个世界、理解这个角色。这种「越看越懂但永远没有答案」的感觉，才是碎片系统要制造的体验。

有时候回顾早期碎片，会发现原来某个细节早就埋下了——不是设计上的刻意提示，而是因为玩家自己读懂了更多上下文之后，旧碎片的含义变了。碎片库不只是历史记录，它是会「成长」的：同样的文字，在不同的时间点读，感受不同。

## Detailed Design

### Core Rules

**接收规则**

1. C3 订阅 C2 的 `return_completed(fragments: Array, outing_id: String)` 信号。收到后，遍历数组，将每个 FragmentPayload 转换为 FragmentRecord 并入库。
2. C3 不校验碎片内容合法性（text 是否为空等），内容正确性由叙事/设计阶段保证。C3 只做格式转换和入库。
3. `id` 由 C3 自增生成，格式 `frag_{n:03d}`（`frag_001`, `frag_002`……），全局唯一，不因游戏重启重置。
4. `acquired_at` 由 C3 在入库时调用 F3 的当前时间戳，不使用 C2 传入的时间（保证时间来源一致）。
5. `is_read` 入库时默认 `false`。

**存储规则**

6. 所有 FragmentRecord 存储在内存 `Dictionary`（键为 `id`）中，游戏启动时从 F4 读取，每次写入后同步持久化到 F4（`c3.fragments` 键）。
7. C3 额外维护一个辅助计数器 `c3.fragment_counter`，用于生成下一个 `id`。
8. C3 不限制碎片总数量上限（由存档文件大小自然约束）。

**查询接口**

9. C3 暴露以下只读接口：
   - `get_all() -> Array[FragmentRecord]` — 返回全部碎片，按 `acquired_at` 降序
   - `get_unread() -> Array[FragmentRecord]` — 返回所有 `is_read == false` 的碎片
   - `get_by_type(type: String) -> Array[FragmentRecord]` — 按类型筛选
   - `get_by_outing(outing_id: String) -> Array[FragmentRecord]` — 按外出批次查询
   - `get_latest(n: int) -> Array[FragmentRecord]` — 返回最新 n 条
   - `mark_read(fragment_id: String) -> void` — 标记为已读，并写入 F4

**信号**

10. C3 在入库完成后发出 `fragments_received(fragment_ids: Array[String])` — P1 浮层提示、Fe1 等可订阅此信号。

### States and Transitions

C3 是无状态服务（图书馆模式），本身不驱动状态机。但每条 FragmentRecord 有两个状态维度：

**碎片生命周期**

```
[不存在]
    │ C2 发出 return_completed
    ▼
[已入库 · 未读]  is_read = false
    │ Fe1/P2 调用 mark_read()
    ▼
[已入库 · 已读]  is_read = true
```

状态不可逆：已读不能重置为未读（防止重复推送通知）。

**系统初始化状态**

```
[未初始化]
    │ _ready() 调用，从 F4 加载 c3.fragments 和 c3.fragment_counter
    ▼
[就绪]  ← 正常运行状态，可接收 C2 信号，可响应查询
```

F4 不可用时（首次运行，存档为空）：`c3.fragments = {}`, `c3.fragment_counter = 0`，正常进入就绪状态。

### Interactions with Other Systems

| 系统 | 方向 | 交互方式 | 说明 |
|------|------|----------|------|
| **C2** 外出-归来循环 | C2 → C3 | 信号 `return_completed(fragments: Array, outing_id: String)` | C3 的唯一数据入口 |
| **F3** 时间/节奏系统 | C3 → F3 | 调用 `F3.get_current_timestamp()` | 入库时获取 `acquired_at`，保证时间来源一致 |
| **F4** 存档系统 | C3 ↔ F4 | `load("c3.fragments")` / `save_batch({"c3.fragments": ..., "c3.fragment_counter": ...})` | 启动时恢复，每次入库/mark_read 后持久化 |
| **Fe1** 对话系统 | C3 → Fe1 | 信号 `fragments_received`；Fe1 调用 `get_latest()` / `mark_read()` | Fe1 订阅信号后主动拉取并展示碎片 |
| **P1** 主界面 UI | C3 → P1 | 信号 `fragments_received` | P1 订阅后触发归来碎片提示浮层 |
| **P2** 碎片日志 UI | C3 → P2 | P2 调用 `get_all()` / `get_unread()` / `mark_read()` | P2 展示完整碎片库，玩家主动触发 |

**初始化顺序约束**：C3 必须在 F4 发出 `save_system_ready` 信号后才开始加载数据。其他系统（Fe1、P2）必须在 C3 就绪后才可调用查询接口（通过 Godot autoload 顺序或 `await` 保证）。

## Formulas

C3 无复杂公式，仅 ID 生成：

```
fragment_id = "frag_" + str(c3.fragment_counter).pad_zeros(4)
c3.fragment_counter += 1
```

计数器上限理论值为 9999（四位数），实际游戏中不会触达；若未来需要可扩展位数。

## Edge Cases

1. **C3 未就绪时 C2 发出 `return_completed`**：C3 通过 `await F4.save_system_ready` 保证就绪前不接收信号。若 C2 信号在 C3 就绪前触发（极端启动时序），碎片丢失并写入警告日志。MVP 阶段可接受（概率极低）。

2. **`fragments` 数组为空**：正常处理，`fragments_received` 不发出（无碎片无需通知）。

3. **`fragments` 数组包含重复 `content_id`**：不去重，按原样入库——同一内容可多次获得（不同外出带回同一类型碎片是合法叙事状态）。

4. **F4 存档中 `c3.fragments` 数据损坏/格式错误**：捕获异常，`c3.fragments = {}`、`c3.fragment_counter = 0` 重新开始，写入错误日志。不崩溃，不影响其他系统。

5. **`mark_read` 传入不存在的 `fragment_id`**：静默忽略，写入警告日志。不抛出异常。

6. **存档极大（碎片数量非常多）**：C3 不做分页，全量加载。若未来成为性能瓶颈，可在 P2 UI 层做懒加载，C3 接口本身不变。

7. **`outing_id` 为空字符串**：合法，不做强制校验。MVP 阶段 C2 始终提供 `outing_id`，若未来 C2 设计变更导致缺失，C3 接受并存储空字符串。

## Dependencies

| 系统 | 类型 | 说明 |
|------|------|------|
| F4 存档系统 | 硬依赖 | C3 无法在 F4 就绪前工作 |
| F3 时间/节奏系统 | 硬依赖 | 入库时获取时间戳 |
| C2 外出-归来循环 | 数据来源 | C3 的唯一数据入口 |

## Tuning Knobs

| 参数 | 默认值 | 范围 | 说明 |
|------|--------|------|------|
| `FRAGMENTS_PER_OUTING_MIN` | 1 | 1-3 | 每次归来最少碎片数 |
| `FRAGMENTS_PER_OUTING_MAX` | 1 | 1-3 | 每次归来最多碎片数（MVP 默认与 MIN 相同，后期测试调高） |

*注：实际碎片数量由 C2 决定并传入，C3 不主动控制数量，此参数供 C2 参考。*

## Acceptance Criteria

- [ ] 游戏启动后，历史碎片从 F4 正确恢复，数量与内容与存档一致
- [ ] C2 发出 `return_completed` 后，碎片正确入库，`fragments_received` 信号发出
- [ ] 新入库碎片 `is_read = false`，`acquired_at` 为正确时间戳，`id` 格式正确且唯一
- [ ] `mark_read()` 调用后，碎片 `is_read` 变为 `true` 且持久化到 F4
- [ ] F4 存档损坏时，C3 以空库启动，不崩溃
- [ ] `get_all()` 返回结果按 `acquired_at` 降序排列
- [ ] `get_unread()` 只返回未读碎片

## Open Questions

- [x] **C4 事件线系统**：`content_id` 格式已确定为 `[line_id]_[node_id]_[variant_id]_[fragment_index]`，如 `ml_001_n1_v1_f1`（主干）或 `br_001_v1_f1`（分支）。通用碎片池格式待 C4 内容创作阶段确认。
- [x] **碎片内容来源**：碎片文本存放在 C4 管理的独立叙事数据文件中（`main_line.json`、`branch_events.json`、`general_fragments.json`），由 C4 选取后经 C2 的 `return_completed` 信号传递给 C3。C2 不持有任何叙事内容。
- [ ] **`ref_id` 物品系统**：`object` 类型碎片的 `ref_id` 关联物品系统，该系统当前无规划，MVP 阶段留空，后续按需扩展。
