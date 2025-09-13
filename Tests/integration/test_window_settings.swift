//
//  test_window_settings.swift
//  TaskWarriorStickiesTests
//
//  Created by GitHub Copilot on 2025-01-13.
//

import XCTest
@testable import TaskWarriorStickies

final class WindowSettingsIntegrationTests: XCTestCase {
    var dataManager: DataManager!

    override func setUp() {
        super.setUp()
        // DataManager will be implemented later - these tests will fail
        dataManager = DataManager()
    }

    override func tearDown() {
        dataManager = nil
        super.tearDown()
    }

    func testSetWindowTransparency() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Transparent Sticky")
        let newTransparency = 0.3

        // When
        let updatedSticky = try await dataManager.updateStickyTransparency(
            id: sticky.id,
            transparency: newTransparency
        )

        // Then
        XCTAssertEqual(updatedSticky.transparency, newTransparency)
        XCTAssertEqual(updatedSticky.id, sticky.id)
    }

    func testSetWindowAlwaysOnTop() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Always On Top Sticky")

        // When
        let updatedSticky = try await dataManager.updateStickyAlwaysOnTop(
            id: sticky.id,
            alwaysOnTop: false
        )

        // Then
        XCTAssertFalse(updatedSticky.alwaysOnTop)
        XCTAssertEqual(updatedSticky.id, sticky.id)
    }

    func testSetWindowTransparencyValidation() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Validation Test")

        // When - invalid transparency values
        let invalidValues = [-0.1, 1.1, 2.0]

        for invalidValue in invalidValues {
            do {
                _ = try await dataManager.updateStickyTransparency(
                    id: sticky.id,
                    transparency: invalidValue
                )
                XCTFail("Expected validation error for transparency: \(invalidValue)")
            } catch {
                // Expected to fail - validation will be implemented
                XCTAssertNotNil(error)
            }
        }
    }

    func testWindowSettingsPersistence() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Persistence Test")

        // When
        let updatedSticky = try await dataManager.updateStickyTransparency(
            id: sticky.id,
            transparency: 0.7
        )
        let alwaysOnTopUpdated = try await dataManager.updateStickyAlwaysOnTop(
            id: updatedSticky.id,
            alwaysOnTop: false
        )

        // Simulate app restart by creating new DataManager
        let newDataManager = DataManager()
        let loadedSticky = try await newDataManager.getSticky(id: sticky.id)

        // Then
        XCTAssertEqual(loadedSticky.transparency, 0.7)
        XCTAssertFalse(loadedSticky.alwaysOnTop)
    }

    func testMultipleWindowSettings() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Multi-Settings Test")

        // When - update multiple settings
        let transparencyUpdated = try await dataManager.updateStickyTransparency(
            id: sticky.id,
            transparency: 0.6
        )
        let alwaysOnTopUpdated = try await dataManager.updateStickyAlwaysOnTop(
            id: transparencyUpdated.id,
            alwaysOnTop: false
        )

        // Then
        XCTAssertEqual(alwaysOnTopUpdated.transparency, 0.6)
        XCTAssertFalse(alwaysOnTopUpdated.alwaysOnTop)
    }

    func testWindowSettingsWithPositionAndSize() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Position Size Test")
        let newPosition = CGPoint(x: 100, y: 200)
        let newSize = CGSize(width: 400, height: 300)

        // When
        let updatedSticky = try await dataManager.updateStickyWindowFrame(
            id: sticky.id,
            position: newPosition,
            size: newSize
        )

        // Then
        XCTAssertEqual(updatedSticky.position, newPosition)
        XCTAssertEqual(updatedSticky.size, newSize)
    }

    func testWindowSettingsBoundsValidation() async throws {
        // Given
        let sticky = try await dataManager.createSticky(title: "Bounds Test")

        // When - invalid position/size
        let invalidPosition = CGPoint(x: -100, y: -200)
        let invalidSize = CGSize(width: 0, height: 0)

        // Then
        do {
            _ = try await dataManager.updateStickyWindowFrame(
                id: sticky.id,
                position: invalidPosition,
                size: invalidSize
            )
            XCTFail("Expected validation error for invalid bounds")
        } catch {
            // Expected to fail - validation will be implemented
            XCTAssertNotNil(error)
        }
    }
}
