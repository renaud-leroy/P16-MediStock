//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Renaud Leroy on 15/01/2026.
//

import SwiftUI

enum AisleSelection: Hashable {
    case existing(String)
    case new
}

struct AddMedicineView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var stock: String = ""
    @State private var selectedAisle: AisleSelection = .new
    @State private var newAisle: String = ""


    var body: some View {
        Form {
            Section(header: Text("Médicament")) {
                TextField("Nom", text: $name)
                    .accessibilityLabel("Nom du médicament")
                TextField("Stock", text: $stock)
                    .keyboardType(.numberPad)
                    .accessibilityLabel("Quantité en stock")
                    .accessibilityHint("Saisir un nombre")
            }

            Section(header: Text("Allée")) {
                Picker("Allée", selection: $selectedAisle) {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        Text(aisle)
                            .tag(AisleSelection.existing(aisle))
                    }
                    Text("Nouvelle allée…")
                        .tag(AisleSelection.new)
                }
                .accessibilityLabel("Choisir une allée")
                if case .new = selectedAisle {
                    TextField("Nom de la nouvelle allée", text: $newAisle)
                        .accessibilityLabel("Nom de la nouvelle allée")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.secondary)
                .accessibilityLabel("Annuler")
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    addMedicine()
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(isFormValid ? .blue : .gray)
                .disabled(!isFormValid)
                .accessibilityLabel("Ajouter le médicament")
            }
        }
        .navigationTitle("Nouveau médicament")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let first = viewModel.aisles.first {
                selectedAisle = .existing(first)
            } else {
                selectedAisle = .new
            }
        }
    }

    // MARK: - Validation
    private var isFormValid: Bool {
        guard !name.isEmpty,
              let _ = Int(stock) else {
            return false
        }

        switch selectedAisle {
            case .existing:
                return true
            case .new:
                return !newAisle.isEmpty
            }
    }

    // MARK: - Action
    private func addMedicine() {
        guard let stockValue = Int(stock) else { return }

        let aisle: String
            switch selectedAisle {
            case .existing(let value):
                aisle = value
            case .new:
                aisle = newAisle
            }
        let medicine = Medicine(
            name: name,
            stock: stockValue,
            aisle: aisle
        )
        
        guard let user = session.session else { return }
        let userId = user.email ?? user.uid

        Task {
            await viewModel.addMedicine(medicine, user: userId)
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        AddMedicineView()
            .environmentObject(MedicineStockViewModel(repository: FirestoreMedicineRepository()))
    }
}
