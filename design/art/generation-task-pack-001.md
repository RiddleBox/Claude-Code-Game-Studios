# Generation Task Pack 001: Cycle 1 Initial Validation

*Created: 2026-04-21*
*Status: Active*
*Target: 3 background samples for workflow validation*

---

## Task Overview

### Objective
Generate 3 background scenes to validate the AI generation workflow, quality standards, and prompt templates. These samples will inform adjustments to the visual design system before scaling to full production.

### Priority Order
1. **Task 1: Simple Scene** - Mochi's Bedroom Window View (Interior)
2. **Task 2: Medium Scene** - Street Corner Cafe Exterior (Outdoor)
3. **Task 3: Complex Scene** - Post-Rain City Street (Outdoor + Weather)

### Expected Time Investment
- Task 1: 30-45 minutes (simple composition, fewer variables)
- Task 2: 45-60 minutes (moderate complexity, outdoor lighting)
- Task 3: 60-90 minutes (complex atmosphere, weather effects)

### Success Criteria
All 3 samples must score ≥3.0 in all 6 quality dimensions before proceeding to batch production. If any sample scores <3.0, iterate on prompts and regenerate.

---

## Task 1: Simple Scene - Mochi's Bedroom Window View (Interior)

### Scene Description

**核心意图 (Core Intent)**:
温馨宁静的卧室一角,透过窗户看到柔和的晨光。这是Mochi每天醒来看到的第一个场景,应传达"新的一天开始"的温暖感和安全感。

**English Prompt Intent**:
A cozy, peaceful bedroom corner with soft morning light streaming through the window. This is the first scene Mochi sees every morning, conveying warmth, safety, and the gentle start of a new day.

### Complete Nana Banana Prompt (REVISED - v2)

**⚠️ CRITICAL CHANGES FROM v1:**
- Replaced "illustration" with "background plate for game character placement"
- Added "color-defined forms without linework" and "intentionally unfinished aesthetic"
- Strengthened negative prompts to exclude "detailed linework", "complete illustration", "architectural precision"
- Added explicit detail control: "foreground clear, midground simplified, background blurred"

```
Watercolor background plate for game character placement, cozy bedroom corner with simplified forms, warm golden morning light streaming through window on left side creating soft glow, bed and nightstand suggested with loose color masses rather than precise details, color-defined forms without linework, right side preserved as open negative space for UI overlay, atmospheric and dreamy quality, intentionally unfinished aesthetic with strategic blur on background wall and window details, foreground floor clear, midground furniture simplified, background wall and window blurred and desaturated, muted pastel palette with cream walls and peach bedding, soft yellow curtains, lived-in atmosphere with minimal decorative elements, asymmetric composition, depth through color temperature shifts, visible paper grain texture, extensive color bleeding at edges, hand-painted aesthetic with organic brush strokes, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: detailed linework, pen and ink outlines, complete illustration, finished artwork, uniform detail density, architectural precision, hard edges, sharp boundaries, vector art, every corner resolved, portfolio piece, standalone illustration, bed frame details, window frame details, floor plank lines, decorative patterns, busy composition, photorealistic, 3D render, CGI, neon colors, oversaturated colors, pure black shadows, cluttered, text, UI elements, people, characters, faces, harsh shadows, dramatic lighting, messy room, complex details, modern electronics, fluorescent lighting
```

### Technical Parameters

- **Resolution**: 1920x1080 pixels (exact)
- **Format**: PNG, 8-bit color depth
- **Target File Size**: <2MB
- **Aspect Ratio**: 16:9
- **Color Profile**: sRGB

### Expected Visual Outcome

**Key Elements**:
- Window on left third, bed on left, right side open for UI
- Warm morning light (3000-4000K color temperature)
- Soft shadows at 45-degree angle
- Cream/peach/yellow color palette
- Visible paper texture at 100% zoom
- Soft edges with 2-5px feathering

**Mood Keywords**: Warm, Peaceful, Safe, Gentle, Morning, Fresh

### Quality Checklist (Minimum Pass: 3/5 per dimension)

#### Dimension 1: Atmosphere (氛围营造)
- [ ] Can identify "bedroom" and "morning" within 5 seconds
- [ ] Warm color temperature (3000-4000K)
- [ ] Visible light source (window) with shadows
- [ ] Contrast ratio ≥ 2:1 (brightest vs darkest area)
- [ ] 5-second test: 2/3 testers say "warm" or "peaceful"

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 2: Depth Layers (层次分离)
- [ ] Three distinct layers: foreground (bed), midground (nightstand), background (window/wall)
- [ ] Grayscale test: RGB average difference ≥ 30 between layers
- [ ] Background contrast 15% lower than midground
- [ ] Foreground contrast 15% higher than midground
- [ ] Gaussian blur 5px test: layer boundaries still visible

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 3: Color Harmony (色彩和谐)
- [ ] All colors within art bible palette (cream #FFF8E7, peach #FFD4B2, yellow #FFF4A3)
- [ ] Hue range ≤ 120° (warm spectrum only)
- [ ] Saturation range 40-70% (no extremes)
- [ ] Color temperature unified ±300K
- [ ] 5-minute viewing test: no visual fatigue

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 4: Paper Texture (纸质感)
- [ ] Texture visible at 100% zoom
- [ ] Texture strength 15-25% (paper_strength = 0.15 ~ 0.25)
- [ ] Grain size consistent across image
- [ ] Texture not visible at 50% zoom (blends into image)
- [ ] On/off comparison shows warmth difference

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 5: Edge Treatment (边缘处理)
- [ ] Edges soft and natural, no hard vector lines
- [ ] Edge feathering 2-5px (edge_softness = 0.02 ~ 0.05)
- [ ] Alpha gradient smooth, no jagged edges
- [ ] 200% zoom test: edges appear watercolor-like
- [ ] No "cutout" feeling against different backgrounds

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 6: Information Clarity (信息清晰度)
- [ ] Key elements (bed, window, nightstand) identifiable within 3 seconds
- [ ] Key element contrast ≥ 3:1 with background
- [ ] Edge clarity ≥ 80% for functional elements
- [ ] 3-second recognition test: 80% accuracy
- [ ] Decorative elements don't distract from key elements

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 7: Detail Restraint (细节克制度) ⭐ NEW

**Purpose**: Ensure the image is a "background plate" not a "finished illustration"

- [ ] **No dominant linework**: Forms defined by color transitions, not pen/ink lines (200% zoom test: no continuous line work visible)
- [ ] **Differential detail density**: Background has 50-70% fewer distinct visual elements than foreground (count elements: background should have ≤5 distinct shapes, foreground can have 10-15)
- [ ] **Strategic incompleteness**: Background elements are "suggestive" not "specific" (can identify "window" but not count window panes, can see "floor" but not individual planks)
- [ ] **Visual hierarchy clear**: Player's eye naturally drawn to character placement area (left/right third), not wandering across entire image (5-second attention test: 80% of viewing time on focal area)
- [ ] **Intentional ambiguity**: At least 30% of the image should feel "unfinished" or "atmospheric" rather than fully resolved (background wall, distant elements should be color washes, not detailed forms)

**Minimum Pass Score**: 3/5 criteria met

**Quantitative Tests**:
- Element count: Background ≤ 5 distinct shapes, Foreground 10-15 shapes
- Edge softness: Background edges 50%+ softer than foreground (measure with edge detection filter)
- Linework test: 200% zoom should show color masses, not drawn lines
- Attention test: Show for 5 seconds, ask where viewer looked first (should be focal area, not background details)

### Pass Threshold

**Overall Pass Requirement**: All 7 dimensions score ≥3/5

**⚠️ CRITICAL**: Dimension 7 (Detail Restraint) is now mandatory. If this dimension scores <3, the image is a "finished illustration" not a "game background" and must be regenerated with stronger negative prompts.

**Decision Matrix**:
- All dimensions ≥3 (including Dimension 7): **PASS** - Proceed to Task 2
- Dimension 7 <3 (linework/over-detailing): **ITERATE** - Strengthen negative prompts, add "no linework", "simplified forms"
- Any other dimension <3: **ITERATE** - Adjust prompt based on failed criteria
- Any dimension =1: **FAIL** - Major issue, revise prompt completely
- After 3 attempts still failing: **ESCALATE** - Consider alternative tools or post-processing workflow

### Iteration Record Template

```markdown
## Task 1 Iteration Log

### Attempt 1
- **Date**: [YYYY-MM-DD HH:MM]
- **Prompt Used**: [Full prompt]
- **Scores**: Atmosphere [X/5], Depth [X/5], Color [X/5], Texture [X/5], Edge [X/5], Clarity [X/5], Detail Restraint [X/5]
- **Overall**: [X.X/5.0]
- **Decision**: [PASS / ITERATE / FAIL]
- **Issues Identified**:
  - [Dimension]: [Specific problem]
  - [Dimension]: [Specific problem]
- **Prompt Adjustments for Next Attempt**:
  - Remove: [keywords]
  - Add: [keywords]
  - Modify: [keywords]

### Attempt 2
[Same structure as Attempt 1]
```

---

## Task 2: Medium Scene - Street Corner Cafe Exterior (Outdoor)

### Scene Description

**核心意图 (Core Intent)**:
安静的街角咖啡馆外景,午后阳光温暖,有几张空椅子和盆栽植物。传达"城市中的宁静角落"感,适合角色外出时的背景。

**English Prompt Intent**:
A quiet street corner cafe exterior in warm afternoon light, with empty chairs and potted plants. Conveys a "peaceful urban corner" feeling, suitable for character outing scenes.

### Complete Nana Banana Prompt (REVISED - v2)

**⚠️ CRITICAL CHANGES FROM v1:**
- Replaced "illustration" with "background plate for game character placement"
- Added "color-defined forms without linework" and "intentionally unfinished aesthetic"
- Strengthened negative prompts to exclude "detailed linework", "complete illustration", "architectural precision"
- Added explicit detail control: "foreground clear, midground simplified, background blurred"

```
Watercolor background plate for game character placement, quiet street corner cafe with simplified forms, warm afternoon sunlight from upper right creating gentle shadows, cafe entrance and outdoor seating suggested with loose color masses rather than precise details, color-defined forms without linework, left side preserved as open negative space for character placement, atmospheric and peaceful quality, intentionally unfinished aesthetic with strategic blur on background buildings and distant street, foreground cobblestones clear, midground cafe simplified, background buildings blurred and desaturated, muted pastel palette with cream buildings and sage green plants, terracotta roof tiles, peaceful atmosphere with minimal decorative elements, asymmetric composition, depth through atmospheric perspective and color temperature shifts, visible paper grain texture, extensive color bleeding at edges, hand-painted aesthetic with organic brush strokes, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: detailed linework, pen and ink outlines, complete illustration, finished artwork, uniform detail density, architectural precision, hard edges, sharp boundaries, vector art, every corner resolved, portfolio piece, standalone illustration, window frame details, door frame details, cobblestone individual stones, roof tile patterns, decorative signs, busy composition, photorealistic, 3D render, CGI, vector art, sharp edges, oversaturated colors, neon colors, pure black shadows, crowded, busy streets, cars, vehicles, people, characters, text on signs, modern buildings, power lines, urban clutter, harsh shadows, complex architectural details, cluttered composition
```

### Technical Parameters

- **Resolution**: 1920x1080 pixels (exact)
- **Format**: PNG, 8-bit color depth
- **Target File Size**: <2MB
- **Aspect Ratio**: 16:9
- **Color Profile**: sRGB

### Expected Visual Outcome

**Key Elements**:
- Cafe entrance on right third, left side open for character
- Warm afternoon light (5000-6000K color temperature)
- Cobblestone foreground with texture
- Beige/terracotta/sage green color palette
- Atmospheric perspective: background buildings misty and desaturated
- Sky occupies 30-40% of upper frame

**Mood Keywords**: Peaceful, Inviting, Quiet, Urban, Afternoon, Cozy

### Quality Checklist (Minimum Pass: 3/5 per dimension)

#### Dimension 1: Atmosphere (氛围营造)
- [ ] Can identify "street cafe" and "afternoon" within 5 seconds
- [ ] Warm neutral color temperature (5000-6000K)
- [ ] Visible light source (sun from upper right) with shadows
- [ ] Contrast ratio ≥ 2:1
- [ ] 5-second test: 2/3 testers say "peaceful" or "inviting"

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 2: Depth Layers (层次分离)
- [ ] Three distinct layers: foreground (cobblestones), midground (cafe), background (buildings/sky)
- [ ] Grayscale test: RGB average difference ≥ 30 between layers
- [ ] Background saturation 30-50% lower than foreground
- [ ] Background blur visible (atmospheric perspective)
- [ ] Color temperature shift: background cooler than foreground (+200K)

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 3: Color Harmony (色彩和谐)
- [ ] All colors within art bible palette (beige #F5F1E8, terracotta #D4876F, sage #B8C5A6)
- [ ] Hue range ≤ 120°
- [ ] Saturation range 40-70%
- [ ] Color temperature unified ±300K
- [ ] 5-minute viewing test: no visual fatigue

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 4: Paper Texture (纸质感)
- [ ] Texture visible at 100% zoom
- [ ] Texture strength 15-25%
- [ ] Grain size consistent across image
- [ ] Texture not visible at 50% zoom
- [ ] On/off comparison shows warmth difference

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 5: Edge Treatment (边缘处理)
- [ ] Edges soft and natural, especially on plants and building edges
- [ ] Edge feathering 2-5px
- [ ] Alpha gradient smooth
- [ ] 200% zoom test: edges appear watercolor-like
- [ ] No "cutout" feeling

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 6: Information Clarity (信息清晰度)
- [ ] Key elements (cafe entrance, chairs, table) identifiable within 3 seconds
- [ ] Key element contrast ≥ 3:1 with background
- [ ] Edge clarity ≥ 80% for functional elements
- [ ] 3-second recognition test: 80% accuracy
- [ ] Background buildings simplified, not distracting

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 7: Detail Restraint (细节克制度) ⭐ NEW

**Purpose**: Ensure the image is a "background plate" not a "finished illustration"

- [ ] **No dominant linework**: Forms defined by color transitions, not pen/ink lines (200% zoom test: no continuous line work visible on building edges, roof tiles, or cobblestones)
- [ ] **Differential detail density**: Background has 50-70% fewer distinct visual elements than foreground (background buildings should be color masses, not detailed facades)
- [ ] **Strategic incompleteness**: Background elements are "suggestive" not "specific" (can identify "buildings" but not count windows, can see "street" but not individual cobblestones in distance)
- [ ] **Visual hierarchy clear**: Player's eye naturally drawn to character placement area (left side), not to background architectural details
- [ ] **Intentional ambiguity**: Background buildings and distant street should be atmospheric washes, not complete illustrations

**Minimum Pass Score**: 3/5 criteria met

### Additional Outdoor Scene Checks

- [ ] Sky gradient natural (no color banding)
- [ ] Sky occupies 30-50% of frame
- [ ] Horizon line at lower 1/3 or upper 1/3 (not dead center)
- [ ] Plant edges organic and soft (no geometric shapes)
- [ ] Atmospheric perspective clear (far = blurry + desaturated)

**Minimum Pass Score**: 3/5 criteria met

### Pass Threshold

**Overall Pass Requirement**: All 7 dimensions + outdoor checks score ≥3/5

**⚠️ CRITICAL**: Dimension 7 (Detail Restraint) is now mandatory. If this dimension scores <3, the image is a "finished illustration" not a "game background" and must be regenerated with stronger negative prompts.

### Iteration Record Template

[Same structure as Task 1]

---

## Task 3: Complex Scene - Post-Rain City Street (Outdoor + Weather)

### Scene Description

**核心意图 (Core Intent)**:
雨后的城市街道,地面有水洼反射,天空放晴但仍有乌云,空气清新湿润。传达"雨过天晴"的希望感和清新感,适合情绪转折场景。

**English Prompt Intent**:
A city street after rain, with puddles reflecting light, clearing sky with lingering clouds, fresh and moist atmosphere. Conveys "hope after rain" and freshness, suitable for emotional turning point scenes.

### Complete Nana Banana Prompt (REVISED - v2)

**⚠️ CRITICAL CHANGES FROM v1:**
- Replaced "illustration" with "background plate for game character placement"
- Added "color-defined forms without linework" and "intentionally unfinished aesthetic"
- Strengthened negative prompts to exclude "detailed linework", "complete illustration", "architectural precision"
- Added explicit detail control: "foreground clear, midground simplified, background blurred"

```
Watercolor background plate for game character placement, quiet city street after rain with simplified forms, wet cobblestones with shallow puddles reflecting warm evening light, clearing sky with soft orange-pink sunset glow breaking through gray-blue clouds, street and buildings suggested with loose color masses rather than precise details, color-defined forms without linework, left side preserved as open negative space for character placement, atmospheric and hopeful quality after storm, intentionally unfinished aesthetic with strategic blur on background buildings and distant sky, foreground puddles with reflections clear, midground buildings simplified, background sky and distant street blurred and desaturated, muted palette with cool gray-blue wet stones and warm orange-pink sky reflections, gentle mist rising from ground, street lamp on right providing warm amber light, peaceful atmosphere with minimal urban details, asymmetric composition, depth through atmospheric perspective and color temperature shifts, visible paper grain texture, extensive color bleeding at water edges simulating wetness, hand-painted aesthetic with organic brush strokes, 16:9 landscape format, high resolution suitable for 1920x1080 display

Negative: detailed linework, pen and ink outlines, complete illustration, finished artwork, uniform detail density, architectural precision, hard edges, sharp boundaries, vector art, every corner resolved, portfolio piece, standalone illustration, brick patterns, window frame details, cobblestone individual stones, building facade details, decorative elements, busy composition, photorealistic, 3D render, CGI, vector art, sharp edges, oversaturated colors, neon colors, pure black shadows, crowded, busy streets, cars, vehicles, people, characters, text on signs, power lines, urban clutter, harsh contrast, heavy rain, storm, dark mood, complex architectural details, cluttered composition
```

### Technical Parameters

- **Resolution**: 1920x1080 pixels (exact)
- **Format**: PNG, 8-bit color depth
- **Target File Size**: <2MB
- **Aspect Ratio**: 16:9
- **Color Profile**: sRGB

### Expected Visual Outcome

**Key Elements**:
- Wet street with puddles and reflections
- Clearing sky: gray-blue clouds + orange-pink sunset breaking through
- Street lamp on right third providing warm light
- Cool wet surfaces (gray-blue) contrasting with warm light (orange-pink)
- Gentle mist rising from ground
- Leading lines (street perspective) toward vanishing point
- High color temperature contrast: cool ground (6000K) vs warm sky/lamp (3000K)

**Mood Keywords**: Hopeful, Fresh, Clearing, Peaceful, Evening, Reflective

### Quality Checklist (Minimum Pass: 3/5 per dimension)

#### Dimension 1: Atmosphere (氛围营造)
- [ ] Can identify "post-rain" and "evening" within 5 seconds
- [ ] Mixed color temperature: cool ground + warm sky/lamp
- [ ] Visible weather effect (wetness, reflections, mist)
- [ ] Contrast ratio ≥ 2:1
- [ ] 5-second test: 2/3 testers say "hopeful" or "fresh"

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 2: Depth Layers (层次分离)
- [ ] Three distinct layers: foreground (puddles), midground (buildings), background (sky)
- [ ] Grayscale test: RGB average difference ≥ 30 between layers
- [ ] Background saturation 30-50% lower than foreground
- [ ] Background blur visible (atmospheric perspective + mist)
- [ ] Color temperature shift: background warmer (sky) than midground (buildings)

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 3: Color Harmony (色彩和谐)
- [ ] Cool-warm contrast intentional and harmonious (gray-blue + orange-pink)
- [ ] Hue range ≤ 180° (cool + warm complementary)
- [ ] Saturation range 40-70%
- [ ] Color temperature contrast ≥ 500K (cool ground vs warm sky)
- [ ] 5-minute viewing test: no visual fatigue despite contrast

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 4: Paper Texture (纸质感)
- [ ] Texture visible at 100% zoom
- [ ] Texture strength 15-25%
- [ ] Grain size consistent across image
- [ ] Texture not visible at 50% zoom
- [ ] On/off comparison shows warmth difference

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 5: Edge Treatment (边缘处理)
- [ ] Edges soft and natural, especially at water boundaries
- [ ] Edge feathering 2-5px
- [ ] Extensive color bleeding at water edges (3-8px)
- [ ] 200% zoom test: edges appear watercolor-like with wetness effect
- [ ] Reflections in puddles have soft, diffused edges

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 6: Information Clarity (信息清晰度)
- [ ] Key elements (street lamp, puddles, buildings) identifiable within 3 seconds
- [ ] Key element contrast ≥ 3:1 with background
- [ ] Reflections visible but not distracting
- [ ] 3-second recognition test: 80% accuracy
- [ ] Mist adds atmosphere but doesn't obscure key elements

**Minimum Pass Score**: 3/5 criteria met

#### Dimension 7: Detail Restraint (细节克制度) ⭐ NEW

**Purpose**: Ensure the image is a "background plate" not a "finished illustration"

- [ ] **No dominant linework**: Forms defined by color transitions, not pen/ink lines (200% zoom test: no continuous line work visible on building edges, cobblestones, or puddle edges)
- [ ] **Differential detail density**: Background has 50-70% fewer distinct visual elements than foreground (background buildings should be atmospheric masses, not detailed facades with windows and bricks)
- [ ] **Strategic incompleteness**: Background elements are "suggestive" not "specific" (can identify "buildings" and "sky" but not architectural details, distant street should fade into mist)
- [ ] **Visual hierarchy clear**: Player's eye naturally drawn to foreground puddles and street lamp, not to background building details
- [ ] **Intentional ambiguity**: Background buildings and distant street should be soft washes with mist, reflections should be impressionistic not mirror-sharp

**Minimum Pass Score**: 3/5 criteria met

### Additional Weather Scene Checks

- [ ] Wetness effect visible (reflections, darker surfaces, mist)
- [ ] Sky shows clearing (mix of clouds and light breaking through)
- [ ] Reflections in puddles match light sources (sky color, lamp color)
- [ ] Color temperature contrast supports mood (cool wet + warm hope)
- [ ] Mist/fog subtle (10-20% opacity), not overpowering

**Minimum Pass Score**: 3/5 criteria met

### Pass Threshold

**Overall Pass Requirement**: All 7 dimensions + weather checks score ≥3/5

**⚠️ CRITICAL**: Dimension 7 (Detail Restraint) is now mandatory. If this dimension scores <3, the image is a "finished illustration" not a "game background" and must be regenerated with stronger negative prompts.

### Iteration Record Template

[Same structure as Task 1]

---

## Evaluation Workflow

### Step 1: Self-Check (5 minutes per sample)

After generating each sample, perform these quick tests:

1. **5-Second Test**: Show image for 5 seconds, hide it, ask yourself:
   - What place is this?
   - What time of day?
   - What's the mood?
   
2. **Grayscale Test**: Convert to grayscale in image editor
   - Can you still distinguish 3 depth layers?
   - Is there clear brightness difference between layers?

3. **Contrast Test**: Use eyedropper tool
   - Sample brightest and darkest areas
   - Calculate contrast ratio (should be ≥ 2:1)

4. **Zoom Test**: View at 100% and 50%
   - At 100%: paper texture visible?
   - At 50%: texture blends in?

5. **Edge Test**: Zoom to 200%
   - Are edges soft and feathered?
   - Any hard vector lines or jagged edges?

**If any test fails**: Note the issue and prepare to iterate.

### Step 2: Detailed Scoring (10 minutes per sample)

Use the quality checklist for each task. For each dimension:

1. Check each criterion (5 per dimension)
2. Count how many criteria are met
3. Score = (criteria met / 5) × 5

Example:
- Atmosphere: 4/5 criteria met = 4.0/5.0
- Depth: 3/5 criteria met = 3.0/5.0
- Color: 5/5 criteria met = 5.0/5.0
- Texture: 3/5 criteria met = 3.0/5.0
- Edge: 4/5 criteria met = 4.0/5.0
- Clarity: 3/5 criteria met = 3.0/5.0

**Overall Score**: (4.0 + 3.0 + 5.0 + 3.0 + 4.0 + 3.0) / 6 = 3.67/5.0

### Step 3: Decision Making

**If Overall Score ≥ 3.0 AND all dimensions ≥ 3.0**:
- **PASS** - Accept the sample
- Document the successful prompt in iteration log
- Proceed to next task

**If Overall Score ≥ 3.0 BUT any dimension < 3.0**:
- **ITERATE** - Identify failed dimension
- Review failed criteria
- Adjust prompt based on troubleshooting guide (see below)
- Regenerate and re-evaluate

**If Overall Score < 3.0 OR any dimension = 1.0**:
- **FAIL** - Major issue with prompt or approach
- Review entire prompt structure
- Consider alternative composition or scene description
- Regenerate from scratch

### Step 4: Iteration Strategy

**For each failed dimension, apply these adjustments**:

#### Atmosphere Issues (Score < 3.0)
- **Problem**: Can't identify scene type or time
  - **Fix**: Add explicit time-of-day keywords ("morning sunlight", "afternoon glow", "evening amber")
- **Problem**: No visible light source
  - **Fix**: Add "warm light streaming from [direction]" and "gentle shadows"
- **Problem**: Wrong mood conveyed
  - **Fix**: Add mood keywords ("peaceful atmosphere", "hopeful mood", "cozy feeling")

#### Depth Issues (Score < 3.0)
- **Problem**: Layers blend together
  - **Fix**: Add "atmospheric perspective with misty background" and "clear foreground/midground/background separation"
- **Problem**: No contrast difference between layers
  - **Fix**: Add "background desaturated and blurred" and "foreground sharp and vibrant"

#### Color Issues (Score < 3.0)
- **Problem**: Colors too saturated
  - **Fix**: Add "muted pastel palette", "desaturated tones", "low saturation"
- **Problem**: Colors outside palette
  - **Fix**: Explicitly list hex colors or color names from art bible
- **Problem**: Color temperature inconsistent
  - **Fix**: Add "warm color temperature" or "cool color temperature" and specify Kelvin range

#### Texture Issues (Score < 3.0)
- **Problem**: No visible paper texture
  - **Fix**: Add "visible paper grain texture", "textured watercolor paper surface"
- **Problem**: Texture too strong
  - **Fix**: Plan to adjust in post-processing (Godot shader parameter)

#### Edge Issues (Score < 3.0)
- **Problem**: Edges too sharp
  - **Fix**: Add "soft edges", "gentle color bleeding", "watercolor diffusion", "blurred boundaries"
- **Problem**: No color bleeding
  - **Fix**: Add "extensive color bleeding at edges", "watercolor bleeding effect"

#### Clarity Issues (Score < 3.0)
- **Problem**: Key elements unclear
  - **Fix**: Add "[element] as clear focal point", increase contrast keywords
- **Problem**: Too cluttered
  - **Fix**: Add "minimal composition", "simple scene", "few elements", "spacious"

### Step 5: Record Keeping

After each attempt, fill out the iteration log:

```markdown
## Task [X] Iteration Log

### Attempt [N]
- **Date**: 2026-04-21 14:30
- **Prompt Used**: [Copy full prompt here]
- **Scores**: 
  - Atmosphere: 4.0/5.0 (4/5 criteria)
  - Depth: 3.0/5.0 (3/5 criteria)
  - Color: 5.0/5.0 (5/5 criteria)
  - Texture: 2.0/5.0 (2/5 criteria) ← FAILED
  - Edge: 4.0/5.0 (4/5 criteria)
  - Clarity: 3.0/5.0 (3/5 criteria)
- **Overall**: 3.5/5.0
- **Decision**: ITERATE (Texture dimension failed)
- **Issues Identified**:
  - Texture: Paper texture barely visible at 100% zoom
  - Texture: No warmth difference when texture toggled off
- **Prompt Adjustments for Next Attempt**:
  - Add: "visible paper grain texture", "textured watercolor paper surface"
  - Emphasize: "hand-painted aesthetic with organic brush strokes"
  - Note: May need to increase paper_strength in Godot shader to 0.25
```

---

## Scoring Sheet Template

Use this template to record scores for all 3 tasks:

```markdown
# Generation Task Pack 001 - Scoring Sheet

## Task 1: Mochi's Bedroom Window View

### Attempt 1
- **Date**: [YYYY-MM-DD HH:MM]
- **Atmosphere**: [X]/5 ([X]/5 criteria met)
- **Depth**: [X]/5 ([X]/5 criteria met)
- **Color**: [X]/5 ([X]/5 criteria met)
- **Texture**: [X]/5 ([X]/5 criteria met)
- **Edge**: [X]/5 ([X]/5 criteria met)
- **Clarity**: [X]/5 ([X]/5 criteria met)
- **Overall**: [X.X]/5.0
- **Decision**: [PASS / ITERATE / FAIL]

### Attempt 2 (if needed)
[Same structure]

### Final Result
- **Accepted Attempt**: [N]
- **Total Attempts**: [N]
- **Final Score**: [X.X]/5.0
- **File Name**: bg_bedroom_morning_1920x1080.png

---

## Task 2: Street Corner Cafe Exterior

[Same structure as Task 1]

---

## Task 3: Post-Rain City Street

[Same structure as Task 1]

---

## Summary

- **Total Samples Generated**: [N]
- **Total Attempts**: [N]
- **Average Score**: [X.X]/5.0
- **Pass Rate**: [X]% (samples passed on first attempt)
- **Most Common Issue**: [Dimension name]
- **Recommended Workflow Adjustments**: [List any patterns or improvements discovered]
```

---

## Quick Reference

### Color Palette Hex Codes

**Warm Comfort Palette** (Task 1):
- Cream: `#FFF8E7`
- Peach: `#FFD4B2`
- Soft Yellow: `#FFF4A3`
- Muted Orange: `#FFB366`

**Earthy Grounded Palette** (Task 2):
- Off-White: `#F5F1E8`
- Terracotta: `#D4876F`
- Sage Green: `#B8C5A6`
- Warm Brown: `#A67C52`

**Cool-Warm Mix Palette** (Task 3):
- Gray-Blue: `#B8C5D4`
- Soft Orange: `#FFB8A3`
- Pale Pink: `#FFD4E6`
- Muted Purple: `#C5B8D4`

### Common Issues Quick Fix

| Issue | Quick Fix |
|-------|-----------|
| Colors too bright | Add "muted pastel palette", "desaturated tones" |
| Edges too sharp | Add "soft edges", "gentle color bleeding" |
| No depth | Add "atmospheric perspective", "background blurred and desaturated" |
| No texture | Add "visible paper grain texture", plan to enhance in Godot |
| Wrong mood | Add explicit mood keywords ("peaceful", "hopeful", "cozy") |
| Too cluttered | Add "minimal composition", "simple scene", "few elements" |
| No light source | Add "warm light streaming from [direction]", "gentle shadows" |

### Time-of-Day Lighting Quick Reference

- **Morning (6-10 AM)**: "soft golden morning light", "warm highlights", "long gentle shadows", 3000-4000K
- **Afternoon (12-3 PM)**: "bright diffused daylight", "minimal shadows", "even illumination", 5000-6000K
- **Evening (5-7 PM)**: "warm amber sunset glow", "deep blue shadows", "high contrast", 2500-3500K
- **Night (8 PM-5 AM)**: "cool moonlight", "deep shadows", "limited color palette", 6000-8000K

---

## Next Steps After Completion

### If All 3 Samples Pass (Score ≥ 3.0)

1. **Document Successful Prompts**: Copy all final prompts to `asset-creation-workflow.md` as validated templates
2. **Update Quality Standards**: If any dimension consistently scored >4.0, consider raising the bar in `visual-design-system.md`
3. **Prepare Batch Production**: Create 10 more background scenes using validated prompts as templates
4. **Schedule User Testing**: Show 3 samples to 5-10 users, collect feedback on mood and atmosphere

### If Any Sample Fails After 3 Attempts

1. **Escalate to Creative Director**: The prompt approach may need fundamental revision
2. **Consider Alternative Tools**: Nana Banana may not be suitable for this scene type
3. **Revise Quality Standards**: The standard may be too strict for AI generation capabilities
4. **Document Lessons Learned**: Record what didn't work in `quality-iteration-guide.md`

### If 2/3 Samples Pass

1. **Analyze Failed Sample**: What made it harder? (Complexity, weather, lighting?)
2. **Create Specialized Template**: Develop dedicated prompt template for that scene type
3. **Proceed with Caution**: Use validated prompts for batch production, avoid failed scene type until resolved

---

## Appendix: Troubleshooting Decision Tree

```
Generated sample → Self-check (5 min) → Pass? 
                                        ├─ Yes → Detailed scoring (10 min) → All dimensions ≥3? 
                                        │                                    ├─ Yes → ACCEPT → Next task
                                        │                                    └─ No → Identify failed dimension → Apply fix → Regenerate
                                        └─ No → Note issue → Apply quick fix → Regenerate

After 3 attempts → Still failing?
                   ├─ Yes → Escalate to Creative Director
                   └─ No → ACCEPT → Next task
```

---

*This task pack is designed for hands-on execution. Fill out the scoring sheet as you work, and update the iteration logs after each attempt. The goal is not perfection, but validation of the workflow and identification of reliable prompt patterns.*
