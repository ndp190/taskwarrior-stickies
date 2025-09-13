//
//  DataManager.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation
import CoreGraphics

@MainActor
class DataManager {
    private let userDefaults = UserDefaults.standard
    private let stickiesKey = "stickies"
    
    func createSticky(title: String, settings: StickySettings? = nil) async throws -> Sticky {
        let id = UUID()
        let sticky = Sticky(
            id: id,
            title: title,
            position: CGPoint(x: 100, y: 100),
            size: CGSize(width: 300, height: 400),
            transparency: settings?.transparency ?? 0.5,
            alwaysOnTop: settings?.alwaysOnTop ?? true,
            filter: settings?.filter,
            sortBy: settings?.sortBy,
            sortOrder: settings?.sortOrder,
            visibleColumns: settings?.visibleColumns ?? ["title", "project", "age", "id"]
        )
        
        try await saveSticky(sticky)
        return sticky
    }

    func getSticky(id: UUID) async throws -> Sticky {
        let stickies = try await loadStickies()
        guard let sticky = stickies.first(where: { $0.id == id }) else {
            throw NSError(domain: "DataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sticky not found"])
        }
        return sticky
    }

    func updateStickyTransparency(id: UUID, transparency: Double) async throws -> Sticky {
        var sticky = try await getSticky(id: id)
        sticky.transparency = transparency
        try await saveSticky(sticky)
        return sticky
    }

    func updateStickyAlwaysOnTop(id: UUID, alwaysOnTop: Bool) async throws -> Sticky {
        var sticky = try await getSticky(id: id)
        sticky.alwaysOnTop = alwaysOnTop
        try await saveSticky(sticky)
        return sticky
    }

    func updateStickyWindowFrame(id: UUID, position: CGPoint, size: CGSize) async throws -> Sticky {
        var sticky = try await getSticky(id: id)
        sticky.position = position
        sticky.size = size
        try await saveSticky(sticky)
        return sticky
    }

    func updateStickySettings(id: UUID, settings: StickySettings) async throws -> Sticky {
        var sticky = try await getSticky(id: id)
        if let transparency = settings.transparency {
            sticky.transparency = transparency
        }
        if let alwaysOnTop = settings.alwaysOnTop {
            sticky.alwaysOnTop = alwaysOnTop
        }
        sticky.filter = settings.filter
        sticky.sortBy = settings.sortBy
        sticky.sortOrder = settings.sortOrder
        if let visibleColumns = settings.visibleColumns {
            sticky.visibleColumns = visibleColumns
        }
        try await saveSticky(sticky)
        return sticky
    }

    private func loadStickies() async throws -> [Sticky] {
        guard let data = userDefaults.data(forKey: stickiesKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([Sticky].self, from: data)
    }

    private func saveSticky(_ sticky: Sticky) async throws {
        var stickies = try await loadStickies()
        
        if let index = stickies.firstIndex(where: { $0.id == sticky.id }) {
            stickies[index] = sticky
        } else {
            stickies.append(sticky)
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(stickies)
        userDefaults.set(data, forKey: stickiesKey)
    }
}
