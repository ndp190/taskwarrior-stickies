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

    func testUpdateTaskTitle() async throws {
        // Given
        let taskUuid = "12345678-1234-1234-1234-123456789abc"
        let update = TaskUpdate(title: "Updated Task Title")
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789abc",
                "description": "Updated Task Title",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", mockResponse] // First for modify, second for getTask

        // When
        let updatedTask = try await taskService.updateTask(uuid: taskUuid, update: update)

        // Then
        XCTAssertNotNil(updatedTask)
        XCTAssertEqual(updatedTask.uuid, taskUuid)
        XCTAssertEqual(updatedTask.title, "Updated Task Title")
    }

    func testUpdateTaskStatus() async throws {
        // Given
        let taskUuid = "12345678-1234-1234-1234-123456789def"
        let update = TaskUpdate(status: "completed")
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789def",
                "description": "Test Task",
                "status": "completed",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", mockResponse]

        // When
        let updatedTask = try await taskService.updateTask(uuid: taskUuid, update: update)

        // Then
        XCTAssertNotNil(updatedTask)
        XCTAssertEqual(updatedTask.uuid, taskUuid)
        XCTAssertEqual(updatedTask.status, "completed")
    }

    func testUpdateTaskMultipleFields() async throws {
        // Given
        let taskUuid = "12345678-1234-1234-1234-123456789fed"
        let update = TaskUpdate(
            title: "Updated Title",
            project: "new-project",
            status: "completed",
            priority: "H",
            comment: "Updated via API"
        )
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789fed",
                "description": "Updated Title",
                "status": "completed",
                "entry": "20250113T000000Z",
                "project": "new-project",
                "priority": "H"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", mockResponse]

        // When
        let updatedTask = try await taskService.updateTask(uuid: taskUuid, update: update)

        // Then
        XCTAssertNotNil(updatedTask)
        XCTAssertEqual(updatedTask.uuid, taskUuid)
        XCTAssertEqual(updatedTask.title, "Updated Title")
        XCTAssertEqual(updatedTask.project, "new-project")
        XCTAssertEqual(updatedTask.status, "completed")
        XCTAssertEqual(updatedTask.priority, "H")
        XCTAssertEqual(updatedTask.comment, "Updated via API")
    }

    func testUpdateTaskValidation() async throws {
        // Given - invalid status should fail
        let taskUuid = "12345678-1234-1234-1234-123456789cba"
        let invalidUpdate = TaskUpdate(status: "invalid-status")
        mockExecutor.mockOutputs = [""]

        // When & Then
        do {
            _ = try await taskService.updateTask(uuid: taskUuid, update: invalidUpdate)
            XCTFail("Expected validation error for invalid status")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testUpdateNonExistentTask() async throws {
        // Given
        let nonExistentUuid = "12345678-1234-1234-1234-000000000000"
        let update = TaskUpdate(title: "Should not work")
        mockExecutor.mockOutputs = [""]

        // When & Then
        do {
            _ = try await taskService.updateTask(uuid: nonExistentUuid, update: update)
            XCTFail("Expected error for non-existent task")
        } catch {
            // Expected to fail - error handling will be implemented
            XCTAssertNotNil(error)
        }
    }
}
