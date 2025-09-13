# Research: Create a Mac App with TaskWarrior Interface

## Research Tasks Completed

### 1. TaskWarrior Integration
**Decision**: Use TaskWarrior CLI via Swift's Process class for command execution and JSON output parsing.  
**Rationale**: TaskWarrior provides a stable CLI interface with JSON export capabilities, allowing seamless integration without requiring a custom API. Swift's Process enables secure execution of shell commands.  
**Alternatives Considered**: Direct library integration (not available), REST API wrapper (overkill for local app).

### 2. SwiftUI Window Management
**Decision**: Use NSWindow with SwiftUI hosting for always-on-top and transparency features.  
**Rationale**: SwiftUI alone doesn't fully support window-level features like always-on-top; NSWindow provides the necessary APIs while hosting SwiftUI content.  
**Alternatives Considered**: Pure SwiftUI (insufficient for window controls), AppKit only (more complex than hybrid approach).

### 3. State Persistence
**Decision**: UserDefaults for simple configurations (filters, sorting), CoreData for complex state (window positions, sticky contents).  
**Rationale**: UserDefaults is lightweight for preferences; CoreData handles relationships and persistence of multiple entities.  
**Alternatives Considered**: File-based JSON (manual serialization), SQLite directly (more boilerplate than CoreData).

### 4. Configurable Table Views
**Decision**: SwiftUI List with dynamic columns using LazyVGrid or custom layout.  
**Rationale**: SwiftUI's flexible layout system allows runtime column configuration; List provides built-in editing and selection.  
**Alternatives Considered**: NSTableView (AppKit, less SwiftUI-native), custom collection view (more complex).

### 5. Synchronization Frequency
**Decision**: On-demand synchronization with manual refresh button, plus background sync every 30 seconds when app is active.  
**Rationale**: Balances real-time updates with performance; user can force refresh for immediate changes.  
**Alternatives Considered**: Real-time polling (resource intensive), file watching (unreliable for TaskWarrior).

### 6. Error Handling
**Decision**: Display user-friendly error messages in sticky windows, log detailed errors to console.  
**Rationale**: Keeps UI clean while providing debugging info; handles TaskWarrior command failures gracefully.  
**Alternatives Considered**: Modal error dialogs (disruptive), silent failures (poor UX).

### 7. Maximum Stickies
**Decision**: No hard limit, but warn at 20+ stickies for performance.  
**Rationale**: Allows flexibility while preventing resource exhaustion; users can manage based on hardware.  
**Alternatives Considered**: Hard limit of 10 (too restrictive), unlimited (risk of performance issues).

## Resolved NEEDS CLARIFICATION
- Synchronization frequency: On-demand + 30s background
- Error handling: User-friendly messages + console logging
- Maximum stickies: Soft limit with warnings
- Language: Swift 5.9 with SwiftUI
- Dependencies: TaskWarrior CLI, SwiftUI framework
- Storage: UserDefaults + CoreData
- Testing: XCTest
- Performance: <100ms for queries, smooth UI
- Constraints: Met via NSWindow + SwiftUI
- Scale: 20 stickies, 100 tasks each
