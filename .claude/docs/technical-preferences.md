# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6.1
- **Godot Executable**: `D:\3_Tool\Godot_v4.6.1-stable`
- **Language**: GDScript (primary), C++ via GDExtension (performance-critical only)
- **Rendering**: Forward+ (default, desktop)
- **Physics**: Jolt (Godot 4.6 default)

## Naming Conventions

- **Classes**: PascalCase (e.g., `PetController`)
- **Variables**: snake_case (e.g., `move_speed`)
- **Functions**: snake_case (e.g., `update_mood()`)
- **Signals/Events**: snake_case past tense (e.g., `mood_changed`, `dialogue_finished`)
- **Files**: snake_case matching class (e.g., `pet_controller.gd`)
- **Scenes/Prefabs**: PascalCase matching root node (e.g., `PetController.tscn`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_ENERGY`)

## Performance Budgets

- **Target Framerate**: 60fps
- **Frame Budget**: 16.6ms
- **Draw Calls**: [TO BE CONFIGURED]
- **Memory Ceiling**: [TO BE CONFIGURED]

## Testing

- **Framework**: GUT (Godot Unit Testing)
- **Minimum Coverage**: [TO BE CONFIGURED]
- **Required Tests**: Gameplay systems, state machines, Aria interface boundary

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- No `await` inside `_process()` or `_physics_process()`
- No hardcoded strings for dialogue/UI text (use string keys)
- No direct coupling to Aria API — always go through the interface layer

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- GUT (Godot Unit Testing) — testing framework
- [None else configured yet — add as dependencies are approved]

## Module Registration Pattern

模块注册方式取决于模块**是否需要加入场景树**：

| 情况 | 注册方式 | 原因 |
|------|----------|------|
| 模块内部调用 `add_child()`（如 Timer、子节点） | `register_module_instance()` | 必须先 `add_child(instance)` 进场景树，子节点才能正常工作 |
| 模块有关联 `.tscn` 场景文件 | `register_module_instance()`，传入 `scene.instantiate()` | 场景含节点层级，同上 |
| 纯脚本模块（只有逻辑，无任何子节点/Timer） | `register_module()` | 不需要场景树 |

**判断规则（按优先级）**：
1. 模块脚本里有 `add_child()` 或 `Timer.new()` / `子节点.new()` → **必须用 `register_module_instance()`**
2. 有 `.tscn` 文件 → **必须用 `register_module_instance()`**
3. 两者都没有 → 可用 `register_module()`

**正确写法**：
```gdscript
# ✅ 有内部 add_child（如 Timer）— 先加入场景树再注册
var instance = module_class.new()
add_child(instance)  # 必须在 register 之前
_module_loader.register_module_instance("module_id", instance, config, deps)

# ✅ 有 .tscn 场景文件
var scene = load("res://src/.../module.tscn")
var instance = scene.instantiate()
add_child(instance)
_module_loader.register_module_instance("module_id", instance, config, deps)

# ✅ 纯脚本模块（无任何子节点）
var module_class = load("res://src/.../module.gd")
_module_loader.register_module("module_id", module_class, config, deps)
```

**已知使用 `register_module_instance()` 的模块**：F1、F3、F4、UI
**已知使用 `register_module()` 的模块**：F2（纯状态机逻辑）

每个带场景的模块目录下应同时包含 `.gd` 和 `.tscn`，且 `.tscn` 中的
`ext_resource uid` 必须与对应 `.gd.uid` 文件内容一致。

详见 `coding-standards.md` 中的代码示例。

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [ADR-001: F1 桌面窗口系统实现方案](docs/architecture/adr-001-desktop-window-system.md) — 混合Hook方案实现像素级点击穿透
- [ADR-002: C8 社交圈系统的离线模拟方案](docs/architecture/adr-002-local-backtrack-simulation.md) — 本地回溯模拟方案实现离线社交演化
