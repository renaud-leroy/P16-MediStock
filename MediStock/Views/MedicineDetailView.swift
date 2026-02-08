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
                .accessibilityLabel("Chargement du médicament")
            }
        }
    }

    // MARK: - Content

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
                        guard let userId = session.session?.uid else { return }
                        Task {
                            await viewModel.saveChanges(
                                for: medicine,
                                name: editedName,
                                aisle: editedAisle,
                                stock: editedStock,
                                user: userId
                            )
                        }
                    }
                } label: {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil")
                    .accessibilityLabel(isEditing ? "Valider les modifications" : "Modifier le médicament")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                    .accessibilityLabel("Supprimer le médicament")
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

// MARK: - Sections

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
            .accessibilityLabel("Nom du médicament")
        }
    }

    private func medicineStockSection(_ medicine: Medicine) -> some View {
        VStack(alignment: .leading, spacing: 10 ) {
            Text("Stock")
                .font(.headline)

            HStack(spacing: 16) {
                if isEditing {
                    TextField("Stock", value: $editedStock, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .onAppear {
                            editedStock = medicine.stock
                        }
                        .accessibilityLabel("Modifier la quantité en stock")
                } else {
                    Text("\(medicine.stock)")
                        .font(.title2)
                        .accessibilityLabel("Stock actuel \(medicine.stock)")
                }
                Spacer()
            }
        }
    }

    private func medicineAisleSection(_ medicine: Medicine) -> some View {
        VStack(alignment: .leading) {
            Text("Aisle")
                .font(.headline)

            TextField("Aisle", text: $editedAisle)
            .textFieldStyle(.roundedBorder)
            .onAppear {
                editedAisle = medicine.aisle
            }
            .disabled(!isEditing)
            .opacity(isEditing ? 1 : 0.6)
            .accessibilityLabel("Rayon du médicament")
        }
    }

    // MARK: - History

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
                .accessibilityElement(children: .combine)
            }
        }
    }
}

