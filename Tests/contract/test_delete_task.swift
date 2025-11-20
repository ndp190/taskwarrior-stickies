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
    var mockExecutor: MockTaskCommandExecutor!

    override func setUp() async throws {
        try await super.setUp()
        mockExecutor = MockTaskCommandExecutor()
        taskService = TaskService(executor: mockExecutor)
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
        mockExecutor = nil
        super.tearDown()
    }

    func testDeleteExistingTask() async throws {
        // Given
        let taskUuid = "12345678-1234-1234-1234-123456789abc"
        mockExecutor.mockOutputs = [""]

        // When
        try await taskService.deleteTask(uuid: taskUuid)

        // Then
        // Verify task is deleted by trying to get it
        mockExecutor.mockOutputs = ["[]"] // Return empty array for getTask
        do {
            _ = try await taskService.getTask(uuid: taskUuid)
            XCTFail("Expected task to be deleted")
        } catch {
            // Expected - task should not exist after deletion
            XCTAssertNotNil(error)
        }
    }

    func testDeleteNonExistentTask() async throws {
        // Given
        let nonExistentUuid = "12345678-1234-1234-1234-000000000000"
        mockExecutor.mockOutputs = [""]

        // When & Then
        do {
            try await taskService.deleteTask(uuid: nonExistentUuid)
            XCTFail("Expected error for deleting non-existent task")
        } catch {
            // Expected to fail - error handling will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testDeleteTaskValidation() async throws {
        // Given - invalid UUID should fail
        let invalidUuid = "invalid-uuid-format"
        mockExecutor.mockOutputs = [""]

        // When & Then
        do {
            try await taskService.deleteTask(uuid: invalidUuid)
            XCTFail("Expected validation error for invalid UUID")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testDeleteTaskWithEmptyId() async throws {
        // Given - empty UUID should fail
        let emptyUuid = ""
        mockExecutor.mockOutputs = [""]

        // When & Then
        do {
            try await taskService.deleteTask(uuid: emptyUuid)
            XCTFail("Expected validation error for empty UUID")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }
}
