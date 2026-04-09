# Sprint 1 -- 2026-04-07 to 2026-04-18

## Sprint Goal
Establish technical foundation by implementing F1 Desktop Window System and F2 Character State Machine, unlocking dependency chain for MVP systems.

## Capacity
- Total days: 10 working days (2 weeks)
- Buffer (20%): 2 days reserved for unplanned work
- Available: 8 days for planned tasks

## Tasks

### Must Have (Critical Path)
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S1-01 | Implement F1 Desktop Window System | godot-specialist + engine-programmer | 4 | None | Window appears transparent, always-on-top, borderless at 320×320. Position persists between sessions. System tray icon with hide/show functionality. |
| S1-02 | Implement F2 Character State Machine | gameplay-programmer | 3 | S1-01 | Three core states (Home, Away, Cooldown) implemented with transitions. State changes trigger appropriate events/signals. |
| S1-03 | Basic window drag functionality | godot-specialist | 1 | S1-01 | User can drag window to reposition. Position saved on drag end. |
| S1-04 | Create project structure and core modules | lead-programmer | 1 | None | src/ directory organized with core/, gameplay/, ui/ subdirectories. Basic module loading pattern established. |

### Should Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S1-05 | Implement F3 Time/Rhythm System foundation | gameplay-programmer | 2 | S1-02 | Real-time progression system tracks time. Can be queried by other systems. |
| S1-06 | Basic UI framework setup | ui-programmer | 2 | S1-01 | UI layer prepared with styling system. Basic components (Label, Panel) working with window transparency. |

### Nice to Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S1-07 | Create test framework for F1/F2 | qa-tester + lead-programmer | 2 | S1-01, S1-02 | GUT test framework configured. Basic unit tests for window and state machine. |
| S1-08 | Document architecture for implemented systems | technical-director | 1 | S1-01, S1-02 | ADRs created for key decisions made during implementation. |

## Carryover from Previous Sprint
| Task | Reason | New Estimate |
|------|--------|-------------|
| N/A - First Sprint | | |

## Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| F1 window transparency issues on Windows | High | High | Test early with Godot 4.6.1 gl_compatibility renderer. Have fallback plan (semi-transparent with visible border). |
| Godot 4.6.1 API differences | Medium | Medium | Consult docs/engine-reference/godot/ and test incrementally. |
| Time estimation inaccurate | Medium | Medium | Use 20% buffer. Prioritize Must Have tasks. |

## Dependencies on External Factors
- Godot 4.6.1 engine installed and working
- Windows platform for testing (primary target)
- No external API dependencies for this sprint

## Definition of Done for this Sprint
- [ ] All Must Have tasks completed (S1-01 through S1-04)
- [ ] All tasks pass acceptance criteria
- [ ] No S1 or S2 bugs in delivered features
- [ ] Design documents updated for any deviations from GDD
- [ ] Code reviewed and merged to main branch

## Sprint Success Metrics
- ✅ F1 Desktop Window System working with basic functionality
- ✅ F2 Character State Machine implemented
- ✅ Project structure established
- ✅ Can move to Sprint 2 (F3, F4, C1 implementation)