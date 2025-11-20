//
//  StickyEntity+CoreDataClass.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation
import CoreData
import CoreGraphics

@objc(StickyEntity)
public class StickyEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var positionX: Double
    @NSManaged public var positionY: Double
    @NSManaged public var width: Double
    @NSManaged public var height: Double
    @NSManaged public var transparency: Double
    @NSManaged public var alwaysOnTop: Bool
    @NSManaged public var filter: String?
    @NSManaged public var sortBy: String?
    @NSManaged public var sortOrder: String?
    @NSManaged public var visibleColumns: [String]
}

extension StickyEntity {
    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set {
            positionX = Double(newValue.x)
            positionY = Double(newValue.y)
        }
    }
    
    var size: CGSize {
        get { CGSize(width: width, height: height) }
        set {
            width = Double(newValue.width)
            height = Double(newValue.height)
        }
    }
    
    func toSticky() -> Sticky {
        return Sticky(
            id: id,
            title: title,
            position: position,
            size: size,
            transparency: transparency,
            alwaysOnTop: alwaysOnTop,
            filter: filter,
            sortBy: sortBy,
            sortOrder: sortOrder,
            visibleColumns: visibleColumns
        )
    }
    
    static func fromSticky(_ sticky: Sticky, context: NSManagedObjectContext) -> StickyEntity {
        let entity = StickyEntity(context: context)
        entity.id = sticky.id
        entity.title = sticky.title
        entity.position = sticky.position
        entity.size = sticky.size
        entity.transparency = sticky.transparency
        entity.alwaysOnTop = sticky.alwaysOnTop
        entity.filter = sticky.filter
        entity.sortBy = sticky.sortBy
        entity.sortOrder = sticky.sortOrder
        entity.visibleColumns = sticky.visibleColumns
        return entity
    }
}
