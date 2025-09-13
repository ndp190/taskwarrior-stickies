//
//  TaskWarriorStickiesApp.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import SwiftUI

@main
struct TaskWarriorStickiesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var windows: [StickyWindow] = []
    let taskService = TaskService()
    let dataManager = DataManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create initial sticky
        createNewSticky()
    }
    
    func createNewSticky() {
        DispatchQueue.main.async {
            Task {
                do {
                    let sticky = try await self.dataManager.createSticky(title: "New Sticky")
                    let window = StickyWindow(sticky: sticky, taskService: self.taskService, dataManager: self.dataManager)
                    self.windows.append(window)
                    window.makeKeyAndOrderFront(nil)
                } catch {
                    print("Failed to create sticky: \(error)")
                }
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 20) {
            Text("TaskWarrior Stickies")
                .font(.largeTitle)
                .padding()
            
            Button("Create New Sticky") {
                // This would need to be handled by the app delegate
                // For now, just show a placeholder
                print("Create new sticky")
            }
            .buttonStyle(.borderedProminent)
            
            Text("Use the menu bar to create new stickies")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 300, height: 200)
    }
}
