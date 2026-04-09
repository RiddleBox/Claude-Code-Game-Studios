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

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [ADR-001: F1 桌面窗口系统实现方案](docs/architecture/adr-001-desktop-window-system.md) — 混合Hook方案实现像素级点击穿透
- [ADR-002: C8 社交圈系统的离线模拟方案](docs/architecture/adr-002-local-backtrack-simulation.md) — 本地回溯模拟方案实现离线社交演化
