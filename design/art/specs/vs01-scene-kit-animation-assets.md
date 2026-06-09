# VS01 Scene Kit Animation Asset Specification

> **Status**: Draft for Prototype
> **Created**: 2026-06-08
> **Scene ID**: VS01
> **Concept Source**: Window-side writing room concept master
> **Architecture**: Scene Kit Runtime Composition

## Purpose

VS01 is the first minimum Scene Kit used to validate the new animation route. It is not a final art pack. It is a production test kit designed to prove that a window-side life scene can be rebuilt as layered, composable assets and animated gently in Godot.

## Source Rule

The reference concept is a **composition and mood master**, not a cutout source.

Do:

- Rebuild full hidden areas behind character, desk props, and foreground plants.
- Export transparent layers where runtime occlusion or replacement is needed.
- Preserve the feeling of architectural sketch, quiet room, window view, and private writing activity.

Do not:

- Crop the concept image into layers.
- Leave holes behind removed character/desk/foreground elements.
- Bake connection state, leak content, or character motion into the room base.

## Runtime Layer Order

```text
0  Exterior_Window_View_Combined
1  Interior_Room_Frame_Occluder
2  Desk_Base
3  Desk_Props_Minimal
4  Character_Writing_Static
5  Character_Local_Motion
6  Foreground_Plants
7  Glass_Atmosphere
8  Signal_Warmth_Overlay
9  Leak_Content
```

For the first pass, layers 3, 5, and 8 may be minimal or placeholder, but their intended slots should exist in the scene.

## Asset List

### VS01-EXT-COMBINED

| Field | Value |
|---|---|
| Asset Name | `Exterior_Window_View_Combined` |
| File Name | `ext_vs01_window_view_combined.png` |
| Required | Yes |
| Transparency | No required alpha |
| Suggested Master Size | 2048x1152 |
| Runtime Role | Exterior city view behind the round window |
| Motion | Slow parallax, optional cloud drift |
| Owner Layer | P1 ExteriorLayer |

**Content**:

- Sky and cloud mass.
- Distant city/towers.
- Near bridge/rooftop silhouettes if needed for depth.
- Lower contrast than interior and character.

**Acceptance**:

- Works behind the round window occluder.
- Can be shifted slightly without obvious tiling or exposed edge.
- Does not compete with the writing character.

### VS01-ROOM-OCCLUDER

| Field | Value |
|---|---|
| Asset Name | `Interior_Room_Frame_Occluder` |
| File Name | `env_vs01_room_frame_occluder.png` |
| Required | Yes |
| Transparency | Yes, window opening transparent |
| Suggested Master Size | 2048x1152 |
| Runtime Role | Room walls, round window frame, interior masking |
| Motion | Mostly static |
| Owner Layer | P1 InteriorOccluderLayer |

**Content**:

- Room wall and dark interior structure.
- Circular window frame/wall hole.
- Book shelves and wall details may be included if not separately exported.
- The window opening must be transparent so the exterior layer shows through.

**Acceptance**:

- Covers the rectangular exterior image outside the round opening.
- No holes appear when the character is hidden.
- Reads as room structure, not magical portal UI.

### VS01-DESK-BASE

| Field | Value |
|---|---|
| Asset Name | `Desk_Base` |
| File Name | `env_vs01_desk_base.png` |
| Required | Yes |
| Transparency | Yes |
| Suggested Master Size | 2048x768 |
| Runtime Role | Desk plane under character and props |
| Motion | Static |
| Owner Layer | P1 DeskLayer |

**Content**:

- Desk surface.
- Base shadows.
- No baked holes from books, hands, or cups.

**Acceptance**:

- Character can be hidden or shifted without exposing missing desk texture.
- Desk provides a believable contact plane for the writing pose.

### VS01-DESK-PROPS-MINIMAL

| Field | Value |
|---|---|
| Asset Name | `Desk_Props_Minimal` |
| File Name | `prop_vs01_desk_props_minimal.png` |
| Required | Recommended |
| Transparency | Yes |
| Suggested Master Size | 1024x512 |
| Runtime Role | A small set of readable life props |
| Motion | Optional paper/steam micro motion later |
| Owner Layer | P1 DeskLayer |

**Content**:

- Open book or paper stack.
- Cup or ink container.
- Small notebook or loose sheets.

**Acceptance**:

- 3 to 5 props are enough for the prototype.
- Props should not face the viewer as if presented to them.

### VS01-CHR-WRITING-STATIC

| Field | Value |
|---|---|
| Asset Name | `Character_Writing_Static` |
| File Name | `chr_aria_writing_static.png` |
| Required | Yes |
| Transparency | Yes |
| Suggested Master Size | 1536x1536 |
| Runtime Role | Main character body pose |
| Motion | Body breathing via C1 AnimationPlayer |
| Owner Layer | C1 BodyPose |

**Content**:

- Character seated at desk, writing.
- Side or three-quarter view.
- Head lowered, focused on her own work.
- No direct viewer eye contact.

**Anchor**:

- Primary anchor should be the writing contact point on the desk or seated body center.
- Do not assume canvas center is the runtime anchor unless explicitly set in import metadata.

**Acceptance**:

- Reads clearly at 320x320.
- Does not feel staged for the player.
- Body can remain mostly static without looking dead once local motion and atmosphere are active.

### VS01-CHR-HAND-PEN-LOOP

| Field | Value |
|---|---|
| Asset Name | `Character_Hand_Pen_Loop` |
| File Name | `chr_aria_hand_pen_write_01.png` to `chr_aria_hand_pen_write_08.png` |
| Required | Prototype Required |
| Transparency | Yes |
| Suggested Master Size | 512x512 |
| Runtime Role | Local writing motion |
| Motion | 4 to 8 frame flipbook |
| Owner Layer | C1 HandPenLoop |

**Content**:

- Only hand, pen, and any necessary wrist/forearm overlap.
- Loop should be subtle and slow enough not to become noisy.

**Acceptance**:

- Frames align with the static body pose.
- No visible popping at loop boundary.
- If this fails visually, switch to a transparent writing flipbook for the whole upper-body area.

### VS01-CHR-AWARE-PAUSE

| Field | Value |
|---|---|
| Asset Name | `Character_Aware_Pause` |
| File Name | `chr_aria_aware_pause_static.png` |
| Required | Recommended |
| Transparency | Yes |
| Suggested Master Size | 1536x1536 |
| Runtime Role | Stop-writing, slight awareness pose |
| Motion | Transition from writing via fade/position/rotation |
| Owner Layer | C1 BodyPose |

**Content**:

- Character pauses writing.
- Head or shoulder angle changes slightly.
- Focus shifts toward the window side, not camera.

**Acceptance**:

- Reads as "maybe noticed something" rather than "looking at the player."
- Can return to writing without feeling like a performance beat.

### VS01-FG-PLANTS

| Field | Value |
|---|---|
| Asset Name | `Foreground_Plants` |
| File Name | `fg_vs01_plants_blur.png` |
| Required | Yes |
| Transparency | Yes |
| Suggested Master Size | 2048x768 |
| Runtime Role | Foreground occlusion and observer distance |
| Motion | Very slight parallax or sway |
| Owner Layer | P1 ForegroundLayer |

**Content**:

- Dark, blurred plant shapes or foreground silhouettes.
- Must help explain that the observer is behind/near something.

**Acceptance**:

- Does not hide the core writing action.
- Adds depth without becoming a decorative blob.

### VS01-GLASS

| Field | Value |
|---|---|
| Asset Name | `Glass_Atmosphere` |
| File Name | `overlay_vs01_glass_atmosphere.png` |
| Required | Yes |
| Transparency | Yes |
| Suggested Master Size | 2048x1152 |
| Runtime Role | Screen glass, dust, reflection, distant connection |
| Motion | Shader/Tween opacity and UV offset |
| Owner Layer | P1 AtmosphereLayer |

**Content**:

- Subtle reflection.
- Light dust or haze.
- No hard UI frame.

**Connection Mapping**:

| F5 State | Glass Strength | Scene Clarity |
|---|---:|---|
| DISCONNECTED | High | Lower clarity, cooler tone |
| DEGRADED | Medium | Slight haze |
| CONNECTED | Low | Mostly clear, still present |

**Acceptance**:

- Expresses distance without looking like an error/glitch effect.
- Does not obscure the character's silhouette.

### VS01-SIGNAL-WARMTH

| Field | Value |
|---|---|
| Asset Name | `Signal_Warmth_Overlay` |
| File Name | `overlay_vs01_signal_warmth.png` |
| Required | Optional for first pass |
| Transparency | Yes |
| Suggested Master Size | 2048x1152 |
| Runtime Role | Stable connection warmth |
| Motion | Slow opacity fade |
| Owner Layer | P1 AtmosphereLayer |

**Content**:

- Warm low-opacity light shape.
- No iconography, no text.

**Acceptance**:

- Stable connection feels warmer without becoming a notification.

## Naming and Folder Proposal

Prototype assets should live under:

```text
assets/art/scene_kits/vs01/
├─ exterior/
├─ interior/
├─ desk/
├─ character/
├─ foreground/
└─ overlays/
```

Suggested files:

```text
assets/art/scene_kits/vs01/exterior/ext_vs01_window_view_combined.png
assets/art/scene_kits/vs01/interior/env_vs01_room_frame_occluder.png
assets/art/scene_kits/vs01/desk/env_vs01_desk_base.png
assets/art/scene_kits/vs01/desk/prop_vs01_desk_props_minimal.png
assets/art/scene_kits/vs01/character/chr_aria_writing_static.png
assets/art/scene_kits/vs01/character/chr_aria_hand_pen_write_01.png
assets/art/scene_kits/vs01/character/chr_aria_aware_pause_static.png
assets/art/scene_kits/vs01/foreground/fg_vs01_plants_blur.png
assets/art/scene_kits/vs01/overlays/overlay_vs01_glass_atmosphere.png
assets/art/scene_kits/vs01/overlays/overlay_vs01_signal_warmth.png
```

## Godot Import Requirements

Default for transparent layers:

```text
Compress > Mode: Lossless
Mipmaps > Generate: false
Process > Fix Alpha Border: true
Process > Premult Alpha: false
Detect 3D > Enabled: false
```

Default for large non-transparent exterior:

```text
Compress > Mode: VRAM Compressed or Lossless during prototype
Mipmaps > Generate: true if scaled frequently
Process > Fix Alpha Border: false
```

## Runtime Animation Requirements

### P1 Motion

| Layer | Motion | Range |
|---|---|---|
| Exterior | Slow parallax | 1 to 4 px over long loops |
| Foreground | Slight parallax/sway | 2 to 8 px, low opacity change if needed |
| Glass | Opacity/UV drift | Subtle, connection-driven |
| Signal Warmth | Opacity fade | Only when connected/stable |

### C1 Motion

| Element | Motion | Range |
|---|---|---|
| BodyPose | Breathing | 1 to 3 px, very slow |
| HandPenLoop | Writing flipbook | 4 to 8 frames |
| HairMicro | Optional sway | 1 to 2 px |
| ShoulderMicro | Optional breathing offset | 1 to 2 px |
| ContactShadow | Opacity/scale | Subtle sync with breathing |

## Prototype Acceptance Checklist

- [ ] Six required layers render in correct order.
- [ ] Hiding the character leaves a complete room and desk.
- [ ] Exterior can move behind the round window without visible rectangle leaks.
- [ ] Character writing pose reads at 320x320.
- [ ] Hand/pen local loop aligns with the body.
- [ ] Aware pause does not look at the viewer.
- [ ] Foreground plants create observation distance without blocking the action.
- [ ] Glass overlay can express disconnected/degraded/connected states.
- [ ] Away state dims the room and hides character.
- [ ] Leak content can appear above the scene without covering the writing pose.
- [ ] Runtime holds 60fps.
- [ ] Any `.gd` or `.tscn` integration passes mandatory Godot verification.

## Deferred Assets

Do not create these until the prototype passes:

- Split sky/city far/city near exterior layers.
- Multiple exterior locations.
- Full desk prop library.
- Full character frame animation sets.
- Live2D model.
- Full weather system.
- Seasonal scene changes.
- Long video loops.

## Review Questions

These should be answered after the first Godot prototype, not before:

| Question | Decision Timing |
|---|---|
| Is local hand/pen animation sufficient? | After C1 prototype |
| Should exterior be split into far/near layers? | After combined exterior works |
| Does glass feel poetic or like a defect? | After F5 visual mapping |
| Is the room too detailed for desktop use? | After 5-minute viewing test |
| Does the character feel alive without full-body animation? | After writing and aware clips |
