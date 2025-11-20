//
//  TaskCommandExecutor.swift
//  TaskWarriorStickies
//
//  Created by GitHub Copilot on 2025-01-13.
//

import Foundation

protocol TaskCommandExecutor: Sendable {
    func execute(arguments: [String]) async throws -> String
}


class RealTaskCommandExecutor: TaskCommandExecutor, @unchecked Sendable {
    private let taskDataPath: String?
    actor OutputCollector {
        private var data = Data()
        
        func append(_ newData: Data) {
            data.append(newData)
        }
        
        func string() -> String {
            String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    init(taskDataPath: String? = nil) {
        self.taskDataPath = taskDataPath
    }
    
    func execute(arguments: [String]) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let pipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/task")
            process.arguments = arguments
            process.standardOutput = pipe
            process.standardError = pipe

            if let taskDataPath = self.taskDataPath {
                var env = ProcessInfo.processInfo.environment
                env["TASKDATA"] = taskDataPath
                process.environment = env
            }

            print("Executing: task \(arguments.joined(separator: " "))")

            // ✅ Use Actor instead of captured mutable var
            let collector = OutputCollector()

            let handle = pipe.fileHandleForReading
            handle.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if !data.isEmpty {
                    Task { await collector.append(data) }
                }
            }
            
            process.terminationHandler = { proc in
                handle.readabilityHandler = nil
                
                Task {
                    let outputStr = await collector.string()
                    
                    if proc.terminationStatus == 0 {
                        continuation.resume(returning: outputStr)
                    } else {
                        let error = NSError(
                            domain: "TaskService",
                            code: Int(proc.terminationStatus),
                            userInfo: [NSLocalizedDescriptionKey: outputStr]
                        )
                        continuation.resume(throwing: error)
                    }
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

class MockTaskCommandExecutor: TaskCommandExecutor, @unchecked Sendable {
    var executedCommands: [[String]] = []
    var mockOutputs: [String] = []
    var mockErrors: [Error?] = []
    
    func execute(arguments: [String]) async throws -> String {
        executedCommands.append(arguments)
        
        if mockErrors.count > executedCommands.count - 1 {
            if let error = mockErrors[executedCommands.count - 1] {
                throw error
            }
        }
        
        if mockOutputs.count > executedCommands.count - 1 {
            return mockOutputs[executedCommands.count - 1]
        }
        
        // Default mock output for export commands
        if arguments.first == "export" {
            return """
            [
                {
                    "id": 1,
                    "description": "Mock Task",
                    "status": "pending",
                    "entry": "20250113T000000Z",
                    "project": "test",
                    "priority": "M"
                }
            ]
            """
        }
        
        return ""
    }
    
    func reset() {
        executedCommands = []
        mockOutputs = []
        mockErrors = []
    }
}
