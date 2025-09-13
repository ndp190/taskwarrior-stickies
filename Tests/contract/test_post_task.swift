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

    override func setUp() {
        super.setUp()
        // TaskService will be implemented later - this test will fail
        taskService = TaskService()
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
