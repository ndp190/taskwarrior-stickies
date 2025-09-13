# GitHub Copilot Instructions: TaskWarrior Stickies App

## Project Overview
Mac application providing a sticky notes interface for TaskWarrior task management. Features always-on-top windows, transparency, multiple stickies with configurable columns, filters, and sorting.

## Technical Stack
- **Language**: Swift 5.9
- **UI Framework**: SwiftUI with NSWindow hosting
- **Persistence**: UserDefaults + CoreData
- **Integration**: TaskWarrior CLI via Process
- **Testing**: XCTest

## Key Components
- **StickyWindow**: NSWindow hosting SwiftUI content
- **TaskService**: Handles TaskWarrior CLI execution
- **StickyView**: Table view with editable rows
- **PreferencesView**: Popup for filter/sort configuration
- **DataManager**: CoreData for state persistence

## Coding Standards
- Use SwiftUI for UI, AppKit for window management
- Async/await for TaskWarrior operations
- ObservableObject for state management
- Error handling with do-catch and user alerts
- Unit tests for services, integration tests for UI

## Recent Changes
- Added support for multiple tasks per sticky
- Implemented configurable columns (title, project, age, id)
- Added filter and sorting preferences
- Integrated state persistence for window positions

## Common Patterns
- TaskWarrior commands: `task export` for JSON, `task add/modify` for changes
- Window management: `NSWindow.level = .floating` for always-on-top
- Data binding: `@StateObject` for view models
- Persistence: `NSUserDefaults` for simple prefs, CoreData for complex state
