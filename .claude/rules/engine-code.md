---
paths:
  - "src/core/**"
  - "src/gameplay/**"
  - "src/ui/**"
---

# Engine Code Rules

- ZERO allocations in hot paths (update loops, rendering, physics) — pre-allocate, pool, reuse
- All engine APIs must be thread-safe OR explicitly documented as single-thread-only
- Profile before AND after every optimization — document the measured numbers
- Engine code must NEVER depend on gameplay code (strict dependency direction: engine <- gameplay)
- Every public API must have usage examples in its doc comment
- Changes to public interfaces require a deprecation period and migration guide
- Use RAII / deterministic cleanup for all resources
- All engine systems must support graceful degradation
- Before writing engine API code, consult `docs/engine-reference/` for the current engine version and verify APIs against the reference docs

## New IModule Protocol (MANDATORY)

**NEVER write IModule boilerplate from scratch.** Mixed indentation in class-level vs
function-level declarations is the #1 source of GDScript parse errors in this project.

When creating any new IModule implementation, you MUST generate the skeleton first:

```powershell
python tools/new_module.py <module_id> <ClassName> [category] [priority]
# Examples:
python tools/new_module.py f5_audio_system F5AudioSystem core high
python tools/new_module.py c2_dialogue_system C2DialogueSystem gameplay medium
```

Then fill in the TODO sections. Do NOT copy-paste from another module or write from scratch.

The generated skeleton enforces:
- Class-level declarations (var/const/signal/enum) with **no indentation**
- Function bodies with **one Tab indent**
- Control structures with **two Tab indents**
- UTF-8 encoding + LF line endings (required by patch_gd.py)

## GDScript Edit Protocol (MANDATORY)

**NEVER use Edit on a .gd file without inspecting the target lines first.**

```powershell
# Step 1 — ALWAYS run this before any Edit on .gd files
python tools/patch_gd.py <file> --inspect <start_line> <end_line> --no-verify
```

If the `repr()` output doesn't match your intended `old_string` byte-for-byte → use
`patch_gd.py` directly. Do not attempt Edit and fix; inspect first, decide once.

**exit code 1 from patch_gd.py does NOT mean the file was not modified.**
Always check the output for `[MODIFIED]` vs `[NOT MODIFIED]` — the file may have been
written successfully even if Godot verification subsequently failed (exit 2).

```
exit code 0 = file written + Godot verify passed        → [OK]
exit code 1 = tool error before file was touched         → [NOT MODIFIED], retry
exit code 2 = file written but Godot verify failed       → [MODIFIED], fix the GDScript error
```

## Examples

**Correct** (zero-alloc hot path):

```gdscript
# Pre-allocated array reused each frame
var _nearby_cache: Array[Node3D] = []

func _physics_process(delta: float) -> void:
    _nearby_cache.clear()  # Reuse, don't reallocate
    _spatial_grid.query_radius(position, radius, _nearby_cache)
```

**Incorrect** (allocating in hot path):

```gdscript
func _physics_process(delta: float) -> void:
    var nearby: Array[Node3D] = []  # VIOLATION: allocates every frame
    nearby = get_tree().get_nodes_in_group("enemies")  # VIOLATION: tree query every frame
```
