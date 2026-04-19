# Shader Material Presets

This directory contains reusable ShaderMaterial resources (.tres files) for common visual styles in 窗语 (Window Whisper).

## Purpose

Instead of configuring shader parameters in code every time, load these preset materials directly:

```gdscript
# Instead of this:
var material = ShaderMaterial.new()
material.shader = load("res://src/shaders/paper_overlay.gdshader")
material.set_shader_parameter("paper_strength", 0.25)
# ... etc

# Do this:
material = load("res://assets/materials/char_default.tres")
```

## Available Presets

### Character Materials

| File | Shaders | Use Case |
|------|---------|----------|
| `char_default.tres` | Edge softening + Paper overlay | Standard character sprites |
| `char_emphasized.tres` | Edge softening (with glow) + Paper overlay | Special moments, focus character |
| `char_background.tres` | Edge softening (subtle) + Paper overlay (light) | Background NPCs, less important |

### UI Materials

| File | Shaders | Use Case |
|------|---------|----------|
| `ui_element.tres` | Paper overlay (light) | Buttons, panels, UI backgrounds |
| `ui_icon.tres` | Paper overlay (very light) | Icons, small UI elements |
| `ui_dialogue_bubble.tres` | Paper overlay (medium) | Dialogue bubbles, notifications |

### Background Materials

| File | Shaders | Use Case |
|------|---------|----------|
| `bg_layer_far.tres` | Paper overlay (subtle, low contrast) | Distant background layers |
| `bg_layer_mid.tres` | Paper overlay (medium) | Mid-ground elements |
| `bg_layer_near.tres` | Paper overlay (stronger) | Foreground decorations |

## Status

All presets are **NOT CREATED YET**. These will be created in Godot editor after:
1. Base textures are generated (`assets/art/textures/base/`)
2. Shaders are tested and verified (`src/shaders/`)
3. Visual style is validated with test assets

## Creation Workflow

### Step 1: Create Material in Godot Editor
1. Right-click in FileSystem dock → New Resource → ShaderMaterial
2. Save as `.tres` file in this directory
3. In Inspector, assign shader (e.g., `res://src/shaders/paper_overlay.gdshader`)
4. Configure shader parameters according to preset specifications below

### Step 2: Configure Parameters

#### char_default.tres
```
Shader: res://src/shaders/edge_softening.gdshader
  edge_softness: 0.02
  edge_threshold: 0.5
  enable_glow: false

Next Pass: ShaderMaterial
  Shader: res://src/shaders/paper_overlay.gdshader
    paper_texture: res://assets/art/textures/base/tex_paper_grain.png
    paper_strength: 0.25
    paper_scale: (2.0, 2.0)
    brightness_adjust: 0.0
    contrast_adjust: 1.05
```

#### char_emphasized.tres
```
Shader: res://src/shaders/edge_softening.gdshader
  edge_softness: 0.03
  edge_threshold: 0.5
  enable_glow: true
  glow_color: rgba(255, 242, 204, 64)  # Warm glow
  glow_size: 0.015

Next Pass: ShaderMaterial
  Shader: res://src/shaders/paper_overlay.gdshader
    paper_texture: res://assets/art/textures/base/tex_paper_grain.png
    paper_strength: 0.25
    paper_scale: (2.0, 2.0)
    brightness_adjust: 0.05
    contrast_adjust: 1.1
```

#### ui_element.tres
```
Shader: res://src/shaders/paper_overlay.gdshader
  paper_texture: res://assets/art/textures/base/tex_paper_grain.png
  paper_strength: 0.15
  paper_scale: (3.0, 3.0)
  brightness_adjust: 0.05
  contrast_adjust: 1.0
```

#### bg_layer_far.tres
```
Shader: res://src/shaders/paper_overlay.gdshader
  paper_texture: res://assets/art/textures/base/tex_paper_grain.png
  paper_strength: 0.2
  paper_scale: (1.5, 1.5)
  brightness_adjust: 0.0
  contrast_adjust: 0.95
```

### Step 3: Test and Iterate
1. Apply material to test sprite
2. View in game at 100% scale
3. Test at different zoom levels
4. Adjust parameters if needed
5. Save final version

## Usage Examples

### In Scene (Editor)
1. Select Sprite2D or AnimatedSprite2D node
2. In Inspector → CanvasItem → Material
3. Drag preset `.tres` file from FileSystem

### In Code (Runtime)
```gdscript
extends Sprite2D

func _ready():
	# Load preset material
	material = load("res://assets/materials/char_default.tres")

# Switch to emphasized version during special moment
func emphasize():
	material = load("res://assets/materials/char_emphasized.tres")

func de_emphasize():
	material = load("res://assets/materials/char_default.tres")
```

### Dynamic Parameter Adjustment
```gdscript
# Even with presets, you can override parameters at runtime
func adjust_paper_strength(strength: float):
	if material is ShaderMaterial:
		material.set_shader_parameter("paper_strength", strength)
```

## Maintenance

- When shader files are updated, materials may need reconfiguration
- Test all presets after shader changes
- Document any new presets added to this README
- Keep parameter values consistent with `design/art/shader-guide.md`

## Next Steps

1. ✅ Shaders created (`src/shaders/`)
2. ⏳ Base textures generated (`assets/art/textures/base/`)
3. ⏳ Create preset materials in Godot editor
4. ⏳ Test with placeholder character sprite
5. ⏳ Validate visual consistency across all presets
