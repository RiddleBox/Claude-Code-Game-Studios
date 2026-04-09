# ADR-002: C8 社交圈系统的离线模拟方案 (Local Backtrack Simulation for Offline Social Evolution)

## 状态 (Status)

**Accepted** (已接受)

## 背景 (Context)

在《窗语》的 C8 社交圈系统中，需要实现角色在玩家离线期间的社交活动模拟，以维持叙事连贯性和世界真实感。然而，作为一个本地桌面应用，没有后端服务器持续运行程序来驱动实时模拟。需要一种在不占用系统资源的情况下，让角色在离线期间“似乎”在进行社交活动的方法。

核心矛盾：
1. **叙事需求**：角色应有连贯的社交生活，玩家上线时应能感受到角色在离线期间的变化
2. **技术限制**：本地应用无法在程序关闭时进行计算
3. **用户体验**：不应依赖常驻后台进程或消耗系统资源

## 决策 (Decision)

采用 **本地回溯模拟 (Local Backtrack Simulation)** 方案，即“时间锚点回溯模拟”。

### 实现方案

1. **时间锚点记录**：
   - 程序退出时，记录 `last_exit_time` (Unix timestamp) 到存档
   - 程序启动时，获取 `current_time`

2. **快进式模拟**：
   - 计算 `time_diff = current_time - last_exit_time`
   - 根据离线时长，按预设频率计算理论上应发生的社交事件数量：
     - 例如：每 4 小时可能发生 1 个社交事件
     - `event_count = floor(time_diff / (4 * 3600))`

3. **确定性随机**：
   - 使用存档中的 `random_seed` 结合 `last_exit_time` 生成确定性随机序列
   - 确保每次重新计算离线事件时，结果一致（避免因计算时机不同产生差异）

4. **叙事锚点整合**：
   - 离线期间仅更新 C8 数值数据（亲密度、提及次数等），**禁止修改 Active List**
   - 在 C2「角色归来」事件触发时：
     a. 先完成 Active List 的轮转计算
     b. 再将离线期间“模拟”的社交活动转化为对话碎片（F6）
     c. 最后弹出归来反馈

5. **扩展性设计**：
   - 抽象模拟接口 `ISocialSimulator`
   - 本地实现 `LocalBacktrackSimulator`（当前采用）
   - 未来可扩展 `ServerBasedSimulator`（如果添加后端服务）

### 接口定义

```gdscript
# ISocialSimulator (接口)
func simulate_offline_period(start_time: int, end_time: int) -> Array[SocialEvent]
func get_event_frequency() -> float  # 返回事件/秒的频率
func set_random_seed(seed: int) -> void

# LocalBacktrackSimulator (具体实现)
func _init(random_seed: int):
    # 初始化确定性随机生成器

func simulate_offline_period(start_time: int, end_time: int) -> Array[SocialEvent]:
    var time_diff = end_time - start_time
    var event_count = floor(time_diff * get_event_frequency())
    var events = []
    
    for i in range(event_count):
        var event_time = start_time + (i * (1.0 / get_event_frequency()))
        var event = _generate_deterministic_event(event_time, i)
        events.append(event)
    
    return events
```

## 理由 (Consequences)

### 正面影响
- **零运行时开销**：程序关闭时不消耗任何系统资源
- **叙事连贯性**：玩家上线时能感受到角色在离线期间的生活变化
- **确定性**：使用种子确保计算结果一致，避免存档不一致问题
- **实现简单**：相比系统级后台进程，实现复杂度低
- **扩展性强**：接口抽象为未来添加服务器模拟留出空间

### 负面影响
- **时间跳跃感**：如果玩家离线时间过长（如一周），一次性生成大量事件可能不自然
- **缺乏实时性**：无法处理玩家突然上线的情况（如离线期间NPC发来“紧急”消息）
- **随机性限制**：确定性随机可能降低事件的不可预测感

### 缓解措施
- 对超长离线时间（>24小时）进行事件采样而非全量生成
- 在归来反馈中模糊时间表述（如“最近”“这几天”而非精确时间）
- 允许玩家通过设置调整模拟频率

## 相关系统影响

- **C2 外出-归来循环**：需提供 `last_exit_time` 和模拟触发点
- **C4 事件线系统**：需支持批量事件生成和快速模拟
- **C6 关系值系统**：需支持批量更新关系数值
- **F4 存档系统**：需存储 `last_exit_time` 和 `random_seed`

## 后续考虑

此方案作为 MVP 阶段的可行实现。如果未来游戏添加：
- **多设备同步**：需升级为服务端权威模拟
- **实时社交功能**：需添加推送通知和实时事件系统
- **跨玩家互动**：需完全重新设计社交架构

当前实现已为这些扩展保留了接口层面的兼容性。