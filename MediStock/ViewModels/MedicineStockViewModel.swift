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

    private let repository: MedicineRepository

    init(repository: MedicineRepository) {
        self.repository = repository
    }


    func loadMedicines() async {
        do {
            medicines = try await repository.fetchMedicines(user: "JohnDoe")
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur inattendue est survenue."
            }
        }
    }

    func addMedicine(_ medicine: Medicine, user: String) async {
        do {
            try await repository.addMedicine(medicine, user: user)
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

    func deleteMedicines(at offsets: IndexSet) async {
        do {
            try await repository.deleteMedicine(at: offsets)
            await loadMedicines()
        } catch {
            if let error = error as? LocalizedError {
                errorMessage = error.errorDescription
            } else {
                errorMessage = "Une erreur inattendue est survenue."
            }
        }
    }
}
