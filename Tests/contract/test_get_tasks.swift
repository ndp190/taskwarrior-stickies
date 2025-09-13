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

    override func setUp() {
        super.setUp()
        // TaskService will be implemented later - this test will fail
        taskService = TaskService()
    }

    override func tearDown() {
        taskService = nil
        super.tearDown()
    }

    func testGetTasksWithoutFilter() async throws {
        // Given
        let filter: String? = nil
        let sort: String? = nil

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

        // When
        let tasks = try await taskService.getTasks(filter: filter, sort: sort)

        // Then
        for task in tasks {
            XCTAssertNotNil(task.id)
            XCTAssertNotNil(task.title)
            XCTAssertNotNil(task.status)
            XCTAssertTrue(["pending", "completed"].contains(task.status))
        }
    }
}
