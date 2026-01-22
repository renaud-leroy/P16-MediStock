//
//  MedicineStockViewModelTests.swift
//  MediStockTests
//
//  Created by Renaud Leroy on 22/01/2026.
//

import XCTest
@testable import MediStock

@MainActor
final class MedicineStockViewModelTests: XCTestCase {

    private var repository: MockMedicineRepository!
    private var viewModel: MedicineStockViewModel!

    override func setUp() {
        super.setUp()
        repository = MockMedicineRepository()
        viewModel = MedicineStockViewModel(repository: repository)
    }

    override func tearDown() {
        repository = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testLoadAisles_success_setsAisles() async {
        // Given
        repository.aisles = ["A", "B", "C"]

        // When
        await viewModel.loadAisles()

        // Then
        XCTAssertEqual(viewModel.aisles, ["A", "B", "C"])
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadAisles_failure_setsErrorMessage() async {
        // Given
        repository.shouldThrowError = true

        // When
        await viewModel.loadAisles()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.aisles.isEmpty)
    }
    
    func testLoadMedicines_success_setsMedicines() async {
        // Given
        let medicine = Medicine(id: "1", name: "doliprane", stock: 10, aisle: "A")
        repository.medicines = [medicine]

        // When
        await viewModel.loadMedicines()

        // Then
        XCTAssertEqual(viewModel.medicines.count, 1)
        XCTAssertEqual(viewModel.medicines.first?.name, "doliprane")
    }
    
    func testLoadMedicines_failure_setsErrorMessage() async {
        // Given
        repository.shouldThrowError = true

        // When
        await viewModel.loadMedicines()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.medicines.isEmpty)
    }
    
    func testAddMedicine_addsMedicineAndReloads() async {
        // Given
        let medicine = Medicine(id: "1", name: "ibuprofen", stock: 5, aisle: "B")

        // When
        await viewModel.addMedicine(medicine)

        // Then
        XCTAssertEqual(repository.medicines.count, 1)
        XCTAssertEqual(viewModel.medicines.count, 1)
    }
    
    func testAddMedicine_failure_setsErrorMessage() async {
        // Given
        repository.shouldThrowError = true
        let medicine = Medicine(id: "1", name: "Test", stock: 1, aisle: "A")

        // When
        await viewModel.addMedicine(medicine)

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testDeleteMedicine_removesMedicine() async {
        // Given
        let medicine = Medicine(id: "1", name: "paracetamol", stock: 3, aisle: "A")
        repository.medicines = [medicine]

        // When
        await viewModel.deleteMedicine(medicine)

        // Then
        XCTAssertTrue(repository.medicines.isEmpty)
    }
    
    func testDeleteMedicine_failure_setsErrorMessage() async {
        // Given
        repository.shouldThrowError = true
        let medicine = Medicine(id: "1", name: "Test", stock: 1, aisle: "A")

        // When
        await viewModel.deleteMedicine(medicine)

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testUpdateStock_sameValue_doesNotCreateHistory() async {
        // Given
        let medicine = Medicine(id: "1", name: "aspirine", stock: 10, aisle: "A")
        repository.medicines = [medicine]

        // When
        await viewModel.updateStock(medicine, to: 10, user: "Renaud")

        // Then
        XCTAssertTrue(repository.history.isEmpty)
    }
    
    func testUpdateStock_differentValue_updatesHistory() async {
        // Given
        let medicine = Medicine(id: "1", name: "aspirine", stock: 10, aisle: "A")
        repository.medicines = [medicine]

        // When
        await viewModel.updateStock(medicine, to: 5, user: "Renaud")
        await viewModel.loadHistory(for: "1")

        // Then
        XCTAssertEqual(viewModel.history.count, 1)
        XCTAssertEqual(viewModel.history.first?.user, "Renaud")
    }
    
    func testUpdateMedicine_success_updatesMedicines() async {
        // Given
        let medicine = Medicine(id: "1", name: "Doliprane", stock: 10, aisle: "A")
        repository.medicines = [medicine]

        let updated = Medicine(id: "1", name: "Doliprane 1000", stock: 10, aisle: "A")

        // When
        await viewModel.updateMedicine(updated, user: "Renaud")

        // Then
        XCTAssertEqual(repository.medicines.first?.name, "Doliprane 1000")
    }
    
    func testUpdateMedicine_failure_setsErrorMessage() async {
        // Given
        repository.shouldThrowError = true
        let medicine = Medicine(id: "1", name: "Test", stock: 1, aisle: "A")

        // When
        await viewModel.updateMedicine(medicine, user: "Renaud")

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testLoadHistory_failure_setsErrorMessage() async {
        // Given
        repository.shouldThrowError = true

        // When
        await viewModel.loadHistory(for: "1")

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.history.isEmpty)
    }
}
