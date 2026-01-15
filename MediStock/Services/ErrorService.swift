//
//  ErrorService.swift
//  MediStock
//
//  Created by Renaud Leroy on 15/01/2026.
//

import Foundation

enum MedicineError: LocalizedError {
    case missingId
    case network(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .missingId:
            return "Impossible de mettre à jour ce médicament (identifiant manquant)."
        case .network:
            return "Problème de connexion au serveur. Réessaie plus tard."
        case .unknown:
            return "Une erreur inconnue est survenue."
        }
    }
}
