# Data Model: Create a Mac App with TaskWarrior Interface

## Entities

### Task
Represents a TaskWarrior task displayed in stickies.

**Fields**:
- id: String (TaskWarrior UUID)
- title: String (editable)
- project: String (optional)
- age: Date (creation date)
- due: Date (optional)
- priority: String (H/M/L/none)
- status: String (pending/completed)
- tags: [String]
- comment: String (optional, for view/edit)

**Relationships**:
- Belongs to Sticky (many-to-one)

**Validation Rules**:
- id must be valid UUID
- title cannot be empty
- status must be one of: pending, completed
- priority must be one of: H, M, L, or empty

**State Transitions**:
- pending → completed (via TaskWarrior update)
- completed → pending (via TaskWarrior update)

### Sticky
Represents a sticky note window containing multiple tasks.

**Fields**:
- id: UUID (internal)
- title: String (editable)
- position: CGPoint (window position)
- size: CGSize (window size)
- transparency: Double (0.0-1.0)
- alwaysOnTop: Bool
- filter: String (TaskWarrior filter query)
- sortBy: String (field to sort by)
- sortOrder: String (asc/desc)
- visibleColumns: [String] (e.g., ["title", "project", "age"])

**Relationships**:
- Has many Tasks (one-to-many)

**Validation Rules**:
- title cannot be empty
- transparency between 0.0 and 1.0
- sortBy must be valid Task field
- sortOrder must be "asc" or "desc"
- visibleColumns must contain at least "title"

### Configuration
Global app configuration (stored in UserDefaults).

**Fields**:
- defaultTransparency: Double (0.5)
- defaultAlwaysOnTop: Bool (true)
- maxStickiesWarning: Int (20)
- syncInterval: TimeInterval (30.0)
- theme: String (light/dark/system)

**Validation Rules**:
- defaultTransparency between 0.0 and 1.0
- maxStickiesWarning > 0
- syncInterval > 0

## Relationships Diagram
```
Configuration (1) ──── Sticky (1..n)
                      │
                      └── Task (1..n)
```

## Data Flow
1. App loads Configuration on startup
2. User creates/edits Sticky with preferences
3. Sticky applies filter/sort to fetch Tasks from TaskWarrior
4. Tasks displayed in table with visible columns
5. Changes saved to TaskWarrior and local state
6. Window state persisted on close
