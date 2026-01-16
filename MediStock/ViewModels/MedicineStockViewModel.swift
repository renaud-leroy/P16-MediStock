//
//  MedicineStockViewModel.swift
//  MediStock
//
//  Created by Renaud Leroy on 15/01/2026.
//

import Foundation

@MainActor
final class MedicineStockViewModel: ObservableObject {
    
    @Published var medicines: [Medicine] = []
    @Published var errorMessage: String?
    @Published var filterText: String = ""
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var sortOption: SortOption = .none
    
    private let repository: MedicineRepository
    
    init(repository: MedicineRepository) {
        self.repository = repository
    }
    
    func loadAisles() async {
        do {
            aisles = try await repository.fetchAisles()
        } catch {
            // gestion erreur à remplir
        }
    }
    
    func increaseStock(_ medicine: Medicine, user: String) async {
        let newStock = medicine.stock + 1
        try? await repository.updateStock(
            medicineId: medicine.id!,
            newStock: newStock
        )
        
        let history = HistoryEntry(
            medicineId: medicine.id!,
            user: user,
            action: "Increase stock",
            details: "Stock from \(medicine.stock) to \(newStock)"
        )
        
        try? await repository.addHistory(history)
    }
    
    func decreaseStock(_ medicine: Medicine, user: String) async {
        guard medicine.stock > 0 else { return }
        
        let newStock = medicine.stock - 1
        
        do {
            try await repository.updateStock(
                medicineId: medicine.id!,
                newStock: newStock
            )
            
            let history = HistoryEntry(
                medicineId: medicine.id!,
                user: user,
                action: "Decrease stock",
                details: "Stock from \(medicine.stock) to \(newStock)"
            )
            
            try await repository.addHistory(history)
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur inattendue est survenue."
            }
        }
    }
    
    func loadMedicines() async {
        do {
            medicines = try await repository.fetchMedicines()
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur inattendue est survenue."
            }
        }
    }
    
    func addMedicine(_ medicine: Medicine) async {
        do {
            try await repository.addMedicine(medicine)
            await loadMedicines()
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur inattendue est survenue."
            }
        }
    }
    
    func updateMedicine(_ medicine: Medicine, user: String) async {
        do {
            try await repository.updateMedicine(medicine, user: user)
            await loadMedicines()
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur inattendue est survenue."
            }
        }
    }
    
    func deleteMedicine(_ medicine: Medicine) async {
        guard let id = medicine.id else { return }
        
        do {
            try await repository.deleteMedicine(id: id)
            await loadMedicines()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadHistory(for medicineId: String) async {
        do {
            history = try await repository.fetchHistory(medicineId: medicineId)
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur est survenue lors du chargement de l’historique."
            }
        }
    }
    
    var displayedMedicines: [Medicine] {
        var result = medicines
        
        if !filterText.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(filterText.lowercased())
            }
        }
        
        switch sortOption {
        case .name:
            result = result.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .stock:
            result = result.sorted { $0.stock < $1.stock }
        case .none:
            break
        }
        
        return result
    }
}
