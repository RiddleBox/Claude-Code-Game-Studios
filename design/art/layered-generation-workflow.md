# Layered Generation Workflow

*Created: 2026-04-22*
*Status: Experimental - For complex scenes that fail single-pass generation*

---

## Purpose

When single-pass AI generation produces over-detailed "finished illustrations" instead of "game background plates", this workflow breaks generation into multiple passes with increasing detail control.

## When to Use This Workflow

Use layered generation when:
- Single-pass generation consistently scores <3 on Dimension 7 (Detail Restraint)
- After 3 attempts with revised prompts, linework and over-detailing persist
- Complex scenes (outdoor + weather, multiple architectural elements) fail quality checks
- Background elements remain too detailed despite strong negative prompts

**Do NOT use for**:
- Simple scenes that pass on first or second attempt
- Scenes where single-pass generation already achieves ≥3.0 on all dimensions

---

## Three-Pass Generation Strategy

### Pass 1: Simplified Color Foundation (色块基础层)

**Goal**: Generate atmospheric color masses with NO details, NO linework

**Prompt Structure**:
```
Watercolor color study, loose color masses only, [scene description], atmospheric mood, blurred and impressionistic, color temperature study, minimal forms, abstract shapes suggesting [key elements], paper texture, soft edges, intentionally vague and unfinished

Negative: details, linework, precision, architectural accuracy, finished, complete, sharp edges, defined forms, specific objects
```

**Example - Bedroom Scene**:
```
Watercolor color study, loose color masses only, bedroom corner with morning light, atmospheric warm mood, blurred and impressionistic, color temperature study with golden yellows and soft creams, minimal forms, abstract shapes suggesting window and bed, paper texture, soft edges, intentionally vague and unfinished, 16:9 landscape format

Negative: details, linework, precision, architectural accuracy, finished, complete, sharp edges, defined forms, specific objects, furniture details, window frames, floor planks, decorative elements
```

**Pass 1 Quality Check**:
- [ ] No recognizable objects (just color areas)
- [ ] No linework visible at 200% zoom
- [ ] Color temperature correct for scene mood
- [ ] Composition roughly correct (focal area placement)
- [ ] Feels like "color sketch" not "painting"

**If Pass 1 fails**: Strengthen negative prompts, try alternative phrasing like "abstract color composition", "color blocking study"

---

### Pass 2: Selective Detail Addition (选择性细节层)

**Goal**: Add details ONLY to foreground/focal areas, keep background as-is

**Two Approaches**:

#### Approach A: Manual Post-Processing (Recommended)
1. Import Pass 1 result into Photoshop/Krita
2. Create new layer for foreground details
3. Manually paint/add details ONLY to:
   - Foreground elements (floor, immediate objects)
   - Focal point (window, door, key furniture)
4. Leave background layer untouched
5. Merge and export

**Time Estimate**: 15-30 minutes per image

#### Approach B: AI img2img with Mask (Advanced)
1. Use Pass 1 result as base image
2. Create mask covering background areas (protect from changes)
3. Use img2img with low strength (0.3-0.5) on foreground only
4. Prompt focuses on foreground details only

**Prompt for img2img**:
```
Add subtle details to foreground only: [specific foreground elements], keep background unchanged, soft watercolor style, minimal linework, color-defined forms

Negative: background details, uniform detail density, complete illustration, linework on background elements
```

**Pass 2 Quality Check**:
- [ ] Foreground has recognizable elements
- [ ] Background remains as color masses from Pass 1
- [ ] No linework added to background
- [ ] Detail density: Foreground 10-15 elements, Background ≤5 elements
- [ ] Transition between detailed foreground and simple background is smooth

---

### Pass 3: Final Polish (最终润色层)

**Goal**: Add paper texture, adjust color balance, ensure game-ready quality

**Post-Processing Steps**:

1. **Paper Texture Overlay** (if not present from Pass 1)
   - Add subtle paper grain texture (15-25% opacity)
   - Use Godot shader or Photoshop overlay

2. **Background Desaturation**
   - Select background areas
   - Reduce saturation by 30-40%
   - Reduce contrast by 15-20%

3. **Background Blur** (if needed)
   - Apply Gaussian blur 3-5px to background only
   - Use gradient mask for smooth transition

4. **Color Bleeding Enhancement**
   - Expand color areas at edges by 2-3px with low opacity
   - Simulate watercolor bleeding effect

5. **Final Adjustments**
   - Check contrast ratios (≥2:1 overall, ≥3:1 for key elements)
   - Verify color palette matches art bible
   - Export as PNG, 1920x1080, <2MB

**Pass 3 Quality Check**:
- [ ] All 7 dimensions score ≥3/5
- [ ] Dimension 7 (Detail Restraint) ≥3/5 specifically
- [ ] File size <2MB
- [ ] Ready for Godot import

---

## Time Investment Comparison

| Workflow | Simple Scene | Medium Scene | Complex Scene |
|----------|--------------|--------------|---------------|
| **Single-Pass** | 30-45 min | 45-60 min | 60-90 min |
| **Layered (Manual)** | 45-60 min | 60-90 min | 90-120 min |
| **Layered (AI img2img)** | 40-50 min | 55-75 min | 75-105 min |

**Trade-off**: Layered workflow adds 15-30 minutes per image but provides much better control over detail distribution.

---

## Decision Tree: Single-Pass vs Layered

```
Generate with single-pass → Score Dimension 7 → ≥3? 
                                              ├─ Yes → ACCEPT (use single-pass)
                                              └─ No → Revise prompt → Try again (max 3 attempts)
                                                                    ├─ Pass → ACCEPT
                                                                    └─ Fail → Switch to Layered Workflow

Layered Workflow:
Pass 1 (color masses) → Pass 2 (selective details) → Pass 3 (polish) → Final check → ≥3 on all dimensions?
                                                                                      ├─ Yes → ACCEPT
                                                                                      └─ No → ESCALATE to creative-director
```

---

## Example: Task 1 Bedroom Scene (Layered Workflow)

### Pass 1 Prompt
```
Watercolor color study, loose color masses only, bedroom corner with morning light from left, atmospheric warm mood, blurred and impressionistic, color temperature study with golden yellows and soft creams, minimal forms, abstract shapes suggesting window area and bed area, paper texture, soft edges, intentionally vague and unfinished, 16:9 landscape format, high resolution

Negative: details, linework, precision, architectural accuracy, finished, complete, sharp edges, defined forms, specific objects, furniture details, window frames, floor planks, bed frame, nightstand details, decorative elements, recognizable objects
```

**Expected Result**: Warm yellow-cream color masses on left (window area), peachy-cream masses in center (bed area), soft shadows, NO recognizable furniture

### Pass 2: Manual Detail Addition
1. Open Pass 1 result in Krita
2. Create new layer "Foreground Details"
3. Paint subtle bed shape (just color mass with slight form)
4. Add suggestion of nightstand (simple rectangle, no details)
5. Keep window as color glow (no frame, no panes)
6. Add floor color variation (no plank lines)
7. Merge layers

**Time**: ~20 minutes

### Pass 3: Polish
1. Add paper texture overlay (20% opacity)
2. Desaturate background wall by 35%
3. Apply 4px Gaussian blur to background wall only
4. Enhance color bleeding at bed edges (3px expansion, 30% opacity)
5. Final color balance adjustment
6. Export PNG

**Time**: ~10 minutes

**Total Time**: Pass 1 (30 min) + Pass 2 (20 min) + Pass 3 (10 min) = **60 minutes**

---

## Alternative: Hybrid AI + Manual Workflow

For teams with digital painting skills:

1. **AI generates composition** (Pass 1 - color masses)
2. **Artist adds strategic details** (Pass 2 - manual painting)
3. **AI enhances texture/atmosphere** (Pass 3 - img2img at low strength)

**Advantages**:
- More artistic control than pure AI
- Faster than full manual painting
- Consistent style across assets

**Disadvantages**:
- Requires digital painting skills
- Not fully automated
- Harder to scale to large asset counts

---

## Tool Recommendations

### For Pass 1 (Color Foundation)
- **Nana Banana**: Good for watercolor color studies
- **Midjourney**: Better at "abstract" and "impressionistic" styles
- **Stable Diffusion**: Most control with custom models

### For Pass 2 (Selective Details)
- **Manual (Krita/Photoshop)**: Most control, best results
- **Stable Diffusion img2img + ControlNet**: Good automation
- **Photoshop Generative Fill**: Quick but less control

### For Pass 3 (Polish)
- **Krita**: Free, excellent brush engine for texture
- **Photoshop**: Industry standard, best filters
- **Godot Shader**: Can add texture/effects in-engine

---

## Success Metrics

Track these metrics to evaluate if layered workflow is worth the extra time:

| Metric | Target |
|--------|--------|
| **Pass Rate** | ≥80% of layered workflow images score ≥3.0 on all dimensions |
| **Time Efficiency** | Layered workflow ≤2x time of single-pass |
| **Dimension 7 Score** | Layered workflow averages ≥4.0 on Detail Restraint |
| **Iteration Count** | Layered workflow requires ≤1.5 iterations per image |

**Review after 10 images**: If layered workflow consistently hits targets, adopt as standard for complex scenes. If not, escalate to creative-director for workflow redesign.

---

## Integration with Existing Workflow

### When to Switch from Single-Pass to Layered

In `generation-task-pack-001.md`, after 3 failed attempts:

```markdown
### Attempt 3
- **Decision**: FAIL (Dimension 7 still <3 after 3 attempts)
- **Next Action**: Switch to Layered Generation Workflow
  - Use Pass 1 prompt from layered-generation-workflow.md
  - Follow 3-pass process
  - Document time and results in iteration log
```

### Updating Quality Standards

If layered workflow becomes standard:
- Update `asset-creation-workflow.md` to include layered workflow as Phase 2B
- Add time estimates to production schedule
- Train team on manual detail addition techniques

---

## Troubleshooting

### Pass 1 still has too much detail
- **Problem**: AI adds recognizable objects despite "abstract" prompt
- **Solution**: Try alternative tools (Midjourney with `--style raw --stylize 50`)
- **Solution**: Use even stronger negative prompts: "no recognizable objects, pure color abstraction"

### Pass 2 details don't match Pass 1 style
- **Problem**: Manual painting looks different from AI base
- **Solution**: Use soft brushes with low opacity (20-40%)
- **Solution**: Sample colors directly from Pass 1 layer
- **Solution**: Add paper texture to manual layer to unify style

### Pass 3 polish makes image too soft
- **Problem**: Background blur makes entire image feel unfocused
- **Solution**: Use gradient mask for blur (100% on far background, 0% on foreground)
- **Solution**: Reduce blur radius to 3px instead of 5px
- **Solution**: Sharpen foreground elements after background blur

### Layered workflow takes too long
- **Problem**: 90-120 minutes per complex scene is unsustainable
- **Solution**: Batch process Pass 3 polish steps (texture, blur, color balance)
- **Solution**: Create Photoshop actions for repetitive steps
- **Solution**: Consider hiring digital painting specialist for Pass 2

---

## Next Steps

1. **Test layered workflow** on Task 3 (Post-Rain Street) if single-pass fails
2. **Document results** in iteration log with time breakdown
3. **Compare quality** between single-pass (with strong prompts) vs layered workflow
4. **Decide**: Is the extra time worth the quality improvement?
5. **Update standards** if layered workflow becomes standard for complex scenes

---

*This workflow is experimental. After testing on 5-10 images, review effectiveness and update this document with lessons learned.*
