//
//  MedicineRepository.swift
//  MediStock
//
//  Created by Renaud Leroy on 15/01/2026.
//

import Foundation
import Firebase


protocol MedicineRepositoryProtocol {
    func addMedicine(_ medicine: Medicine) async throws
    func updateMedicine(_ medicine: Medicine, user: String) async throws
    func deleteMedicine(id: String) async throws
    func fetchMedicines(aisle: String?, searchText: String?, showOnlyInStock: Bool, sortBy: MedicineSortOption) async throws -> [Medicine]
    func fetchAisles() async throws -> [String]
    func updateStock(medicineId: String, newStock: Int) async throws
    func fetchHistory(medicineId: String) async throws -> [HistoryEntry]
    func addHistory(_ history: HistoryEntry) async throws
}

final class FirestoreMedicineRepository: MedicineRepositoryProtocol {
    
    private let db = Firestore.firestore()
    
    func addMedicine(_ medicine: Medicine) async throws {
        do {
            // Création de l'id en local
            let docRef = db.collection("medicines").document()
            
            // Création de l'objet et injection de l'id dans celui-ci avant l'envoi vers firebase
            var newMedicine = medicine
            newMedicine.id = docRef.documentID
            
            // Sauvegarde de l'objet
            try docRef.setData(from: newMedicine)
            
            // Ajout de la trace de l'id dans l'historique
            let history = HistoryEntry(
                medicineId: docRef.documentID,
                user: "system",
                action: "Add medicine",
                details: "Medicine added"
            )
            
            try await addHistory(history)
            
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func updateMedicine(_ medicine: Medicine, user: String) async throws {
        guard let id = medicine.id else {
            throw MedicineError.missingId
        }
        do {
            try db.collection("medicines")
                .document(id)
                .setData(from: medicine, merge: true)
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func deleteMedicine(id: String) async throws {
        do {
            try await db.collection("medicines")
                .document(id)
                .delete()
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func fetchMedicines(aisle: String?, searchText: String?, showOnlyInStock: Bool, sortBy: MedicineSortOption) async throws -> [Medicine] {
        do {
            var query: Query = db.collection("medicines")
            
            if let aisle {
                query = query.whereField("aisle", isEqualTo: aisle)
            }
            
            if let searchText, !searchText.isEmpty {
                query = query
                    .whereField("name", isGreaterThanOrEqualTo: searchText)
                    .whereField("name", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            }
            
            if showOnlyInStock {
                query = query.whereField("stock", isGreaterThan: 0)
            }
            
            switch sortBy {
            case .name:
                query = query.order(by: "name")
            case .stock:
                query = query.order(by: "stock")
            }
            
            let snapshot = try await query.getDocuments()
            return snapshot.documents.compactMap {
                try? $0.data(as: Medicine.self)
            }
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func fetchAisles() async throws -> [String] {
        do {
            let snapshot = try await db.collection("medicines").getDocuments()
            let aisles = snapshot.documents.compactMap { $0["aisle"] as? String }
            return Array(Set(aisles)).sorted()
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func updateStock(medicineId: String, newStock: Int) async throws {
        do {
            try await db.collection("medicines")
                .document(medicineId)
                .updateData(["stock": newStock])
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func fetchHistory(medicineId: String) async throws -> [HistoryEntry] {
        do {
            let snapshot = try await db.collection("history")
                .whereField("medicineId", isEqualTo: medicineId)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap {
                try? $0.data(as: HistoryEntry.self)
            }
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func addHistory(_ history: HistoryEntry) async throws {
        do {
            try db.collection("history")
                .document()
                .setData(from: history)
        } catch {
            throw MedicineError.network(error)
        }
    }
}
