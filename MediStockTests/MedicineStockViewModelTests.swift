//
//  MedicineStockViewModelTests.swift
//  MediStockTests
//
//  Created by Renaud Leroy on 22/01/2026.
//

import XCTest
@testable import MediStock

private struct NonLocalizedError: Error {}

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

    // MARK: - Non-localized error branches

    func testLoadAisles_nonLocalizedError_setsGenericMessage() async {
        // Given
        repository.shouldThrowError = true
        repository.errorToThrow = NonLocalizedError()

        // When
        await viewModel.loadAisles()

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Une erreur est survenue lors du chargement des rayons.")
    }

    func testLoadMedicines_nonLocalizedError_setsGenericMessage() async {
        // Given
        repository.shouldThrowError = true
        repository.errorToThrow = NonLocalizedError()

        // When
        await viewModel.loadMedicines()

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Une erreur inattendue est survenue.")
    }

    func testAddMedicine_nonLocalizedError_setsGenericMessage() async {
        // Given
        repository.shouldThrowError = true
        repository.errorToThrow = NonLocalizedError()
        let medicine = Medicine(id: "1", name: "Test", stock: 1, aisle: "A")

        // When
        await viewModel.addMedicine(medicine)

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Une erreur inattendue est survenue.")
    }

    func testUpdateMedicine_nonLocalizedError_setsGenericMessage() async {
        // Given
        repository.shouldThrowError = true
        repository.errorToThrow = NonLocalizedError()
        let medicine = Medicine(id: "1", name: "Test", stock: 1, aisle: "A")

        // When
        await viewModel.updateMedicine(medicine, user: "Renaud")

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Une erreur inattendue est survenue.")
    }

    func testUpdateStock_nonLocalizedError_setsGenericMessage() async {
        // Given
        repository.shouldThrowError = true
        repository.errorToThrow = NonLocalizedError()
        let medicine = Medicine(id: "1", name: "Test", stock: 5, aisle: "A")

        // When
        await viewModel.updateStock(medicine, to: 10, user: "Renaud")

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Une erreur est survenue lors de la mise à jour du stock.")
    }

    func testLoadHistory_nonLocalizedError_setsGenericMessage() async {
        // Given
        repository.shouldThrowError = true
        repository.errorToThrow = NonLocalizedError()

        // When
        await viewModel.loadHistory(for: "1")

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Une erreur est survenue lors du chargement de l'historique.")
    }

    // MARK: - Guard nil id branches

    func testDeleteMedicine_nilId_doesNothing() async {
        // Given
        let medicine = Medicine(id: nil, name: "Test", stock: 1, aisle: "A")
        repository.medicines = [Medicine(id: "1", name: "Existing", stock: 5, aisle: "B")]

        // When
        await viewModel.deleteMedicine(medicine)

        // Then
        XCTAssertEqual(repository.medicines.count, 1)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUpdateStock_nilId_doesNothing() async {
        // Given
        let medicine = Medicine(id: nil, name: "Test", stock: 5, aisle: "A")

        // When
        await viewModel.updateStock(medicine, to: 10, user: "Renaud")

        // Then
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Business Logic

    func testMedicinesForAisle_filtersCorrectly() async {
        // Given
        repository.medicines = [
            Medicine(id: "1", name: "Doliprane", stock: 10, aisle: "A"),
            Medicine(id: "2", name: "Ibuprofen", stock: 5, aisle: "B"),
            Medicine(id: "3", name: "Aspirine", stock: 3, aisle: "A")
        ]
        await viewModel.loadMedicines()

        // When
        let result = viewModel.medicinesForAisle("A")

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.aisle == "A" })
    }

    func testSaveChanges_updatesAndSetsStock() async {
        // Given
        let medicine = Medicine(id: "1", name: "Doliprane", stock: 10, aisle: "A")
        repository.medicines = [medicine]

        // When
        await viewModel.saveChanges(for: medicine, name: "Doliprane 1000", aisle: "B", stock: 5, user: "Renaud")

        // Then
        XCTAssertEqual(repository.medicines.first?.name, "Doliprane 1000")
        XCTAssertEqual(repository.medicines.first?.aisle, "B")
    }

    func testSaveChanges_negativeStock_clampedToZero() async {
        // Given
        let medicine = Medicine(id: "1", name: "Doliprane", stock: 10, aisle: "A")
        repository.medicines = [medicine]

        // When
        await viewModel.saveChanges(for: medicine, name: "Doliprane", aisle: "A", stock: -3, user: "Renaud")

        // Then
        XCTAssertEqual(viewModel.history.first?.details, "Stock from 10 to 0")
    }
}
