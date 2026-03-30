# Systems Index — 窗语（Window Whisper）

*Created: 2026-03-26*
*Last Updated: 2026-03-26*
*Status: Active*

---

## 概览

| 统计 | 数量 |
|------|------|
| 总系统数 | 22 |
| 已设计 | 12 |
| 设计中 | 0 |
| 未开始 | 10 |
| Future Vision | 4 |

---

## P0 — MVP 层（技术验证）

> 目标：验证核心陪伴感 + 出门-归来循环可行性

| # | ID | 系统名 | 状态 | GDD 文件 | 依赖 | 备注 |
|---|----|--------|------|----------|------|------|
| 1 | F1 | 桌面窗口系统 | ✅ 已设计 | design/gdd/f1-desktop-window-system.md | — | **最高技术风险**，阻塞 C1/P1 |
| 2 | F2 | 角色状态机 | ✅ 已设计 | design/gdd/f2-character-state-machine.md | F1 | 几乎所有系统的基础 |
| 3 | F3 | 时间/节奏系统 | ✅ 已设计 | design/gdd/f3-time-rhythm-system.md | — | Idle 循环基础 |
| 4 | F4 | 存档系统 | ✅ 已设计 | design/gdd/f4-save-system.md | — | 常驻游戏必须持久化 |
| 5 | C1 | 角色动画系统 | ✅ 已设计 | design/gdd/c1-character-animation-system.md | F1, F2 | 存在感核心表现 |
| 6 | C2 | 外出-归来循环 | ✅ 已设计 | design/gdd/c2-out-return-cycle.md | F2, F3 | **核心 Idle 循环** |
| 7 | Fe2 | 泄漏内容系统 | ✅ 已设计 | design/gdd/fe2-leak-content-system.md | C2, C5 | 外出期间的好奇心钩子 |
| 8 | Fe5 | 声音系统 | ✅ 已设计 | design/gdd/fe5-sound-system.md | F2 | 泄漏内容依赖音效 |
| 9 | P1 | 主界面 UI | ✅ 已设计 | design/gdd/p1-main-ui.md | F1, C1 | 玩家能看到和点击的东西 |

---

## P1 — 垂直切片层

> 目标：验证叙事深度，1个角色 + 完整初始事件线

| # | ID | 系统名 | 状态 | GDD 文件 | 依赖 | 备注 |
|---|----|--------|------|----------|------|------|
| 10 | C3 | 碎片系统 | ✅ 已设计 | design/gdd/c3-fragment-system.md | F4 | 叙事内容的容器 |
| 11 | C4 | 事件线系统 | ✅ 已设计 | design/gdd/c4-event-line-system.md | F3, F4 | 精心设计的故事节点 |
| 12 | C5 | 性格变量系统 | ✅ 已设计 | design/gdd/c5-personality-variable-system.md | F2 | **叙事分支核心变量** |
| 13 | Fe1 | 对话系统 | ✅ 已设计 | design/gdd/fe1-dialogue-system.md | C3, C5 | 碎片的主要呈现方式 |
| 14 | Fe6 | 通知/提醒系统 | ✅ 已设计 | design/gdd/fe6-notification-system.md | F1, C2 | 不打扰原则的实现 |
| 15 | P2 | 碎片日志 UI | ✅ 已设计 | design/gdd/p2-fragment-log-ui.md | C3, Fe3 | 玩家回顾碎片 |
| 16 | P3 | 设置 UI | ✅ 已设计 | design/gdd/p3-settings-ui.md | F1, F5 | Aria 连接配置入口 |

---

## P2 — Alpha 层

> 目标：验证重玩价值，随机性格 + 共鸣成长 + AI 联通

| # | ID | 系统名 | 状态 | GDD 文件 | 依赖 | 备注 |
|---|----|--------|------|----------|------|------|
| 17 | C6 | 关系值系统 | ✅ 已设计 | design/gdd/c6-relationship-system.md | F3, F4 | 深化机制的量化 |
| 18 | F5 | Aria 接口层 | ✅ 已设计 | design/gdd/f5-aria-interface.md | — | AI 联通 + 降级模式 |
| 19 | F6 | 角色上下文管理器 | 🔴 未开始 | — | F4, C5 | 动态 System Prompt 生成 |
| 20 | C7 | 对话记忆库 | 🔴 未开始 | — | F4, F6, C5, C6 | 记忆积累 + 共鸣成长触发 |
| 21 | Fe3 | 朋友圈系统 | 🔴 未开始 | — | C4, C5 | 世界观深度扩展 |
| 22 | Fe4 | 共鸣成长系统 | 🔴 未开始 | — | C5, C6, C7 | 性格渐变完整实现 |

---

## Future Vision（当前不实现）

| ID | 系统名 | 描述 | 目标层级 |
|----|--------|------|----------|
| FV1 | 随机角色生成系统 | 随机外形 + 性格的召唤/邂逅机制 | 完整版后期 |
| FV2 | 跨用户串门系统 | 不同玩家的桌宠互相拜访 | DLC / 远期 |
| FV3 | 创意工坊支持 | 玩家自制故事包 | 远期 |
| FV4 | Steam 平台集成 | 成就、截图分享等 | 完整版 |

---

## 依赖层次图

```
Foundation:   F1 ──► F2 ──► F3 ──► F4 ──► F5
               │      │                    │
               ▼      ▼                    ▼
Core:          C1     C2 ──► C3     F6 ──► C7
               │      │      │      │
               ▼      ▼      ▼      ▼
             [P1]   [Fe2]  [C4]──►[C5]──►[C6]
                             │      │
                             ▼      ▼
Feature:                   [Fe3] [Fe1,Fe2,Fe4]
                             │
                             ▼
Presentation:              [P1]──►[P2]──►[P3]
```

**关键瓶颈系统（优先解锁）：**
- **F1** 桌面窗口系统 → 阻塞 C1, P1（技术未验证）
- **F2** 角色状态机 → 阻塞 C1, C2, C5, Fe5
- **C5** 性格变量系统 → 阻塞 Fe1, Fe2, Fe3, Fe4, F6, C7

---

## GDD 编写顺序建议

按依赖顺序，每次运行 `/design-system` 处理下一个未开始的系统：

```
第1轮（MVP 基础）:  F1 → F2 → F3 → F4
第2轮（MVP 核心）:  C1 → C2 → Fe2 → Fe5 → P1
第3轮（垂直切片）:  C3 → C4 → C5 → Fe1 → Fe6 → P2 → P3
第4轮（Alpha）:    C6 → F5 → F6 → C7 → Fe3 → Fe4
```

---

## Next Steps

- [ ] 运行 `/design-system Fe5` — 声音系统（下一个 P0 MVP 核心系统）
- [ ] 运行 `/design-system P1` — 主界面 UI
- [ ] 运行 `/design-system C3` — 碎片系统（垂直切片第一步）
