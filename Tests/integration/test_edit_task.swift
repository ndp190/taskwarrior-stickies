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

    override func setUp() {
        super.setUp()
        // Services will be implemented later - these tests will fail
        taskService = TaskService()
        dataManager = DataManager()
    }

    override func tearDown() {
        taskService = nil
        dataManager = nil
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
        let sticky = try await dataManager.createSticky(title: "Test Sticky")
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

        // When - simulate concurrent edits
        async let edit1 = taskService.updateTask(id: createdTask.id, update: TaskUpdate(title: "Edit 1"))
        async let edit2 = taskService.updateTask(id: createdTask.id, update: TaskUpdate(title: "Edit 2"))

        // Then - one should succeed, one should fail (concurrency control)
        do {
            let result1 = try await edit1
            let result2 = try await edit2
            // If both succeed, that's also acceptable depending on implementation
            XCTAssertTrue(result1.title == "Edit 1" || result1.title == "Edit 2")
            XCTAssertTrue(result2.title == "Edit 1" || result2.title == "Edit 2")
        } catch {
            // Expected if concurrency control prevents both edits
            XCTAssertNotNil(error)
        }
    }
}
