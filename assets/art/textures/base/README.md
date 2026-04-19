# Base Texture Library

This directory contains the foundational textures used across all visual assets in 窗语 (Window Whisper).

## Quick Reference

| Texture | Resolution | Tileable | Purpose |
|---------|------------|----------|---------|
| `tex_paper_grain.png` | 512x512 | ✅ Yes | Paper fiber texture for material consistency |
| `tex_watercolor_edge.png` | 256x256 | ❌ No | Soft edge mask for watercolor effects |
| `tex_noise_soft.png` | 256x256 | ✅ Yes | Smooth noise for subtle variation |

## Status

- [ ] `tex_paper_grain.png` — **NOT CREATED YET**
- [ ] `tex_watercolor_edge.png` — **NOT CREATED YET**
- [ ] `tex_noise_soft.png` — **NOT CREATED YET**

## Creation Instructions

See `TEXTURE_SPECS.md` for detailed specifications, AI generation prompts, and technical requirements.

### Quick Start (AI Generation)

**For tex_paper_grain.png:**
```
Prompt: Seamless tileable paper texture, subtle fiber grain, watercolor paper surface, 
neutral gray, soft organic noise, no harsh contrasts, top-down view, even lighting, 
photorealistic material scan, 4K resolution

Negative: text, watermarks, stains, wrinkles, folds, shadows, directional lighting, 
obvious patterns, high contrast
```

**For tex_watercolor_edge.png:**
```
Prompt: Single watercolor paint blob, soft feathered edges, organic irregular shape, 
white paint on transparent background, top-down view, diffuse edge, natural bleed effect, 
isolated element, high resolution alpha mask

Negative: multiple blobs, hard edges, geometric shapes, patterns, texture, noise, 
background elements
```

**For tex_noise_soft.png:**
```
Prompt: Seamless tileable Perlin noise texture, soft organic clouds, subtle value variation, 
neutral gray, smooth gradients, abstract flow pattern, no harsh edges, procedural noise

Negative: high contrast, sharp details, geometric patterns, obvious repetition, 
directional flow, texture details
```

## Usage

These textures are referenced by shaders in `src/shaders/`:
- `paper_overlay.gdshader` uses `tex_paper_grain.png`
- `edge_softening.gdshader` optionally uses `tex_watercolor_edge.png`
- Background shaders use `tex_noise_soft.png`

See `design/art/shader-guide.md` for implementation details.

## Directory Structure

```
base/
├── README.md                    # This file
├── TEXTURE_SPECS.md             # Detailed specifications
├── tex_paper_grain.png          # [TO BE CREATED]
├── tex_watercolor_edge.png      # [TO BE CREATED]
├── tex_noise_soft.png           # [TO BE CREATED]
└── source/                      # Source files (PSD/XCF) - gitignored
```

## Import Settings (Godot)

All textures should use these import settings:
- **Compress Mode**: VRAM Compressed
- **Mipmaps**: Generate = true
- **Filter**: Linear
- **Repeat**: Enabled (for tileable textures), Disabled (for masks)

## Next Steps

1. Generate or create the 3 base textures using specifications in `TEXTURE_SPECS.md`
2. Place PNG files in this directory
3. Import into Godot and verify settings
4. Test with shaders in `src/shaders/`
5. Update status checkboxes above when complete
