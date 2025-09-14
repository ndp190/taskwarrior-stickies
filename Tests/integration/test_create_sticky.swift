//
//  test_create_sticky.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class CreateStickyIntegrationTests: XCTestCase {
    var dataManager: DataManager!
    var taskService: TaskService!
    var mockExecutor: MockTaskCommandExecutor!

    override func setUp() async throws {
        try await super.setUp()
        
        dataManager = await DataManager()
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
        dataManager = nil
        taskService = nil
        mockExecutor = nil
        super.tearDown()
    }

    func testCreateStickyWithDefaultSettings() async throws {
        // Given
        let stickyTitle = "My Tasks"

        // When
        let sticky = try await dataManager.createSticky(title: stickyTitle)

        // Then
        XCTAssertNotNil(sticky)
        XCTAssertEqual(sticky.title, stickyTitle)
        XCTAssertNotNil(sticky.id)
        XCTAssertEqual(sticky.transparency, 0.5) // Default
        XCTAssertTrue(sticky.alwaysOnTop) // Default
        XCTAssertEqual(sticky.visibleColumns, ["title", "project", "age"]) // Default
    }

    func testCreateStickyWithCustomSettings() async throws {
        // Given
        let stickyTitle = "Work Tasks"
        let customSettings = StickySettings(
            transparency: 0.8,
            alwaysOnTop: false,
            filter: "project:work",
            sortBy: "priority",
            sortOrder: "desc",
            visibleColumns: ["title", "priority", "due"]
        )

        // When
        let sticky = try await dataManager.createSticky(title: stickyTitle, settings: customSettings)

        // Then
        XCTAssertNotNil(sticky)
        XCTAssertEqual(sticky.title, stickyTitle)
        XCTAssertEqual(sticky.transparency, 0.8)
        XCTAssertFalse(sticky.alwaysOnTop)
        XCTAssertEqual(sticky.filter, "project:work")
        XCTAssertEqual(sticky.sortBy, "priority")
        XCTAssertEqual(sticky.sortOrder, "desc")
        XCTAssertEqual(sticky.visibleColumns, ["title", "priority", "due"])
    }

    func testCreateStickyAndLoadTasks() async throws {
        // Given
        let stickyTitle = "Project Tasks"
        let filter = "project:development"
        let mockResponse = """
        [
            {
                "uuid": "12345678-1234-1234-1234-123456789abc",
                "description": "Development Task",
                "status": "pending",
                "entry": "20250113T000000Z",
                "project": "development"
            }
        ]
        """
        mockExecutor.mockOutputs = [mockResponse]

        // When
        let sticky = try await dataManager.createSticky(title: stickyTitle)
        let tasks = try await taskService.getTasks(filter: filter, sort: nil)

        // Then
        XCTAssertNotNil(sticky)
        XCTAssertNotNil(tasks)

        // Verify tasks match the sticky's filter
        for task in tasks {
            if let project = task.project {
                XCTAssertTrue(project.contains("development"))
            }
        }
    }

    func testCreateMultipleStickies() async throws {
        // Given
        let titles = ["Work", "Personal", "Shopping"]

        // When
        var stickies: [Sticky] = []
        for title in titles {
            let sticky = try await dataManager.createSticky(title: title)
            stickies.append(sticky)
        }

        // Then
        XCTAssertEqual(stickies.count, 3)
        for (index, sticky) in stickies.enumerated() {
            XCTAssertEqual(sticky.title, titles[index])
            XCTAssertNotNil(sticky.id)
        }

        // Verify all IDs are unique
        let ids = stickies.map { $0.id }
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testCreateStickyValidation() async throws {
        // Given - empty title should fail
        let emptyTitle = ""

        // When & Then
        do {
            _ = try await dataManager.createSticky(title: emptyTitle)
            XCTFail("Expected validation error for empty title")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }
}
