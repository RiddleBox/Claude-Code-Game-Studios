# Claude Code Game Studios -- Game Studio Agent Architecture

Indie game development managed through 48 coordinated Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: Godot 4.6.1 (`D:\3_Tool\Godot_v4.6.1-stable`)
- **Language**: GDScript (primary), C++ via GDExtension (performance-critical)
- **Version Control**: Git with trunk-based development
- **Build System**: Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

@.claude/docs/directory-structure.md

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Technical Preferences

@.claude/docs/technical-preferences.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no engine configured and no game concept,
> run `/start` to begin the guided onboarding flow.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

@.claude/docs/context-management.md

## Project Memory

At the start of every conversation, read `.claude/memory/MEMORY.md` to restore project context, design progress, and user preferences. This file is tracked by git and is the authoritative memory source across all machines.

Additional memory files are listed in `.claude/memory/MEMORY.md`.

## Mandatory Verification After Code Changes

After writing or editing **any** `.gd` or `.tscn` file, you MUST verify before marking the task done:

```powershell
# 1. Refresh import cache (required when .tscn files change)
godot --path <project_root> --headless --import

# 2. Verify — zero output means pass
godot --path <project_root> --headless --quit 2>&1 | Where-Object { $_ -match "^(ERROR|SCRIPT ERROR|WARNING)" }
```

**Rules:**
- Zero output = ✅ pass. Any `SCRIPT ERROR` or `ERROR` = ❌ fix before proceeding.
- Warnings treated as errors (same as Godot project settings).
- If Godot is unavailable, mark file as `⚠️ UNVERIFIED` in `production/session-state/active.md` and stop — do NOT mark the task complete.
- **If the Edit tool fails even once: run `patch_gd.py`. Never use sed/awk/Bash.**

## Edit Tool Failure Protocol (Mandatory)

GDScript files use Tab indentation. The Edit tool requires byte-perfect `old_string` matching.
Any Tab/space mismatch or `\r\n` vs `\n` difference causes silent failure.

**When Edit fails, run these commands — copy and adapt, do not improvise:**

### Step 1 — Inspect target lines (always do this first)
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py <file> --inspect <start_line> <end_line> --no-verify
```
Example:
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py src\core\f3_time_system\f3_time_system.gd --inspect 120 135 --no-verify
```
This prints `repr()` of each line so you can see exact Tab/space characters before touching anything.

### Step 2 — Apply the fix

**Replace a single line:**
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py <file> <line_num> "<new_content>"
```
Use `\t` for Tab in `<new_content>`. Example:
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py src\core\f3_time_system\f3_time_system.gd 125 "\t\tvar save_success = _save_last_timestamp_to_f4()"
```

**Replace multiple lines at once:**
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py <file> --multi "{\"125\": \"\t\tvar x = 1\", \"126\": \"\t\tif x:\"}"
```

**Delete a line:**
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py <file> --delete <line_num>
```

**Delete a range of lines:**
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py <file> --delete-range <start> <end>
```

**Insert a new line after line N:**
```powershell
python D:\AITools\godot-watch\tools\patch_gd.py <file> --insert-after <line_num> "<new_content>"
```

### Step 3 — Verify (automatic)
`patch_gd.py` runs Godot headless verify automatically after every write.
If verify fails, it prints the errors and exits with code 2 — fix before proceeding.

### Why NOT sed/awk
- `sed -i` on Windows has inconsistent `\t` escape — may silently write spaces instead of Tabs
- `sed` on Windows may convert LF → CRLF, breaking Godot parsing
- `patch_gd.py` enforces UTF-8 + LF on every write, guaranteed
