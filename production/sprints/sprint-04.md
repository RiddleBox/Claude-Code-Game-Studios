# Sprint 4 -- 2026-05-08 to 2026-05-17

## Sprint Goal
Implement P1 Vertical Slice systems (C3, C4, C5, Fe6, P2, P3) to complete narrative depth and enable full initial event line experience.

## Capacity
- Total days: 10 days (1.5 weeks, includes weekends)
- Buffer (10%): 1 day reserved for unplanned work
- Available: 9 days for planned tasks

## Tasks

### Must Have (Critical Path)
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S4-01 | Implement C3 Fragment System module | narrative-designer + gameplay-programmer | 2 | F4 (existing), Fe2 (existing) | Module implements IModule interface. Stores narrative fragments in C3 format with metadata. Supports fragment unlocking via Fe2 integration. Persists to F4 save system. |
| S4-02 | Implement C5 Personality Variable System module | game-designer + gameplay-programmer | 2 | F2 (existing) | Module implements IModule interface. Manages 5+ personality dimensions with normalization. Subscribes to F2 state changes and updates variables. Feeds into Fe1 for dialogue variation. |
| S4-03 | Implement C4 Event Line System module | narrative-designer + gameplay-programmer | 3 | F3 (existing), F4 (existing), C3 (S4-01) | Module implements IModule interface. Implements event node graph with conditions/actions. Integrates with C3 for fragment unlocks. Timeline-based progression via F3 ticks. |
| S4-04 | Implement Fe6 Notification System module | ui-programmer + godot-specialist | 1.5 | F1 (existing), C2 (existing) | Module implements IModule interface. Non-intrusive toast notifications with priority levels. Queuing with respect to "do not disturb" mode. Integrates with C2 for outing return alerts. |
| S4-05 | Implement P2 Fragment Log UI module | ui-programmer | 1.5 | C3 (S4-01), Fe3 (existing) | Module implements IModule interface. Scrollable fragment list with filters. Displays fragment details and unlock timestamps. Integrates with Fe3 for affinity-gated content. |
| S4-06 | Implement P3 Settings UI module | ui-programmer | 1 | F1 (existing), F5 (existing) | Module implements IModule interface. Settings panel for audio, window, and gameplay options. Integrates with F5 for volume controls. Integrates with F1 for window behavior toggles. |

### Should Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S4-07 | Create narrative content configuration guide | technical-writer | 1 | C3 (S4-01), C4 (S4-03) | Non-technical user guide for creating fragments and event lines. JSON schema examples. Step-by-step tutorial for adding initial event line. |
| S4-08 | Create Sprint 4 integration tests | qa-tester | 1 | All Must Have | Integration test validates C3 unlock flow, C5 personality variation, C4 event progression, Fe6 notifications, P2/P3 UI functions. |

### Nice to Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S4-09 | C4 advanced event triggers | narrative-designer | 1 | C4 (S4-03) | Time-based triggers, affinity-gated branches, random variation support. |
| S4-10 | P2 fragment search/filtering | ui-programmer | 1 | P2 (S4-05) | Search by keyword, filter by fragment type, sort by unlock time. |

## Definition of Done for this Sprint
- [ ] All Must Have tasks completed (S4-01 through S4-06)
- [ ] C3 fragment system working with Fe2 integration
- [ ] C5 personality system varying Fe1 dialogue
- [ ] C4 event line system progressing initial story
- [ ] Fe6 notification system non-intrusive
- [ ] P2 fragment log UI viewable and filterable
- [ ] P3 settings UI functional
- [ ] No critical bugs in delivered features
- [ ] Integration tests passing for new systems
- [ ] Code reviewed and merged to main branch

## Sprint Success Metrics
- ✅ C3 Fragment System implemented and integrated with Fe2
- ✅ C5 Personality System implemented with F2 integration
- ✅ C4 Event Line System implemented with timeline progression
- ✅ Fe6 Notification System implemented with "do not disturb"
- ✅ P2 Fragment Log UI implemented
- ✅ P3 Settings UI implemented
- ✅ Sprint 4 integration tests all passing
- ✅ Narrative content configuration guide created
- ✅ Ready for first playtest of vertical slice

## Dependencies on External Factors
- Existing F1, F2, F3, F4, Fe2, Fe3, Fe5, P1 modules stable
- No external API dependencies

## Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| C4 event line complexity | High | Medium | Implement simplified linear flow first, iterate toward branching. |
| C5 personality normalization | Medium | Medium | Start with simple linear mapping, validate with Fe1 integration. |
| UI implementation time | Medium | Low | Prioritize P2 and P3 core functionality first, polish later. |

## P1 Vertical Slice Exit Criteria
- [ ] Full initial event line playable from start to finish
- [ ] Narrative fragments unlocking through gameplay
- [ ] Personality variation visible in dialogue
- [ ] Player can review fragments in P2 log
- [ ] Settings configurable in P3 UI
- [ ] Notifications respecting "do not disturb" mode
