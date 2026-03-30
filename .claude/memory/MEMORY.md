# Project Memory — 窗语（Window Whisper）

## Project Overview
- **Working Title**: 窗语（Window Whisper）
- **Genre**: 桌宠 / Idle / 叙事碎片
- **Engine**: Godot 4.6.1 (`D:\3_Tool\Godot_v4.6.1-stable`)
- **Language**: GDScript (primary), GDExtension C++ (performance-critical only)
- **Platform**: PC Windows (primary), Mac (TBD)
- **Scope**: 中型个人独立开发，6-12个月
- **Price**: 15-20元 / 6-10美元，买断制 + DLC
- **External Dependency**: Aria 项目（语音识别、AI辅助、LLM调用）

## Key Design Pillars
1. 窥视感 — 永远只能看到异世界一角，信息碎片化暗示性
2. 真实存在感 — 角色有自己的生活，不只在交互时活着
3. 性格即命运 — 随机性格是叙事分支核心变量
4. 陪伴不打扰 — 常驻桌面但不强制注意力
5. 治愈日常 — 坏事也蠢萌，基调永远温暖
6. 共鸣成长 — 性格层面内在变化，吸收玩家正向特质

## Key Files
- `design/gdd/game-concept.md` — 游戏概念文档（完整）
- `design/gdd/systems-index.md` — 22个系统列表，优先级和依赖关系
- `docs/engine-reference/godot/VERSION.md` — Godot 4.6.1 版本参考
- `.claude/docs/technical-preferences.md` — 技术偏好（已配置）
- `CLAUDE.md` — 主配置（已更新引擎信息）

## Systems Summary (22 systems)
### P0 MVP: F1(窗口), F2(状态机), F3(时间), F4(存档), C1(动画), C2(外出循环), Fe2(泄漏内容), Fe5(声音), P1(主界面UI)
### P1 垂直切片: C3(碎片), C4(事件线), C5(性格变量), Fe1(对话), Fe6(通知), P2(日志UI), P3(设置UI)
### P2 Alpha: C6(关系值), F5(Aria接口), F6(角色上下文管理器), C7(对话记忆库), Fe3(朋友圈), Fe4(共鸣成长)
### Future Vision: 随机角色生成、跨用户串门、创意工坊、Steam集成

## Architecture Decisions
- Aria 项目负责：语音识别、LLM调用、行为执行
- 本项目负责：性格档案(System Prompt)、语音风格参数、对话记忆库、共鸣成长计算
- F5 Aria接口层需要完整降级模式（无API时走预设脚本 + 屏幕玻璃世界观视觉）
- 最高技术风险：F1 桌面窗口系统（Godot 4 透明悬浮窗未验证）

## User Preferences
- 语言：用中文交流
- 协作风格：遵循 Question→Options→Decision→Draft→Approval 流程
- 写文件前必须征得同意
- 不喜欢收集竞争类设计，核心是陪伴而非收集

## Current Status
- [x] 引擎配置完成（Godot 4.6.1）
- [x] 游戏概念文档完成（game-concept.md）
- [x] 系统拆解完成（systems-index.md，22个系统）
- [x] P0 MVP 层全部设计完成（9/9）
- [x] P1 垂直切片层全部设计完成（7/7）：C3, C4, C5, Fe1, Fe6, P2, P3
- [x] P2 Alpha 层部分完成（2/6）：C6, F5
- [ ] 下一步：F6（角色上下文管理器）→ C7 → Fe3 → Fe4
- [ ] C6 关系值系统数值待原型阶段深入研究（见 project_c6_balance_research.md）

## Memory Files
- `project_c6_balance_research.md` — C6 积累数值为初稿，需原型验证后调校