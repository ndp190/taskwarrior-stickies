//
//  test_put_task.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class PutTaskContractTests: XCTestCase {
    var taskService: TaskService!

    override func setUp() async throws {
        try await super.setUp()
        // TaskService will be implemented later - this test will fail
        taskService = TaskService()
        
        // Skip all tests if TaskWarrior is not available
        if !isTaskWarriorAvailable() {
            throw XCTSkip("TaskWarrior is not available in test environment")
        }
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
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    override func tearDown() {
        taskService = nil
        super.tearDown()
    }

    func testUpdateTaskTitle() async throws {
        // Given
        let taskId = "test-uuid-123"
        let update = TaskUpdate(title: "Updated Task Title")

        // When
        let updatedTask = try await taskService.updateTask(id: taskId, update: update)

        // Then
        XCTAssertNotNil(updatedTask)
        XCTAssertEqual(updatedTask.id, taskId)
        XCTAssertEqual(updatedTask.title, "Updated Task Title")
    }

    func testUpdateTaskStatus() async throws {
        // Given
        let taskId = "test-uuid-456"
        let update = TaskUpdate(status: "completed")

        // When
        let updatedTask = try await taskService.updateTask(id: taskId, update: update)

        // Then
        XCTAssertNotNil(updatedTask)
        XCTAssertEqual(updatedTask.id, taskId)
        XCTAssertEqual(updatedTask.status, "completed")
    }

    func testUpdateTaskMultipleFields() async throws {
        // Given
        let taskId = "test-uuid-789"
        let update = TaskUpdate(
            title: "Updated Title",
            project: "new-project",
            status: "completed",
            priority: "H",
            comment: "Updated via API"
        )

        // When
        let updatedTask = try await taskService.updateTask(id: taskId, update: update)

        // Then
        XCTAssertNotNil(updatedTask)
        XCTAssertEqual(updatedTask.id, taskId)
        XCTAssertEqual(updatedTask.title, "Updated Title")
        XCTAssertEqual(updatedTask.project, "new-project")
        XCTAssertEqual(updatedTask.status, "completed")
        XCTAssertEqual(updatedTask.priority, "H")
        XCTAssertEqual(updatedTask.comment, "Updated via API")
    }

    func testUpdateTaskValidation() async throws {
        // Given - invalid status should fail
        let taskId = "test-uuid-invalid"
        let invalidUpdate = TaskUpdate(status: "invalid-status")

        // When & Then
        do {
            _ = try await taskService.updateTask(id: taskId, update: invalidUpdate)
            XCTFail("Expected validation error for invalid status")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testUpdateNonExistentTask() async throws {
        // Given
        let nonExistentId = "non-existent-uuid"
        let update = TaskUpdate(title: "Should not work")

        // When & Then
        do {
            _ = try await taskService.updateTask(id: nonExistentId, update: update)
            XCTFail("Expected error for non-existent task")
        } catch {
            // Expected to fail - error handling will be implemented
            XCTAssertNotNil(error)
        }
    }
}
