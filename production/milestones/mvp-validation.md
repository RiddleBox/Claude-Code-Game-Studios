# MVP Validation Milestone

**Target Date**: 2026-05-07 (4 weeks from start)
**Goal**: Validate core companionship loop + outing-return cycle feasibility

## Success Criteria
1. ✅ Desktop window system (F1) working with transparent, always-on-top behavior
2. ✅ Character state machine (F2) implementing all 3 core states
3. ✅ Time/rhythm system (F3) handling real-time progression
4. ✅ Save system (F4) persisting character state between sessions
5. ✅ Character animation system (C1) providing basic visual presence
6. ✅ Outing-return cycle (C2) implementing full restlessness accumulation logic
7. ✅ Leak content system (Fe2) providing curiosity hooks during outings
8. ✅ Sound system (Fe5) providing ambient audio feedback
9. ✅ Main UI (P1) providing basic player interaction

## Deliverables
- Playable vertical slice demonstrating full idle loop
- Technical validation of desktop window implementation
- Performance baseline measurements
- Documentation of any technical blockers discovered

## Risk Assessment
- **High**: F1 desktop window system may have platform-specific challenges
- **Medium**: Real-time sync between multiple systems
- **Low**: Core gameplay logic (C2) already prototyped

## Dependencies
- Godot 4.6.1 engine configured
- GDScript proficiency
- Windows platform testing environment

## Exit Criteria
- All 9 MVP systems implemented and integrated
- Core loop playable end-to-end
- No critical bugs blocking basic functionality
- Performance within target budgets