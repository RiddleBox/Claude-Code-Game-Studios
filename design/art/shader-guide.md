# Shader Guide: 窗语 (Window Whisper)

*Created: 2026-04-19*
*Status: Active*

---

## Overview

This document describes the custom shaders used to achieve the paper-watercolor visual style in 窗语. All shaders are written in Godot's GLSL-based shader language and target the `canvas_item` render mode (2D).

**Design Goal**: Create a warm, handcrafted aesthetic that unifies disparate visual elements (characters, UI, backgrounds) through consistent material treatment.

---

## Shader 1: Paper Overlay Shader

### Purpose
Applies a subtle paper grain texture to sprites, giving them a tactile, handcrafted quality. This is the primary shader for achieving visual consistency across all assets.

### File Location
`src/shaders/paper_overlay.gdshader`

### Visual Effect
- Overlays tileable paper texture using multiply blend mode
- Adds organic grain without obscuring base colors
- Maintains sprite transparency
- Optional brightness/contrast adjustment for fine-tuning

### Uniform Parameters

| Parameter | Type | Range | Default | Description |
|-----------|------|-------|---------|-------------|
| `paper_texture` | sampler2D | - | white | The paper grain texture (see `assets/art/textures/base/tex_paper_grain.png`) |
| `paper_strength` | float | 0.0 - 1.0 | 0.3 | Intensity of paper effect (0 = no effect, 1 = full strength) |
| `paper_scale` | vec2 | - | (2.0, 2.0) | UV scaling for paper texture (higher = smaller grain) |
| `paper_offset` | vec2 | - | (0.0, 0.0) | UV offset for paper texture (for animation or variation) |
| `brightness_adjust` | float | -0.2 - 0.2 | 0.0 | Brightness adjustment after paper application |
| `contrast_adjust` | float | 0.8 - 1.2 | 1.0 | Contrast adjustment after paper application |

### Recommended Settings by Asset Type

#### Character Sprites
```gdscript
material.set_shader_parameter("paper_strength", 0.25)
material.set_shader_parameter("paper_scale", Vector2(2.0, 2.0))
material.set_shader_parameter("brightness_adjust", 0.0)
material.set_shader_parameter("contrast_adjust", 1.05)
```

#### UI Elements
```gdscript
material.set_shader_parameter("paper_strength", 0.15)
material.set_shader_parameter("paper_scale", Vector2(3.0, 3.0))
material.set_shader_parameter("brightness_adjust", 0.05)
material.set_shader_parameter("contrast_adjust", 1.0)
```

#### Background Layers
```gdscript
material.set_shader_parameter("paper_strength", 0.2)
material.set_shader_parameter("paper_scale", Vector2(1.5, 1.5))
material.set_shader_parameter("brightness_adjust", 0.0)
material.set_shader_parameter("contrast_adjust", 0.95)
```

### Usage Example (GDScript)

```gdscript
extends Sprite2D

func _ready():
	# Create shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://src/shaders/paper_overlay.gdshader")
	
	# Load paper texture
	var paper_tex = load("res://assets/art/textures/base/tex_paper_grain.png")
	shader_material.set_shader_parameter("paper_texture", paper_tex)
	
	# Configure parameters for character sprite
	shader_material.set_shader_parameter("paper_strength", 0.25)
	shader_material.set_shader_parameter("paper_scale", Vector2(2.0, 2.0))
	
	# Apply to sprite
	material = shader_material
```

### Performance Notes
- **Cost**: Low (single texture sample + multiply blend)
- **Batching**: Compatible with sprite batching if same material
- **Mipmaps**: Paper texture should have mipmaps enabled for proper scaling
- **Mobile**: Fully compatible, no performance concerns

### Troubleshooting

**Problem**: Paper texture appears too strong/harsh
- **Solution**: Reduce `paper_strength` to 0.1-0.2 range

**Problem**: Paper grain looks pixelated
- **Solution**: Ensure paper texture has mipmaps enabled in import settings

**Problem**: Colors look washed out
- **Solution**: Increase `contrast_adjust` to 1.05-1.1

**Problem**: Visible tiling pattern in paper texture
- **Solution**: Use higher quality seamless paper texture, or increase `paper_scale`

---

## Shader 2: Edge Softening Shader

### Purpose
Softens the edges of sprites to reduce harsh vector/pixel art feel. Creates a gentle fade at alpha boundaries, mimicking watercolor bleed.

### File Location
`src/shaders/edge_softening.gdshader`

### Visual Effect
- Smooths alpha channel transitions using smoothstep function
- Optional subtle glow around edges
- Maintains sprite shape while reducing harshness
- No color bleeding (only alpha manipulation)

### Uniform Parameters

| Parameter | Type | Range | Default | Description |
|-----------|------|-------|---------|-------------|
| `edge_softness` | float | 0.0 - 0.1 | 0.02 | Width of edge fade zone (higher = softer edges) |
| `edge_threshold` | float | 0.0 - 1.0 | 0.5 | Alpha value at which edge softening begins |
| `enable_glow` | bool | - | false | Enable subtle glow effect around edges |
| `glow_color` | vec4 | - | (1, 1, 1, 0.3) | Color and intensity of glow (RGBA) |
| `glow_size` | float | 0.0 - 0.05 | 0.01 | Size of glow halo |

### Recommended Settings by Asset Type

#### Character Sprites (Primary Use Case)
```gdscript
material.set_shader_parameter("edge_softness", 0.02)
material.set_shader_parameter("edge_threshold", 0.5)
material.set_shader_parameter("enable_glow", false)
```

#### Character Sprites (Emphasized/Magical)
```gdscript
material.set_shader_parameter("edge_softness", 0.03)
material.set_shader_parameter("edge_threshold", 0.5)
material.set_shader_parameter("enable_glow", true)
material.set_shader_parameter("glow_color", Color(1.0, 0.95, 0.8, 0.2))
material.set_shader_parameter("glow_size", 0.015)
```

#### UI Icons (Subtle Softening)
```gdscript
material.set_shader_parameter("edge_softness", 0.01)
material.set_shader_parameter("edge_threshold", 0.5)
material.set_shader_parameter("enable_glow", false)
```

### Usage Example (GDScript)

```gdscript
extends AnimatedSprite2D

func _ready():
	# Create shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://src/shaders/edge_softening.gdshader")
	
	# Configure for character sprite
	shader_material.set_shader_parameter("edge_softness", 0.02)
	shader_material.set_shader_parameter("edge_threshold", 0.5)
	
	# Apply to animated sprite
	material = shader_material

# Optional: Enable glow during special moments
func enable_emphasis_glow():
	material.set_shader_parameter("enable_glow", true)
	material.set_shader_parameter("glow_color", Color(1.0, 0.9, 0.7, 0.25))
	material.set_shader_parameter("glow_size", 0.02)

func disable_emphasis_glow():
	material.set_shader_parameter("enable_glow", false)
```

### Performance Notes
- **Cost**: Low without glow, Medium with glow enabled
- **Glow Cost**: 8 additional texture samples (use sparingly)
- **Batching**: Breaks batching if glow enabled (different shader variant)
- **Mobile**: Glow may impact performance on low-end devices

### Troubleshooting

**Problem**: Edges look too blurry/undefined
- **Solution**: Reduce `edge_softness` to 0.01 or lower

**Problem**: Sprite appears to shrink slightly
- **Solution**: Reduce `edge_threshold` to 0.4-0.45

**Problem**: Glow effect not visible
- **Solution**: Increase `glow_color` alpha channel, or increase `glow_size`

**Problem**: Glow looks pixelated
- **Solution**: Increase sprite resolution, or reduce `glow_size`

**Problem**: Performance drop with glow enabled
- **Solution**: Only enable glow on hero character, disable on background elements

---

## Shader Combination Strategies

### Strategy 1: Layered Application (Recommended)
Apply both shaders sequentially using CanvasLayer or nested nodes:

```gdscript
# Character node structure:
# CharacterSprite (Sprite2D) — has edge_softening shader
#   └─ PaperOverlay (Sprite2D) — duplicate sprite with paper_overlay shader, blend mode Multiply

extends Sprite2D

func _ready():
	# Apply edge softening to main sprite
	var edge_material = ShaderMaterial.new()
	edge_material.shader = load("res://src/shaders/edge_softening.gdshader")
	edge_material.set_shader_parameter("edge_softness", 0.02)
	material = edge_material
	
	# Create paper overlay as child
	var paper_sprite = Sprite2D.new()
	paper_sprite.texture = texture  # Same texture
	paper_sprite.centered = centered
	
	var paper_material = ShaderMaterial.new()
	paper_material.shader = load("res://src/shaders/paper_overlay.gdshader")
	paper_material.set_shader_parameter("paper_texture", load("res://assets/art/textures/base/tex_paper_grain.png"))
	paper_material.set_shader_parameter("paper_strength", 0.25)
	paper_sprite.material = paper_material
	
	# Set blend mode to multiply
	paper_sprite.self_modulate = Color(1, 1, 1, 0.3)  # Control paper intensity via alpha
	
	add_child(paper_sprite)
```

### Strategy 2: Combined Shader (Advanced)
Create a custom shader that combines both effects (requires shader knowledge):

```glsl
// combined_character.gdshader
shader_type canvas_item;

uniform sampler2D paper_texture : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float paper_strength : hint_range(0.0, 1.0) = 0.25;
uniform vec2 paper_scale = vec2(2.0, 2.0);
uniform float edge_softness : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	// Step 1: Edge softening
	vec4 base_color = texture(TEXTURE, UV);
	float softened_alpha = smoothstep(0.5 - edge_softness, 0.5 + edge_softness, base_color.a);
	
	// Step 2: Paper overlay
	vec2 paper_uv = UV * paper_scale;
	float paper_value = dot(texture(paper_texture, paper_uv).rgb, vec3(0.299, 0.587, 0.114));
	float paper_multiplier = mix(1.0, paper_value, paper_strength);
	vec3 final_color = base_color.rgb * paper_multiplier;
	
	COLOR = vec4(final_color, softened_alpha * base_color.a);
}
```

### Strategy 3: Material Presets (Production Workflow)
Create reusable ShaderMaterial resources:

```
res://assets/materials/
  ├─ char_default.tres          # Edge softening + paper overlay preset
  ├─ char_emphasized.tres       # Same + glow enabled
  ├─ ui_element.tres            # Light paper overlay only
  └─ background_layer.tres      # Subtle paper overlay
```

Load in code:
```gdscript
material = load("res://assets/materials/char_default.tres")
```

---

## Shader Application Workflow

### For New Character Assets

1. **Import sprite** into Godot (PNG with alpha)
2. **Create AnimatedSprite2D** node
3. **Apply edge_softening shader** first
   - Set `edge_softness` to 0.02
   - Test in-game, adjust if needed
4. **Add paper_overlay shader** (via child node or combined shader)
   - Set `paper_strength` to 0.25
   - Load `tex_paper_grain.png` as paper texture
5. **Test at multiple scales** (zoom in/out in editor)
6. **Verify performance** (check FPS with multiple instances)

### For UI Elements

1. **Import UI sprite** (PNG with alpha)
2. **Create Sprite2D or TextureRect** node
3. **Apply paper_overlay shader only** (skip edge softening for clarity)
   - Set `paper_strength` to 0.15
   - Set `paper_scale` to Vector2(3.0, 3.0) for finer grain
4. **Test readability** against various backgrounds
5. **Adjust brightness_adjust** if text/icons are too dark

### For Background Layers

1. **Import background art** (PNG, large resolution)
2. **Create Sprite2D** node
3. **Apply paper_overlay shader**
   - Set `paper_strength` to 0.2
   - Set `paper_scale` to Vector2(1.5, 1.5) for larger grain
   - Set `contrast_adjust` to 0.95 for softer look
4. **Layer multiple backgrounds** with different paper offsets for depth
5. **Test with character in foreground** to ensure visual hierarchy

---

## Performance Optimization

### Batching Considerations
- **Same shader + same parameters** = can batch
- **Different shader parameters** = breaks batch
- **Solution**: Use material presets, minimize unique parameter combinations

### Texture Memory
- Paper texture is shared across all instances (loaded once)
- Use VRAM compression for paper texture (see `TEXTURE_SPECS.md`)
- Mipmaps add ~33% memory but improve quality at distance

### Shader Complexity
- Both shaders are fragment-only (no vertex manipulation)
- No branching in hot paths (except optional glow)
- Mobile-friendly (tested on integrated GPUs)

### Profiling Commands
```gdscript
# Check draw calls
print(Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME))

# Check texture memory
print(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED))

# Check FPS
print(Performance.get_monitor(Performance.TIME_FPS))
```

---

## Visual Regression Testing

When modifying shaders, verify against these reference cases:

### Test Case 1: Character Sprite
- **Asset**: `char_mochi_idle_01.png`
- **Expected**: Soft edges, subtle paper grain, warm feel
- **Check**: No harsh outlines, no color shift, alpha preserved

### Test Case 2: UI Button
- **Asset**: `ui_btn_primary_normal.png`
- **Expected**: Clear edges, light paper texture, readable
- **Check**: Text remains sharp, no blur, consistent with other UI

### Test Case 3: Background Layer
- **Asset**: `bg_room_far_01.png`
- **Expected**: Soft watercolor feel, low contrast paper
- **Check**: No obvious tiling, depth maintained, not too noisy

### Test Case 4: Multiple Instances
- **Setup**: 20+ character sprites on screen
- **Expected**: 60 FPS maintained
- **Check**: No frame drops, batching working, memory stable

---

## Troubleshooting Guide

### Common Issues

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Shader not applying | Material not assigned | Check `material` property is set |
| Paper texture missing | Texture not loaded | Verify path to `tex_paper_grain.png` |
| Edges too soft | `edge_softness` too high | Reduce to 0.01-0.02 range |
| Colors too dark | `paper_strength` too high | Reduce to 0.15-0.25 range |
| Performance drop | Glow enabled on many sprites | Disable glow or reduce sprite count |
| Tiling visible | Paper texture not seamless | Use higher quality texture |
| Shader error on load | Godot version mismatch | Verify Godot 4.6+ syntax |

### Debug Visualization

Add this to shader for debugging:
```glsl
// At end of fragment() function, add:
// COLOR = vec4(vec3(paper_value), 1.0);  // Visualize paper texture
// COLOR = vec4(vec3(softened_alpha), 1.0);  // Visualize edge softening
```

---

## Future Shader Roadmap

### Planned Additions (Post-MVP)
- **Watercolor wash shader**: Animated color bleeding for backgrounds
- **Ink outline shader**: Optional stylized outlines for characters
- **Time-of-day shader**: Global color grading based on F3 time system
- **Weather overlay shader**: Rain/snow particle effects

### Experimental Ideas
- **Parallax paper texture**: Scroll paper texture based on camera movement
- **Animated grain**: Subtle noise animation for "living" paper feel
- **Depth-based softening**: Softer edges for background layers

---

## References

### Godot Shader Documentation
- Canvas Item Shaders: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html
- Shader Language: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html

### Visual Inspiration
- Gris (watercolor backgrounds)
- Child of Light (paper texture overlays)
- Ori series (soft character edges)

### Technical References
- Smoothstep function: https://en.wikipedia.org/wiki/Smoothstep
- Multiply blend mode: https://en.wikipedia.org/wiki/Blend_modes#Multiply

---

*This guide is a living document. Update when new shaders are added or existing shaders are modified. All changes should be tested against the visual regression test cases.*
