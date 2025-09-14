//
//  test_post_task.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class PostTaskContractTests: XCTestCase {
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

    func testCreateTaskWithMinimumFields() async throws {
        // Given
        let taskInput = TaskInput(title: "Test Task")
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789abc",
                "description": "Test Task",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", mockResponse] // First for add, second for getTasks

        // When
        let createdTask = try await taskService.createTask(taskInput)

        // Then
        XCTAssertNotNil(createdTask)
        XCTAssertEqual(createdTask.title, "Test Task")
        XCTAssertNotNil(createdTask.uuid)
        XCTAssertEqual(createdTask.status, "pending")
    }

    func testCreateTaskWithAllFields() async throws {
        // Given
        let taskInput = TaskInput(
            title: "Complete project",
            project: "work",
            due: Date().addingTimeInterval(86400), // Tomorrow
            priority: "H",
            tags: ["urgent", "important"]
        )
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789abc",
                "description": "Complete project",
                "status": "pending",
                "entry": "20250113T000000Z",
                "project": "work",
                "priority": "H",
                "tags": ["urgent", "important"]
            }
        ]
        """
        mockExecutor.mockOutputs = ["", mockResponse]

        // When
        let createdTask = try await taskService.createTask(taskInput)

        // Then
        XCTAssertNotNil(createdTask)
        XCTAssertEqual(createdTask.title, "Complete project")
        XCTAssertEqual(createdTask.project, "work")
        XCTAssertNotNil(createdTask.due)
        XCTAssertEqual(createdTask.priority, "H")
        XCTAssertEqual(createdTask.tags, ["urgent", "important"])
        XCTAssertEqual(createdTask.status, "pending")
    }

    func testCreateTaskValidation() async throws {
        // Given - empty title should fail
        let invalidTaskInput = TaskInput(title: "")
        mockExecutor.mockOutputs = [""]

        // When & Then
        do {
            _ = try await taskService.createTask(invalidTaskInput)
            XCTFail("Expected validation error for empty title")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testCreateTaskResponseFormat() async throws {
        // Given
        let taskInput = TaskInput(title: "Test Task")
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789abc",
                "description": "Test Task",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", mockResponse]

        // When
        let createdTask = try await taskService.createTask(taskInput)

        // Then
        XCTAssertNotNil(createdTask.uuid)
        XCTAssertNotNil(createdTask.title)
        XCTAssertNotNil(createdTask.status)
        XCTAssertTrue(["pending", "completed"].contains(createdTask.status))
    }
}
