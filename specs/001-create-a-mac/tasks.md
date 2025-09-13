# Tasks: Create a Mac App with TaskWarrior Interface

**Input**: Design documents from `/specs/001-create-a-mac/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Single project**: `src/`, `tests/` at repository root
- Paths assume single Mac app project structure

## Phase 3.1: Setup
- [ ] T001 Create Xcode project structure per implementation plan
- [ ] T002 Initialize Swift project with SwiftUI dependencies
- [ ] T003 [P] Configure SwiftLint for code formatting

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T004 [P] Contract test GET /tasks in tests/contract/test_get_tasks.swift
- [ ] T005 [P] Contract test POST /tasks in tests/contract/test_post_task.swift
- [ ] T006 [P] Contract test PUT /tasks/{id} in tests/contract/test_put_task.swift
- [ ] T007 [P] Contract test DELETE /tasks/{id} in tests/contract/test_delete_task.swift
- [ ] T008 [P] Integration test create sticky and load tasks in tests/integration/test_create_sticky.swift
- [ ] T009 [P] Integration test edit task title in tests/integration/test_edit_task.swift
- [ ] T010 [P] Integration test set transparency and always-on-top in tests/integration/test_window_settings.swift
- [ ] T011 [P] Integration test filter and sort tasks in tests/integration/test_filter_sort.swift

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T012 [P] Task model in src/models/Task.swift
- [ ] T013 [P] Sticky model in src/models/Sticky.swift
- [ ] T014 [P] Configuration model in src/models/Configuration.swift
- [ ] T015 TaskService for TaskWarrior integration in src/services/TaskService.swift
- [ ] T016 DataManager for persistence in src/services/DataManager.swift
- [ ] T017 StickyView UI component in src/views/StickyView.swift
- [ ] T018 PreferencesView UI component in src/views/PreferencesView.swift
- [ ] T019 StickyWindow NSWindow hosting in src/views/StickyWindow.swift
- [ ] T020 Implement GET /tasks endpoint in src/services/TaskService.swift
- [ ] T021 Implement POST /tasks endpoint in src/services/TaskService.swift
- [ ] T022 Implement PUT /tasks/{id} endpoint in src/services/TaskService.swift
- [ ] T023 Implement DELETE /tasks/{id} endpoint in src/services/TaskService.swift

## Phase 3.4: Integration
- [ ] T024 Connect TaskService to TaskWarrior CLI
- [ ] T025 Integrate DataManager with CoreData
- [ ] T026 Add window state persistence
- [ ] T027 Implement background task sync

## Phase 3.5: Polish
- [ ] T028 [P] Unit tests for models in tests/unit/test_models.swift
- [ ] T029 [P] Unit tests for services in tests/unit/test_services.swift
- [ ] T030 Performance tests (<100ms queries)
- [ ] T031 [P] Update README.md with usage
- [ ] T032 Run quickstart validation

## Dependencies
- Tests (T004-T011) before implementation (T012-T023)
- Models (T012-T014) before services (T015-T016)
- Services (T015-T016) before UI (T017-T019)
- Services before endpoints (T020-T023)
- Core (T012-T023) before integration (T024-T027)
- Implementation before polish (T028-T032)

## Parallel Example
```
# Launch T004-T007 together:
Task: "Contract test GET /tasks in tests/contract/test_get_tasks.swift"
Task: "Contract test POST /tasks in tests/contract/test_post_task.swift"
Task: "Contract test PUT /tasks/{id} in tests/contract/test_put_task.swift"
Task: "Contract test DELETE /tasks/{id} in tests/contract/test_delete_task.swift"

# Launch T008-T011 together:
Task: "Integration test create sticky and load tasks in tests/integration/test_create_sticky.swift"
Task: "Integration test edit task title in tests/integration/test_edit_task.swift"
Task: "Integration test set transparency and always-on-top in tests/integration/test_window_settings.swift"
Task: "Integration test filter and sort tasks in tests/integration/test_filter_sort.swift"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
   
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   
3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [x] All contracts have corresponding tests
- [x] All entities have model tasks
- [x] All tests come before implementation
- [x] Parallel tasks truly independent
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
