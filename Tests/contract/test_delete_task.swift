//
//  test_delete_task.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class DeleteTaskContractTests: XCTestCase {
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

    func testDeleteExistingTask() async throws {
        // Given
        let taskId = "test-uuid-delete"

        // When
        try await taskService.deleteTask(id: taskId)

        // Then
        // Verify task is deleted by trying to get it
        do {
            _ = try await taskService.getTask(id: taskId)
            XCTFail("Expected task to be deleted")
        } catch {
            // Expected - task should not exist after deletion
            XCTAssertNotNil(error)
        }
    }

    func testDeleteNonExistentTask() async throws {
        // Given
        let nonExistentId = "non-existent-uuid"

        // When & Then
        do {
            try await taskService.deleteTask(id: nonExistentId)
            XCTFail("Expected error for deleting non-existent task")
        } catch {
            // Expected to fail - error handling will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testDeleteTaskValidation() async throws {
        // Given - invalid UUID should fail
        let invalidId = "invalid-uuid-format"

        // When & Then
        do {
            try await taskService.deleteTask(id: invalidId)
            XCTFail("Expected validation error for invalid UUID")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testDeleteTaskWithEmptyId() async throws {
        // Given - empty ID should fail
        let emptyId = ""

        // When & Then
        do {
            try await taskService.deleteTask(id: emptyId)
            XCTFail("Expected validation error for empty ID")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }
}
