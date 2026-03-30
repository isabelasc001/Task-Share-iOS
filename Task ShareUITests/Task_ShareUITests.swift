//
//  Task_ShareUITests.swift
//  Task ShareUITests
//

import XCTest

final class Task_ShareUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }
    
    /// Helper to dismiss the software keyboard if it's showing
    private func dismissKeyboard(in app: XCUIApplication) {
        if app.keyboards.count > 0 {
            app.keyboards.buttons["Return"].tap()
        }
    }

    @MainActor
    func testLandingPageNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Assert Landing Page is visible
        XCTAssertTrue(app.staticTexts["Task Share"].exists)
        XCTAssertTrue(app.staticTexts["Organize and share your tasks easily"].exists)
        
        // Tap continue
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.exists)
        continueButton.tap()
        
        // Assert Home Page is visible
        XCTAssertTrue(app.searchFields["Search lists"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["newListButton"].exists)
        XCTAssertTrue(app.buttons["archivedButton"].exists)
    }

    @MainActor
    func testCreateNewList() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Skip Landing if needed or tap continue
        if app.buttons["Continue"].exists {
            app.buttons["Continue"].tap()
        }
        
        // Tap new list button
        let newListBtn = app.buttons["newListButton"]
        XCTAssertTrue(newListBtn.waitForExistence(timeout: 2.0))
        newListBtn.tap()
        
        // Fill list title
        let titleField = app.textFields["List title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2.0))
        titleField.tap()
        titleField.typeText("My Grocery List")
        
        // Dismiss keyboard so buttons below are accessible
        dismissKeyboard(in: app)
        
        // Add an item
        let addItemBtn = app.buttons["+ Add Item"]
        XCTAssertTrue(addItemBtn.waitForExistence(timeout: 2.0))
        addItemBtn.tap()
        
        let alert = app.alerts["New Item"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2.0))
        let alertTextField = alert.textFields.firstMatch
        alertTextField.typeText("Buy Milk")
        alert.buttons["Add"].tap()
        
        // Save list
        let saveBtn = app.buttons["Save"]
        XCTAssertTrue(saveBtn.waitForExistence(timeout: 2.0))
        saveBtn.tap()
        
        // Verify it appears on Home
        XCTAssertTrue(app.staticTexts["My Grocery List"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["• Buy Milk"].exists)
    }
    
    @MainActor
    func testSearchAndFiltering() throws {
        let app = XCUIApplication()
        app.launch()
        
        if app.buttons["Continue"].exists {
            app.buttons["Continue"].tap()
        }
        
        // Create 1st List
        app.buttons["newListButton"].tap()
        let titleField1 = app.textFields["List title"]
        XCTAssertTrue(titleField1.waitForExistence(timeout: 2.0))
        titleField1.tap()
        titleField1.typeText("Work Tasks")
        dismissKeyboard(in: app)
        
        let saveBtn1 = app.buttons["Save"]
        XCTAssertTrue(saveBtn1.waitForExistence(timeout: 2.0))
        saveBtn1.tap()
        
        // Wait for Home
        XCTAssertTrue(app.staticTexts["Work Tasks"].waitForExistence(timeout: 2.0))
        
        // Create 2nd List
        app.buttons["newListButton"].tap()
        let titleField2 = app.textFields["List title"]
        XCTAssertTrue(titleField2.waitForExistence(timeout: 2.0))
        titleField2.tap()
        titleField2.typeText("Home Chores")
        dismissKeyboard(in: app)
        
        let saveBtn2 = app.buttons["Save"]
        XCTAssertTrue(saveBtn2.waitForExistence(timeout: 2.0))
        saveBtn2.tap()
        
        XCTAssertTrue(app.staticTexts["Home Chores"].waitForExistence(timeout: 2.0))
        
        // Search for "Work"
        let searchField = app.searchFields["Search lists"]
        searchField.tap()
        searchField.typeText("Work")
        
        // Assert
        XCTAssertTrue(app.staticTexts["Work Tasks"].exists)
        XCTAssertFalse(app.staticTexts["Home Chores"].exists)
    }
    
    @MainActor
    func testInteractingWithTasksAndArchiving() throws {
        let app = XCUIApplication()
        app.launch()
        
        if app.buttons["Continue"].exists {
            app.buttons["Continue"].tap()
        }
        
        // Create List
        app.buttons["newListButton"].tap()
        let titleField = app.textFields["List title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2.0))
        titleField.tap()
        titleField.typeText("Daily Reading")
        
        // Dismiss keyboard so + Add Item is visible
        dismissKeyboard(in: app)
        
        let addItemBtn = app.buttons["+ Add Item"]
        XCTAssertTrue(addItemBtn.waitForExistence(timeout: 2.0))
        addItemBtn.tap()
        
        let alert = app.alerts["New Item"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2.0))
        alert.textFields.firstMatch.typeText("Read Book")
        alert.buttons["Add"].tap()
        
        let saveBtn = app.buttons["Save"]
        XCTAssertTrue(saveBtn.waitForExistence(timeout: 2.0))
        saveBtn.tap()
        
        // Verify list is created
        let listCard = app.staticTexts["Daily Reading"]
        XCTAssertTrue(listCard.waitForExistence(timeout: 2.0))
        
        // Tap list to open
        listCard.tap()
        
        // Check task — tap the checkbox button area
        let taskCell = app.staticTexts["Read Book"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2.0))
        taskCell.tap()
        
        // Wait for update
        let updateBtn = app.buttons["Update"]
        XCTAssertTrue(updateBtn.waitForExistence(timeout: 2.0))
        updateBtn.tap()
        
        // Wait for Home Screen
        XCTAssertTrue(app.buttons["newListButton"].waitForExistence(timeout: 2.0))
        
        // The list should now be archived (auto-archive since it has 1 item which is complete)
        // Verify it disappeared from Home
        XCTAssertFalse(app.staticTexts["Daily Reading"].exists)
        
        // Go to Archived
        app.buttons["archivedButton"].tap()
        let archivedListCard = app.staticTexts["Daily Reading"]
        XCTAssertTrue(archivedListCard.waitForExistence(timeout: 2.0))
    }
}
