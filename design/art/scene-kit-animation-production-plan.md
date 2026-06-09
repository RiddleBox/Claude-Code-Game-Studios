# Scene Kit Animation Production Plan

> **Status**: Active
> **Created**: 2026-06-08
> **Decision Source**: `docs/architecture/adr-004-scene-kit-runtime-animation-architecture.md`
> **Applies To**: P1 scene composition, C1 character performance, VS01 concept master

## Purpose

This plan converts the animation route into a production workflow. The goal is to validate a calm, living, window-side scene using rebuilt Scene Kit layers and local character performance, not full-scene video or full-body frame animation.

The first target is not final art. The first target is a **runtime proof**:

> At 320x320, the player can glance at the window and understand: she is in her own room, writing near the window, while the world outside and the glass between you quietly breathe.

## Route Locked

The project uses:

```text
Scene Kit Runtime Composition
+ Parametric Character Performance Layer
+ Optional rare flipbook/video event moments
```

The project does not use as the primary route:

- Full-scene looping video.
- Full-body frame animation for all states.
- Live2D front-facing avatar presentation.
- Pure static scene with only shader effects.

## Current Project Fit

Current implementation status means the next work should validate presentation, not invent new core systems:

| Area | Current State | Production Decision |
|---|---|---|
| F1 desktop window | MVP technical base exists | Keep as window/container owner |
| F2 state machine | State-driven character logic exists | Keep as state source |
| C1 character animation | Placeholder/full-sprite assumptions | Upgrade to character performance root |
| C2 outing-return | Outing loop exists | Drive away/return presentation |
| Fe2 leak content | Curiosity hook exists | Render above Scene Kit |
| F5 connection | Connection state exists | Drive glass/clarity/warmth |
| P1 main UI | Four-layer compositor | Upgrade to Scene Kit compositor |

## Production Phases

### Phase 0: Decision Lock

**Goal**: Prevent route drift before code work starts.

**Deliverables**:

- `docs/architecture/adr-004-scene-kit-runtime-animation-architecture.md`
- `design/art/scene-kit-animation-production-plan.md`
- `design/art/specs/vs01-scene-kit-animation-assets.md`

**Exit Criteria**:

- The docs clearly separate P1 scene composition from C1 character performance.
- The docs state when video, Live2D, and full-body frame animation are allowed.
- Sprint 6 visual work can be rewritten from "frame vs skeleton" to Scene Kit runtime validation.

### Phase 1: VS01 Six-Piece Scene Kit

**Goal**: Build the smallest asset kit that can prove the experience.

**Required assets**:

| ID | Asset | Required | Notes |
|---|---|---:|---|
| VS01-EXT-COMBINED | `Exterior_Window_View_Combined` | Yes | One combined exterior image for the first pass |
| VS01-ROOM-OCCLUDER | `Interior_Room_Frame_Occluder` | Yes | Room and circular window mask/occluder |
| VS01-DESK-BASE | `Desk_Base` | Yes | Desk plane without permanent prop holes |
| VS01-CHR-WRITING | `Character_Writing_Static` | Yes | Transparent writing pose |
| VS01-FG-PLANTS | `Foreground_Plants` | Yes | Foreground occlusion and voyeuristic distance |
| VS01-GLASS | `Glass_Atmosphere` | Yes | Glass, dust, soft reflection |

**Exit Criteria**:

- All assets can be stacked in Godot without holes.
- The room still works if the character is hidden.
- The exterior can be replaced without changing room, desk, character, or foreground.
- The 320x320 crop still reads as a window-side writing scene.

### Phase 2: P1 Scene Compositor Prototype

**Goal**: Convert P1 into a minimal runtime compositor.

**Minimum node structure**:

```text
P1SceneRoot
├─ ExteriorLayer
├─ InteriorOccluderLayer
├─ DeskLayer
├─ CharacterMount
├─ ForegroundLayer
├─ GlassAtmosphereLayer
└─ LeakContentLayer
```

**Required behavior**:

| Behavior | Target |
|---|---|
| Layer order | Deterministic and documented |
| Parallax | Exterior slow, foreground slightly faster |
| Away state | Scene dims to about 20 percent brightness |
| Connection state | Glass and clarity change by F5 quality |
| Leak content | Fe2 content appears above scene |
| Graceful degradation | Missing optional layers do not crash |

**Deferred**:

- Weather system.
- Seasonal scene variants.
- Multiple exterior locations.
- Complex shader stack.
- Camera pathing.

### Phase 3: C1 Character Performance Prototype

**Goal**: Replace the placeholder full-sprite assumption with local performance.

**Minimum node structure**:

```text
C1CharacterPerformanceRoot
├─ BodyPose
├─ HandPenLoop
├─ HairMicro
├─ ShoulderMicro
├─ ContactShadow
└─ AnimationPlayer
```

**Minimum clips**:

| Clip | Source State | Description |
|---|---|---|
| `writing_idle` | Idle | Body is mostly static; hand/pen or paper moves subtly |
| `aware_pause` | Aware/Attentive | Stops writing and subtly turns/pauses toward the window |
| `away_hidden` | Away | Character hidden; scene remains readable |
| `return_hint` | Returning | Simple return presence, not a full cinematic |

**Rules**:

- The character should not look directly into the camera.
- Local motion should be small enough for a desktop corner experience.
- Hand/pen animation should be tested before adding hair/cloth complexity.
- If local splitting looks cheap, use a transparent flipbook for the writing loop.

### Phase 4: State Integration

**Goal**: Reconnect the new presentation stack to existing systems.

| System | Integration |
|---|---|
| F2 | Maps Idle/Aware/Attentive/Away/Returning to C1 clips |
| C2 | Drives away and return visual sequence |
| F5 | Drives glass and clarity through P1 |
| Fe2 | Displays leak content above scene |
| Fe5 | Optionally receives animation events from C1 |

**Target flow**:

```text
writing_idle
  -> aware_pause
  -> away_hidden + room dim
  -> leak content over empty room
  -> return_hint
  -> writing_idle
```

### Phase 5: Validation

**Goal**: Decide whether the locked route is working before expanding asset count.

**Pass Criteria**:

- The first glance reads as "she is writing in her own space."
- Motion is present but not attention-grabbing.
- The glass/foreground/exterior create a sense of observed distance.
- Away state feels like an empty but still living room.
- The character does not read as a front-facing assistant.
- The scene remains usable under degraded connection visuals.
- Runtime performance remains at 60fps.
- Godot verification has zero errors, script errors, and warnings.

**Fallback Ladder**:

1. If hand/pen local animation fails, use a transparent character writing flipbook.
2. If character motion still feels cheap, reduce character animation and increase paper/light/glass motion.
3. If Scene Kit cohesion fails, improve asset reconstruction before changing architecture.
4. Only consider Live2D or full video for a future special mode, not for the main window.

## Sprint 6 Reframe

Existing Sprint 6 visual tasks should be reframed:

| Old Task | New Task |
|---|---|
| S6-01 background placeholder system | VIS-02 VS01 Six-Piece Scene Kit |
| S6-02 character animation placeholder system | VIS-03 P1 compositor + VIS-04 C1 performance root |
| "frame animation vs skeleton animation" choice | ADR-004 route lock |
| 8 state animations | 4 core clips that validate the relationship |

Suggested sprint tasks:

| ID | Task | Owner | Estimate | Acceptance |
|---|---|---:|---:|---|
| VIS-01 | Route lock docs | Codex + user approval | 1d | ADR and production docs accepted |
| VIS-02 | VS01 six-piece asset kit | art-director + technical-artist | 2d | Assets stack without holes |
| VIS-03 | P1 Scene Compositor prototype | ui-programmer | 3d | Six layers render and respond to away/connection |
| VIS-04 | C1 Character Performance prototype | gameplay-programmer + technical-artist | 3d | Four clips work from F2 state |
| VIS-05 | System integration pass | lead-programmer | 2d | F2/C2/F5/Fe2 drive visual changes |
| VIS-06 | Validation report | qa-tester + producer | 1d | Pass/fail against criteria |

## Production Rules

1. Do not expand asset count until the six-piece kit works in Godot.
2. Do not create full-body animation sets before `writing_idle` and `aware_pause` are validated.
3. Do not use UI text/icons to explain connection quality if glass/light can express it.
4. Do not let leak content cover the character's core activity.
5. Do not treat the concept image as a cutout source. Rebuild hidden areas.
6. Do not make the character face the player unless a future narrative exception is approved.

## Documentation Updates After Prototype

After the prototype passes:

- Update `design/gdd/c1-character-animation-system.md`.
- Update `design/gdd/p1-main-ui.md`.
- Update `design/art/art-direction.md`.
- Update `design/art/specs/c1-character-assets.md`.
- Update or supersede `design/art/background-layering-system.md`.
- Update Sprint 6 or create Sprint 7 based on actual prototype results.
