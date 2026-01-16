import SwiftUI

struct MedicineDetailView: View {
    @State var medicine: Medicine
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
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
        .onChange(of: medicine) {
            Task {
                await viewModel.updateMedicine(medicine, user: session.session?.uid ?? "")
            }
        }
        .alert("Souhaitez-vous supprimer ce médicament",
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
            HStack {
                Button(action: {
                    Task {
                        medicine.stock -= 1
                        await viewModel.decreaseStock(medicine, user: session.session?.uid ?? "")
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                TextField("Stock", value: $medicine.stock, formatter: NumberFormatter(), onCommit: {
                    Task {
                        await viewModel.updateMedicine(medicine, user: session.session?.uid ?? "")
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 100)
                Button(action: {
                    Task {
                        medicine.stock += 1
                        await viewModel.increaseStock(medicine, user: session.session?.uid ?? "")
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
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
            ForEach(viewModel.history.filter { $0.medicineId == medicine.id }, id: \.id) { entry in
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
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
        MedicineDetailView(medicine: sampleMedicine).environmentObject(SessionStore())
    }
}
