# Quickstart: TaskWarrior Stickies App

## Prerequisites
- macOS 12.0 or later
- Xcode 14.0 or later
- TaskWarrior installed (`brew install taskwarrior-tui` or from source)
- Swift 5.9

## Setup
1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd taskwarrior-stickies
   ```

2. Open in Xcode:
   ```bash
   open TaskWarriorStickies.xcodeproj
   ```

3. Build and run the app (⌘R)

## First Use
1. Launch the app
2. The app will check for TaskWarrior installation
3. If TaskWarrior is not found, follow the error message to install it
4. Create your first sticky: Click "New Sticky" in the menu
5. Configure the sticky:
   - Set a title
   - Choose visible columns (title, project, age, id)
   - Set filter (e.g., "+work" for work tasks)
   - Choose sort order
6. Tasks will load from TaskWarrior matching the filter
7. Edit task titles inline by clicking on them
8. Use the preferences popup (gear icon) to adjust settings

## Key Features Test
- **Always on top**: Toggle in sticky preferences
- **Transparency**: Adjust slider in preferences
- **Multiple stickies**: Create multiple windows
- **Filters**: Use TaskWarrior syntax (e.g., "project:home", "due.before:today")
- **Sorting**: Click column headers or set in preferences
- **Persistence**: Close and reopen - state is saved

## Troubleshooting
- If tasks don't load: Check TaskWarrior is installed and run `task --version`
- If windows don't stay on top: Ensure app has necessary permissions
- For performance issues: Limit to <20 stickies with <100 tasks each

## Development
- Run tests: ⌘U in Xcode
- Build for release: Product > Archive
- Debug TaskWarrior commands: Check console for logged commands
