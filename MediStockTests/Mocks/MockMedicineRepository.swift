//
//  MockMedicineRepository.swift
//  MediStockTests
//
//  Created by Renaud Leroy on 22/01/2026.
//

import Foundation
@testable import MediStock


final class MockMedicineRepository: MedicineRepositoryProtocol {
    
    
    // MARK: - Mock data
    var medicines: [Medicine] = []
    var aisles: [String] = []
    var history: [HistoryEntry] = []
    
    
    // MARK: - Error simulation
    var shouldThrowError = false
    
    func addMedicine(_ medicine: MediStock.Medicine) async throws {
        if shouldThrowError {
            throw TestError.generic
        }
        medicines.append(medicine)
    }
    
    func fetchAisles() async throws -> [String] {
        if shouldThrowError {
            throw TestError.generic
        }
        return aisles
    }
    
    func updateMedicine(_ medicine: MediStock.Medicine, user: String) async throws {
        if shouldThrowError {
            throw TestError.generic
        }
        guard let id = medicine.id else { return }

            if let index = medicines.firstIndex(where: { $0.id == id }) {
                medicines[index] = medicine
            }
    }
    
    func deleteMedicine(id: String) async throws {
        if shouldThrowError {
            throw TestError.generic
        }
        medicines.removeAll { $0.id == id }
    }
    
    func fetchMedicines(aisle: String?, searchText: String?, showOnlyInStock: Bool, sortBy: MediStock.MedicineSortOption) async throws -> [MediStock.Medicine] {
        if shouldThrowError {
            throw TestError.generic
        }
        return medicines
    }
    
    func updateStock(medicineId: String, newStock: Int) async throws {
        if shouldThrowError {
            throw TestError.generic
        }
    }
    
    func fetchHistory(medicineId: String) async throws -> [HistoryEntry] {
        if shouldThrowError {
            throw TestError.generic
        }
        return history.filter { $0.medicineId == medicineId }
    }
    
    func addHistory(_ entry: HistoryEntry) async throws {
        if shouldThrowError {
            throw TestError.generic
        }
        history.append(entry)
    }
    
    enum TestError: LocalizedError {
        case generic
        
        var errorDescription: String? {
            "Erreur de test"
        }
    }
}



