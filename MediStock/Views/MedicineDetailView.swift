import SwiftUI

struct MedicineDetailView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    @State var editedStock: Int = 0
    @State var isEditingStock: Bool = false
    @State var medicine: Medicine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text(medicine.name)
                .font(.largeTitle)
            // Medicine Name
            medicineNameSection
            
            // Medicine Stock
            medicineStockSection
            
            // Medicine Aisle
            medicineAisleSection
            
            // History Section
            ScrollView {
                historySection
            }
        }
        .padding()
        .navigationBarTitle("Medicine Details", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .task {
            guard let id = medicine.id else { return }
            await viewModel.loadHistory(for: id)
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
            Text("Attention cette action est définitive.")
        }
    }
}

extension MedicineDetailView {
    private var medicineNameSection: some View {
        VStack(alignment: .leading) {
            Text("Name")
                .font(.headline)
            TextField("Name", text: $medicine.name, onCommit: {
                Task {
                    await viewModel.updateMedicine(medicine, user: session.session?.uid ?? "")
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var medicineStockSection: some View {
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
                        // Validation → envoi au ViewModel puis reload
                        Task {
                            let finalStock = max(0, editedStock)
                            await viewModel.updateStock(
                                medicine,
                                to: finalStock,
                                user: session.session?.uid ?? ""
                            )
                        }
                    } else {
                        // Entrée en mode édition
                        editedStock = medicine.stock
                    }

                    isEditingStock.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var medicineAisleSection: some View {
        VStack(alignment: .leading) {
            Text("Aisle")
                .font(.headline)
            TextField("Aisle", text: $medicine.aisle, onCommit: {
                Task {
                    await viewModel.updateMedicine(medicine, user: session.session?.uid ?? "")
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading) {
            Text("History")
                .font(.headline)
                .padding(.top, 20)
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


