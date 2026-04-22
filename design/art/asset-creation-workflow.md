# Asset Creation Workflow

## Overview

This document defines the production workflow for creating visual assets using AI generation tools (primarily Nana Banana), quality evaluation criteria, and structured feedback loops.

## Background Scene Production Checklist

### Phase 1: Concept & Reference
- [ ] Review art bible for style constraints (color palette, line weight, texture language)
- [ ] Identify scene purpose (gameplay context, mood, time of day)
- [ ] Gather reference images (architecture, lighting, composition)
- [ ] Define key visual elements (focal points, depth layers, atmospheric effects)
- [ ] Sketch thumbnail composition (rule of thirds, visual flow)

### Phase 2: AI Generation (Nana Banana)
- [ ] Select appropriate prompt template from library (see Prompt Library section)
- [ ] Customize prompt with scene-specific details
- [ ] Generate initial batch (4-8 variations)
- [ ] Run quality evaluation checklist (see External Workflow: AI Quality Evaluation)
- [ ] Select top 2-3 candidates for refinement

### Phase 3: Refinement & Iteration
- [ ] Apply structured feedback (see External Workflow: Structured Feedback)
- [ ] Regenerate with adjusted prompts
- [ ] Compare against art bible (color accuracy, style consistency)
- [ ] Verify technical specs (resolution, format, file size)
- [ ] Check visual hierarchy (does it guide player attention correctly?)

### Phase 4: Integration & Testing
- [ ] Import to Godot (verify import settings)
- [ ] Place in test scene with UI overlay
- [ ] Test readability at target resolution (1920x1080 minimum)
- [ ] Verify performance (draw calls, memory usage)
- [ ] Validate against accessibility guidelines (contrast ratios)

### Phase 5: Documentation & Archival
- [ ] Apply naming convention (see Naming Convention section)
- [ ] Document generation parameters (prompt, seed, model version)
- [ ] Add to asset registry (`assets/registry.md`)
- [ ] Commit to version control with descriptive message
- [ ] Update art bible if new patterns/techniques emerged

## Nana Banana Prompt Library (Expanded)

### Base Template Structure
```
[Style Descriptor], [Subject/Scene], [Composition], [Lighting], [Mood], [Color Palette], [Technical Specs], [Negative Prompt]
```

### Style Descriptor (Always Include)
```
Watercolor illustration with soft edges and paper texture, gentle color bleeding, hand-painted aesthetic, warm and inviting atmosphere, organic brush strokes, subtle grain texture
```

### Scene Type Templates (Detailed)

#### Interior Room - Cozy Bedroom
**Template**:
```
Watercolor illustration with soft edges and paper texture, cozy bedroom interior with [bed/desk/bookshelf], warm natural light streaming through window on [left/right], gentle shadows on wooden floor, muted pastel palette with cream walls and soft blue accents, lived-in atmosphere with personal items, slightly asymmetric composition with bed as focal point, depth through overlapping furniture, visible paper grain texture, 16:9 landscape format
```

**Complete Examples**:

1. **Morning Bedroom (Warm & Peaceful)**:
```
Watercolor illustration with soft edges and paper texture, cozy bedroom interior with unmade bed and small nightstand, warm golden morning light streaming through window on left side, long gentle shadows on wooden floor, muted pastel palette with cream walls and peach bedding, soft yellow curtains, lived-in atmosphere with open book on nightstand, slightly asymmetric composition with bed as focal point, depth through overlapping furniture and window frame, visible paper grain texture, gentle color bleeding at edges, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D render, sharp vector edges, neon colors, cluttered, busy patterns, text, UI elements, people, harsh shadows, oversaturated
```

2. **Evening Bedroom (Calm & Intimate)**:
```
Watercolor illustration with soft edges and paper texture, cozy bedroom interior with neatly made bed and reading lamp, warm amber sunset glow through window on right side, deep blue shadows in corners, muted palette with lavender walls and cream bedding, soft orange lamp light, serene atmosphere with plant on windowsill, rule of thirds composition with window as secondary focal point, layered depth with foreground lamp and background window, visible paper texture, gentle color diffusion, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, CGI, hard edges, bright neon, messy room, complex patterns, text overlays, characters, dramatic lighting, pure black shadows, oversaturated colors
```

3. **Night Bedroom (Quiet & Restful)**:
```
Watercolor illustration with soft edges and paper texture, cozy bedroom interior with bed and small desk, cool moonlight filtering through curtained window, deep shadows with limited color palette, muted blue-gray walls and white bedding, mysterious quiet mood, centered composition with bed as focal point, minimal details in shadows, visible paper grain, soft color bleeding at light edges, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D, sharp lines, vibrant colors, cluttered space, busy details, text, people, harsh contrast, pure black, oversaturated
```

#### Interior Room - Study/Library
**Template**:
```
Watercolor illustration with soft edges and paper texture, quiet study room with [bookshelf/desk/chair], [lighting type] from [direction], gentle shadows, [color palette], contemplative atmosphere, [composition style], depth through book stacks and furniture, visible paper texture, 16:9 landscape format
```

**Complete Examples**:

1. **Afternoon Study (Bright & Focused)**:
```
Watercolor illustration with soft edges and paper texture, quiet study room with tall bookshelf and wooden desk, bright diffused daylight from large window on left, minimal shadows, muted palette with sage green walls and warm brown furniture, cream curtains, contemplative atmosphere with open books on desk, asymmetric composition with desk as focal point, depth through bookshelf layers and window frame, visible paper grain texture, gentle color bleeding, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D render, vector art, neon colors, messy, cluttered, text on books, people, harsh shadows, oversaturated, busy patterns
```

2. **Evening Study (Warm & Cozy)**:
```
Watercolor illustration with soft edges and paper texture, intimate study corner with small bookshelf and reading chair, warm desk lamp glow, deep blue evening shadows, muted palette with terracotta walls and cream chair, soft yellow lamp light, cozy atmosphere with tea cup on side table, centered composition with chair as focal point, layered depth with foreground lamp and background bookshelf, visible paper texture, soft color diffusion at light edges, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, CGI, sharp edges, bright colors, chaotic, complex details, text, characters, dramatic contrast, pure black, oversaturated
```

#### Exterior - Garden/Nature
**Template**:
```
Watercolor illustration with soft edges and paper texture, [garden/park/forest] exterior with [natural elements], [lighting type], atmospheric perspective with misty background, gentle color gradients, [mood], rule of thirds composition, foreground/midground/background separation, visible paper texture, 16:9 landscape format
```

**Complete Examples**:

1. **Morning Garden (Fresh & Hopeful)**:
```
Watercolor illustration with soft edges and paper texture, small garden exterior with flowering plants and wooden bench, soft golden morning light, long gentle shadows on grass, atmospheric perspective with misty trees in background, gentle color gradients from warm foreground to cool background, peaceful and fresh mood, rule of thirds composition with bench on right third, clear foreground flowers/midground bench/background trees separation, visible paper grain texture, gentle color bleeding at edges, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D, vector art, oversaturated, cluttered, busy patterns, text, people, harsh shadows, pure black, neon colors, sharp edges
```

2. **Afternoon Park (Serene & Open)**:
```
Watercolor illustration with soft edges and paper texture, open park exterior with single tree and path, bright diffused daylight, minimal shadows, atmospheric perspective with pale blue sky and distant buildings, gentle color gradients, serene and quiet mood, asymmetric composition with tree on left third, layered depth with foreground path/midground tree/background cityscape, visible paper texture, soft color diffusion, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, CGI, hard edges, vibrant colors, crowded, complex details, text, characters, dramatic lighting, oversaturated, busy composition
```

3. **Evening Garden (Warm & Nostalgic)**:
```
Watercolor illustration with soft edges and paper texture, intimate garden corner with stone path and lantern, warm amber sunset glow, deep blue shadows under plants, atmospheric perspective with orange sky fading to purple, high contrast color gradients, nostalgic and contemplative mood, centered composition with lantern as focal point, clear foreground stones/midground plants/background sky separation, visible paper grain, gentle color bleeding at light edges, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D render, sharp lines, neon colors, cluttered, busy patterns, text, people, harsh contrast, pure black shadows, oversaturated
```

#### Exterior - Street/Urban
**Template**:
```
Watercolor illustration with soft edges and paper texture, [street/alley/plaza] exterior with [architectural elements], [lighting type], atmospheric perspective, [color palette], [mood], [composition style], depth layers, visible paper texture, 16:9 landscape format
```

**Complete Examples**:

1. **Morning Street (Quiet & Peaceful)**:
```
Watercolor illustration with soft edges and paper texture, quiet residential street with small shops and potted plants, soft golden morning light, long gentle shadows on cobblestones, atmospheric perspective with misty background buildings, muted palette with cream buildings and terracotta roofs, peaceful and empty mood, asymmetric composition with shop entrance on right, clear foreground cobblestones/midground shops/background buildings separation, visible paper grain texture, gentle color bleeding, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D, vector art, oversaturated, crowded, busy details, text on signs, people, cars, harsh shadows, pure black, neon colors, sharp edges
```

2. **Evening Alley (Warm & Intimate)**:
```
Watercolor illustration with soft edges and paper texture, narrow alley with brick walls and hanging plants, warm amber sunset glow from end of alley, deep blue shadows on walls, atmospheric perspective with orange light at vanishing point, muted palette with warm brown bricks and green plants, intimate and cozy mood, centered composition with alley leading to light, strong foreground/midground/background depth through perspective, visible paper texture, soft color diffusion at light source, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, CGI, hard edges, vibrant colors, cluttered, complex patterns, text, characters, harsh contrast, oversaturated, busy composition
```

#### Abstract/Emotional Space
**Template**:
```
Watercolor illustration with soft edges and paper texture, abstract representation of [emotion/concept], flowing organic shapes, [color palette], dreamlike and introspective atmosphere, balanced asymmetry, negative space emphasis, visible paper texture, 16:9 landscape format
```

**Complete Examples**:

1. **Loneliness (Cool & Sparse)**:
```
Watercolor illustration with soft edges and paper texture, abstract representation of loneliness, single small figure silhouette in vast empty space, flowing organic shapes suggesting distance, desaturated blue-gray and muted purple palette with soft beige accents, dreamlike and introspective atmosphere, asymmetric composition with figure in lower third, heavy negative space emphasis in upper two-thirds, visible paper grain texture, gentle color bleeding creating soft boundaries, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D, sharp edges, bright colors, cluttered, busy patterns, text, detailed features, harsh contrast, oversaturated, complex shapes
```

2. **Hope (Warm & Uplifting)**:
```
Watercolor illustration with soft edges and paper texture, abstract representation of hope, upward flowing organic shapes like rising light, soft yellow and peach palette with cream highlights, gentle warm atmosphere, balanced asymmetry with light source in upper third, moderate negative space, visible paper texture, soft color diffusion creating glow effect, dreamlike and optimistic mood, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, CGI, vector art, oversaturated, dark colors, cluttered, text, people, harsh shadows, pure black, neon colors, sharp geometric shapes
```

3. **Memory (Faded & Nostalgic)**:
```
Watercolor illustration with soft edges and paper texture, abstract representation of fading memory, overlapping translucent shapes suggesting fragments, heavily desaturated palette with muted beige and pale blue, nostalgic and melancholic atmosphere, centered composition with overlapping layers, balanced negative space, visible paper grain texture with increased strength, extensive color bleeding creating dreamlike boundaries, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D render, sharp edges, vibrant colors, cluttered, busy details, text, clear figures, harsh contrast, oversaturated, solid shapes
```

### Lighting Variations (Expanded)

#### Time-of-Day Lighting
- **Dawn (5-6 AM)**: `pre-sunrise cool blue light, minimal shadows, soft pink horizon glow, quiet and still atmosphere`
- **Morning (7-10 AM)**: `soft golden morning light, long gentle shadows at 45-degree angle, warm highlights on surfaces, fresh and energetic mood`
- **Late Morning (10-12 PM)**: `bright warm light, shorter shadows, high contrast between light and shadow, clear and vibrant atmosphere`
- **Afternoon (12-3 PM)**: `bright diffused daylight, minimal shadows directly below objects, even illumination, neutral and calm mood`
- **Late Afternoon (3-5 PM)**: `warm yellow light, medium-length shadows, gentle contrast, relaxed atmosphere`
- **Evening/Golden Hour (5-7 PM)**: `warm amber sunset glow, long deep blue shadows, high contrast, nostalgic and contemplative mood`
- **Dusk (7-8 PM)**: `fading orange light, deep purple shadows, low contrast, mysterious and transitional atmosphere`
- **Night (8 PM-5 AM)**: `cool moonlight, deep shadows with limited color palette, high contrast in lit areas, quiet and mysterious mood`

#### Weather/Atmospheric Lighting
- **Clear Sky**: `direct sunlight, defined shadows, high contrast, vibrant colors`
- **Overcast**: `soft gray light, no harsh shadows, muted colors, gentle and even atmosphere, low contrast`
- **Partly Cloudy**: `intermittent sunlight, dappled shadows, moderate contrast, dynamic atmosphere`
- **Misty/Foggy**: `diffused light, no visible shadows, desaturated colors, atmospheric perspective strong, mysterious mood`
- **Rainy**: `cool gray light, wet surfaces with reflections, muted colors, melancholic atmosphere`
- **Snowy**: `bright reflected light, soft shadows, cool color temperature, high key lighting, serene mood`

#### Artificial Lighting
- **Warm Lamp**: `soft yellow-orange glow, limited range, deep shadows outside light cone, cozy and intimate mood`
- **Cool Fluorescent**: `pale blue-white light, even illumination, minimal shadows, clinical or modern atmosphere`
- **Candlelight**: `warm flickering glow, very limited range, dramatic shadows, romantic or mysterious mood`
- **String Lights**: `multiple small warm glows, soft ambient lighting, gentle shadows, festive or cozy atmosphere`

### Color Palette Modifiers (Expanded)

#### Emotional Palettes
- **Warm Comfort**: `peach (#FFD4B2), cream (#FFF8E7), soft yellow (#FFF4A3), muted orange accents (#FFB366), gentle and welcoming`
- **Cool Calm**: `pale blue (#D4E4F7), lavender (#E6D9F2), soft gray (#E8E8E8), white highlights (#FFFFFF), serene and peaceful`
- **Earthy Grounded**: `terracotta (#D4876F), sage green (#B8C5A6), warm brown (#A67C52), off-white (#F5F1E8), stable and natural`
- **Melancholic**: `desaturated blue-gray (#B8C5D4), muted purple (#C5B8D4), soft beige (#E8DDD4), minimal contrast, introspective and sad`
- **Energetic Optimism**: `soft coral (#FFB8A3), light mint (#B8F2D4), pale yellow (#FFF8B8), cream (#FFF8E7), uplifting and hopeful`
- **Mysterious Twilight**: `deep blue-purple (#6B7BA6), muted indigo (#7B6BA6), soft gray-blue (#A6B8C5), dark shadows, enigmatic and contemplative`

#### Seasonal Palettes
- **Spring**: `soft pink (#FFD4E6), light green (#D4F2B8), pale yellow (#FFF8D4), sky blue (#D4E6FF), fresh and renewing`
- **Summer**: `bright cream (#FFFAE6), soft blue (#B8D4FF), light coral (#FFD4B8), white (#FFFFFF), warm and vibrant`
- **Autumn**: `burnt orange (#D4876F), golden yellow (#FFD4A3), warm brown (#A67C52), deep red (#B86F6F), nostalgic and rich`
- **Winter**: `cool white (#F5F8FF), pale blue (#D4E4F7), soft gray (#E8E8E8), icy blue (#B8D4E6), crisp and serene`

#### Saturation Levels
- **High Saturation (Vibrant)**: `increase color intensity by 20-30%, use for energetic or dramatic scenes`
- **Medium Saturation (Balanced)**: `standard palette, use for most scenes, comfortable for long viewing`
- **Low Saturation (Muted)**: `decrease color intensity by 30-50%, use for melancholic or nostalgic scenes`
- **Desaturated (Faded)**: `decrease color intensity by 50-70%, use for memories or dreams`

### Composition Keywords (Expanded)

#### Focal Point Strategies
- `centered focal point with breathing room and minimal distractions`
- `off-center focal point on rule of thirds intersection, balanced by secondary element`
- `focal point in lower third, emphasizing sky or upper space`
- `focal point in upper third, emphasizing ground or lower space`
- `multiple focal points with clear visual hierarchy (primary, secondary, tertiary)`

#### Balance & Weight
- `asymmetric balance with visual weight on left third, right side open for UI`
- `asymmetric balance with visual weight on right third, left side open for character`
- `symmetric balance with centered focal point, formal and stable composition`
- `dynamic diagonal balance, creating movement and energy`
- `radial balance with focal point at center, elements radiating outward`

#### Depth & Layers
- `layered depth with foreground silhouette, midground focal point, background atmosphere`
- `strong foreground framing through architectural element (window, door, arch)`
- `strong foreground framing through natural element (tree branches, plants)`
- `atmospheric perspective with three distinct depth layers (near, mid, far)`
- `overlapping elements creating depth (furniture, plants, architectural details)`

#### Visual Flow & Leading Lines
- `leading lines toward focal point through path, road, or hallway`
- `leading lines toward focal point through architectural elements (walls, beams)`
- `leading lines toward focal point through natural elements (tree trunks, rivers)`
- `S-curve composition creating gentle visual flow`
- `diagonal lines creating dynamic movement toward focal point`

#### Negative Space
- `heavy negative space in upper two-thirds, focal point in lower third`
- `negative space on left/right side for UI overlay placement`
- `balanced negative space around focal point, creating breathing room`
- `minimal negative space, intimate and enclosed feeling`
- `asymmetric negative space, creating tension or movement`

### Technical Specs (Always Append)
```
, high resolution, clean edges suitable for game background, no text or UI elements, no visible characters or people, suitable for 1920x1080 display, optimized for digital screen viewing
```

### Negative Prompt Library (Critical)

#### Universal Negative Prompts (Always Include)
```
photorealistic, 3D render, CGI, vector art, sharp edges, hard lines, oversaturated colors, neon colors, pure black shadows, text, UI elements, watermarks, signatures, people, characters, faces, animals with human features, busy patterns, cluttered composition, complex details, harsh contrast, dramatic lighting
```

#### Scene-Specific Negative Prompts

**Interior Scenes**:
```
messy, cluttered, chaotic, too many objects, busy wallpaper, complex patterns, visible text on books/posters, people, pets, modern electronics (unless intended), harsh fluorescent lighting, pure white walls, sterile atmosphere
```

**Exterior Scenes**:
```
crowded, busy streets, cars, vehicles, people, text on signs, modern buildings (unless intended), power lines, urban clutter, harsh shadows, oversaturated sky, unrealistic colors, complex architectural details
```

**Abstract Scenes**:
```
recognizable objects (unless intended), geometric precision, sharp angles, solid shapes, clear boundaries, realistic textures, detailed features, complex patterns, busy composition, high contrast
```

**Lighting-Specific**:
```
harsh shadows, pure black areas, overexposed highlights, lens flare, artificial glow effects, neon lighting (unless intended), dramatic contrast, unrealistic light sources
```

**Style-Specific**:
```
anime style, manga style, cartoon style, pixel art, low poly, cel shaded, comic book style, sketch style, pencil drawing, oil painting, acrylic painting (unless watercolor is maintained)
```

## Naming Convention

All assets follow: `[category]_[name]_[variant]_[size].[ext]`

### Categories
- `bg` — Background scene
- `char` — Character sprite/portrait
- `ui` — UI element
- `vfx` — Visual effect
- `prop` — Interactive object
- `overlay` — Screen overlay (vignette, paper texture, etc.)

### Examples
- `bg_bedroom_morning_1920x1080.png`
- `bg_park_evening_1920x1080.png`
- `bg_abstract_loneliness_1920x1080.png`
- `overlay_paper_texture_1920x1080.png`
- `ui_window_frame_default_512x512.png`

### Variant Naming
- Time of day: `morning`, `afternoon`, `evening`, `night`
- Mood: `calm`, `tense`, `melancholic`, `joyful`
- Season: `spring`, `summer`, `autumn`, `winter`
- Iteration: `v01`, `v02`, `v03` (for A/B testing)

## External Workflow: AI Quality Evaluation (Detailed)

**Purpose**: Systematic checklist to evaluate AI-generated assets before refinement.

**Required Inputs**:
- Generated image file
- Original prompt
- Target use case (background, UI element, etc.)
- Art bible reference (color palette, style guide)

**Evaluation Criteria** (Scored 1-5, Minimum Pass: 3):

### Style Consistency (Weight: 30%)

**Watercolor Aesthetic (1-5)**:
- **5**: Perfect watercolor feel, soft edges throughout, visible color bleeding, organic brush strokes
- **4**: Strong watercolor feel, mostly soft edges, some color bleeding visible
- **3**: Recognizable watercolor style, soft edges present, minimal color bleeding
- **2**: Weak watercolor feel, some hard edges, no visible color bleeding
- **1**: No watercolor aesthetic, looks digital/vector/3D

**Checklist**:
- [ ] Soft edges present on 90%+ of elements (measure edge gradient width ≥ 3px)
- [ ] Paper texture visible at 100% zoom (grain pattern detectable)
- [ ] Color bleeding visible at element boundaries (≥ 2px color diffusion)
- [ ] Organic brush strokes (no perfect geometric shapes or hard lines)

**Paper Texture Quality (1-5)**:
- **5**: Perfect paper texture, visible but not distracting, consistent grain
- **4**: Good paper texture, visible at close inspection, mostly consistent
- **3**: Adequate paper texture, detectable, some inconsistency acceptable
- **2**: Weak paper texture, barely visible, inconsistent
- **1**: No paper texture or texture too strong (distracting)

**Checklist**:
- [ ] Texture visible at 100% zoom but not at 50% zoom
- [ ] Grain size consistent across image (no sudden scale changes)
- [ ] Texture strength 15-25% (not overpowering colors)
- [ ] No digital noise or compression artifacts

**Color Palette Compliance (1-5)**:
- **5**: All colors within art bible palette, perfect hex match (±5 RGB)
- **4**: All colors within palette, slight variation (±10 RGB)
- **3**: Most colors within palette (90%+), minor deviations (±20 RGB)
- **2**: Some colors outside palette (70-90% compliant)
- **1**: Many colors outside palette (<70% compliant)

**Checklist**:
- [ ] Sample 10 random pixels, check against art bible hex codes
- [ ] No oversaturated colors (saturation ≤ 70% in HSL)
- [ ] No pure black (#000000) or pure white (#FFFFFF)
- [ ] Color temperature consistent (all warm or all cool, no mixing)

**Measurement Tool**: Use Photoshop/GIMP eyedropper + color picker to sample and compare

### Technical Quality (Weight: 20%)

**Resolution & Sharpness (1-5)**:
- **5**: Perfect 1920x1080, focal point sharp, appropriate blur in background
- **4**: Correct resolution, mostly sharp, minor blur issues
- **3**: Correct resolution, acceptable sharpness, some blur where shouldn't be
- **2**: Wrong resolution or significant sharpness issues
- **1**: Severely wrong resolution or unusable blur/sharpness

**Checklist**:
- [ ] Exact 1920x1080 pixels (verify in image properties)
- [ ] Focal point elements sharp (edge contrast ≥ 30%)
- [ ] Background appropriately blurred (if depth intended)
- [ ] No upscaling artifacts (check for pixelation at 100% zoom)

**Artifacts & Distortion (1-5)**:
- **5**: Zero artifacts, clean image, no distortion
- **4**: Minor artifacts in non-critical areas, no distortion
- **3**: Some artifacts but not distracting, minimal distortion
- **2**: Noticeable artifacts or distortion in important areas
- **1**: Severe artifacts or distortion, unusable

**Checklist**:
- [ ] No AI generation artifacts (weird textures, impossible geometry)
- [ ] No compression artifacts (JPEG blocking, color banding)
- [ ] No perspective distortion (straight lines are straight)
- [ ] No color fringing or chromatic aberration

**File Size & Format (1-5)**:
- **5**: PNG format, <1.5MB, lossless quality
- **4**: PNG format, 1.5-2MB, lossless quality
- **3**: PNG format, 2-2.5MB, acceptable quality
- **2**: Wrong format or >2.5MB
- **1**: Unusable format or excessive file size

**Checklist**:
- [ ] PNG format (not JPEG, WebP, or other lossy formats)
- [ ] File size ≤ 2MB (check file properties)
- [ ] 8-bit color depth (not 16-bit or 32-bit unless needed)
- [ ] No embedded metadata (strip EXIF data)

### Composition & Readability (Weight: 25%)

**Focal Point Clarity (1-5)**:
- **5**: Focal point immediately obvious, unobstructed, perfect placement
- **4**: Focal point clear, mostly unobstructed, good placement
- **3**: Focal point identifiable, some obstruction, acceptable placement
- **2**: Focal point unclear or heavily obstructed
- **1**: No clear focal point or completely obstructed

**Checklist**:
- [ ] Focal point contrast ≥ 4.5:1 with background
- [ ] Focal point on rule of thirds intersection (±10%)
- [ ] No competing elements with similar visual weight
- [ ] Eye tracking test: 90% of viewers look at focal point first

**Visual Hierarchy (1-5)**:
- **5**: Perfect hierarchy, supports UI overlay, clear depth layers
- **4**: Good hierarchy, mostly supports UI, depth layers clear
- **3**: Acceptable hierarchy, UI placement possible, depth distinguishable
- **2**: Weak hierarchy, UI placement difficult, depth unclear
- **1**: No hierarchy, UI placement impossible, flat image

**Checklist**:
- [ ] Three distinct depth layers (foreground/mid/background) with ≥20% contrast difference
- [ ] Upper corners and edges have low visual weight (for UI placement)
- [ ] Center area has moderate visual weight (for character placement)
- [ ] Background elements don't compete with foreground (saturation ≤50% of foreground)

**Negative Space (1-5)**:
- **5**: Perfect negative space, ideal for text/windows, balanced composition
- **4**: Good negative space, sufficient for UI, mostly balanced
- **3**: Adequate negative space, UI placement possible, acceptable balance
- **2**: Insufficient negative space, UI placement difficult
- **1**: No negative space, cluttered, UI placement impossible

**Checklist**:
- [ ] At least 30% of image is negative space (low detail areas)
- [ ] Negative space in strategic locations (top corners, sides)
- [ ] Negative space has low contrast (≤2:1 internal variation)
- [ ] Negative space doesn't create awkward shapes or "holes"

### Mood & Atmosphere (Weight: 15%)

**Emotional Conveyance (1-5)**:
- **5**: Intended emotion immediately felt, powerful and clear
- **4**: Intended emotion clearly conveyed, strong feeling
- **3**: Intended emotion recognizable, adequate feeling
- **2**: Intended emotion weak or ambiguous
- **1**: Wrong emotion or no emotional impact

**Checklist**:
- [ ] 5-second test: 80% of viewers identify correct emotion
- [ ] Color palette matches emotion (warm=comfort, cool=calm, etc.)
- [ ] Lighting supports emotion (soft=peaceful, dramatic=tense, etc.)
- [ ] Composition supports emotion (open=freedom, enclosed=intimacy, etc.)

**Lighting Quality (1-5)**:
- **5**: Perfect lighting, supports mood, realistic and beautiful
- **4**: Good lighting, mostly supports mood, mostly realistic
- **3**: Adequate lighting, supports mood, acceptable realism
- **2**: Weak lighting, doesn't support mood, unrealistic
- **1**: Bad lighting, contradicts mood, very unrealistic

**Checklist**:
- [ ] Light source direction consistent (all shadows point same way)
- [ ] Light color temperature matches time of day (warm morning, cool night)
- [ ] Shadow softness matches light source (soft for diffused, hard for direct)
- [ ] No impossible lighting (shadows without light source, etc.)

**Color Temperature (1-5)**:
- **5**: Perfect color temperature, matches scene context exactly
- **4**: Good color temperature, mostly matches context
- **3**: Adequate color temperature, acceptable for context
- **2**: Wrong color temperature, conflicts with context
- **1**: Severely wrong color temperature, breaks immersion

**Checklist**:
- [ ] Morning scenes: 3000-4000K (warm yellow-orange)
- [ ] Afternoon scenes: 5000-6000K (neutral white)
- [ ] Evening scenes: 2500-3500K (warm amber-orange)
- [ ] Night scenes: 6000-8000K (cool blue-white)

### Gameplay Integration (Weight: 10%)

**UI Compatibility (1-5)**:
- **5**: Perfect for UI overlay, doesn't compete, enhances UI
- **4**: Good for UI overlay, minimal competition, supports UI
- **3**: Acceptable for UI overlay, some competition, doesn't harm UI
- **2**: Difficult for UI overlay, competes with UI
- **1**: Incompatible with UI overlay, severely competes

**Checklist**:
- [ ] UI overlay areas (corners, edges) have low detail and contrast
- [ ] Background doesn't use colors reserved for UI (bright red, green, blue)
- [ ] No visual elements that look like UI (buttons, windows, text)
- [ ] Test with actual UI overlay: all UI elements clearly readable

**Readability at Target Resolution (1-5)**:
- **5**: Perfect readability, all details clear at 1920x1080
- **4**: Good readability, most details clear
- **3**: Adequate readability, important details clear
- **2**: Poor readability, some important details unclear
- **1**: Unreadable, details lost or muddy

**Checklist**:
- [ ] View at actual 1920x1080 on target display (not zoomed)
- [ ] Focal point elements clearly identifiable from 2 feet away
- [ ] No details too small to see (minimum feature size ≥ 5px)
- [ ] No details too large to fit (maximum feature size ≤ 50% of image)

**Player Focus Support (1-5)**:
- **5**: Perfect support, guides attention, not distracting
- **4**: Good support, mostly guides attention, minimal distraction
- **3**: Adequate support, doesn't distract, neutral guidance
- **2**: Poor support, somewhat distracting
- **1**: Actively distracting, competes for attention

**Checklist**:
- [ ] Background animation (if any) is subtle (≤10% movement)
- [ ] No high-contrast elements in peripheral areas
- [ ] Color saturation decreases toward edges (center 20% higher than edges)
- [ ] 5-minute viewing test: no eye strain or distraction reported

**Accessibility (1-5)**:
- **5**: Perfect accessibility, exceeds WCAG AAA (7:1 contrast)
- **4**: Good accessibility, meets WCAG AAA (7:1 contrast)
- **3**: Adequate accessibility, meets WCAG AA (4.5:1 contrast)
- **2**: Poor accessibility, below WCAG AA
- **1**: Fails accessibility, unusable for low vision

**Checklist**:
- [ ] Text overlay areas have ≥4.5:1 contrast ratio (WCAG AA)
- [ ] Important elements have ≥3:1 contrast with background
- [ ] No reliance on color alone (use shape/pattern too)
- [ ] Test with color blindness simulator (Deuteranopia, Protanopia, Tritanopia)

### Scoring & Decision

**Calculate Weighted Score**:
```
Total Score = (Style × 0.30) + (Technical × 0.20) + (Composition × 0.25) + (Mood × 0.15) + (Gameplay × 0.10)
```

**Decision Thresholds**:
- **5.0-4.5**: Excellent — Approve immediately, no refinement needed
- **4.4-4.0**: Good — Approve with minor notes, optional refinement
- **3.9-3.0**: Acceptable — Approve for MVP, recommend refinement for polish
- **2.9-2.0**: Needs Refinement — Reject, provide detailed feedback, regenerate
- **1.9-1.0**: Unusable — Reject, revise prompt completely, regenerate

**Output Template**:
```markdown
## Quality Evaluation Report

**Asset**: [filename]
**Date**: [YYYY-MM-DD]
**Evaluator**: [name]

### Scores
- Style Consistency: [X.X]/5.0 (Weight: 30%)
- Technical Quality: [X.X]/5.0 (Weight: 20%)
- Composition & Readability: [X.X]/5.0 (Weight: 25%)
- Mood & Atmosphere: [X.X]/5.0 (Weight: 15%)
- Gameplay Integration: [X.X]/5.0 (Weight: 10%)

**Weighted Total**: [X.X]/5.0

### Decision
[Approve / Approve with Notes / Needs Refinement / Unusable]

### Failed Criteria (if any)
- [Criterion name]: [Score] — [Specific issue]
- [Criterion name]: [Score] — [Specific issue]

### Refinement Notes
[Detailed feedback for regeneration, see Structured Feedback workflow]

### Approval Signature
[Name] — [Date]
```

## External Workflow: Structured Feedback

**Purpose**: Convert evaluation failures into actionable prompt adjustments.

**Required Inputs**:
- Failed evaluation criteria (from Quality Evaluation workflow)
- Original prompt
- Generated image reference

**Feedback Template**:

```markdown
### Issue: [Specific criterion that failed]

**Observed**: [What the image shows]
**Expected**: [What it should show per art bible]
**Root Cause**: [Prompt element likely responsible]

**Prompt Adjustment**:
- Remove: [keywords to remove]
- Add: [keywords to add]
- Modify: [keywords to change]

**Priority**: [High/Medium/Low]
```

**Example**:

```markdown
### Issue: Color palette too saturated

**Observed**: Bright, vivid colors (RGB 255, 180, 60)
**Expected**: Muted pastels (RGB 240, 210, 190 range per art bible)
**Root Cause**: Missing "muted" and "desaturated" keywords

**Prompt Adjustment**:
- Remove: "vibrant", "rich colors"
- Add: "muted pastel palette", "desaturated tones", "soft color bleeding"
- Modify: "warm atmosphere" → "gentle warm atmosphere with low saturation"

**Priority**: High
```

**Output**: Revised prompt ready for regeneration.

## Integration with Art Bible

All workflows reference `design/art/art-bible.md` as the source of truth for:
- Color palette definitions (hex codes, RGB ranges)
- Style keywords (watercolor, soft edges, paper texture)
- Composition rules (visual hierarchy, negative space)
- Technical specifications (resolution, format, file size)

When art bible and generated asset conflict, art bible wins. Update prompts to enforce compliance.

## Version Control & Iteration Tracking

- Commit each approved asset with generation parameters in commit message
- Tag major iterations: `asset/bg_bedroom_v01`, `asset/bg_bedroom_v02`
- Maintain `assets/registry.md` with:
  - Asset name
  - Generation date
  - Prompt used
  - Model version (Nana Banana version/settings)
  - Approval status
  - Integration status (in-game, testing, archived)

## Quality Gates (Detailed)

Assets must pass all gates before integration. Each gate has specific criteria and responsible parties.

### Gate 1: Art Director Review

**Responsible**: Art Director agent
**Timing**: Immediately after AI generation and initial quality evaluation
**Duration**: 5-10 minutes per asset

**Criteria**:

1. **Style Consistency (Critical)**:
   - [ ] Watercolor aesthetic matches art bible examples
   - [ ] Soft edges present on all organic elements
   - [ ] Paper texture visible and consistent
   - [ ] Color bleeding visible at boundaries
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Return to Phase 2 (AI Generation) with style-focused prompt adjustments

2. **Art Bible Compliance (Critical)**:
   - [ ] All colors within defined palette (±10 RGB tolerance)
   - [ ] Color temperature matches scene context
   - [ ] Saturation levels within 40-70% range
   - [ ] No forbidden elements (pure black, neon colors, hard edges)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Return to Phase 2 with color-focused prompt adjustments

3. **Visual Hierarchy (Important)**:
   - [ ] Focal point clear and properly placed
   - [ ] Depth layers distinguishable (≥20% contrast difference)
   - [ ] Negative space adequate for UI (≥30% of image)
   - [ ] Composition supports intended mood
   - **Pass Threshold**: 3 of 4 criteria met
   - **Fail Action**: Return to Phase 2 with composition-focused prompt adjustments

4. **Mood & Atmosphere (Important)**:
   - [ ] Intended emotion conveyed (5-second test with 3 people)
   - [ ] Lighting supports mood
   - [ ] Color palette supports emotion
   - [ ] Overall atmosphere matches design intent
   - **Pass Threshold**: 3 of 4 criteria met
   - **Fail Action**: Return to Phase 2 with mood-focused prompt adjustments

**Output**: Approve / Reject with specific feedback
**Documentation**: Record decision in `assets/registry.md` with timestamp and notes

### Gate 2: Technical Review

**Responsible**: Technical Artist agent
**Timing**: After Art Director approval
**Duration**: 3-5 minutes per asset

**Criteria**:

1. **File Specifications (Critical)**:
   - [ ] Resolution exactly 1920x1080 pixels
   - [ ] PNG format with 8-bit color depth
   - [ ] File size ≤ 2MB
   - [ ] No embedded metadata (EXIF stripped)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Reprocess file (resize, convert, compress, strip metadata)

2. **Image Quality (Critical)**:
   - [ ] No compression artifacts (JPEG blocking, color banding)
   - [ ] No AI generation artifacts (weird textures, impossible geometry)
   - [ ] No upscaling artifacts (pixelation, blur)
   - [ ] Focal point sharp (edge contrast ≥30%)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Return to Phase 2 (regenerate at correct resolution)

3. **Performance Impact (Important)**:
   - [ ] File size optimized (use pngquant or similar)
   - [ ] No unnecessary alpha channel complexity
   - [ ] Suitable for real-time rendering (no excessive detail)
   - [ ] Memory footprint acceptable (≤8MB uncompressed)
   - **Pass Threshold**: 3 of 4 criteria met
   - **Fail Action**: Optimize file (compress, simplify alpha, reduce detail)

4. **Technical Compatibility (Important)**:
   - [ ] Imports correctly into Godot (no errors)
   - [ ] Displays correctly at target resolution
   - [ ] No color shift after import (compare in Godot vs source)
   - [ ] Suitable for shader application (paper texture, edge softening)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Adjust import settings or reprocess file

**Output**: Approve / Reject with specific technical issues
**Documentation**: Record file specs and performance metrics in `assets/registry.md`

### Gate 3: UX Review

**Responsible**: UX Designer agent
**Timing**: After Technical Review approval
**Duration**: 5-10 minutes per asset

**Criteria**:

1. **Readability (Critical)**:
   - [ ] All important elements identifiable at 1920x1080 from 2 feet away
   - [ ] Minimum feature size ≥5px
   - [ ] No details too small to see or too large to fit
   - [ ] Focal point immediately obvious (3-second test)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Return to Phase 2 with readability-focused adjustments

2. **Accessibility (Critical)**:
   - [ ] Text overlay areas have ≥4.5:1 contrast ratio (WCAG AA)
   - [ ] Important elements have ≥3:1 contrast with background
   - [ ] No reliance on color alone (use shape/pattern too)
   - [ ] Passes color blindness simulation (Deuteranopia, Protanopia, Tritanopia)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Adjust contrast, add patterns, or return to Phase 2

3. **Player Focus (Important)**:
   - [ ] Background doesn't compete with UI elements
   - [ ] No high-contrast elements in peripheral areas
   - [ ] Color saturation decreases toward edges
   - [ ] 5-minute viewing test: no eye strain or distraction
   - **Pass Threshold**: 3 of 4 criteria met
   - **Fail Action**: Adjust saturation, blur edges, or return to Phase 2

4. **UI Compatibility (Important)**:
   - [ ] UI overlay areas (corners, edges) have low detail and contrast
   - [ ] Background doesn't use colors reserved for UI
   - [ ] No visual elements that look like UI
   - [ ] Test with actual UI overlay: all UI elements clearly readable
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Adjust UI areas or return to Phase 2

**Output**: Approve / Reject with specific UX issues
**Documentation**: Record accessibility metrics and UI compatibility notes in `assets/registry.md`

### Gate 4: Integration Test

**Responsible**: Technical Artist + UI Programmer
**Timing**: After UX Review approval
**Duration**: 10-15 minutes per asset

**Criteria**:

1. **In-Engine Appearance (Critical)**:
   - [ ] Displays correctly in Godot (no visual bugs)
   - [ ] Colors match source file (no color shift)
   - [ ] Shaders apply correctly (paper texture, edge softening)
   - [ ] No rendering artifacts (z-fighting, alpha issues)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Adjust import settings, shader parameters, or file format

2. **UI Integration (Critical)**:
   - [ ] UI elements overlay correctly
   - [ ] Text readable on all background areas
   - [ ] UI doesn't obscure important background elements
   - [ ] Background supports UI visual hierarchy
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Adjust UI placement or background composition

3. **Character Integration (Important)**:
   - [ ] Character sprite visible and clear on background
   - [ ] Character doesn't blend into background (contrast ≥3:1)
   - [ ] Character placement areas have appropriate negative space
   - [ ] Character and background styles harmonize
   - **Pass Threshold**: 3 of 4 criteria met
   - **Fail Action**: Adjust character placement, background contrast, or shader parameters

4. **Performance (Important)**:
   - [ ] No frame rate drop when displaying background
   - [ ] Memory usage within budget (check Godot profiler)
   - [ ] Load time acceptable (≤100ms)
   - [ ] No GPU bottleneck (check draw calls)
   - **Pass Threshold**: All 4 criteria met
   - **Fail Action**: Optimize file, reduce resolution, or simplify shaders

**Output**: Approve / Reject with specific integration issues
**Documentation**: Record integration test results and performance metrics in `assets/registry.md`

### Gate Failure Handling

**Single Gate Failure**:
- Document specific failure reasons
- Return to appropriate phase (usually Phase 2 or Phase 3)
- Apply structured feedback (see Structured Feedback workflow)
- Re-enter quality gate process from Gate 1

**Multiple Gate Failures (2+ gates)**:
- Indicates fundamental issue with prompt or approach
- Return to Phase 1 (Concept & Reference)
- Review art bible and design intent
- Revise prompt template completely
- Consider alternative AI tool or manual creation

**Repeated Failures (3+ attempts)**:
- Escalate to Creative Director
- Evaluate if AI generation is appropriate for this asset
- Consider commissioning manual artwork
- Document lessons learned for future assets

### Quality Gate Metrics

Track and report monthly:
- **Pass Rate**: % of assets passing all gates on first attempt (Target: ≥60%)
- **Average Iterations**: Average number of regenerations per asset (Target: ≤2.5)
- **Gate-Specific Failure Rate**: Which gate fails most often (identify bottleneck)
- **Time to Approval**: Average time from generation to final approval (Target: ≤2 hours)

**Continuous Improvement**:
- If pass rate <60%: Review and improve prompt templates
- If average iterations >3: Improve quality evaluation criteria or AI tool settings
- If specific gate fails >40%: Provide additional training or documentation for that area
- If time to approval >3 hours: Streamline review process or add automation

## Appendix A: Prompt Combination Matrix

This matrix shows how to combine different prompt elements for specific scene types and moods.

### Matrix Structure

| Scene Type | Time of Day | Mood | Color Palette | Composition | Example Use Case |
|------------|-------------|------|---------------|-------------|------------------|
| Interior - Bedroom | Morning | Peaceful | Warm Comfort | Asymmetric, focal on bed | Character waking up, daily routine start |
| Interior - Bedroom | Evening | Intimate | Cool Calm | Centered, focal on window | Character reflecting, quiet moment |
| Interior - Bedroom | Night | Restful | Melancholic | Asymmetric, focal on desk | Character working late, insomnia |
| Interior - Study | Afternoon | Focused | Earthy Grounded | Asymmetric, focal on desk | Character studying, concentration |
| Interior - Study | Evening | Cozy | Warm Comfort | Centered, focal on chair | Character reading, relaxation |
| Exterior - Garden | Morning | Hopeful | Energetic Optimism | Rule of thirds, focal on path | Character starting journey, new beginning |
| Exterior - Garden | Afternoon | Serene | Cool Calm | Centered, focal on bench | Character resting, peaceful moment |
| Exterior - Garden | Evening | Nostalgic | Warm Comfort | Asymmetric, focal on sunset | Character reminiscing, memory trigger |
| Exterior - Street | Morning | Quiet | Cool Calm | Leading lines, focal on shop | Character exploring, discovery |
| Exterior - Street | Evening | Intimate | Warm Comfort | Framing, focal on alley | Character meeting friend, connection |
| Abstract - Emotion | Any | Loneliness | Melancholic | Heavy negative space | Emotional state visualization |
| Abstract - Emotion | Any | Hope | Energetic Optimism | Upward flow | Emotional state visualization |
| Abstract - Emotion | Any | Memory | Desaturated | Overlapping layers | Flashback, recollection |

### Combination Examples

**Example 1: Peaceful Morning Bedroom**
```
Base: Interior - Bedroom
+ Time: Morning (soft golden morning light, long gentle shadows, warm highlights)
+ Mood: Peaceful (serene and quiet mood)
+ Palette: Warm Comfort (peach, cream, soft yellow, muted orange accents)
+ Composition: Asymmetric balance with visual weight on left third (bed), right side open for UI

Result Prompt:
Watercolor illustration with soft edges and paper texture, cozy bedroom interior with unmade bed and small nightstand, warm golden morning light streaming through window on left side, long gentle shadows on wooden floor, muted pastel palette with cream walls and peach bedding, soft yellow curtains, serene and quiet mood, lived-in atmosphere with open book on nightstand, asymmetric composition with bed as focal point on left third, right side open for UI overlay, depth through overlapping furniture and window frame, visible paper grain texture, gentle color bleeding at edges, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D render, sharp vector edges, neon colors, cluttered, busy patterns, text, UI elements, people, harsh shadows, oversaturated
```

**Example 2: Nostalgic Evening Garden**
```
Base: Exterior - Garden
+ Time: Evening (warm amber sunset glow, deep blue shadows, high contrast)
+ Mood: Nostalgic (contemplative and wistful)
+ Palette: Warm Comfort (peach, cream, soft yellow, muted orange accents)
+ Composition: Asymmetric balance with visual weight on right third (sunset), left side open for character

Result Prompt:
Watercolor illustration with soft edges and paper texture, intimate garden corner with stone path and lantern, warm amber sunset glow, deep blue shadows under plants, atmospheric perspective with orange sky fading to purple, high contrast color gradients, nostalgic and contemplative mood, asymmetric composition with lantern as focal point on right third, left side open for character placement, clear foreground stones/midground plants/background sky separation, visible paper grain, gentle color bleeding at light edges, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D render, sharp lines, neon colors, cluttered, busy patterns, text, people, harsh contrast, pure black shadows, oversaturated
```

**Example 3: Focused Afternoon Study**
```
Base: Interior - Study
+ Time: Afternoon (bright diffused daylight, minimal shadows, even illumination)
+ Mood: Focused (concentrated and attentive)
+ Palette: Earthy Grounded (terracotta, sage green, warm brown, off-white)
+ Composition: Asymmetric balance with visual weight on left third (desk), right side open for UI

Result Prompt:
Watercolor illustration with soft edges and paper texture, quiet study room with tall bookshelf and wooden desk, bright diffused daylight from large window on left, minimal shadows, muted palette with sage green walls and warm brown furniture, cream curtains, contemplative atmosphere with open books on desk, asymmetric composition with desk as focal point on left third, right side open for UI overlay, depth through bookshelf layers and window frame, visible paper grain texture, gentle color bleeding, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: photorealistic, 3D render, vector art, neon colors, messy, cluttered, text on books, people, harsh shadows, oversaturated, busy patterns
```

### Quick Reference: Mood + Palette Combinations

| Mood | Best Palette | Alternative Palette | Avoid Palette |
|------|--------------|---------------------|---------------|
| Peaceful | Cool Calm | Warm Comfort | Melancholic |
| Intimate | Warm Comfort | Earthy Grounded | Cool Calm |
| Restful | Cool Calm | Melancholic | Energetic Optimism |
| Focused | Earthy Grounded | Cool Calm | Warm Comfort |
| Cozy | Warm Comfort | Earthy Grounded | Cool Calm |
| Hopeful | Energetic Optimism | Warm Comfort | Melancholic |
| Serene | Cool Calm | Earthy Grounded | Energetic Optimism |
| Nostalgic | Warm Comfort | Melancholic | Cool Calm |
| Quiet | Cool Calm | Melancholic | Energetic Optimism |
| Loneliness | Melancholic | Cool Calm | Energetic Optimism |

## Appendix B: Troubleshooting Common Issues

### Issue: Colors Too Saturated

**Symptoms**:
- Colors appear vibrant and intense
- Fails art bible compliance check
- Looks digital rather than watercolor

**Diagnosis**:
- Sample 10 random pixels
- Check HSL saturation values
- If average saturation >70%, too saturated

**Solutions**:

1. **Prompt Adjustment** (First Try):
   - Add: "muted pastel palette", "desaturated tones", "low saturation", "soft colors"
   - Remove: "vibrant", "rich colors", "vivid", "bright"
   - Modify: "warm atmosphere" → "gentle warm atmosphere with low saturation"

2. **Post-Processing** (If Regeneration Fails):
   - Open in Photoshop/GIMP
   - Image → Adjustments → Hue/Saturation
   - Reduce Saturation by 20-30%
   - Check against art bible palette

3. **Godot Shader** (Runtime Solution):
   - Apply desaturation shader
   - Set saturation_multiplier = 0.7-0.8
   - Adjust per-scene if needed

**Prevention**:
- Always include "muted" and "desaturated" in base style descriptor
- Avoid color-related adjectives that imply high saturation
- Test with color picker before submitting for review

### Issue: Edges Too Sharp

**Symptoms**:
- Hard lines and crisp edges
- Looks vector or digital
- No watercolor bleeding visible

**Diagnosis**:
- Zoom to 200%
- Check edge gradient width
- If gradient <3px, too sharp

**Solutions**:

1. **Prompt Adjustment** (First Try):
   - Add: "soft edges", "gentle color bleeding", "watercolor diffusion", "blurred boundaries"
   - Remove: "sharp", "crisp", "clean lines", "defined edges"
   - Emphasize: "hand-painted aesthetic", "organic brush strokes"

2. **Post-Processing** (If Regeneration Fails):
   - Apply Gaussian Blur (radius 1-2px) to entire image
   - Use layer mask to preserve focal point sharpness
   - Add color bleeding manually with soft brush

3. **Godot Shader** (Runtime Solution):
   - Apply edge_softening.gdshader
   - Set edge_softness = 0.03-0.05
   - Adjust per-asset if needed

**Prevention**:
- Always include "soft edges" in base style descriptor
- Use negative prompt: "sharp edges, hard lines, vector art"
- Reference watercolor examples in prompt

### Issue: No Paper Texture Visible

**Symptoms**:
- Surface looks smooth and digital
- No visible grain at 100% zoom
- Lacks hand-painted warmth

**Diagnosis**:
- Zoom to 100%
- Look for grain pattern
- If no texture visible, missing or too weak

**Solutions**:

1. **Prompt Adjustment** (First Try):
   - Add: "visible paper texture", "paper grain", "textured surface", "rough paper"
   - Emphasize: "hand-painted on textured paper"
   - Specify: "watercolor paper texture visible"

2. **Post-Processing** (If Regeneration Fails):
   - Overlay paper texture image
   - Set blend mode to Multiply or Overlay
   - Opacity 15-25%
   - Match texture scale to image size

3. **Godot Shader** (Runtime Solution):
   - Apply paper_overlay.gdshader
   - Set paper_strength = 0.20
   - Adjust paper_scale based on asset size
   - This is the standard solution

**Prevention**:
- Always include "paper texture" in base style descriptor
- Plan to apply paper texture shader in Godot (standard workflow)
- Don't rely solely on AI to generate texture

### Issue: Composition Too Cluttered

**Symptoms**:
- Too many elements competing for attention
- No clear focal point
- Insufficient negative space for UI

**Diagnosis**:
- Identify focal point (should be obvious in 3 seconds)
- Measure negative space (should be ≥30%)
- Count major elements (should be ≤5)

**Solutions**:

1. **Prompt Adjustment** (First Try):
   - Add: "minimal composition", "simple scene", "few elements", "spacious"
   - Remove: "detailed", "rich", "full", "busy"
   - Specify: "negative space for UI overlay", "breathing room"

2. **Post-Processing** (If Regeneration Fails):
   - Blur or desaturate non-essential elements
   - Crop to remove peripheral clutter
   - Paint over distracting elements with background color

3. **Regeneration** (Recommended):
   - Simplify scene description
   - Reduce number of specified elements
   - Emphasize focal point more strongly

**Prevention**:
- Limit scene description to 3-5 key elements
- Always specify negative space requirements
- Use "minimal" and "simple" in composition keywords

### Issue: Wrong Color Temperature

**Symptoms**:
- Morning scene looks cool instead of warm
- Night scene looks warm instead of cool
- Color temperature conflicts with time of day

**Diagnosis**:
- Sample dominant colors
- Check color temperature in Kelvin
- Compare to expected range for time of day

**Solutions**:

1. **Prompt Adjustment** (First Try):
   - Explicitly specify color temperature
   - Morning: "warm color temperature 3000-4000K"
   - Afternoon: "neutral color temperature 5000-6000K"
   - Evening: "warm color temperature 2500-3500K"
   - Night: "cool color temperature 6000-8000K"

2. **Post-Processing** (If Regeneration Fails):
   - Apply color balance adjustment
   - Shift toward warm (add yellow/orange) or cool (add blue)
   - Use Photo Filter in Photoshop (Warming Filter 85 or Cooling Filter 80)

3. **Godot Shader** (Runtime Solution):
   - Apply color temperature adjustment shader
   - Set temperature_shift parameter
   - Adjust per-scene dynamically

**Prevention**:
- Always specify color temperature explicitly in prompt
- Use lighting variation keywords that include temperature
- Test with color temperature meter tool

### Issue: Focal Point Unclear

**Symptoms**:
- Multiple elements compete for attention
- No obvious place for eye to land
- Fails 3-second focal point test

**Diagnosis**:
- Show image to 3 people for 3 seconds
- Ask "what did you look at first?"
- If answers vary widely, focal point unclear

**Solutions**:

1. **Prompt Adjustment** (First Try):
   - Explicitly specify focal point
   - Add: "[element] as clear focal point", "centered on [element]"
   - Increase focal point contrast: "bright [element] against muted background"
   - Use composition keywords: "leading lines toward [element]"

2. **Post-Processing** (If Regeneration Fails):
   - Increase contrast of intended focal point (20-30%)
   - Decrease contrast of competing elements (20-30%)
   - Add vignette to darken edges
   - Add subtle glow or highlight to focal point

3. **Regeneration** (Recommended):
   - Simplify scene to single clear focal point
   - Use stronger composition keywords
   - Specify focal point placement (rule of thirds)

**Prevention**:
- Always specify focal point explicitly in prompt
- Use composition keywords that guide attention
- Limit number of high-contrast elements to 1-2
