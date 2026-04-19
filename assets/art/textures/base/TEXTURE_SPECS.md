# Base Texture Library Specifications

*Created: 2026-04-19*
*Status: Active*

---

## Overview

This document defines the base texture library used across all visual assets in 窗语 (Window Whisper). These textures are applied via shaders to create the unified paper-watercolor aesthetic.

**Purpose**: Provide tileable, reusable textures that add warmth and handcrafted feel without requiring unique textures per asset.

---

## Texture 1: Paper Grain Texture

### File Information
- **Filename**: `tex_paper_grain.png`
- **Resolution**: 512x512 pixels
- **Format**: PNG (8-bit grayscale or RGB)
- **Color Space**: sRGB
- **Tileable**: YES (seamless on all edges)
- **File Size Target**: < 200KB

### Visual Characteristics
- **Style**: Subtle paper fiber texture with organic grain
- **Contrast**: Low (avoid harsh black/white spots)
- **Frequency**: Medium-high (visible at 1:1 scale but not distracting)
- **Directionality**: Minimal (avoid obvious brush strokes)
- **Value Range**: 40-60% gray (middle values only)

### Usage Scenarios
- **Character sprites**: Overlay at 20-30% opacity to add tactile warmth
- **UI backgrounds**: Overlay at 15-25% opacity for subtle depth
- **Background elements**: Overlay at 10-20% opacity for consistency

### Technical Requirements
- Must tile seamlessly (test by placing 2x2 grid)
- No visible seams or repetition patterns
- Grayscale preferred (shader will multiply with base color)
- Mipmap-friendly (no fine details that alias when scaled down)

### AI Generation Prompt (Stable Diffusion / Midjourney)

```
Seamless tileable paper texture, subtle fiber grain, watercolor paper surface, 
neutral gray, soft organic noise, no harsh contrasts, top-down view, 
even lighting, photorealistic material scan, 4K resolution

Negative prompt: text, watermarks, stains, wrinkles, folds, shadows, 
directional lighting, obvious patterns, high contrast
```

### Alternative Generation Method
Use procedural noise in image editor:
1. Create 512x512 canvas, fill with 50% gray
2. Add Perlin noise (scale: 8-12, detail: 3-4, roughness: 0.5)
3. Reduce opacity to 30%
4. Add slight Gaussian blur (0.5-1px) to soften
5. Ensure edges tile using offset filter (256px horizontal + vertical)

---

## Texture 2: Watercolor Edge Texture

### File Information
- **Filename**: `tex_watercolor_edge.png`
- **Resolution**: 256x256 pixels
- **Format**: PNG with Alpha channel
- **Color Space**: sRGB
- **Tileable**: NO (used as mask/stamp)
- **File Size Target**: < 150KB

### Visual Characteristics
- **Style**: Soft, irregular edge fade mimicking watercolor bleed
- **Shape**: Circular/organic blob with feathered edges
- **Center**: Fully opaque white (255, 255, 255, 255)
- **Edge**: Gradual fade to transparent (alpha 0)
- **Transition Zone**: 30-40% of radius (soft falloff)
- **Irregularity**: Slight organic variation (not perfect circle)

### Usage Scenarios
- **Background layers**: Apply as mask to create soft vignette edges
- **Particle effects**: Use as sprite texture for ambient particles
- **Shader effects**: Sample as lookup texture for edge softening

### Technical Requirements
- Alpha channel must be smooth gradient (no banding)
- Center must be fully opaque for maximum flexibility
- Edges must fade to fully transparent (alpha = 0)
- No color information needed (white RGB, alpha does the work)

### AI Generation Prompt (Stable Diffusion / Midjourney)

```
Single watercolor paint blob, soft feathered edges, organic irregular shape, 
white paint on transparent background, top-down view, diffuse edge, 
natural bleed effect, isolated element, high resolution alpha mask

Negative prompt: multiple blobs, hard edges, geometric shapes, patterns, 
texture, noise, background elements
```

### Manual Creation Method
In Photoshop/GIMP/Krita:
1. Create 256x256 canvas with transparent background
2. Use soft round brush (hardness: 0%, size: 180px)
3. Paint white blob in center
4. Apply Gaussian blur (radius: 15-20px)
5. Use Liquify tool to add slight organic irregularity
6. Adjust levels to ensure center is fully opaque
7. Export as PNG with alpha

---

## Texture 3: Soft Noise Texture

### File Information
- **Filename**: `tex_noise_soft.png`
- **Resolution**: 256x256 pixels
- **Format**: PNG (8-bit grayscale)
- **Color Space**: sRGB
- **Tileable**: YES (seamless on all edges)
- **File Size Target**: < 100KB

### Visual Characteristics
- **Style**: Smooth Perlin-like noise, organic flow
- **Contrast**: Very low (gentle value variation)
- **Frequency**: Low (large, smooth shapes)
- **Value Range**: 45-55% gray (narrow range for subtlety)
- **Pattern**: No obvious repetition or directionality

### Usage Scenarios
- **Shader randomization**: Add subtle variation to color/position
- **Background wash**: Create gentle color shifts in sky/water
- **Animation**: Scroll slowly for ambient movement

### Technical Requirements
- Must tile seamlessly (critical for scrolling effects)
- Low frequency to avoid visual noise
- Smooth gradients (no sharp transitions)
- Suitable for UV scrolling (no obvious repetition when animated)

### AI Generation Prompt (Stable Diffusion / Midjourney)

```
Seamless tileable Perlin noise texture, soft organic clouds, 
subtle value variation, neutral gray, smooth gradients, 
abstract flow pattern, no harsh edges, procedural noise

Negative prompt: high contrast, sharp details, geometric patterns, 
obvious repetition, directional flow, texture details
```

### Procedural Generation Method
Use Blender or shader graph:
1. Create 256x256 plane
2. Apply Noise Texture node (Scale: 2.0, Detail: 2, Roughness: 0.4)
3. ColorRamp to compress values to 45-55% range
4. Bake to image texture
5. Verify tiling by checking edges match

### Alternative: Godot NoiseTexture2D
```gdscript
# Can be generated at runtime if needed
var noise = NoiseTexture2D.new()
var noise_gen = FastNoiseLite.new()
noise_gen.noise_type = FastNoiseLite.TYPE_PERLIN
noise_gen.frequency = 0.02
noise_gen.fractal_octaves = 2
noise.noise = noise_gen
noise.width = 256
noise.height = 256
noise.seamless = true
```

---

## Texture Integration Checklist

Before using any texture in production:

### Technical Validation
- [ ] File size within target range
- [ ] Resolution matches specification
- [ ] Format correct (PNG with/without alpha as specified)
- [ ] Tileable textures verified (2x2 grid test)
- [ ] No compression artifacts visible
- [ ] Imports correctly into Godot without errors

### Visual Validation
- [ ] Matches art direction (paper-watercolor aesthetic)
- [ ] Contrast level appropriate (not too harsh)
- [ ] No distracting patterns or repetition
- [ ] Works at multiple scales (test at 50%, 100%, 200%)
- [ ] Blends well with color palette

### Performance Validation
- [ ] Mipmaps generate correctly
- [ ] No performance impact when applied to multiple sprites
- [ ] Memory usage acceptable (check in Godot profiler)

---

## Godot Import Settings

### For Paper Grain Texture (tex_paper_grain.png)
```
Compress > Mode: VRAM Compressed
Mipmaps > Generate: true
Repeat: Enabled
Filter: true (Linear)
```

### For Watercolor Edge Texture (tex_watercolor_edge.png)
```
Compress > Mode: VRAM Compressed
Mipmaps > Generate: true
Repeat: Disabled
Filter: true (Linear)
```

### For Soft Noise Texture (tex_noise_soft.png)
```
Compress > Mode: VRAM Compressed
Mipmaps > Generate: true
Repeat: Enabled
Filter: true (Linear)
```

---

## Texture Variants (Future Expansion)

### Potential Additional Textures
- `tex_paper_grain_rough.png` — Heavier grain for emphasis elements
- `tex_watercolor_splatter.png` — Irregular splatter shapes for accents
- `tex_canvas_weave.png` — Canvas texture for alternative material feel
- `tex_noise_fine.png` — Higher frequency noise for detail variation

**Note**: Only create variants when specific need arises. Start with the 3 base textures.

---

## Maintenance Notes

- Textures are version-controlled in git (binary files)
- Source files (PSD/XCF) should be stored in `assets/art/textures/base/source/` (gitignored)
- Any changes to base textures require visual regression testing across all assets
- Document any modifications in git commit messages

---

*This specification ensures consistent material language across all visual assets while maintaining performance and flexibility.*
