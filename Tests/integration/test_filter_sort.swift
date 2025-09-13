//
//  test_filter_sort.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class FilterSortIntegrationTests: XCTestCase {
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

    func testFilterTasksByProject() async throws {
        // Given - create tasks with different projects
        let task1 = TaskInput(title: "Work Task 1", project: "work")
        let task2 = TaskInput(title: "Work Task 2", project: "work")
        let task3 = TaskInput(title: "Personal Task", project: "personal")

        _ = try await taskService.createTask(task1)
        _ = try await taskService.createTask(task2)
        _ = try await taskService.createTask(task3)

        // When
        let filteredTasks = try await taskService.getTasks(filter: "project:work", sort: nil)

        // Then
        XCTAssertEqual(filteredTasks.count, 2)
        for task in filteredTasks {
            XCTAssertEqual(task.project, "work")
        }
    }

    func testFilterTasksByStatus() async throws {
        // Given - create tasks with different statuses
        let pendingTask = TaskInput(title: "Pending Task")
        let completedTask = TaskInput(title: "Completed Task")

        let createdPending = try await taskService.createTask(pendingTask)
        let createdCompleted = try await taskService.createTask(completedTask)

        // Mark one as completed
        _ = try await taskService.updateTask(
            id: createdCompleted.id,
            update: TaskUpdate(status: "completed")
        )

        // When
        let pendingTasks = try await taskService.getTasks(filter: "status:pending", sort: nil)
        let completedTasks = try await taskService.getTasks(filter: "status:completed", sort: nil)

        // Then
        XCTAssertTrue(pendingTasks.contains { $0.id == createdPending.id })
        XCTAssertTrue(completedTasks.contains { $0.id == createdCompleted.id })
    }

    func testSortTasksByPriority() async throws {
        // Given - create tasks with different priorities
        let highPriority = TaskInput(title: "High Priority", priority: "H")
        let mediumPriority = TaskInput(title: "Medium Priority", priority: "M")
        let lowPriority = TaskInput(title: "Low Priority", priority: "L")

        _ = try await taskService.createTask(highPriority)
        _ = try await taskService.createTask(mediumPriority)
        _ = try await taskService.createTask(lowPriority)

        // When
        let sortedTasks = try await taskService.getTasks(filter: nil, sort: "priority")

        // Then - verify sorting (H > M > L)
        XCTAssertEqual(sortedTasks.count, 3)
        // Priority sorting validation will be implemented
    }

    func testSortTasksByDueDate() async throws {
        // Given - create tasks with different due dates
        let tomorrow = Date().addingTimeInterval(86400)
        let nextWeek = Date().addingTimeInterval(604800)

        let urgentTask = TaskInput(title: "Urgent", due: tomorrow)
        let normalTask = TaskInput(title: "Normal", due: nextWeek)

        _ = try await taskService.createTask(urgentTask)
        _ = try await taskService.createTask(normalTask)

        // When
        let sortedTasks = try await taskService.getTasks(filter: nil, sort: "due")

        // Then - verify due date sorting
        XCTAssertEqual(sortedTasks.count, 2)
        // Due date sorting validation will be implemented
    }

    func testCombinedFilterAndSort() async throws {
        // Given - create multiple tasks
        let tasks = [
            TaskInput(title: "Work High", project: "work", priority: "H"),
            TaskInput(title: "Work Low", project: "work", priority: "L"),
            TaskInput(title: "Personal High", project: "personal", priority: "H"),
            TaskInput(title: "Personal Low", project: "personal", priority: "L")
        ]

        for task in tasks {
            _ = try await taskService.createTask(task)
        }

        // When - filter by project and sort by priority
        let filteredSortedTasks = try await taskService.getTasks(
            filter: "project:work",
            sort: "priority"
        )

        // Then
        XCTAssertEqual(filteredSortedTasks.count, 2)
        for task in filteredSortedTasks {
            XCTAssertEqual(task.project, "work")
        }
        // Priority sorting within filtered results will be validated
    }

    func testStickyFilterAndSortSettings() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Filtered Sticky")
        let customSettings = StickySettings(
            filter: "project:development",
            sortBy: "priority",
            sortOrder: "desc"
        )

        // When
        let updatedSticky = try await dataManager.updateStickySettings(
            id: sticky.id,
            settings: customSettings
        )

        // Then
        XCTAssertEqual(updatedSticky.filter, "project:development")
        XCTAssertEqual(updatedSticky.sortBy, "priority")
        XCTAssertEqual(updatedSticky.sortOrder, "desc")
    }

    func testInvalidFilterQuery() async throws {
        // Given
        let invalidFilter = "invalid:query:syntax"

        // When & Then
        do {
            _ = try await taskService.getTasks(filter: invalidFilter, sort: nil)
            XCTFail("Expected error for invalid filter query")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testInvalidSortField() async throws {
        // Given
        let invalidSort = "invalid_field"

        // When & Then
        do {
            _ = try await taskService.getTasks(filter: nil, sort: invalidSort)
            XCTFail("Expected error for invalid sort field")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }

    func testEmptyFilterResults() async throws {
        // Given
        let nonMatchingFilter = "project:nonexistent"

        // When
        let tasks = try await taskService.getTasks(filter: nonMatchingFilter, sort: nil)

        // Then
        XCTAssertEqual(tasks.count, 0)
    }
}
