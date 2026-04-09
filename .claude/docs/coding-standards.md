# Coding Standards

- All game code must include doc comments on public APIs
- Every system must have a corresponding architecture decision record in `docs/architecture/`
- Gameplay values must be data-driven (external config), never hardcoded
- All public methods must be unit-testable (dependency injection over singletons)
- Commits must reference the relevant design document or task ID
- **Verification-driven development**: Write tests first when adding gameplay systems.
  For UI changes, verify with screenshots. Compare expected output to actual output
  before marking work complete. Every implementation should have a way to prove it works.

# Design Document Standards

- All design docs use Markdown
- Each mechanic has a dedicated document in `design/gdd/`
- Documents must include these 8 required sections:
  1. **Overview** -- one-paragraph summary
  2. **Player Fantasy** -- intended feeling and experience
  3. **Detailed Rules** -- unambiguous mechanics
  4. **Formulas** -- all math defined with variables
  5. **Edge Cases** -- unusual situations handled
  6. **Dependencies** -- other systems listed
  7. **Tuning Knobs** -- configurable values identified
  8. **Acceptance Criteria** -- testable success conditions
- Balance values must link to their source formula or rationale

# Module Registration Examples

## 有场景文件的模块（含子节点）

`gdscript
## 在 app.gd 中注册带场景的模块
func _register_f1_window_system() -> void:
    var scene := load("res://src/core/f1_window_system/f1_window_system.tscn") as PackedScene
    if not scene:
        push_error("[App] 无法加载F1窗口系统场景")
        return
    var instance := scene.instantiate()
    _module_loader.register_module_instance(
        "f1_window_system", instance, config, [], [], 100
    )
`

## 纯脚本模块（无子节点）

`gdscript
## 在 app.gd 中注册纯脚本模块
func _register_f2_state_machine() -> void:
    var module_class := load("res://src/core/f2_state_machine/f2_state_machine.gd") as GDScript
    if not module_class:
        push_error("[App] 无法加载F2状态机模块类")
        return
    _module_loader.register_module(
        "f2_state_machine", module_class, config, ["f1_window_system"], [], 90
    )
`

## 判断原则

- 模块需要 @onready 绑定子节点 → 有 .tscn → 用 egister_module_instance()
- 模块只有逻辑，无 UI/Sprite 子节点 → 无 .tscn → 用 egister_module()
- .tscn 中的 xt_resource uid 必须与 .gd.uid 文件内容一致，否则 Godot 编辑器报加载错误