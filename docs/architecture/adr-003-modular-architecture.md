# ADR-003: 模块化架构和加载模式 (Modular Architecture and Loading Pattern)

## 状态
**Proposed** (提案中)

## 日期
2026-04-08

## 上下文

### 问题陈述
《窗语》项目包含22个系统，分为F系列（核心）、C系列（角色）、Fe系列（功能）和UI系统。当前代码结构简单，没有明确的模块边界、依赖管理和加载策略。随着系统数量增加，需要建立清晰的架构来支持：

1. **清晰的依赖方向**：防止循环依赖，确保Core → Character → Features → UI的层次结构
2. **模块隔离**：每个系统独立开发、测试和部署
3. **延迟加载**：按需初始化，减少启动时间和内存占用
4. **错误恢复**：单个模块失败不应导致应用崩溃
5. **可维护性**：支持热重载、模块替换和版本管理

### 约束
- 必须兼容Godot 4.6.1的GDScript生态系统
- 必须支持现有F1窗口系统和F2状态机的迁移
- 必须保持60fps性能目标，加载开销需控制在16.6ms/帧内
- 必须支持无网络环境下的降级模式（F5 Aria接口）
- 必须遵循项目编码标准：数据驱动、无硬编码、文档化接口

### 需求
- 必须支持模块间的信号通信，避免直接引用
- 必须提供模块生命周期管理：初始化、启动、停止、卸载
- 必须支持依赖自动解析和加载顺序控制
- 必须提供错误隔离和降级机制
- 必须支持配置驱动的模块定义
- 必须提供调试和监控工具

## 决策

采用**分层模块化架构**，包含以下核心组件：

### 1. 目录结构
```
src/
├── app/                    # 应用入口和核心管理器
│   ├── app.gd             # 主应用控制器
│   ├── module_loader.gd   # 模块加载器
│   └── dependency_graph.gd # 依赖关系图
├── core/                  # 核心系统 (F系列)
│   ├── f1_window_system/
│   ├── f2_state_machine/
│   ├── f3_time_system/
│   ├── f4_save_system/
│   └── f5_aria_interface/
├── character/            # 角色系统 (C系列)
│   ├── c1_animation/
│   ├── c2_out_return/
│   ├── c3_fragments/
│   ├── c4_event_line/
│   ├── c5_personality/
│   ├── c6_relationship/
│   ├── c7_dialogue_memory/
│   └── c8_social_circle/
├── features/             # 功能系统 (Fe系列)
│   ├── fe1_dialogue/
│   ├── fe2_leak_content/
│   ├── fe3_voice/
│   ├── fe4_resonance/
│   ├── fe5_sound/
│   └── fe6_notification/
├── ui/                   # UI系统 (P系列)
│   ├── p1_main_ui/
│   ├── p2_fragment_log/
│   └── p3_settings/
├── data/                 # 数据配置
│   ├── config/
│   └── resources/
└── shared/               # 共享组件
    ├── signals/
    ├── interfaces/
    └── utilities/
```

### 2. 模块接口定义 (IModule)
```gdscript
# interface/imodule.gd
class_name IModule
extends RefCounted

## 模块唯一标识符
var module_id: String

## 模块显示名称
var module_name: String

## 模块版本
var module_version: String

## 依赖模块ID列表
var dependencies: Array[String] = []

## 可选依赖模块ID列表
var optional_dependencies: Array[String] = []

## 模块配置路径
var config_path: String = ""

## 初始化模块（加载资源、建立连接）
func initialize(config: Dictionary = {}) -> bool:
    return true

## 启动模块（开始运行）
func start() -> bool:
    return true

## 停止模块（暂停运行）
func stop() -> void:
    pass

## 关闭模块（释放资源）
func shutdown() -> void:
    pass

## 获取模块状态
func get_status() -> Dictionary:
    return {}

## 处理模块错误
func handle_error(error: Dictionary) -> bool:
    return false
```

### 3. 模块加载器 (ModuleLoader)
```gdscript
# app/module_loader.gd
class_name ModuleLoader
extends Node

## 模块注册表 {module_id: module_instance}
var _modules: Dictionary = {}

## 模块状态 {module_id: status_data}
var _module_status: Dictionary = {}

## 依赖关系图
var _dependency_graph: DependencyGraph

## 加载模块定义并初始化
func load_module(module_id: String, module_class: GDScript, config: Dictionary = {}) -> bool

## 按依赖顺序启动所有模块
func start_all_modules() -> bool

## 停止所有模块
func stop_all_modules() -> void

## 获取模块实例
func get_module(module_id: String) -> IModule

## 检查模块是否就绪
func is_module_ready(module_id: String) -> bool

## 重新加载模块
func reload_module(module_id: String) -> bool
```

### 4. 依赖关系图 (DependencyGraph)
```gdscript
# app/dependency_graph.gd
class_name DependencyGraph
extends RefCounted

## 构建依赖拓扑排序
func topological_sort(modules: Dictionary) -> Array[String]

## 检测循环依赖
func detect_cycles(modules: Dictionary) -> Array[Array]

## 获取模块依赖链
func get_dependency_chain(module_id: String) -> Array[String]

## 获取依赖模块的模块
func get_dependent_modules(module_id: String) -> Array[String]
```

### 5. 主应用控制器 (App)
```gdscript
# app/app.gd
class_name App
extends Node

## 应用启动流程
func _ready() -> void:
    # 1. 加载基础配置
    # 2. 初始化模块加载器
    # 3. 按优先级加载模块
    # 4. 启动所有模块
    # 5. 进入主循环
    pass

## 应用关闭流程
func _exit_tree() -> void:
    # 1. 停止所有模块
    # 2. 保存状态
    # 3. 清理资源
    pass
```

### 架构图
```
┌─────────────────────────────────────────────┐
│                  App (Node)                 │
│  ┌──────────────────────────────────────┐  │
│  │         ModuleLoader (Node)          │  │
│  │  ┌─────────────┬──────────────────┐  │  │
│  │  │ Dependency  │   Module Registry│  │  │
│  │  │   Graph     │   {id: instance} │  │  │
│  │  └─────────────┴──────────────────┘  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐   │
│  │ Core │  │Char. │  │Feat. │  │  UI  │   │
│  │Modules│ │Modules│ │Modules│ │Modules│   │
│  └──────┘  └──────┘  └──────┘  └──────┘   │
└─────────────────────────────────────────────┘
        信号通信 (Signals) │ 依赖注入 (DI)
           ▼              ▼
    ┌──────────────────────────┐
    │      Shared Signals      │
    │   Shared Interfaces      │
    │     Shared Utilities     │
    └──────────────────────────┘
```

### 关键接口
1. **模块注册接口**：`register_module(module_id, module_class)`
2. **依赖声明接口**：`declare_dependencies(module_id, deps)`
3. **状态查询接口**：`get_module_status(module_id)`
4. **错误报告接口**：`report_module_error(module_id, error)`
5. **配置管理接口**：`load_module_config(module_id)`

## 替代方案考虑

### 替代方案1: Godot自动加载 (Autoload)
- **描述**：使用Godot的Autoload功能，每个系统作为单例自动加载
- **优点**：Godot原生支持，简单易用
- **缺点**：缺乏依赖管理，加载顺序不可控，错误隔离差，难以热重载
- **拒绝原因**：不符合模块化需求，无法支持复杂的依赖关系和错误恢复

### 替代方案2: 服务定位器模式 (Service Locator)
- **描述**：中央服务注册表，模块通过服务定位器获取依赖
- **优点**：解耦模块，支持运行时替换
- **缺点**：依赖关系隐式，难以静态分析，调试困难
- **拒绝原因**：依赖关系不明确，违反显式依赖原则

### 替代方案3: 事件总线架构 (Event Bus)
- **描述**：所有通信通过中央事件总线，模块完全解耦
- **优点**：高度解耦，易于扩展
- **缺点**：性能开销大，调试困难，类型安全差
- **拒绝原因**：Godot信号系统已提供类似功能，无需额外抽象层

## 后果

### 正面
- **清晰的架构边界**：每个系统有明确的职责和接口
- **可维护性**：模块独立开发、测试和部署
- **错误隔离**：单个模块失败不影响整体应用
- **性能优化**：按需加载，减少启动时间和内存占用
- **可测试性**：模块可独立测试，依赖可模拟

### 负面
- **实现复杂度**：需要额外的加载器和依赖管理代码
- **学习曲线**：新开发者需要理解模块化架构
- **启动延迟**：依赖解析和初始化需要时间
- **内存开销**：模块管理结构占用额外内存

### 风险
1. **循环依赖风险**：模块间可能形成循环依赖
   - **缓解**：依赖图检测，构建时验证
2. **性能风险**：模块加载和通信可能影响帧率
   - **缓解**：异步加载，信号优化，性能监控
3. **兼容性风险**：模块版本不兼容
   - **缓解**：版本检查，接口契约，降级处理

## 性能影响
- **CPU**：模块加载和依赖解析在启动时一次性开销，运行时开销可忽略
- **内存**：模块管理结构额外占用~100KB，模块实例按需加载
- **加载时间**：依赖解析增加~50ms启动时间，但支持异步加载可隐藏
- **网络**：不直接影响，但支持模块的远程更新和配置

## 迁移计划
1. **阶段1**：创建基础架构（app/, shared/目录）
2. **阶段2**：迁移F1窗口系统为第一个模块化系统
3. **阶段3**：迁移F2状态机，建立模块间信号通信
4. **阶段4**：逐步迁移其他系统，保持向后兼容
5. **阶段5**：移除旧代码，完全切换到模块化架构

## 验证标准
1. **功能验证**：
   - [ ] 模块加载器能正确加载和初始化模块
   - [ ] 依赖关系正确解析和排序
   - [ ] 模块失败不影响其他模块运行
   - [ ] 信号通信正常工作
2. **性能验证**：
   - [ ] 启动时间增加不超过100ms
   - [ ] 运行时内存开销不超过200KB
   - [ ] 模块加载不影响60fps目标
3. **兼容性验证**：
   - [ ] 现有F1/F2系统能正常迁移
   - [ ] 支持编辑器模式和独立运行模式
   - [ ] 配置驱动正常工作

## 相关决策
- [ADR-001: F1 桌面窗口系统实现方案](adr-001-desktop-window-system.md)
- [ADR-002: C8 社交圈系统的离线模拟方案](adr-002-local-backtrack-simulation.md)