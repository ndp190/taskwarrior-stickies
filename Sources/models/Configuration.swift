//
//  Configuration.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation

struct Configuration {
    var defaultTransparency: Double
    var defaultAlwaysOnTop: Bool
    var maxStickiesWarning: Int
    var syncInterval: TimeInterval
    var theme: String

    static let `default` = Configuration(
        defaultTransparency: 0.5,
        defaultAlwaysOnTop: true,
        maxStickiesWarning: 20,
        syncInterval: 30.0,
        theme: "system"
    )
}
