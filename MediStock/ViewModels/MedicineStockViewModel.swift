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
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var sortOption: MedicineSortOption = .name
    @Published var selectedAisle: String? = nil
    @Published var searchText: String = ""
    @Published var showOnlyInStock: Bool = false
    
    private let repository: MedicineRepositoryProtocol
    
    init(repository: MedicineRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadAisles() async {
        do {
            aisles = try await repository.fetchAisles()
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur est survenue lors du chargement des rayons."
            }
        }
    }

    func updateStock(_ medicine: Medicine, to newStock: Int, user: String) async {
        guard let id = medicine.id else { return }

        do {
            try await repository.updateStock(medicineId: id, newStock: newStock)

            guard medicine.stock != newStock else {
                return
            }

            let entry = HistoryEntry(
                medicineId: id,
                user: user,
                action: "Set stock",
                details: "Stock from \(medicine.stock) to \(newStock)",
                timestamp: Date()
            )

            try await repository.addHistory(entry)
            await loadHistory(for: id)
            await loadMedicines()
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur est survenue lors de la mise à jour du stock."
            }
        }
    }
    
    func loadMedicines() async {
        do {
            medicines = try await repository.fetchMedicines(
                aisle: selectedAisle,
                searchText: searchText,
                showOnlyInStock: showOnlyInStock,
                sortBy: sortOption
            )
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
}
