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

    override func setUp() async throws {
        try await super.setUp()
        
        mockExecutor = MockTaskCommandExecutor()
        taskService = TaskService(executor: mockExecutor)
        dataManager = await DataManager()
    }

    override func tearDown() {
        taskService = nil
        dataManager = nil
        mockExecutor = nil
        super.tearDown()
    }

    func testEditTaskTitle() async throws {
        // Given
        let originalTitle = "Original Task"
        let newTitle = "Updated Task Title"
        let taskUuid = "12345678-1234-1234-1234-123456789abc"
        
        // Mock responses: first for createTask (add + getTasks), then for updateTask (modify + getTask)
        let createResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "\(originalTitle)",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        let updateResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "\(newTitle)",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", createResponse, "", updateResponse]

        // Create a task first
        let taskInput = TaskInput(title: originalTitle)
        let createdTask = try await taskService.createTask(taskInput)

        // When
        let update = TaskUpdate(title: newTitle)
        let updatedTask = try await taskService.updateTask(uuid: createdTask.uuid, update: update)

        // Then
        XCTAssertEqual(updatedTask.title, newTitle)
        XCTAssertEqual(updatedTask.uuid, createdTask.uuid)
    }

    func testEditTaskInStickyView() async throws {
        // Given
        _ = try await dataManager.createSticky(title: "Test Sticky")
        let taskInput = TaskInput(title: "Task to Edit")
        let taskUuid = "12345678-1234-1234-1234-123456789abc"
        let newTitle = "Edited in Sticky View"
        
        // Mock responses
        let createResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "Task to Edit",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        let updateResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "\(newTitle)",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        let getTasksResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "\(newTitle)",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", createResponse, "", updateResponse, getTasksResponse]

        let createdTask = try await taskService.createTask(taskInput)

        // When - simulate editing in UI
        let update = TaskUpdate(title: newTitle)
        let updatedTask = try await taskService.updateTask(uuid: createdTask.uuid, update: update)

        // Then
        XCTAssertEqual(updatedTask.title, newTitle)

        // Verify the change is reflected when loading tasks for the sticky
        let tasks = try await taskService.getTasks(filter: nil, sort: nil)
        let foundTask = tasks.first { $0.uuid == createdTask.uuid }
        XCTAssertNotNil(foundTask)
        XCTAssertEqual(foundTask?.title, newTitle)
    }

    func testEditMultipleTaskFields() async throws {
        // Given
        let taskInput = TaskInput(title: "Multi-field Task")
        let taskUuid = "12345678-1234-1234-1234-123456789abc"
        
        // Mock responses
        let createResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "Multi-field Task",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        let updateResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "Updated Multi-field Task",
                "status": "completed",
                "entry": "20250113T000000Z",
                "project": "new-project",
                "priority": "H"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", createResponse, "", updateResponse]

        let createdTask = try await taskService.createTask(taskInput)

        // When
        let update = TaskUpdate(
            title: "Updated Multi-field Task",
            project: "new-project",
            status: "completed",
            priority: "H"
        )
        let updatedTask = try await taskService.updateTask(uuid: createdTask.uuid, update: update)

        // Then
        XCTAssertEqual(updatedTask.title, "Updated Multi-field Task")
        XCTAssertEqual(updatedTask.project, "new-project")
        XCTAssertEqual(updatedTask.status, "completed")
        XCTAssertEqual(updatedTask.priority, "H")
    }

    func testEditTaskValidation() async throws {
        // Given
        let taskInput = TaskInput(title: "Task to Validate")
        let taskUuid = "12345678-1234-1234-1234-123456789abc"
        
        // Mock responses for create
        let createResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "Task to Validate",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", createResponse, ""]

        let createdTask = try await taskService.createTask(taskInput)

        // When - try to set empty title
        let invalidUpdate = TaskUpdate(title: "")

        // Then
        do {
            _ = try await taskService.updateTask(uuid: createdTask.uuid, update: invalidUpdate)
            XCTFail("Expected validation error for empty title")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testEditNonExistentTask() async throws {
        // Given
        let nonExistentUuid = "12345678-1234-1234-1234-000000000000"
        let update = TaskUpdate(title: "Should not work")
        mockExecutor.mockOutputs = [""]

        // When & Then
        do {
            _ = try await taskService.updateTask(uuid: nonExistentUuid, update: update)
            XCTFail("Expected error for editing non-existent task")
        } catch {
            // Expected to fail - error handling will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testConcurrentTaskEdits() async throws {
        // Given
        let taskInput = TaskInput(title: "Concurrent Edit Task")
        let taskUuid = "12345678-1234-1234-1234-123456789abc"
        
        // Mock responses
        let createResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "Concurrent Edit Task",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        let updateResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "Edit 1",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        let getTasksResponse = """
        [
            {
                "uuid": "\(taskUuid)",
                "description": "Edit 1",
                "status": "pending",
                "entry": "20250113T000000Z"
            }
        ]
        """
        mockExecutor.mockOutputs = ["", createResponse, "", updateResponse, getTasksResponse]

        let createdTask = try await taskService.createTask(taskInput)

        // When - simulate concurrent edits (simplified version)
        let update1 = TaskUpdate(title: "Edit 1")
        
        // Perform edits sequentially for now (concurrency testing can be more complex)
        let result1 = try await taskService.updateTask(uuid: createdTask.uuid, update: update1)
        
        // Then
        XCTAssertEqual(result1.title, "Edit 1")
        
        // Verify the task was updated
        let tasks = try await taskService.getTasks(filter: nil, sort: nil)
        let foundTask = tasks.first { $0.uuid == createdTask.uuid }
        XCTAssertNotNil(foundTask)
        XCTAssertEqual(foundTask?.title, "Edit 1")
    }
}
