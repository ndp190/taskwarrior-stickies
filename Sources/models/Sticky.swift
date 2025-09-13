//
//  Sticky.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation
import CoreGraphics

struct Sticky {
    let id: UUID
    var title: String
    var position: CGPoint
    var size: CGSize
    var transparency: Double
    var alwaysOnTop: Bool
    var filter: String?
    var sortBy: String?
    var sortOrder: String?
    var visibleColumns: [String]
}

struct StickySettings {
    var transparency: Double?
    var alwaysOnTop: Bool?
    var filter: String?
    var sortBy: String?
    var sortOrder: String?
    var visibleColumns: [String]?

    init(transparency: Double? = nil, alwaysOnTop: Bool? = nil, filter: String? = nil,
         sortBy: String? = nil, sortOrder: String? = nil, visibleColumns: [String]? = nil) {
        self.transparency = transparency
        self.alwaysOnTop = alwaysOnTop
        self.filter = filter
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.visibleColumns = visibleColumns
    }
}
