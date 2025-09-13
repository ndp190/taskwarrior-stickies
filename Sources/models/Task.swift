//
//  Task.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation

struct Task {
    let id: String
    var title: String
    var project: String?
    var age: Date?
    var due: Date?
    var priority: String?
    var status: String
    var tags: [String]
    var comment: String?
}

struct TaskInput {
    let title: String
    var project: String?
    var due: Date?
    var priority: String?
    var tags: [String]?

    init(title: String, project: String? = nil, due: Date? = nil, priority: String? = nil, tags: [String]? = nil) {
        self.title = title
        self.project = project
        self.due = due
        self.priority = priority
        self.tags = tags ?? []
    }
}

struct TaskUpdate {
    var title: String?
    var project: String?
    var status: String?
    var priority: String?
    var comment: String?

    init(title: String? = nil, project: String? = nil, status: String? = nil, priority: String? = nil, comment: String? = nil) {
        self.title = title
        self.project = project
        self.status = status
        self.priority = priority
        self.comment = comment
    }
}
