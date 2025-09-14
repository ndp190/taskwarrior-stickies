//
//  TaskService.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation

class TaskService: @unchecked Sendable {
    private let executor: TaskCommandExecutor

    init(executor: TaskCommandExecutor = RealTaskCommandExecutor()) {
        self.executor = executor
    }

    func getTasks(filter: String?, sort: String?) async throws -> [TWTask] {
        var arguments = ["export"]
        if let filter = filter {
            arguments.append(filter)
        }
        let output = try await executor.execute(arguments: arguments)
        return try parseTasks(from: output)
    }

    func getTask(uuid: String) async throws -> TWTask {
        let output = try await executor.execute(arguments: ["export", "uuid:\(uuid)"])
        let tasks = try parseTasks(from: output)
        guard let task = tasks.first else {
            throw NSError(domain: "TaskService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
        }
        return task
    }

    func createTask(_ input: TaskInput) async throws -> TWTask {
        var arguments = ["add", input.title]
        if let project = input.project {
            arguments.append("project:\(project)")
        }
        if let due = input.due {
            let formatter = ISO8601DateFormatter()
            arguments.append("due:\(formatter.string(from: due))")
        }
        if let priority = input.priority {
            arguments.append("priority:\(priority)")
        }
        for tag in input.tags ?? [] {
            arguments.append("+\(tag)")
        }
        
        _ = try await executor.execute(arguments: arguments)
        
        // Get the newly created task by finding the most recent one
        // This is a simplification; in practice, you might need to parse the output or use UUID
        let tasks = try await getTasks(filter: nil, sort: nil)
        return tasks.last!
    }

    func updateTask(uuid: String, update: TaskUpdate) async throws -> TWTask {
        var arguments = ["uuid:\(uuid)", "modify"]
        if let title = update.title {
            arguments.append(title)
        }
        if let project = update.project {
            arguments.append("project:\(project)")
        }
        if let status = update.status {
            arguments.append("status:\(status)")
        }
        if let priority = update.priority {
            arguments.append("priority:\(priority)")
        }
        if let comment = update.comment {
            arguments.append("annotate:\(comment)")
        }
        
        _ = try await executor.execute(arguments: arguments)
        return try await getTask(uuid: uuid)
    }

    func deleteTask(uuid: String) async throws {
        _ = try await executor.execute(arguments: ["uuid:\(uuid)", "delete", "--yes"])
    }

    private func parseTasks(from jsonString: String) throws -> [TWTask] {
        let data = jsonString.data(using: .utf8)!
        let jsonArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
        
        return jsonArray.compactMap { dict in
            // Extract uuid (primary identifier)
            guard let uuid = dict["uuid"] as? String else { return nil }
            
            // Safely extract required fields
            guard let title = dict["description"] as? String,
                  let status = dict["status"] as? String else {
                return nil
            }
            
            let project = dict["project"] as? String
            let tags = dict["tags"] as? [String] ?? []
            
            // Parse dates with better error handling
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            
            var age: Date? = nil
            if let entry = dict["entry"] as? String {
                age = dateFormatter.date(from: entry)
            }
            
            var due: Date? = nil
            if let dueStr = dict["due"] as? String {
                due = dateFormatter.date(from: dueStr)
            }
            
            let priority = dict["priority"] as? String
            
            return TWTask(uuid: uuid, title: title, project: project, age: age, due: due, 
                         priority: priority, status: status, tags: tags, comment: nil)
        }
    }
}
