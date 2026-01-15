//
//  MedicineRepository.swift
//  MediStock
//
//  Created by Renaud Leroy on 15/01/2026.
//

import Foundation
import Firebase


protocol MedicineRepository {
    func addMedicine(_ medicine: Medicine, user: String) async throws
    func updateMedicine(_ medicine: Medicine, user: String) async throws
    func deleteMedicine(at offsets: IndexSet) async throws
    func fetchMedicines(user: String) async throws -> [Medicine]
}

final class FirestoreMedicineRepository: MedicineRepository {
    
    private let db = Firestore.firestore()
    
    func addMedicine(_ medicine: Medicine, user: String) async throws {
        do {
            try db.collection("medicines")
                .document()
                .setData(from: medicine)
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func updateMedicine(_ medicine: Medicine, user: String) async throws {
        guard let id = medicine.id else {
            throw MedicineError.missingId
        }
        do {
            try await db.collection("medicines")
                .document(id)
                .setData(from: medicine, merge: true)
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func deleteMedicine(at offsets: IndexSet) async throws {
        do {
            let snapshot = try await db.collection("medicines").getDocuments()

            let documents = snapshot.documents

            for index in offsets {
                guard documents.indices.contains(index) else { continue }
                let documentId = documents[index].documentID
                try await db.collection("medicines")
                    .document(documentId)
                    .delete()
            }
        } catch {
            throw MedicineError.network(error)
        }
    }
    
    func fetchMedicines(user: String) async throws -> [Medicine] {
        do {
            let snapshot = try await db.collection("medicines").getDocuments()

            return snapshot.documents.compactMap {
                try? $0.data(as: Medicine.self)
            }
        } catch {
            throw MedicineError.network(error)
        }
    }
}
