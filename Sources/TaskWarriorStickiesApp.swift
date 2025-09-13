//
//  TaskWarriorStickiesApp.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import SwiftUI

@main
struct TaskWarriorStickiesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    var body: some View {
        Text("TaskWarrior Stickies")
            .font(.largeTitle)
            .padding()
    }
}
