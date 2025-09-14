//
//  DataManager.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation
import CoreGraphics
import CoreData

@MainActor
class DataManager {
    private let coreDataStack = CoreDataStack.shared
    private let viewContext: NSManagedObjectContext
    
    init() {
        self.viewContext = coreDataStack.viewContext
    }
    
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
        let fetchRequest = NSFetchRequest<StickyEntity>(entityName: "StickyEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let entities = try viewContext.fetch(fetchRequest)
        guard let entity = entities.first else {
            throw NSError(domain: "DataManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sticky not found"])
        }
        
        return entity.toSticky()
    }

    func getAllStickies() async throws -> [Sticky] {
        let fetchRequest = NSFetchRequest<StickyEntity>(entityName: "StickyEntity")
        let entities = try viewContext.fetch(fetchRequest)
        return entities.map { $0.toSticky() }
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

    func deleteSticky(id: UUID) async throws {
        let fetchRequest = NSFetchRequest<StickyEntity>(entityName: "StickyEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let entities = try viewContext.fetch(fetchRequest)
        for entity in entities {
            viewContext.delete(entity)
        }
        
        try viewContext.save()
    }

    private func saveSticky(_ sticky: Sticky) async throws {
        // Delete existing entity if it exists
        let fetchRequest = NSFetchRequest<StickyEntity>(entityName: "StickyEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", sticky.id as CVarArg)
        
        let existingEntities = try viewContext.fetch(fetchRequest)
        for entity in existingEntities {
            viewContext.delete(entity)
        }
        
        // Create new entity
        _ = StickyEntity.fromSticky(sticky, context: viewContext)
        
        try viewContext.save()
    }
}
