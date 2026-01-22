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
    @State private var isEditing = false

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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditing.toggle()
                    isEditingStock = false
                    if !isEditing {
                        Task {
                            var updated = medicine
                            updated.name = editedName
                            updated.aisle = editedAisle

                            await viewModel.updateMedicine(
                                updated,
                                user: session.session?.uid ?? ""
                            )

                            let finalStock = max(0, editedStock)
                            await viewModel.updateStock(
                                updated,
                                to: finalStock,
                                user: session.session?.uid ?? ""
                            )
                        }
                    }
                } label: {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
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

            TextField("Name", text: $editedName)
            .textFieldStyle(.roundedBorder)
            .onAppear {
                editedName = medicine.name
            }
            .disabled(!isEditing)
            .opacity(isEditing ? 1 : 0.6)
        }
    }

    private func medicineStockSection(_ medicine: Medicine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Stock")
                .font(.headline)

            HStack(spacing: 16) {
                if isEditing {
                    Picker("Stock", selection: $editedStock) {
                        ForEach(0...500, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .onAppear {
                        editedStock = medicine.stock
                    }
                } else {
                    Text("\(medicine.stock)")
                        .font(.title2)
                }
                Spacer()
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
            .disabled(!isEditing)
            .opacity(isEditing ? 1 : 0.6)
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
