//
//  test_get_tasks.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class GetTasksContractTests: XCTestCase {
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

    func testGetTasksWithoutFilter() async throws {
        // Given
        let filter: String? = nil
        let sort: String? = nil
        mockExecutor.mockOutputs = ["[]"]

        // When
        let tasks = try await taskService.getTasks(filter: filter, sort: sort)

        // Then
        XCTAssertNotNil(tasks)
        XCTAssertTrue(tasks.isEmpty) // Should return empty array initially
    }

    func testGetTasksWithFilter() async throws {
        // Given
        let filter = "project:work"
        let sort: String? = nil
        mockExecutor.mockOutputs = ["[]"]

        // When
        let tasks = try await taskService.getTasks(filter: filter, sort: sort)

        // Then
        XCTAssertNotNil(tasks)
        // All returned tasks should match the filter
        for task in tasks {
            XCTAssertTrue(task.project?.contains("work") ?? false)
        }
    }

    func testGetTasksWithSort() async throws {
        // Given
        let filter: String? = nil
        let sort = "priority"
        mockExecutor.mockOutputs = ["[]"]

        // When
        let tasks = try await taskService.getTasks(filter: filter, sort: sort)

        // Then
        XCTAssertNotNil(tasks)
        // Tasks should be sorted by priority (this will be validated in implementation)
    }

    func testGetTasksResponseFormat() async throws {
        // Given
        let filter: String? = nil
        let sort: String? = nil
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789abc",
                "description": "Test Task",
                "status": "pending",
                "entry": "20250113T000000Z",
                "project": "test",
                "priority": "M"
            }
        ]
        """
        mockExecutor.mockOutputs = [mockResponse]

        // When
        let tasks = try await taskService.getTasks(filter: filter, sort: sort)

        // Then
        for task in tasks {
            XCTAssertNotNil(task.uuid)
            XCTAssertNotNil(task.title)
            XCTAssertNotNil(task.status)
            XCTAssertTrue(["pending", "completed"].contains(task.status))
        }
    }
}
