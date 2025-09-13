//
//  PreferencesView.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject private var viewModel: PreferencesViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: PreferencesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Preferences")
                .font(.title)
                .padding(.top)
            
            Form {
                Section("Appearance") {
                    Slider(value: $viewModel.transparency, in: 0.1...1.0) {
                        Text("Transparency")
                    }
                    Text("Transparency: \(Int(viewModel.transparency * 100))%")
                        .font(.caption)
                    
                    Toggle("Always on Top", isOn: $viewModel.alwaysOnTop)
                }
                
                Section("Filter & Sort") {
                    TextField("Filter", text: Binding(
                        get: { viewModel.filter ?? "" },
                        set: { viewModel.filter = $0.isEmpty ? nil : $0 }
                    ))
                    
                    Picker("Sort By", selection: $viewModel.sortBy) {
                        Text("None").tag(String?.none)
                        Text("Title").tag("title" as String?)
                        Text("Project").tag("project" as String?)
                        Text("Age").tag("age" as String?)
                        Text("Priority").tag("priority" as String?)
                    }
                    
                    if viewModel.sortBy != nil {
                        Picker("Sort Order", selection: $viewModel.sortOrder) {
                            Text("Ascending").tag("ascending")
                            Text("Descending").tag("descending")
                        }
                    }
                }
                
                Section("Visible Columns") {
                    ForEach(["id", "title", "project", "age", "priority", "status"], id: \.self) { column in
                        Toggle(column.capitalized, isOn: Binding(
                            get: { viewModel.visibleColumns.contains(column) },
                            set: { isVisible in
                                if isVisible {
                                    viewModel.visibleColumns.append(column)
                                } else {
                                    viewModel.visibleColumns.removeAll { $0 == column }
                                }
                            }
                        ))
                    }
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    Task {
                        await viewModel.saveChanges()
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 400, height: 600)
    }
}

@MainActor
class PreferencesViewModel: ObservableObject {
    @Published var transparency: Double
    @Published var alwaysOnTop: Bool
    @Published var filter: String?
    @Published var sortBy: String?
    @Published var sortOrder: String
    @Published var visibleColumns: [String]
    
    private let sticky: Sticky
    private let dataManager: DataManager
    
    init(sticky: Sticky, dataManager: DataManager) {
        self.sticky = sticky
        self.dataManager = dataManager
        self.transparency = sticky.transparency
        self.alwaysOnTop = sticky.alwaysOnTop
        self.filter = sticky.filter
        self.sortBy = sticky.sortBy
        self.sortOrder = sticky.sortOrder ?? "ascending"
        self.visibleColumns = sticky.visibleColumns
    }
    
    func saveChanges() async {
        let settings = StickySettings(
            transparency: transparency,
            alwaysOnTop: alwaysOnTop,
            filter: filter?.isEmpty == false ? filter : nil,
            sortBy: sortBy,
            sortOrder: sortOrder,
            visibleColumns: visibleColumns
        )
        
        do {
            _ = try await dataManager.updateStickySettings(id: sticky.id, settings: settings)
        } catch {
            print("Failed to save preferences: \(error)")
        }
    }
}
