# Sprint 2 -- 2026-04-19 to 2026-04-28

## Sprint Goal
Implement F4 Save System, C1 Character Animation System, and C2 Outing-Return Cycle to establish core gameplay loop and unlock remaining MVP systems.

## Capacity
- Total days: 10 days (1.5 weeks, includes weekends)
- Buffer (10%): 1 day reserved for unplanned work
- Available: 9 days for planned tasks

## Tasks

### Must Have (Critical Path)
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S2-01 | Implement F4 Save System module | gameplay-programmer | 3 | None | Module implements IModule interface. Provides save(key, value), load(key, default), save_batch(), delete() APIs. Saves to user://save.json in JSON format with _meta version info. |
| S2-02 | Integrate F4 with F3 Time System | lead-programmer | 1 | S2-01 | F3 uses F4 to persist last_online_timestamp instead of memory storage. F3's TODO dependency on F4 resolved. Save/load tested across app restarts. |
| S2-03 | Implement C1 Character Animation System module | godot-specialist + gameplay-programmer | 3 | S2-01, existing F2 | Module implements IModule interface. Subscribes to F2 state_changed signals. Provides basic animation switching between 3 core states (Idle, Attentive, Interacting). Uses placeholder sprite resources. |
| S2-04 | Integrate C1 with F1 window scene | godot-specialist | 1 | S2-03, existing F1 | Character sprite added to F1 window scene with proper positioning. Animation visible in transparent window context. |
| S2-05 | Implement C2 Outing-Return Cycle module | gameplay-programmer | 3 | S2-01, existing F2, existing F3 | Module implements IModule interface. Subscribes to F3 tick signals. Implements basic departure logic: MIN_OUTING_INTERVAL (20 min), random departure after cooldown, Away state management. |

### Should Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S2-06 | C2 integration with F2 State Machine | gameplay-programmer | 2 | S2-05 | F2 responds to C2 departure_triggered with departure_accepted/declined based on current state. Proper state transitions between Home → Away → Returning. |
| S2-07 | Basic integration testing for F4+C1+C2 | qa-tester + lead-programmer | 2 | S2-02, S2-04, S2-06 | Integration test validates: F4 persistence works, C1 animations trigger on F2 state changes, C2 cycle triggers departures and returns. Test report generated. |
| S2-08 | Update app.gd module registration | lead-programmer | 1 | S2-01, S2-03, S2-05 | New modules (F4, C1, C2) registered in app.gd with correct dependencies. Module initialization order validated. |

### Nice to Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|
| S2-09 | C1 advanced animation features | godot-specialist | 2 | S2-03 | Animation blending via AnimationTree, composition mode switching (INSIDE/LEANING_OUT) with tween transitions. |
| S2-10 | C2 offline return simulation | gameplay-programmer | 2 | S2-05 | If offline duration > threshold (4 hours), trigger return event with simulated away time on startup. |
| S2-11 | F4 auto-save and version migration | lead-programmer | 1 | S2-01 | Auto-save every 5 minutes. Basic version metadata tracking for future migration support. |

## Carryover from Previous Sprint
| Task | Reason | New Estimate |
|------|--------|-------------|
| None | All Sprint 1 tasks completed | |

## Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| F4 file I/O issues on Windows | Medium | High | Test early with Godot 4.6.1 file APIs. Use user:// directory for compatibility. Have fallback to in-memory storage. |
| C1 animation integration with F1 transparency | Medium | Medium | Test animation rendering in transparent window early. Verify alpha blending works correctly. |
| C2 timing logic complexity | High | Medium | Implement simplified version first (fixed intervals). Iterate toward random+probability model. |
| Module dependency circularity | Low | High | Validate dependency graph before implementation. Use optional_dependencies where appropriate. |
| Time estimation too optimistic | Medium | Medium | Prioritize Must Have tasks. Be ready to descope Should Have items. |

## Dependencies on External Factors
- Godot 4.6.1 engine working with file I/O
- Existing F1, F2, F3 modules stable
- No external API dependencies

## Definition of Done for this Sprint
- [ ] All Must Have tasks completed (S2-01 through S2-05)
- [ ] F4 save system working and integrated with F3
- [ ] C1 animation system visible in F1 window
- [ ] C2 outing-return cycle triggering basic departures
- [ ] No critical bugs in delivered features
- [ ] Integration tests passing for new systems
- [ ] Code reviewed and merged to main branch

## Sprint Success Metrics
- ✅ F4 Save System implemented and used by F3
- ✅ C1 Character Animation System visible in window
- ✅ C2 Outing-Return Cycle triggering departures
- ✅ Core gameplay loop established (F1→F2→F3→F4→C1→C2)
- ✅ Ready for Sprint 3 (Fe5, P1, Fe2 implementation)