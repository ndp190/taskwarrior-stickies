//
//  StickyView.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import SwiftUI

struct StickyView: View {
    @StateObject private var viewModel: StickyViewModel
    @State private var showingPreferences = false
    private let dataManager: DataManager
    
    init(viewModel: StickyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.dataManager = viewModel.dataManager
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                TextField("Sticky Title", text: $viewModel.sticky.title)
                    .font(.headline)
                    .textFieldStyle(.plain)
                
                Spacer()
                
                Button(action: { showingPreferences = true }) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Tasks table
            Table(viewModel.filteredTasks, selection: $viewModel.selectedTaskIds) {
                if viewModel.sticky.visibleColumns.contains("uuid") {
                    TableColumn("ID", value: \.uuid)
                        .width(min: 50, ideal: 60)
                }
                
                TableColumn("Title") { task in
                    TextField("", text: Binding(
                        get: { task.title },
                        set: { newTitle in
                            Task {
                                await viewModel.updateTaskTitle(task.uuid, newTitle: newTitle)
                            }
                        }
                    ))
                }
                .width(min: 100, ideal: 200)
                
                if viewModel.sticky.visibleColumns.contains("project") {
                    TableColumn("Project") { task in
                        Text(task.project ?? "")
                    }
                    .width(min: 80, ideal: 100)
                }
                
                if viewModel.sticky.visibleColumns.contains("age") {
                    TableColumn("Age") { task in
                        if let age = task.age {
                            Text(age, style: .relative)
                        } else {
                            Text("")
                        }
                    }
                    .width(min: 80, ideal: 100)
                }
                
                if viewModel.sticky.visibleColumns.contains("priority") {
                    TableColumn("Priority") { task in
                        Text(task.priority ?? "")
                    }
                    .width(min: 60, ideal: 80)
                }
                
                if viewModel.sticky.visibleColumns.contains("status") {
                    TableColumn("Status") { task in
                        Text(task.status)
                    }
                    .width(min: 60, ideal: 80)
                }
            }
            .tableStyle(.bordered)
        }
        .sheet(isPresented: $showingPreferences) {
            PreferencesView(viewModel: PreferencesViewModel(sticky: viewModel.sticky, dataManager: dataManager))
        }
        .task {
            await viewModel.loadTasks()
        }
    }
}

@MainActor
class StickyViewModel: ObservableObject {
    @Published var sticky: Sticky
    @Published var tasks: [TWTask] = []
    @Published var selectedTaskIds: Set<String> = []
    
    let taskService: TaskService
    let dataManager: DataManager
    
    var filteredTasks: [TWTask] {
        var filtered = tasks
        
        if let filter = sticky.filter, !filter.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(filter) ||
                (task.project?.localizedCaseInsensitiveContains(filter) ?? false) ||
                task.tags.contains(where: { $0.localizedCaseInsensitiveContains(filter) })
            }
        }
        
        if let sortBy = sticky.sortBy {
            filtered.sort { lhs, rhs in
                let ascending = sticky.sortOrder != "descending"
                
                switch sortBy {
                case "title":
                    return ascending ? lhs.title < rhs.title : lhs.title > rhs.title
                case "project":
                    let lhsProject = lhs.project ?? ""
                    let rhsProject = rhs.project ?? ""
                    return ascending ? lhsProject < rhsProject : lhsProject > rhsProject
                case "age":
                    let lhsAge = lhs.age ?? Date.distantPast
                    let rhsAge = rhs.age ?? Date.distantPast
                    return ascending ? lhsAge < rhsAge : lhsAge > rhsAge
                case "priority":
                    let lhsPriority = lhs.priority ?? ""
                    let rhsPriority = rhs.priority ?? ""
                    return ascending ? lhsPriority < rhsPriority : lhsPriority > rhsPriority
                default:
                    return false
                }
            }
        }
        
        return filtered
    }
    
    init(sticky: Sticky, taskService: TaskService, dataManager: DataManager) {
        self.sticky = sticky
        self.taskService = taskService
        self.dataManager = dataManager
    }
    
    func loadTasks() async {
        do {
            tasks = try await taskService.getTasks(filter: nil, sort: nil)
        } catch {
            print("Failed to load tasks: \(error)")
        }
    }
    
    func refreshTasks() async {
        await loadTasks()
    }
    
    func updateTaskTitle(_ taskUuid: String, newTitle: String) async {
        do {
            _ = try await taskService.updateTask(uuid: taskUuid, update: TaskUpdate(title: newTitle))
            await loadTasks() // Reload to reflect changes
        } catch {
            print("Failed to update task: \(error)")
        }
    }
}
