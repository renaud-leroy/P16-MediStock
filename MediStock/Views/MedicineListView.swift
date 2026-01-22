import SwiftUI

struct MedicineListView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    
    var aisle: String

    var body: some View {
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                if let id = medicine.id {
                    NavigationLink(destination: MedicineDetailView(medicineId: id)) {
                        VStack(alignment: .leading) {
                            Text(medicine.name)
                                .font(.headline)
                            Text("Stock: \(medicine.stock)")
                                .font(.subheadline)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(medicine.name), stock \(medicine.stock)")
                        .accessibilityHint("Afficher les détails du médicament")
                    }
                }
            }
        }
        .navigationBarTitle(aisle)
        .onAppear {
            Task {
                await viewModel.loadMedicines()
            }
        }
    }
}

struct MedicineListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicineListView(aisle: "Aisle 1").environmentObject(SessionStore())
    }
}
