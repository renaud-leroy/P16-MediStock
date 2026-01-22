//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Renaud Leroy on 15/01/2026.
//

import SwiftUI

struct AddMedicineView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var stock: String = ""
    @State private var selectedAisle: String = ""
    @State private var newAisle: String = ""

    private let newAisleTag = "__NEW_AISLE__"

    var body: some View {
        Form {
            // MARK: - Medicine
            Section(header: Text("Médicament")) {
                TextField("Nom", text: $name)
                    .accessibilityLabel("Nom du médicament")
                TextField("Stock", text: $stock)
                    .keyboardType(.numberPad)
                    .accessibilityLabel("Quantité en stock")
                    .accessibilityHint("Saisir un nombre")
            }

            // MARK: - Aisle
            Section(header: Text("Allée")) {
                Picker("Allée", selection: $selectedAisle) {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        Text(aisle).tag(aisle)
                    }
                    Text("Nouvelle allée…").tag(newAisleTag)
                }
                .accessibilityLabel("Choisir une allée")
                if selectedAisle == newAisleTag {
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
                .accessibilityLabel("Annuler")
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    addMedicine()
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
                .accessibilityLabel("Ajouter le médicament")
            }
        }
        .navigationTitle("Nouveau médicament")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedAisle.isEmpty {
                selectedAisle = viewModel.aisles.first ?? newAisleTag
            }
        }
    }

    // MARK: - Validation
    private var isFormValid: Bool {
        guard !name.isEmpty,
              let _ = Int(stock) else {
            return false
        }

        if selectedAisle == newAisleTag {
            return !newAisle.isEmpty
        }

        return !selectedAisle.isEmpty
    }

    // MARK: - Action
    private func addMedicine() {
        guard let stockValue = Int(stock) else { return }

        let aisle = selectedAisle == newAisleTag
        ? newAisle
        : selectedAisle

        let medicine = Medicine(
            name: name,
            stock: stockValue,
            aisle: aisle
        )

        Task {
            await viewModel.addMedicine(medicine)
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
