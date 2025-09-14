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

    func testCreateTaskWithMinimumFields() async throws {
        // Given
        let taskInput = TaskInput(title: "Test Task")

        // When
        let createdTask = try await taskService.createTask(taskInput)

        // Then
        XCTAssertNotNil(createdTask)
        XCTAssertEqual(createdTask.title, "Test Task")
        XCTAssertNotNil(createdTask.id)
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

        // When
        let createdTask = try await taskService.createTask(taskInput)

        // Then
        XCTAssertNotNil(createdTask.id)
        XCTAssertNotNil(createdTask.title)
        XCTAssertNotNil(createdTask.status)
        XCTAssertTrue(["pending", "completed"].contains(createdTask.status))
    }
}
