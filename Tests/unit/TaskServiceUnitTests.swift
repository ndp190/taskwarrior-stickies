//
//  TaskServiceUnitTests.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class TaskServiceUnitTests: XCTestCase {
    var taskService: TaskService!
    var mockExecutor: MockTaskCommandExecutor!

    override func setUp() {
        super.setUp()
        mockExecutor = MockTaskCommandExecutor()
        taskService = TaskService(executor: mockExecutor)
    }

    override func tearDown() {
        taskService = nil
        mockExecutor = nil
        super.tearDown()
    }

    func testGetTasksCommand() async throws {
        // Given
        mockExecutor.mockOutputs = ["[]"]

        // When
        _ = try await taskService.getTasks(filter: nil, sort: nil)

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 1)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["export"])
    }

    func testGetTasksWithFilterCommand() async throws {
        // Given
        mockExecutor.mockOutputs = ["[]"]

        // When
        _ = try await taskService.getTasks(filter: "project:work", sort: nil)

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 1)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["export", "project:work"])
    }

    func testGetTaskCommand() async throws {
        // Given
        mockExecutor.mockOutputs = ["[]"]

        // When
        _ = try await taskService.getTask(id: "123")

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 1)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["export", "123"])
    }

    func testCreateTaskCommand() async throws {
        // Given
        mockExecutor.mockOutputs = ["", "[]"] // First for add, second for getTasks

        // When
        let input = TaskInput(title: "Test Task", project: "work", priority: "H")
        _ = try await taskService.createTask(input)

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 2)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["add", "Test Task", "project:work", "priority:H"])
        XCTAssertEqual(mockExecutor.executedCommands[1], ["export"])
    }

    func testCreateTaskWithTagsCommand() async throws {
        // Given
        mockExecutor.mockOutputs = ["", "[]"]

        // When
        let input = TaskInput(title: "Tagged Task", tags: ["urgent", "personal"])
        _ = try await taskService.createTask(input)

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 2)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["add", "Tagged Task", "+urgent", "+personal"])
    }

    func testUpdateTaskCommand() async throws {
        // Given
        mockExecutor.mockOutputs = ["", "[]"] // First for modify, second for getTask

        // When
        let update = TaskUpdate(title: "Updated Title", project: "new-project", status: "completed", priority: "L", comment: "Updated comment")
        _ = try await taskService.updateTask(id: "123", update: update)

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 2)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["123", "modify", "Updated Title", "project:new-project", "status:completed", "priority:L", "annotate:Updated comment"])
        XCTAssertEqual(mockExecutor.executedCommands[1], ["export", "123"])
    }

    func testUpdateTaskPartialCommand() async throws {
        // Given
        mockExecutor.mockOutputs = ["", "[]"]

        // When
        let update = TaskUpdate(title: "Only Title")
        _ = try await taskService.updateTask(id: "456", update: update)

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 2)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["456", "modify", "Only Title"])
    }

    func testDeleteTaskCommand() async throws {
        // Given
        mockExecutor.mockOutputs = [""]

        // When
        try await taskService.deleteTask(id: "789")

        // Then
        XCTAssertEqual(mockExecutor.executedCommands.count, 1)
        XCTAssertEqual(mockExecutor.executedCommands[0], ["789", "delete", "--yes"])
    }
}
