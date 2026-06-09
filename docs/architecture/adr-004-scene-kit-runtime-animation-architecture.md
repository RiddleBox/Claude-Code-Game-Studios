# ADR-004: Scene Kit Runtime Animation Architecture

## Status

**Accepted**

## Date

2026-06-08

## Context

### Problem Statement

The original C1 animation plan framed the core technical choice as full-body frame animation versus simple cutout/skeleton animation. That framing is now too narrow for the current visual direction.

The current concept reference is no longer treated as a source image to cut apart. It is a **Scene Kit concept master**: a guide for rebuilding a reusable, editable, replaceable, parallax-ready window-side life scene. The core experience is not "a character animation playing in a window"; it is "a small observed slice of another person's life."

The project therefore needs an animation architecture that can:

1. Preserve the quality and atmosphere of an illustration-like scene.
2. Support the core relationship rule that the character is not performing for the player.
3. Keep the desktop window calm enough for long work sessions.
4. Allow scene layers, foreground occlusion, glass effects, connection quality, and leak content to change independently.
5. Avoid locking the project into expensive full-body AI frame animation or non-composable video.

### Constraints

- The engine is Godot 4.6.1.
- The desktop window target remains a small 320x320 presentation area for current validation.
- F1, F2, C1, C2, Fe2, Fe5, F5, and P1 already exist as modules or GDDs.
- C1 currently uses placeholder `AnimatedSprite2D`/`SpriteFrames` style animation.
- P1 currently describes a simpler layer stack: frame, background, character, leak content, plus optional glass.
- The core philosophy document requires:
  - Player as accidental neighbor, not operator.
  - Presence greater than interaction.
  - Slow change higher priority than fast action.
  - Character should not face or perform to the player.
- The project must remain feasible for solo/indie production.

### Requirements

- Must support a layered Scene Kit built from independently replaceable PNG assets.
- Must support low-frequency environmental motion: parallax, glass, dust, light, foreground occlusion.
- Must support character life performance with partial/local animation rather than requiring full-body frame animation for every state.
- Must keep F2 as the state owner and C1/P1 as presentation systems.
- Must allow F5 connection state to affect glass/clarity/warmth without adding UI-like status indicators.
- Must allow Fe2 leak content to render above the scene without breaking composition.
- Must leave room for rare event flipbooks or short video-like sequences without making them the default rendering model.

## Decision

Adopt **Scene Kit Runtime Composition with a Parametric Character Performance Layer** as the primary animation architecture.

The main visual surface is no longer a single background plus a full-body animated character. It is a runtime-composited scene:

```text
P1SceneRoot
├─ ExteriorLayer
│  ├─ Sky
│  ├─ CityFar
│  └─ CityNear
├─ InteriorOccluderLayer
│  ├─ RoomBase
│  ├─ RoundWindowFrame
│  └─ WallDecor
├─ DeskLayer
│  ├─ DeskBase
│  └─ DeskProps
├─ CharacterMount
│  └─ C1CharacterPerformanceRoot
├─ ForegroundLayer
│  └─ ForegroundPlants
├─ AtmosphereLayer
│  ├─ GlassAtmosphere
│  ├─ DustLight
│  └─ SignalWarmth
└─ LeakContentLayer
```

C1 owns only the character performance subtree:

```text
C1CharacterPerformanceRoot
├─ BodyPose Sprite2D
├─ HandPen AnimatedSprite2D
├─ HairMicro Sprite2D
├─ ShoulderMicro Sprite2D
├─ ContactShadow Sprite2D
└─ AnimationPlayer
```

P1 owns scene composition and environmental motion. C1 owns character pose, local motion, and animation events. F2 owns abstract state. F5 owns connection quality. C2 owns outing/return transitions. Fe2 owns leak content.

### Key Interfaces

F2 to C1:

```gdscript
state_changed(old_state: int, new_state: int)
```

C1 maps state to a character performance clip:

```gdscript
writing_idle
aware_pause
busy_back_loop
away_hidden
return_hint
```

F5 to P1:

```gdscript
connection_quality_changed(old_quality: int, new_quality: int)
```

P1 maps connection quality to atmosphere:

```text
DISCONNECTED -> stronger glass, lower clarity, cooler/desaturated scene
DEGRADED     -> light glass, slight desaturation
CONNECTED    -> subtle glass, warmer signal overlay allowed
```

C2 to P1/C1 through existing system flow:

```text
outbound_triggered -> P1 dims scene, F2 changes to Away, C1 hides character
return_completed   -> P1 restores scene, F2 changes to Returning/Idle, C1 plays return hint
```

### Architecture Rules

1. Scene assets are rebuilt as layers. The concept image is not used as a cutout source.
2. P1 must be able to render a valid scene if C1 is missing or hidden.
3. C1 must be able to render a valid character performance if some optional micro layers are missing.
4. Full-scene video is not a default state renderer.
5. Full-body frame animation is reserved for rare cases or short transparent flipbooks.
6. Live2D is not part of the primary architecture. Its action-tag idea may be borrowed later, but not its front-facing avatar presentation model.
7. Common motion should be slow, low-contrast, and composable.
8. Any animation that makes the character face the viewer directly is invalid unless explicitly approved for a special narrative exception.

## Alternatives Considered

### Alternative 1: Full Scene Video

- **Description**: Render the whole window as a looping video or generated animation clip.
- **Pros**:
  - Can look fluid if the source video is high quality.
  - Simplifies runtime composition.
  - Good for cinematic one-off moments.
- **Cons**:
  - Cannot independently swap exterior, glass, foreground, character, and leak content.
  - Locks connection state and outing state into baked frames.
  - Hard to preserve transparent desktop-window hit testing.
  - Poor fit for long-running idle state variation.
  - Godot video support is less flexible than sprite/layer composition for this use case.
- **Rejection Reason**: Too non-composable for a state-driven desktop companion.

### Alternative 2: Full-Body Frame Animation

- **Description**: Generate full transparent character frames for each state and play them through `AnimatedSprite2D`/`SpriteFrames`.
- **Pros**:
  - Simple to integrate with current C1 code.
  - Strong hand-drawn feel when frames are consistent.
  - Good for small chibi characters.
- **Cons**:
  - AI frame consistency risk grows quickly with detailed human illustration.
  - Writing, hair, hands, books, and clothing can drift between frames.
  - High production cost for many states.
  - Does not animate the scene itself.
- **Rejection Reason**: Useful as a fallback/rare flipbook, but too expensive and fragile as the main route.

### Alternative 3: Pure Cutout/Skeleton Animation

- **Description**: Split the character into body parts and animate transforms with `AnimationPlayer`, bones, or cutout nodes.
- **Pros**:
  - Highly controllable.
  - Low runtime cost.
  - Easy to tune without regenerating art.
- **Cons**:
  - Can look like paper puppetry if overused.
  - Does not preserve the subtle quality of a detailed concept illustration.
  - Still ignores the scene-as-protagonist requirement.
- **Rejection Reason**: Good as a local technique inside C1, but insufficient as the full architecture.

### Alternative 4: Live2D Primary Avatar

- **Description**: Use a Live2D-style model for the character, similar to Open-LLM-VTuber.
- **Pros**:
  - Excellent for front-facing speech, expressions, lip sync, and VTuber interaction.
  - Mature concept of motions, expressions, hit areas, and emotion mapping.
  - Strong for AI assistant style products.
- **Cons**:
  - Optimized for the character facing the user.
  - Pushes the project toward "AI avatar" rather than "observed life scene."
  - Adds external production/tooling complexity.
  - Does not solve Scene Kit composition.
- **Rejection Reason**: Wrong center of gravity for this project. We may borrow the action-intent layer later, not the full presentation model.

### Alternative 5: Static Scene with Shader Atmosphere Only

- **Description**: Use mostly static art, with only light, dust, and glass shaders.
- **Pros**:
  - Very stable and low cost.
  - Preserves illustration quality.
  - Low risk for MVP.
- **Cons**:
  - Character may feel too inert.
  - Hard to sell "living presence" without at least some local character motion.
- **Rejection Reason**: Good emergency fallback, but too conservative as the primary target.

## Consequences

### Positive

- Aligns animation implementation with the project's core philosophy.
- Keeps the concept art quality by avoiding excessive full-frame AI animation.
- Supports independent iteration of scene, character, glass, foreground, and leak content.
- Reduces long-term rework by making P1 a real scene compositor.
- Keeps rare video/flipbook/event animation available without letting it dominate architecture.
- Makes the first validation sprint concrete: prove the window-side life scene works before expanding asset count.

### Negative

- Requires updating C1 and P1 documents and implementation assumptions.
- More node/layer management than a single background plus character sprite.
- Requires clearer asset naming, anchors, and layer contracts.
- Requires art production discipline: hidden areas must be rebuilt, not left as holes.

### Risks

1. **Layered assets may not visually cohere**
   - Mitigation: First produce a six-piece VS01 kit and test in Godot before expanding.

2. **Character local animation may look cheap**
   - Mitigation: Keep motion minimal; if hand/pen split fails, use transparent character flipbook for the writing loop.

3. **P1 scope may grow too large**
   - Mitigation: MVP compositor supports six core layers only. Weather, seasons, and multi-location scenes are deferred.

4. **Old C1 full-frame assumptions may keep leaking into production**
   - Mitigation: Update C1 GDD and C1 asset specs after this ADR is accepted.

## Performance Implications

- **CPU**: Low. Most common motion is Tween/AnimationPlayer property animation.
- **GPU**: Moderate increase from extra transparent layers and shaders. The 320x320 viewport keeps risk low.
- **Memory**: Higher than a single background, lower than long video or many full-body frame sets.
- **Load Time**: Slight increase due to multiple PNG layers. Acceptable for desktop idle app.
- **Network**: None.

## Migration Plan

1. Create Scene Kit production docs and VS01 asset specification.
2. Update Sprint 6 scope: replace "frame animation vs skeleton animation" with Scene Kit runtime validation.
3. Implement a P1 Scene Compositor prototype with six core layers.
4. Replace the C1 placeholder full-body sprite with a `CharacterPerformanceRoot` prototype.
5. Wire F2, C2, F5, and Fe2 into the new presentation stack.
6. Run Godot headless verification after any `.gd`/`.tscn` edits.
7. After validation, update C1/P1 GDDs and art specs to remove obsolete assumptions.

## Validation Criteria

- [ ] A 320x320 test window displays the VS01 Scene Kit with correct layer order.
- [ ] The exterior can be swapped without breaking interior/character layers.
- [ ] Away state dims the scene and hides the character without exposing holes.
- [ ] F5 connection quality changes glass/clarity/warmth without UI status text.
- [ ] `writing_idle` uses at least one local animated element such as hand/pen or paper.
- [ ] `aware_pause` reads as "noticed something near the window" without direct viewer eye contact.
- [ ] Fe2 leak content can appear above the scene without covering the character's core action.
- [ ] The prototype holds 60fps in the target desktop window.
- [ ] Godot verification reports zero `ERROR`, `SCRIPT ERROR`, or `WARNING`.

## Related Decisions

- [ADR-001: F1 桌面窗口系统实现方案](adr-001-desktop-window-system.md)
- [ADR-003: 模块化架构和加载模式](adr-003-modular-architecture.md)
- [C1 Character Animation System](../../design/gdd/c1-character-animation-system.md)
- [P1 Main UI](../../design/gdd/p1-main-ui.md)
- [Connection Relationship](../../design/core/connection-relationship.md)
