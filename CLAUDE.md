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
- **If the Edit tool fails even once: use Python to fix, never sed/awk/Bash string manipulation.**

## Edit Tool Failure Protocol (Mandatory)

GDScript files use Tab indentation. The Edit tool requires byte-perfect `old_string` matching — any Tab/space mismatch or `\r\n` vs `\n` difference will silently fail.

**When Edit fails, always use this Python pattern instead:**

```python
# Step 1: Read the file
with open(r"D:\AIproject\claude-code-game-studios\src\...\file.gd", "r", encoding="utf-8") as f:
    lines = f.readlines()

# Step 2: Inspect the target lines (always do this first)
for i, line in enumerate(lines[120:135], start=121):
    print(f"{i:03d}: {repr(line)}")

# Step 3: Modify by line number (not by content matching)
lines[124] = "\t\tvar save_success = _save_last_timestamp_to_f4()\n"
lines[125] = "\t\tif save_success:\n"

# Step 4: Write back — MUST use newline="\n" (Godot requires LF, not CRLF)
with open(r"D:\AIproject\claude-code-game-studios\src\...\file.gd", "w", encoding="utf-8", newline="\n") as f:
    f.writelines(lines)
```

**Why Python, not sed/awk:**
- `sed -i` on Windows (Git Bash) has inconsistent `\t` escape behavior — `\t` may not be interpreted as Tab
- `sed` on Windows may silently convert LF to CRLF, breaking Godot parsing
- Python `readlines()` preserves exact bytes; line-number indexing has no matching ambiguity
- `newline="\n"` guarantees LF output regardless of OS

**Rules:**
1. Before modifying, always print `repr(line)` for the target lines to confirm Tab vs space
2. Always use `encoding="utf-8"` and `newline="\n"`
3. Always run headless verify after writing
4. Never use sed, awk, or Bash heredoc for GDScript files
