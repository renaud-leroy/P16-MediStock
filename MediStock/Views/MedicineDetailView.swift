import SwiftUI

struct MedicineDetailView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteAlert = false
    @State private var editedStock: Int = 0
    @State private var editedName: String = ""
    @State private var editedAisle: String = ""
    @State private var isEditingStock = false

    let medicineId: String

    private var medicine: Medicine? {
        viewModel.medicines.first { $0.id == medicineId }
    }

    var body: some View {
        Group {
            if let medicine {
                content(medicine)
            } else {
                ProgressView()
            }
        }
    }

    private func content(_ medicine: Medicine) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            Text(medicine.name)
                .font(.largeTitle)

            medicineNameSection(medicine)
            medicineStockSection(medicine)
            medicineAisleSection(medicine)

            Text("History")
                .font(.headline)

            ScrollView {
                historySection
            }
        }
        .padding()
        .navigationTitle("Medicine Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .task {
            await viewModel.loadHistory(for: medicineId)
        }
        .alert("Souhaitez-vous supprimer ce médicament ?",
               isPresented: $showDeleteAlert) {
            Button("Confirmer", role: .destructive) {
                Task {
                    await viewModel.deleteMedicine(medicine)
                    dismiss()
                }
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Attention, cette action est définitive.")
        }
    }
}

extension MedicineDetailView {

    private func medicineNameSection(_ medicine: Medicine) -> some View {
        VStack(alignment: .leading) {
            Text("Name")
                .font(.headline)

            TextField("Name", text: $editedName, onCommit: {
                Task {
                    var updated = medicine
                    updated.name = editedName
                    await viewModel.updateMedicine(updated, user: session.session?.uid ?? "")
                }
            })
            .textFieldStyle(.roundedBorder)
            .onAppear {
                editedName = medicine.name
            }
        }
    }

    private func medicineStockSection(_ medicine: Medicine) -> some View {
        VStack(alignment: .leading) {
            Text("Stock")
                .font(.headline)

            HStack(spacing: 16) {
                if isEditingStock {
                    Picker("Stock", selection: $editedStock) {
                        ForEach(0...500, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                } else {
                    Text("\(medicine.stock)")
                        .font(.title2)
                }

                Spacer()

                Button(isEditingStock ? "Valider" : "Modifier") {
                    if isEditingStock {
                        Task {
                            let finalStock = max(0, editedStock)
                            await viewModel.updateStock(
                                medicine,
                                to: finalStock,
                                user: session.session?.uid ?? ""
                            )
                        }
                    } else {
                        editedStock = medicine.stock
                    }
                    isEditingStock.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func medicineAisleSection(_ medicine: Medicine) -> some View {
        VStack(alignment: .leading) {
            Text("Aisle")
                .font(.headline)

            TextField("Aisle", text: $editedAisle, onCommit: {
                Task {
                    var updated = medicine
                    updated.aisle = editedAisle
                    await viewModel.updateMedicine(updated,
                                                   user: session.session?.uid ?? "")
                }
            })
            .textFieldStyle(.roundedBorder)
            .onAppear {
                editedAisle = medicine.aisle
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.history, id: \.timestamp) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.action)
                        .font(.headline)
                    Text("User: \(entry.user)")
                        .font(.subheadline)
                    Text("Date: \(entry.timestamp.formatted())")
                        .font(.subheadline)
                    Text("Details: \(entry.details)")
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
}
