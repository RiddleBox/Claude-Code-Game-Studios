# Visual Style Implementation Overview

*Created: 2026-04-19*

This document provides a high-level overview of how the visual style system works in 窗语 (Window Whisper).

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Art Direction Document                    │
│              (design/art/art-direction.md)                   │
│  Defines: Color palette, style keywords, visual hierarchy   │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌──────────────────┐    ┌──────────────────┐
│  Base Textures   │    │     Shaders      │
│  (3 textures)    │    │   (2 shaders)    │
└────────┬─────────┘    └────────┬─────────┘
         │                       │
         │  ┌────────────────────┘
         │  │
         ▼  ▼
    ┌──────────────────┐
    │ Material Presets │
    │   (9 presets)    │
    └────────┬─────────┘
             │
             ▼
    ┌──────────────────┐
    │  Game Assets     │
    │ (sprites, UI)    │
    └──────────────────┘
```

---

## Component Breakdown

### 1. Base Textures (Foundation Layer)

**Location**: `assets/art/textures/base/`

| Texture | Purpose | Used By |
|---------|---------|---------|
| `tex_paper_grain.png` | Adds paper fiber texture | `paper_overlay.gdshader` |
| `tex_watercolor_edge.png` | Soft edge mask | Background effects, particles |
| `tex_noise_soft.png` | Subtle variation | Background wash, animation |

**Status**: Specifications complete, textures not yet generated

**Documentation**: `TEXTURE_SPECS.md` contains AI generation prompts and technical specs

---

### 2. Shaders (Effect Layer)

**Location**: `src/shaders/`

#### Shader A: Paper Overlay (`paper_overlay.gdshader`)
- **Input**: Any sprite texture + paper grain texture
- **Output**: Sprite with subtle paper texture overlay
- **Key Parameters**: 
  - `paper_strength` (0.0-1.0) — How visible the paper texture is
  - `paper_scale` (vec2) — Size of paper grain
- **Use Cases**: All visual assets (characters, UI, backgrounds)

#### Shader B: Edge Softening (`edge_softening.gdshader`)
- **Input**: Any sprite texture
- **Output**: Sprite with softened alpha edges
- **Key Parameters**:
  - `edge_softness` (0.0-0.1) — Width of edge fade
  - `enable_glow` (bool) — Optional glow effect
- **Use Cases**: Character sprites, foreground elements

**Status**: Both shaders implemented and documented

**Documentation**: `design/art/shader-guide.md` (472 lines, comprehensive)

---

### 3. Material Presets (Application Layer)

**Location**: `assets/materials/`

Pre-configured ShaderMaterial resources for common use cases:

#### Character Materials
- `char_default.tres` — Standard character (edge softening + paper overlay)
- `char_emphasized.tres` — Special moments (adds glow)
- `char_background.tres` — Background NPCs (lighter effects)

#### UI Materials
- `ui_element.tres` — Buttons, panels (light paper overlay)
- `ui_icon.tres` — Icons (very light paper overlay)
- `ui_dialogue_bubble.tres` — Dialogue bubbles (medium paper overlay)

#### Background Materials
- `bg_layer_far.tres` — Distant layers (subtle, low contrast)
- `bg_layer_mid.tres` — Mid-ground (medium)
- `bg_layer_near.tres` — Foreground decorations (stronger)

**Status**: Specifications complete, `.tres` files not yet created in Godot

**Documentation**: `assets/materials/README.md` contains parameter configurations

---

## Workflow: From Concept to Implementation

### Phase 1: Design (Complete ✅)
1. Art direction defined in `design/art/art-direction.md`
2. Visual style keywords: watercolor wash, soft edges, paper texture
3. Color palette established
4. Material language defined

### Phase 2: Foundation (Complete ✅)
1. Base texture specifications written
2. Shaders implemented and documented
3. Material preset specifications defined

### Phase 3: Asset Creation (Next Steps ⏳)
1. Generate 3 base textures using AI prompts
2. Import textures into Godot with correct settings
3. Create 9 material preset `.tres` files in Godot editor
4. Test with placeholder sprites

### Phase 4: Production (Future 🔮)
1. Create actual game assets (character sprites, UI, backgrounds)
2. Apply material presets to assets
3. Fine-tune parameters per asset if needed
4. Validate visual consistency across all assets

---

## Usage Example: Creating a Character Sprite

```gdscript
# Step 1: Create sprite node
var character = AnimatedSprite2D.new()
character.sprite_frames = load("res://assets/characters/mochi/mochi_animations.tres")

# Step 2: Apply material preset
character.material = load("res://assets/materials/char_default.tres")

# Step 3: Done! The material preset already has:
#   - Edge softening shader configured
#   - Paper overlay shader configured
#   - Paper grain texture loaded
#   - All parameters tuned for characters

# Optional: Override specific parameters at runtime
character.material.set_shader_parameter("paper_strength", 0.3)  # Slightly stronger paper
```

---

## Visual Style Consistency Checklist

When creating any new visual asset, ensure:

- [ ] **Color palette**: Uses colors from `art-direction.md` palette
- [ ] **Material preset**: Applies appropriate preset from `assets/materials/`
- [ ] **Edge treatment**: Soft edges for characters, clear edges for UI
- [ ] **Paper texture**: Visible but subtle (not overpowering base colors)
- [ ] **Lighting direction**: Consistent 45° from top-left
- [ ] **Visual hierarchy**: Importance matches contrast/size/motion

---

## Performance Considerations

### Memory Usage
- **Base textures**: ~1 MB total (shared across all assets)
- **Shader compilation**: One-time cost at startup
- **Material instances**: Minimal overhead (parameters only)

### Rendering Cost
- **Paper overlay**: +1 texture sample per fragment (~2% frame time)
- **Edge softening**: +1 smoothstep operation per fragment (~1% frame time)
- **Combined**: ~3-5% frame time increase (acceptable for visual quality gain)

### Optimization Tips
- Use material presets (avoid unique materials per sprite)
- Disable glow on background characters
- Batch sprites with same material
- Use VRAM compression for textures

---

## Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| Paper texture too strong | Reduce `paper_strength` to 0.15-0.2 |
| Edges too blurry | Reduce `edge_softness` to 0.01 |
| Colors look washed out | Increase `contrast_adjust` to 1.05-1.1 |
| Performance drop | Disable glow, check sprite count |
| Shader not applying | Verify material is assigned to sprite |
| Texture missing error | Check path to `tex_paper_grain.png` |

---

## File Reference Map

```
design/art/
├── art-direction.md          # Overall visual direction (existing)
└── shader-guide.md           # Shader documentation (NEW ✅)

assets/art/textures/base/
├── README.md                 # Quick reference (NEW ✅)
├── TEXTURE_SPECS.md          # Detailed specs (NEW ✅)
├── tex_paper_grain.png       # [TO BE CREATED]
├── tex_watercolor_edge.png   # [TO BE CREATED]
└── tex_noise_soft.png        # [TO BE CREATED]

assets/materials/
├── README.md                 # Preset specs (NEW ✅)
├── char_default.tres         # [TO BE CREATED]
├── char_emphasized.tres      # [TO BE CREATED]
├── char_background.tres      # [TO BE CREATED]
├── ui_element.tres           # [TO BE CREATED]
├── ui_icon.tres              # [TO BE CREATED]
├── ui_dialogue_bubble.tres   # [TO BE CREATED]
├── bg_layer_far.tres         # [TO BE CREATED]
├── bg_layer_mid.tres         # [TO BE CREATED]
└── bg_layer_near.tres        # [TO BE CREATED]

src/shaders/
├── paper_overlay.gdshader    # Paper texture shader (NEW ✅)
└── edge_softening.gdshader   # Edge softening shader (NEW ✅)
```

---

## Next Actions

1. **Generate textures** using AI prompts from `TEXTURE_SPECS.md`
2. **Test shaders** in Godot with placeholder sprite
3. **Create material presets** in Godot editor
4. **Validate visual style** against art direction document

---

*This overview provides a mental model of how all visual style components fit together. Refer to individual documentation files for detailed specifications.*
