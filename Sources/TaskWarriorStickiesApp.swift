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
    private var syncTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start background sync timer
        startBackgroundSync()
        
        // Load existing stickies from CoreData
        Task {
            do {
                let stickies = try await dataManager.getAllStickies()
                if stickies.isEmpty {
                    // Create initial sticky if none exist
                    createNewSticky()
                } else {
                    // Restore existing stickies
                    for sticky in stickies {
                        createWindow(for: sticky)
                    }
                }
            } catch {
                print("Failed to load stickies: \(error)")
                // Create initial sticky as fallback
                createNewSticky()
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        syncTimer?.invalidate()
    }
    
    private func startBackgroundSync() {
        // Sync every 30 seconds (configurable)
        let interval = Configuration.default.syncInterval
        syncTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.performBackgroundSync()
            }
        }
    }
    
    private func performBackgroundSync() async {
        for window in windows {
            await window.refreshTasks()
        }
    }
    
    func createNewSticky() {
        Task {
            do {
                let sticky = try await dataManager.createSticky(title: "New Sticky")
                createWindow(for: sticky)
            } catch {
                print("Failed to create sticky: \(error)")
            }
        }
    }
    
    private func createWindow(for sticky: Sticky) {
        let window = StickyWindow(sticky: sticky, taskService: taskService, dataManager: dataManager)
        windows.append(window)
        window.makeKeyAndOrderFront(nil)
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
