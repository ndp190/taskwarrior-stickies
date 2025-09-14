//
//  test_edit_task.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class EditTaskIntegrationTests: XCTestCase {
    var taskService: TaskService!
    var dataManager: DataManager!
    var mockExecutor: MockTaskCommandExecutor!
    var testTaskDataPath: String!

    override func setUp() async throws {
        try await super.setUp()
        
        // Create a temporary directory for test TaskWarrior data
        let tempDir = NSTemporaryDirectory()
        testTaskDataPath = tempDir + "taskwarrior_test_data_\(UUID().uuidString)"
        try FileManager.default.createDirectory(atPath: testTaskDataPath, withIntermediateDirectories: true)
        
        let realExecutor = RealTaskCommandExecutor(taskDataPath: testTaskDataPath)
        taskService = TaskService(executor: realExecutor)
        dataManager = await DataManager()
        
        // Skip all tests if TaskWarrior is not available
        if !isTaskWarriorAvailable() {
            throw XCTSkip("TaskWarrior is not available in test environment")
        }
    }

    override func tearDown() {
        taskService = nil
        dataManager = nil
        if let testTaskDataPath = testTaskDataPath {
            try? FileManager.default.removeItem(atPath: testTaskDataPath)
        }
        testTaskDataPath = nil
        super.tearDown()
    }

    func testEditTaskTitle() async throws {
        // Given
        let originalTitle = "Original Task"
        let newTitle = "Updated Task Title"

        // Create a task first
        let taskInput = TaskInput(title: originalTitle)
        let createdTask = try await taskService.createTask(taskInput)

        // When
        let update = TaskUpdate(title: newTitle)
        let updatedTask = try await taskService.updateTask(id: createdTask.id, update: update)

        // Then
        XCTAssertEqual(updatedTask.title, newTitle)
        XCTAssertEqual(updatedTask.id, createdTask.id)
    }

    func testEditTaskInStickyView() async throws {
        // Given
        _ = try await dataManager.createSticky(title: "Test Sticky")
        let taskInput = TaskInput(title: "Task to Edit")
        let createdTask = try await taskService.createTask(taskInput)

        // When - simulate editing in UI
        let newTitle = "Edited in Sticky View"
        let update = TaskUpdate(title: newTitle)
        let updatedTask = try await taskService.updateTask(id: createdTask.id, update: update)

        // Then
        XCTAssertEqual(updatedTask.title, newTitle)

        // Verify the change is reflected when loading tasks for the sticky
        let tasks = try await taskService.getTasks(filter: nil, sort: nil)
        let foundTask = tasks.first { $0.id == createdTask.id }
        XCTAssertNotNil(foundTask)
        XCTAssertEqual(foundTask?.title, newTitle)
    }

    func testEditMultipleTaskFields() async throws {
        // Given
        let taskInput = TaskInput(title: "Multi-field Task")
        let createdTask = try await taskService.createTask(taskInput)

        // When
        let update = TaskUpdate(
            title: "Updated Multi-field Task",
            project: "new-project",
            status: "completed",
            priority: "H"
        )
        let updatedTask = try await taskService.updateTask(id: createdTask.id, update: update)

        // Then
        XCTAssertEqual(updatedTask.title, "Updated Multi-field Task")
        XCTAssertEqual(updatedTask.project, "new-project")
        XCTAssertEqual(updatedTask.status, "completed")
        XCTAssertEqual(updatedTask.priority, "H")
    }

    func testEditTaskValidation() async throws {
        // Given
        let taskInput = TaskInput(title: "Task to Validate")
        let createdTask = try await taskService.createTask(taskInput)

        // When - try to set empty title
        let invalidUpdate = TaskUpdate(title: "")

        // Then
        do {
            _ = try await taskService.updateTask(id: createdTask.id, update: invalidUpdate)
            XCTFail("Expected validation error for empty title")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testEditNonExistentTask() async throws {
        // Given
        let nonExistentId = "non-existent-task-id"
        let update = TaskUpdate(title: "Should not work")

        // When & Then
        do {
            _ = try await taskService.updateTask(id: nonExistentId, update: update)
            XCTFail("Expected error for editing non-existent task")
        } catch {
            // Expected to fail - error handling will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testConcurrentTaskEdits() async throws {
        // Given
        let taskInput = TaskInput(title: "Concurrent Edit Task")
        let createdTask = try await taskService.createTask(taskInput)

        // When - simulate concurrent edits (simplified version)
        let update1 = TaskUpdate(title: "Edit 1")
        
        // Perform edits sequentially for now (concurrency testing can be more complex)
        let result1 = try await taskService.updateTask(id: createdTask.id, update: update1)
        
        // Then
        XCTAssertEqual(result1.title, "Edit 1")
        
        // Verify the task was updated
        let tasks = try await taskService.getTasks(filter: nil, sort: nil)
        let foundTask = tasks.first { $0.id == createdTask.id }
        XCTAssertNotNil(foundTask)
        XCTAssertEqual(foundTask?.title, "Edit 1")
    }
    
    private func isTaskWarriorAvailable() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/task")
        process.arguments = ["--version"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            
            // Wait for the process to complete with a timeout
            let timeoutSeconds = 5.0
            let startTime = Date()
            
            while process.isRunning {
                if Date().timeIntervalSince(startTime) > timeoutSeconds {
                    process.terminate()
                    return false
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
