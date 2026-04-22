# Quality Iteration Guide

## Purpose

Define the evaluation and iteration workflow for visual assets, ensuring quality standards evolve based on real production samples rather than theoretical specs.

## Initial Sample Evaluation (First 3 Backgrounds)

### Sample Set Requirements

- 3 backgrounds representing different complexity levels:
  - **Simple** (minimal detail, clear focal point): Single room interior, 3-5 elements, single light source
  - **Medium** (moderate detail, 2-3 depth layers): Room with window view, 5-8 elements, multiple light sources
  - **Complex** (high detail, multiple elements, atmospheric effects): Outdoor scene with foreground/mid/background, 8+ elements, atmospheric perspective

### Evaluation Checklist (Detailed Scoring)

For each sample, assess using 1-5 scoring system:

#### 1. Style Consistency (Weight: 35%)

**Color Palette Compliance (1-5)**:
- **5**: All colors within art bible palette, perfect hex match (±5 RGB)
- **4**: All colors within palette, slight variation (±10 RGB)
- **3**: Most colors within palette (90%+), minor deviations (±20 RGB)
- **2**: Some colors outside palette (70-90% compliant)
- **1**: Many colors outside palette (<70% compliant)

**Scoring Method**:
- Sample 20 random pixels from the image
- Compare each to nearest art bible color using RGB distance formula: `sqrt((R1-R2)² + (G1-G2)² + (B1-B2)²)`
- Count how many are within tolerance
- Score = (compliant pixels / total pixels) × 5

**Line Weight & Texture (1-5)**:
- **5**: Perfect watercolor aesthetic, soft edges throughout, visible paper texture
- **4**: Strong watercolor feel, mostly soft edges, paper texture visible
- **3**: Recognizable watercolor style, soft edges present, texture adequate
- **2**: Weak watercolor feel, some hard edges, texture weak
- **1**: No watercolor aesthetic, digital/vector appearance

**Scoring Method**:
- Edge softness: Measure edge gradient width at 10 random boundaries (target ≥3px)
- Paper texture: Check visibility at 100% zoom (should be detectable but not distracting)
- Color bleeding: Check for color diffusion at element boundaries (target ≥2px)
- Score based on how many criteria meet target

**Lighting Direction (1-5)**:
- **5**: Perfect lighting logic, consistent shadows, realistic light behavior
- **4**: Good lighting logic, mostly consistent shadows, minor issues
- **3**: Acceptable lighting, shadows present, some inconsistencies
- **2**: Weak lighting logic, inconsistent shadows, unrealistic
- **1**: No lighting logic, random shadows, breaks immersion

**Scoring Method**:
- Identify light source(s) in the image
- Check if all shadows point away from light source (consistency test)
- Measure shadow softness (should match light source type)
- Check for reflected light in shadow areas (no pure black)
- Score based on how many lighting rules are followed

**Style Consistency Subscore**:
```
Style Score = (Color Palette × 0.4) + (Line Weight & Texture × 0.4) + (Lighting × 0.2)
```

#### 2. Technical Quality (Weight: 20%)

**Resolution & Format (1-5)**:
- **5**: Exact 1920x1080 PNG, perfect quality, no artifacts
- **4**: Correct resolution and format, minor quality issues
- **3**: Correct resolution and format, acceptable quality
- **2**: Wrong resolution or format, or significant quality issues
- **1**: Severely wrong specs or unusable quality

**Scoring Method**:
- Check image properties: must be exactly 1920×1080 pixels
- Check format: must be PNG (not JPEG, WebP, etc.)
- Check for compression artifacts at 100% zoom
- Check for AI generation artifacts (weird textures, impossible geometry)
- All criteria must pass for score ≥3

**File Size (1-5)**:
- **5**: <1.5MB, optimal compression
- **4**: 1.5-2MB, good compression
- **3**: 2-2.5MB, acceptable
- **2**: 2.5-3MB, needs optimization
- **1**: >3MB, unacceptable

**Scoring Method**:
- Check file size in properties
- Score directly based on size ranges above
- If >2.5MB, test with pngquant or similar optimizer

**Performance Impact (1-5)**:
- **5**: Loads instantly (<50ms), no frame drops, minimal memory
- **4**: Loads quickly (<100ms), no frame drops, acceptable memory
- **3**: Loads acceptably (<200ms), no frame drops, within budget
- **2**: Slow load (>200ms) or minor frame drops
- **1**: Very slow load or significant performance issues

**Scoring Method**:
- Import into Godot test scene
- Measure load time using Godot profiler
- Check frame rate with background displayed (should maintain 60fps)
- Check memory usage (should be <8MB uncompressed)
- Score based on performance metrics

**Technical Quality Subscore**:
```
Technical Score = (Resolution & Format × 0.4) + (File Size × 0.3) + (Performance × 0.3)
```

#### 3. Readability (Weight: 25%)

**Character Silhouette Clarity (1-5)**:
- **5**: Character perfectly visible on all background areas, contrast ≥7:1
- **4**: Character clearly visible, contrast ≥4.5:1
- **3**: Character visible, contrast ≥3:1, acceptable
- **2**: Character barely visible, contrast <3:1
- **1**: Character blends into background, unusable

**Scoring Method**:
- Place test character sprite on background at 5 different positions
- Measure contrast ratio at each position using WCAG formula
- Average the 5 measurements
- Score based on average contrast ratio

**UI Element Legibility (1-5)**:
- **5**: All UI elements perfectly legible, no interference
- **4**: UI elements clearly legible, minimal interference
- **3**: UI elements legible, some interference but acceptable
- **2**: UI elements difficult to read, significant interference
- **1**: UI elements illegible, background competes too much

**Scoring Method**:
- Overlay test UI (window frames, text, buttons) on background
- Test readability at 1920x1080 from 2 feet away
- Check contrast ratios for text areas (target ≥4.5:1)
- Ask 3 people to read UI text quickly (should be instant)
- Score based on readability test results

**Visual Hierarchy (1-5)**:
- **5**: Perfect hierarchy, focal point obvious, supports gameplay
- **4**: Good hierarchy, focal point clear, mostly supports gameplay
- **3**: Acceptable hierarchy, focal point identifiable, adequate support
- **2**: Weak hierarchy, focal point unclear, poor gameplay support
- **1**: No hierarchy, confusing, hinders gameplay

**Scoring Method**:
- 3-second test: Show to 5 people for 3 seconds, ask "what did you look at first?"
- If 4+ people identify the intended focal point → score ≥4
- If 3 people identify focal point → score = 3
- If <3 people identify focal point → score ≤2
- Check if background elements compete with UI/character (should not)

**Readability Subscore**:
```
Readability Score = (Character Clarity × 0.35) + (UI Legibility × 0.35) + (Visual Hierarchy × 0.3)
```

#### 4. Production Feasibility (Weight: 20%)

**Creation Time (1-5)**:
- **5**: <30 minutes per asset (highly efficient)
- **4**: 30-60 minutes per asset (efficient)
- **3**: 60-90 minutes per asset (acceptable)
- **2**: 90-120 minutes per asset (slow)
- **1**: >120 minutes per asset (unsustainable)

**Scoring Method**:
- Track actual time from prompt creation to final approved asset
- Include all iterations and refinements
- Average across the 3 sample assets
- Score based on average time

**Technique Repeatability (1-5)**:
- **5**: Perfectly repeatable, same prompt produces consistent results
- **4**: Highly repeatable, minor variations acceptable
- **3**: Repeatable with some variation, requires occasional adjustment
- **2**: Difficult to repeat, frequent adjustments needed
- **1**: Not repeatable, each attempt significantly different

**Scoring Method**:
- Generate same prompt 3 times (different seeds)
- Compare results for consistency in style, color, composition
- If 3/3 results are usable → score = 5
- If 2/3 results are usable → score = 3-4
- If 1/3 or 0/3 results are usable → score ≤2

**Complexity Sustainability (1-5)**:
- **5**: Can easily produce 50+ assets at this quality level
- **4**: Can produce 30-50 assets at this quality level
- **3**: Can produce 20-30 assets at this quality level
- **2**: Can produce 10-20 assets at this quality level
- **1**: Cannot sustain this quality level for full production

**Scoring Method**:
- Estimate based on creation time and team capacity
- Consider tool limitations (AI generation quotas, manual work required)
- Consider burnout risk (if process is tedious or frustrating)
- Discuss with team to get realistic estimate

**Production Feasibility Subscore**:
```
Feasibility Score = (Creation Time × 0.4) + (Repeatability × 0.3) + (Sustainability × 0.3)
```

### Overall Sample Score

**Calculate Weighted Total**:
```
Total Score = (Style × 0.35) + (Technical × 0.20) + (Readability × 0.25) + (Feasibility × 0.20)
```

**Score Interpretation**:
- **5.0-4.5**: Excellent — Standards are perfect, proceed with confidence
- **4.4-4.0**: Good — Standards are solid, minor tweaks optional
- **3.9-3.0**: Acceptable — Standards are workable, monitor closely
- **2.9-2.0**: Needs Adjustment — Standards too high or process flawed
- **1.9-1.0**: Unacceptable — Major revision needed

### Decision Points (Detailed Decision Tree)

After evaluating 3 samples, calculate average score and follow decision tree:

```
Average Score ≥ 4.0?
├─ YES → Accept Standards
│   ├─ Document approved samples in iteration-log.md
│   ├─ Lock art bible section (mark as "Production Ready v1.0")
│   ├─ Proceed with batch production (next 10 assets)
│   └─ Schedule Cycle 2 review after 10 assets
│
└─ NO → Average Score < 4.0
    │
    ├─ Any dimension score < 2.0?
    │   ├─ YES → Major Issue Detected
    │   │   ├─ Identify which dimension(s) failed
    │   │   ├─ Root cause analysis (see Adjustment Protocol)
    │   │   ├─ Decide: Adjust Standards OR Adjust Scope
    │   │   └─ Regenerate 3 new samples, re-evaluate
    │   │
    │   └─ NO → All dimensions ≥ 2.0 but average < 4.0
    │       ├─ Minor Issues Across Multiple Dimensions
    │       ├─ Prioritize improvements (focus on lowest scores)
    │       ├─ Make targeted adjustments (see Adjustment Protocol)
    │       └─ Regenerate 1-2 samples to test adjustments
    │
    └─ After Adjustments
        ├─ Re-evaluate adjusted samples
        ├─ If average score now ≥ 3.5 → Accept with monitoring
        ├─ If average score still < 3.5 → Escalate to Creative Director
        └─ Document all decisions in iteration-log.md
```

### Sample Evaluation Report Template

```markdown
# Sample Evaluation Report

**Date**: [YYYY-MM-DD]
**Evaluator**: [Name]
**Sample Set**: [Simple / Medium / Complex]

## Sample 1: [Filename] (Simple)

### Scores
- Style Consistency: [X.X]/5.0
  - Color Palette: [X.X]/5.0
  - Line Weight & Texture: [X.X]/5.0
  - Lighting Direction: [X.X]/5.0
- Technical Quality: [X.X]/5.0
  - Resolution & Format: [X.X]/5.0
  - File Size: [X.X]/5.0
  - Performance: [X.X]/5.0
- Readability: [X.X]/5.0
  - Character Clarity: [X.X]/5.0
  - UI Legibility: [X.X]/5.0
  - Visual Hierarchy: [X.X]/5.0
- Production Feasibility: [X.X]/5.0
  - Creation Time: [X.X]/5.0 ([X] minutes)
  - Repeatability: [X.X]/5.0
  - Sustainability: [X.X]/5.0

**Weighted Total**: [X.X]/5.0

### Notes
[Specific observations, strengths, weaknesses]

## Sample 2: [Filename] (Medium)
[Same structure as Sample 1]

## Sample 3: [Filename] (Complex)
[Same structure as Sample 1]

## Overall Assessment

**Average Score**: [X.X]/5.0

**Decision**: [Accept / Adjust Standards / Adjust Scope]

**Rationale**: [Explanation of decision based on scores and observations]

**Next Steps**:
- [Action item 1]
- [Action item 2]
- [Action item 3]

**Approval**: [Name] — [Date]
```

## Standard Adjustment Protocol (Detailed)

### When to Adjust

Trigger adjustment review when:

- **Initial 3 samples fail** (average score < 4.0)
- **Batch review reveals drift** (every 10 assets, check for consistency)
- **User/playtest feedback** identifies visual issues (clarity, mood, style)
- **Technical constraints discovered** (performance, file size, tool limitations)
- **Team feedback** indicates process issues (too slow, too difficult, too inconsistent)

### Adjustment Process (Step-by-Step)

#### Step 1: Identify Issue

**Question Set**:
1. Which evaluation criterion failed? (Style / Technical / Readability / Feasibility)
2. What is the specific problem? (Colors wrong / Edges too sharp / UI illegible / Takes too long)
3. Is it isolated or systemic? (One asset / Multiple assets / All assets)
4. Does it affect existing assets? (Yes / No / Partially)

**Issue Classification**:
- **Critical**: Breaks art bible compliance, unusable for gameplay (score <2.0)
- **Important**: Reduces quality but usable (score 2.0-2.9)
- **Minor**: Acceptable but could be better (score 3.0-3.9)

**Documentation**:
```markdown
## Issue Identification

**Date**: [YYYY-MM-DD]
**Identified By**: [Name]
**Criterion Failed**: [Style / Technical / Readability / Feasibility]
**Specific Problem**: [Detailed description]
**Severity**: [Critical / Important / Minor]
**Affected Assets**: [List or count]
**Isolated or Systemic**: [Isolated / Systemic]
```

#### Step 2: Root Cause Analysis

**Decision Tree for Root Cause**:

```
Problem: Colors too saturated
├─ Check: Art bible color palette definition
│   ├─ Palette defined with hex codes? → YES
│   │   ├─ Check: AI prompt includes "muted" and "desaturated"?
│   │   │   ├─ YES → AI tool not respecting prompt
│   │   │   │   └─ Solution: Add stronger negative prompts, try different AI tool
│   │   │   └─ NO → Prompt missing key keywords
│   │   │       └─ Solution: Update prompt template
│   │   └─ NO → Palette too saturated in art bible
│   │       └─ Solution: Adjust art bible palette (reduce saturation 20-30%)
│   └─ Palette not defined with hex codes? → NO
│       └─ Solution: Define precise palette in art bible with hex codes

Problem: Edges too sharp
├─ Check: AI prompt includes "soft edges" and "watercolor"?
│   ├─ YES → AI tool producing vector-style output
│   │   ├─ Solution: Add negative prompts ("sharp edges", "vector art")
│   │   └─ Or: Apply edge softening in post-processing or Godot shader
│   └─ NO → Prompt missing key keywords
│       └─ Solution: Update prompt template with edge softness keywords

Problem: UI illegible on background
├─ Check: Background has sufficient negative space?
│   ├─ YES → Negative space has too much detail/contrast
│   │   └─ Solution: Adjust prompt to simplify negative space areas
│   └─ NO → Background too cluttered
│       └─ Solution: Simplify scene description, reduce element count

Problem: Creation time too long (>90 minutes)
├─ Check: How many iterations needed per asset?
│   ├─ 1-2 iterations → Prompt is good, AI tool is slow
│   │   └─ Solution: Try faster AI tool or accept longer timeline
│   ├─ 3-5 iterations → Prompt needs improvement
│   │   └─ Solution: Refine prompt template for better first-try results
│   └─ 6+ iterations → Prompt or standards are problematic
│       └─ Solution: Major prompt revision or lower quality standards
```

**Root Cause Documentation**:
```markdown
## Root Cause Analysis

**Problem**: [Specific issue from Step 1]
**Root Cause**: [Underlying reason, not just symptom]
**Evidence**: [How we determined this is the root cause]
**Contributing Factors**: [Other factors that worsen the issue]
```

#### Step 3: Propose Solution

**Solution Types**:

1. **Art Bible Change** (affects design standards):
   - Color palette adjustment (change hex codes, saturation levels)
   - Style guide adjustment (edge softness, texture strength, lighting rules)
   - Composition rules adjustment (negative space requirements, focal point placement)
   - **Impact**: May require rework of existing assets
   - **Approval Required**: Creative Director

2. **Asset Specification Change** (affects technical requirements):
   - Resolution change (e.g., 1920x1080 → 1600x900)
   - Format change (e.g., PNG → WebP)
   - File size budget change (e.g., 2MB → 3MB)
   - **Impact**: May require re-export of existing assets
   - **Approval Required**: Technical Director

3. **Production Process Change** (affects workflow):
   - Prompt template update (add/remove keywords)
   - AI tool change (switch to different generator)
   - Post-processing step addition (edge softening, color correction)
   - Quality gate adjustment (change pass/fail thresholds)
   - **Impact**: Changes how future assets are created
   - **Approval Required**: Art Director

4. **Scope Change** (affects project plan):
   - Reduce asset count (e.g., 50 backgrounds → 30 backgrounds)
   - Reduce complexity (e.g., no complex scenes, only simple/medium)
   - Extend timeline (allow more time per asset)
   - **Impact**: Changes project scope and schedule
   - **Approval Required**: Producer + Creative Director

**Solution Proposal Template**:
```markdown
## Solution Proposal

**Solution Type**: [Art Bible / Asset Spec / Process / Scope]
**Proposed Change**: [Detailed description of what will change]

**Pros**:
- [Benefit 1]
- [Benefit 2]

**Cons**:
- [Drawback 1]
- [Drawback 2]

**Alternatives Considered**:
- [Alternative 1]: [Why not chosen]
- [Alternative 2]: [Why not chosen]

**Recommended Solution**: [Which solution to implement and why]
```

#### Step 4: Impact Assessment

**Impact Assessment Checklist**:

**Existing Assets**:
- [ ] How many existing assets are affected? [Count]
- [ ] Do they need rework? [Yes / No / Partial]
- [ ] Estimated rework time per asset: [X minutes]
- [ ] Total rework time: [X hours]
- [ ] Priority: [High / Medium / Low]

**Downstream Systems**:
- [ ] Does it affect UI system? [Yes / No]
- [ ] Does it affect VFX system? [Yes / No]
- [ ] Does it affect character integration? [Yes / No]
- [ ] Does it affect shaders? [Yes / No]
- [ ] Estimated downstream work: [X hours]

**Time & Cost**:
- [ ] Rework time: [X hours]
- [ ] Downstream work: [X hours]
- [ ] Testing time: [X hours]
- [ ] Total time impact: [X hours]
- [ ] Schedule impact: [X days delay]
- [ ] Cost impact: [$ amount if applicable]

**Risk Assessment**:
- [ ] Risk of introducing new issues: [Low / Medium / High]
- [ ] Risk of not fixing: [Low / Medium / High]
- [ ] Mitigation plan: [How to reduce risk]

**Impact Assessment Template**:
```markdown
## Impact Assessment

**Affected Assets**: [X] assets need rework
**Rework Time**: [X] hours total ([Y] minutes per asset)
**Downstream Impact**: [List affected systems and estimated work]
**Schedule Impact**: [X] days delay
**Risk Level**: [Low / Medium / High]
**Mitigation Plan**: [How to minimize impact]

**Go/No-Go Decision**: [Proceed / Defer / Reject]
**Rationale**: [Why this decision makes sense]
```

#### Step 5: Document Change

**Art Bible Update Process**:
1. Create new version of art bible (increment version number)
2. Mark changed sections with version number and date
3. Add changelog entry at top of document
4. Archive previous version in `design/art/archive/`
5. Update all references to art bible in other documents

**Iteration Log Entry**:
```markdown
## [YYYY-MM-DD] - [Asset Category] - [Issue Type]

**Issue**: [Description of problem]
**Root Cause**: [Underlying reason]
**Solution**: [What changed]
**Art Bible Changes**: [List specific changes with version number]
**Affected Assets**: [List or count]
**Rework Status**: [Not Started / In Progress / Complete]
**Impact**: [Time cost, schedule impact]
**Status**: [Resolved / In Progress / Deferred]
**Approved By**: [Name] — [Date]

**Before/After Comparison**:
- Before: [Old standard or process]
- After: [New standard or process]
- Reason: [Why this change improves quality or feasibility]
```

**Asset Tagging**:
- Tag affected assets in `assets/registry.md` with `[NEEDS_REWORK_v1.1]`
- Create rework task list with priority order
- Assign rework tasks to team members
- Track rework progress in iteration log

#### Step 6: Regenerate Samples

**Sample Regeneration Process**:
1. Apply changes to prompt template or art bible
2. Generate 1-2 new samples (not full 3-sample set)
3. Focus on the specific issue that was identified
4. Compare new samples to old samples (before/after)
5. Re-evaluate using same scoring system
6. Confirm issue is resolved (score improvement ≥1.0 point)

**Validation Criteria**:
- [ ] New samples score ≥1.0 point higher in failed dimension
- [ ] New samples don't introduce new issues (other dimensions stable)
- [ ] New samples are achievable with updated process (repeatability test)
- [ ] Team agrees new samples are better (consensus check)

**If Validation Fails**:
- Analyze why the change didn't work
- Consider alternative solutions
- May need to iterate on the adjustment itself
- Document failed attempts to avoid repeating mistakes

### What NOT to Adjust

**Do NOT adjust standards for**:

1. **Single Outlier Asset**:
   - Problem: One asset out of 10 has an issue
   - Action: Fix the asset, not the standard
   - Reason: Standards should be based on patterns, not exceptions

2. **Personal Preference Without User Feedback**:
   - Problem: "I think the colors should be more vibrant"
   - Action: Gather user feedback first
   - Reason: Personal taste ≠ player experience

3. **Minor Variations Within Acceptable Range**:
   - Problem: Asset scores 3.8 instead of 4.0
   - Action: Accept the variation
   - Reason: Perfection is not the goal, consistency is

4. **Temporary Tool Issues**:
   - Problem: AI tool is having a bad day, producing poor results
   - Action: Wait and retry, don't change standards
   - Reason: Tool issues are transient, standards are permanent

5. **Scope Creep Disguised as Quality**:
   - Problem: "Let's add more detail to make it better"
   - Action: Stick to original scope
   - Reason: More detail ≠ better quality, and increases cost

**Decision Checkpoint**:
Before adjusting any standard, ask:
- Is this a pattern (3+ assets) or an outlier (1 asset)?
- Do we have user feedback supporting this change?
- Will this change improve player experience or just satisfy personal taste?
- Is the cost of adjustment justified by the benefit?
- Are we solving the root cause or just treating symptoms?

If answer to any question is uncertain, defer the adjustment and gather more data.

### Adjustment Decision Matrix

| Issue Severity | Affected Assets | User Impact | Decision |
|----------------|-----------------|-------------|----------|
| Critical | 1 | None | Fix asset, don't adjust standard |
| Critical | 3+ | None | Adjust standard (systemic issue) |
| Critical | Any | High | Adjust standard immediately |
| Important | 1-2 | Low | Fix assets, monitor for pattern |
| Important | 3+ | Low | Adjust standard (systemic issue) |
| Important | Any | Medium-High | Adjust standard |
| Minor | Any | Low | Accept variation, don't adjust |
| Minor | 5+ | Medium | Consider adjustment, gather more data |
| Minor | Any | High | Adjust standard (user feedback trumps score) |

### Real-World Adjustment Examples

#### Example 1: Colors Too Saturated (Critical, Systemic)

**Issue Identification**:
- All 3 initial samples scored 2.0/5.0 on Color Palette Compliance
- Colors measured at 80-90% saturation, art bible specifies 40-70%
- Systemic issue affecting all assets

**Root Cause Analysis**:
- AI prompt includes "watercolor" but not "muted" or "desaturated"
- AI tool (Nana Banana) defaults to high saturation for "watercolor"
- Art bible palette examples are low saturation but not explicitly specified

**Solution Proposed**:
- Update prompt template: Add "muted pastel palette, desaturated tones, low saturation"
- Update art bible: Add explicit saturation range (40-70%) with HSL values
- Add negative prompt: "oversaturated, vibrant, neon colors"

**Impact Assessment**:
- 3 existing samples need regeneration (3 × 45 min = 2.25 hours)
- No downstream impact (assets not yet integrated)
- Schedule impact: 1 day delay
- Risk: Low (clear solution, well-understood problem)

**Change Documentation**:
- Art Bible v1.0 → v1.1
- Changed: Color palette section, added saturation specifications
- Prompt template updated with new keywords
- Iteration log entry created

**Regeneration Results**:
- New samples scored 4.2/5.0 on Color Palette Compliance (+2.2 improvement)
- Saturation measured at 50-65%, within target range
- Issue resolved, proceed with production

#### Example 2: UI Illegible on Background (Important, Isolated)

**Issue Identification**:
- 1 out of 10 assets scored 2.5/5.0 on UI Legibility
- Text overlay on upper-right corner has insufficient contrast (2.8:1, need 4.5:1)
- Isolated issue, other 9 assets passed

**Root Cause Analysis**:
- This specific background has high-contrast pattern in upper-right corner
- Prompt didn't specify negative space requirements for UI areas
- Other backgrounds happened to have low-contrast corners by chance

**Solution Proposed**:
- Fix this asset: Regenerate with explicit "low detail in upper corners" keyword
- Update prompt template: Add "negative space in corners for UI overlay"
- Don't change art bible (standards are correct, execution was off)

**Impact Assessment**:
- 1 asset needs regeneration (45 min)
- No downstream impact
- Schedule impact: None (within normal iteration time)
- Risk: Low (simple fix)

**Change Documentation**:
- Art Bible: No change
- Prompt template updated with negative space specification
- Iteration log entry created (minor issue, documented for learning)

**Regeneration Results**:
- New asset scored 4.5/5.0 on UI Legibility (+2.0 improvement)
- Contrast measured at 5.2:1, exceeds target
- Issue resolved, no further action needed

#### Example 3: Creation Time Too Long (Important, Systemic)

**Issue Identification**:
- Average creation time: 105 minutes per asset (target: 60-90 minutes)
- Requires 4-6 iterations per asset to achieve acceptable quality
- Systemic issue affecting all assets

**Root Cause Analysis**:
- Prompt template is too vague, AI produces inconsistent results
- Quality standards are achievable but require many iterations
- No clear pattern in what works vs. what doesn't

**Solution Proposed**:
- Option A: Refine prompt template with more specific keywords (reduce iterations)
- Option B: Lower quality standards slightly (accept 3.5+ instead of 4.0+)
- Option C: Extend timeline (accept 105 min as new baseline)
- **Recommended**: Option A (improve process, maintain quality)

**Impact Assessment**:
- Option A: 8 hours to refine and test new prompt template, then 45 min/asset (saves 60 min/asset)
- Option B: No time investment, but quality reduction may affect player experience
- Option C: No time investment, but extends project timeline by 30%
- **Decision**: Option A (best long-term solution)

**Change Documentation**:
- Prompt template refined with 15 new specific keywords
- Tested on 3 new samples: average 2.5 iterations (down from 5)
- Average creation time: 65 minutes (down from 105 minutes)
- Iteration log entry created with detailed prompt improvements

**Results**:
- Next 10 assets averaged 68 minutes creation time (within target)
- Quality maintained at 4.1/5.0 average (no degradation)
- Issue resolved, process improved

## Iteration Cycles (Detailed Timeline)

### Cycle 1: Initial Validation (First 3 Assets)

**Goal**: Validate art bible and production feasibility

**Timeline**: Days 1-5 (1 week)

**Day 1: Preparation**
- [ ] Review art bible thoroughly (2 hours)
- [ ] Set up evaluation tools (color picker, contrast checker, Godot test scene) (1 hour)
- [ ] Prepare prompt templates from asset-creation-workflow.md (1 hour)
- [ ] Define 3 sample scenes (simple/medium/complex) (1 hour)
- **Total**: 5 hours

**Day 2: Generation - Simple Sample**
- [ ] Create prompt for simple scene (30 min)
- [ ] Generate initial batch (4-8 variations) (1 hour)
- [ ] Quick quality check, select top 2 candidates (30 min)
- [ ] Refine and regenerate (1-2 iterations) (1 hour)
- [ ] Final selection and export (30 min)
- **Total**: 3.5 hours
- **Output**: 1 approved simple background

**Day 3: Generation - Medium Sample**
- [ ] Create prompt for medium scene (30 min)
- [ ] Generate initial batch (4-8 variations) (1 hour)
- [ ] Quick quality check, select top 2 candidates (30 min)
- [ ] Refine and regenerate (2-3 iterations) (1.5 hours)
- [ ] Final selection and export (30 min)
- **Total**: 4 hours
- **Output**: 1 approved medium background

**Day 4: Generation - Complex Sample**
- [ ] Create prompt for complex scene (45 min)
- [ ] Generate initial batch (4-8 variations) (1 hour)
- [ ] Quick quality check, select top 2 candidates (30 min)
- [ ] Refine and regenerate (3-4 iterations) (2 hours)
- [ ] Final selection and export (30 min)
- **Total**: 4.75 hours
- **Output**: 1 approved complex background

**Day 5: Evaluation & Decision**
- [ ] Detailed evaluation of all 3 samples (3 hours)
  - Score each sample across all dimensions
  - Calculate weighted totals
  - Document findings in evaluation report
- [ ] Team review meeting (1 hour)
  - Present scores and samples
  - Discuss issues and potential solutions
  - Make decision: Accept / Adjust / Escalate
- [ ] Document decision in iteration-log.md (30 min)
- [ ] If accepted: Lock art bible section, plan next 10 assets (30 min)
- [ ] If adjustments needed: Plan adjustment protocol (1 hour)
- **Total**: 5-6 hours
- **Output**: Decision documented, next steps planned

**Cycle 1 Total Time**: 22-23 hours (approximately 1 week)

**Success Criteria**:
- Average score ≥ 4.0 across all 3 samples
- All dimensions score ≥ 3.0 (no critical failures)
- Team consensus that standards are achievable
- Creation time per asset ≤ 90 minutes

**Failure Handling**:
- If average score < 4.0: Enter Adjustment Protocol (add 2-3 days)
- If any dimension < 2.0: Major revision needed (add 1 week)
- If creation time > 120 min: Process optimization needed (add 2-3 days)

### Cycle 2: Batch Production (Every 10 Assets)

**Goal**: Catch drift and maintain consistency

**Timeline**: After every 10 assets (approximately every 2 weeks)

**Week 1-2: Production**
- [ ] Produce 10 assets following approved standards
- [ ] Track creation time per asset
- [ ] Note any issues or deviations during production
- [ ] Maintain asset registry with generation parameters
- **Total**: 10-15 hours (1-1.5 hours per asset average)

**Week 2: Batch Review (Day 1)**
- [ ] Gather all 10 assets for review (15 min)
- [ ] Visual consistency check (1 hour)
  - Display all 10 assets side-by-side
  - Check for style drift (color, edges, texture)
  - Identify outliers
- [ ] Spot-check technical specs (30 min)
  - Verify resolution, format, file size
  - Check 3 random assets in detail
- [ ] Compare to art bible (1 hour)
  - Sample colors from 5 random assets
  - Check against palette hex codes
  - Measure edge softness on 3 assets
- [ ] Document findings (30 min)
- **Total**: 3 hours

**Week 2: Batch Review (Day 2) - If Issues Found**
- [ ] Detailed evaluation of problematic assets (1-2 hours)
- [ ] Root cause analysis (1 hour)
- [ ] Decide: Minor corrections / Adjustment protocol / Acceptable variation
- [ ] If minor corrections: Regenerate 1-3 assets (1-3 hours)
- [ ] If adjustment needed: Enter Adjustment Protocol (see timeline below)
- [ ] Update iteration log (30 min)
- **Total**: 3.5-6.5 hours (only if issues found)

**Batch Review Decision Tree**:
```
All 10 assets consistent with art bible?
├─ YES → Continue production
│   └─ Document "No issues found" in iteration log
│
└─ NO → Issues detected
    │
    ├─ 1-2 assets have issues?
    │   ├─ Minor issues (score 3.0-3.9)?
    │   │   └─ Accept variation, continue production
    │   └─ Major issues (score <3.0)?
    │       └─ Regenerate those assets, continue production
    │
    └─ 3+ assets have issues?
        ├─ Same issue across multiple assets?
        │   └─ Systemic problem → Enter Adjustment Protocol
        └─ Different issues?
            └─ Process breakdown → Review workflow, retrain team
```

**Success Criteria**:
- ≥8 out of 10 assets pass all quality checks
- No systemic issues detected
- Average creation time stable (±15 minutes from baseline)
- Style consistency maintained (visual inspection passes)

**Cycle 2 Frequency**: Every 10 assets, approximately every 2 weeks during production

### Cycle 3: User Testing (After Playable Build)

**Goal**: Validate player experience and readability

**Timeline**: After first playable build (approximately 4-6 weeks into production)

**Week 1: Test Preparation**
- [ ] Build playable demo with 10-15 backgrounds (2 days, technical team)
- [ ] Prepare user testing script (1 hour)
  - Questions about visual clarity
  - Questions about mood and atmosphere
  - Questions about style appeal
  - UI legibility tasks
- [ ] Recruit 10-15 testers (2 hours)
- [ ] Set up testing environment (1 hour)
- **Total**: 4 hours (art team) + 2 days (technical team)

**Week 2: Testing Sessions**
- [ ] Conduct 10-15 individual testing sessions (10 hours)
  - 30-45 minutes per session
  - Observe gameplay with backgrounds
  - Ask prepared questions
  - Note spontaneous feedback
- [ ] Compile feedback (2 hours)
  - Categorize by theme (clarity, mood, style, technical)
  - Identify patterns (3+ testers mention same issue)
  - Prioritize issues by severity and frequency
- **Total**: 12 hours

**Week 3: Analysis & Decision**
- [ ] Analyze feedback against current standards (2 hours)
  - Do backgrounds support gameplay? (readability)
  - Do backgrounds convey intended mood? (atmosphere)
  - Do players like the visual style? (appeal)
  - Are there accessibility issues? (contrast, clarity)
- [ ] Team review meeting (2 hours)
  - Present findings
  - Discuss implications for standards
  - Decide: Accept / Adjust / Major revision
- [ ] Document findings in iteration log (1 hour)
- [ ] If adjustments needed: Plan and execute (see Adjustment Protocol)
- **Total**: 5+ hours

**User Testing Decision Matrix**:

| Feedback Type | Frequency | Severity | Decision |
|---------------|-----------|----------|----------|
| Positive (like the style) | 80%+ | N/A | Continue as-is |
| Neutral (no strong opinion) | 50-80% | N/A | Continue, monitor |
| Negative (dislike style) | <20% | Low | Accept variation in taste |
| Negative (dislike style) | 20-50% | Medium | Consider adjustments |
| Negative (dislike style) | >50% | High | Major revision needed |
| Clarity issue | 3+ testers | Any | Adjust standards (readability) |
| Mood mismatch | 5+ testers | Any | Adjust standards (atmosphere) |
| Accessibility issue | 1+ tester | Any | Fix immediately (critical) |

**Success Criteria**:
- ≥70% of testers rate visual style positively (4-5 out of 5)
- <20% of testers report clarity or readability issues
- No accessibility issues reported
- Mood and atmosphere match design intent (80%+ agreement)

**Failure Handling**:
- If <50% positive feedback: Major style revision needed (escalate to Creative Director)
- If clarity issues >30%: Readability standards too low (adjust immediately)
- If accessibility issues: Fix affected assets and update standards (critical priority)

**Cycle 3 Total Time**: 3 weeks (includes testing, analysis, potential adjustments)

### Cycle 4: Pre-Production Lock

**Goal**: Finalize standards before full production

**Timeline**: After 20+ assets and user testing complete (approximately 8-10 weeks into project)

**Lock Criteria Checklist**:
- [ ] 3 initial samples approved (Cycle 1 complete)
- [ ] 20+ assets produced with consistent quality (average score ≥4.0)
- [ ] At least 2 batch reviews completed (Cycle 2 × 2)
- [ ] User testing shows no major visual issues (Cycle 3 complete)
- [ ] Team can reliably hit quality bar (creation time stable, repeatability high)
- [ ] No systemic issues in last 10 assets
- [ ] Art bible has been stable for 2+ weeks (no recent adjustments)

**Lock Process**:
1. **Final Review Meeting** (2 hours)
   - Review all 20+ assets together
   - Confirm style consistency across all assets
   - Verify all quality criteria are met
   - Team consensus that standards are final

2. **Art Bible Finalization** (2 hours)
   - Mark art bible as "Production Locked v1.0"
   - Add lock date and approval signatures
   - Archive all previous versions
   - Distribute final version to all team members

3. **Process Documentation** (2 hours)
   - Document final prompt templates
   - Document quality gate thresholds
   - Document common issues and solutions
   - Create quick reference guide for production team

4. **Communication** (1 hour)
   - Announce lock to all stakeholders
   - Explain change control process going forward
   - Set expectations for production phase

**Total Lock Process Time**: 7 hours

**After Lock**:
- Art bible changes require formal review and version bump (v1.0 → v1.1)
- Changes must be justified by critical issues or user feedback
- Focus shifts from experimentation to execution
- Quality gates remain active but standards are stable
- Continue Cycle 2 batch reviews every 10 assets

**Change Control After Lock**:
```
Proposed change to locked art bible
├─ Critical issue (breaks gameplay, accessibility)?
│   ├─ YES → Emergency change allowed
│   │   ├─ Document in iteration log
│   │   ├─ Update art bible version (v1.0 → v1.1)
│   │   └─ Notify all stakeholders
│   └─ NO → Continue evaluation
│
└─ User feedback or systemic issue?
    ├─ YES → Formal review required
    │   ├─ Present to Creative Director
    │   ├─ Assess impact (time, cost, rework)
    │   ├─ Decide: Approve / Defer / Reject
    │   └─ If approved: Update version, notify team
    └─ NO → Reject change
        └─ Document reason in iteration log
```

### Overall Timeline Summary

**Pre-Production Phase** (Weeks 1-10):
- Week 1: Cycle 1 - Initial Validation (3 samples)
- Weeks 2-3: Adjustments if needed
- Weeks 4-7: Produce 20 assets (Cycle 2 × 2)
- Weeks 8-10: Cycle 3 - User Testing
- Week 10: Cycle 4 - Production Lock

**Production Phase** (Weeks 11+):
- Ongoing: Produce remaining assets (30-80 more)
- Every 2 weeks: Cycle 2 - Batch Review
- As needed: Minor adjustments (rare after lock)

**Total Pre-Production Time**: 10 weeks (includes validation, testing, lock)
**Production Rate**: 5-10 assets per week (depending on complexity)

### Iteration Cycle Metrics

Track and report monthly:

**Cycle 1 Metrics**:
- Initial sample pass rate (target: 100% after adjustments)
- Average score of initial samples (target: ≥4.0)
- Time to approval (target: ≤1 week)

**Cycle 2 Metrics**:
- Batch consistency rate (target: ≥80% of assets pass)
- Style drift incidents (target: 0 per batch)
- Average creation time (target: stable ±15 min)

**Cycle 3 Metrics**:
- User satisfaction rate (target: ≥70% positive)
- Clarity issue rate (target: <20% of testers)
- Accessibility issue rate (target: 0%)

**Cycle 4 Metrics**:
- Time to lock (target: ≤10 weeks)
- Post-lock change rate (target: <1 change per month)
- Production stability (target: no quality degradation)

**Continuous Improvement**:
- If Cycle 1 takes >2 weeks: Improve art bible clarity or prompt templates
- If Cycle 2 detects issues >30% of time: Improve quality gates or training
- If Cycle 3 shows <70% satisfaction: Major style revision needed
- If Cycle 4 lock delayed >12 weeks: Scope or standards too ambitious

## Iteration Log Format

Maintain `design/art/iteration-log.md` with entries:

```markdown
## [Date] - [Asset Category] - [Issue Type]

**Issue**: [Description of problem]
**Affected Assets**: [List or count]
**Solution**: [What changed in art bible or specs]
**Impact**: [Time cost, rework needed]
**Status**: [Resolved / In Progress / Deferred]
```

## Quality Gates

Before marking any asset as "production ready":

- [ ] Passes all 4 evaluation criteria (style, technical, readability, feasibility)
- [ ] Matches current art bible version
- [ ] Follows asset naming convention
- [ ] Documented in asset manifest

## Escalation

If iteration cycles reveal systemic issues:

- **Art bible fundamentally flawed**: Escalate to creative-director for vision review
- **Technical constraints blocking quality**: Escalate to technical-artist for pipeline solution
- **Scope vs. quality conflict**: Escalate to producer for schedule/scope adjustment

---

**Next Steps After This Document**:

1. Create `design/art/iteration-log.md` (empty, ready for first entry)
2. Generate first 3 background samples
3. Run initial evaluation
4. Document decision and proceed
