import SwiftUI

struct AllMedicinesView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var authSession: SessionStore

    @State private var stockFilter: StockFilter = .all
    @State private var showAddMedicineSheet = false
    @State private var showLogoutAlert = false

    var body: some View {
        VStack(spacing: 12) {
            Picker("Stock filter", selection: $stockFilter) {
                Text("All").tag(StockFilter.all)
                Text("In stock").tag(StockFilter.inStock)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            TextField("Filter by name", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List {
                ForEach(viewModel.medicines, id: \.id) { medicine in
                    if let id = medicine.id {
                        NavigationLink(destination: MedicineDetailView(medicineId: id)) {
                            VStack(alignment: .leading) {
                                Text(medicine.name)
                                    .font(.headline)
                                Text("Stock: \(medicine.stock)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadMedicines()
        }
        .onChange(of: viewModel.searchText) {
            Task { await viewModel.loadMedicines() }
        }
        .onChange(of: stockFilter) {
            viewModel.showOnlyInStock = (stockFilter == .inStock)
            Task { await viewModel.loadMedicines() }
        }
        .navigationTitle("All Medicines")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddMedicineSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showLogoutAlert = true
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .sheet(isPresented: $showAddMedicineSheet) {
            NavigationStack {
                AddMedicineView()
            }
        }
        .alert("Souhaitez-vous vous déconnecter ?",
               isPresented: $showLogoutAlert) {
            Button("Confirmer", role: .destructive) {
                authSession.signOut()
            }
            Button("Annuler", role: .cancel) { }
        }
    }
}

enum StockFilter: String, CaseIterable, Identifiable {
    case all
    case inStock

    var id: String { rawValue }
}

struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AllMedicinesView()
    }
}
