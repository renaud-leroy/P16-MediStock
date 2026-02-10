import SwiftUI

struct AllMedicinesView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var authSession: SessionStore

    @State private var stockFilter: StockFilter = .all
    @State private var showAddMedicineSheet = false
    @State private var showLogoutAlert = false
    @State private var isLoading: Bool = true

    var body: some View {
        VStack(spacing: 12) {
            Picker("Stock filter", selection: $stockFilter) {
                Text("All").tag(StockFilter.all)
                Text("In stock").tag(StockFilter.inStock)
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Filtrer les médicaments par disponibilité")
            .padding(.horizontal)

            TextField("Filter by name", text: $viewModel.searchText)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primary.opacity(0.25), lineWidth: 1)
                )
                .accessibilityLabel("Filtrer par nom de médicament")
                .padding(.horizontal)

            // MARK: - List
            VStack {
                Group {
                    if isLoading {
                        Spacer()
                        ProgressView("Medicine loading...")
                        Spacer()
                    } else {
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
                                        .accessibilityElement(children: .ignore)
                                        .accessibilityLabel("\(medicine.name), stock \(medicine.stock)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("All Medicines")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddMedicineSheet = true
                } label: {
                    Image(systemName: "plus")
                        .accessibilityLabel("Ajouter un médicament")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showLogoutAlert = true
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .accessibilityLabel("Se déconnecter")
                }
            }
        }
        .tint(.primary)
        .sheet(isPresented: $showAddMedicineSheet) {
            NavigationStack {
                AddMedicineView()
            }
            .tint(.primary)
        }
        .alert("Souhaitez-vous vous déconnecter ?",
               isPresented: $showLogoutAlert) {
            Button("Confirmer", role: .destructive) {
                authSession.signOut()
            }
            Button("Annuler", role: .cancel) { }
        }
        // MARK: - Data loading
        .task {
            isLoading = true
            await viewModel.loadMedicines()
            isLoading = false
        }
        .task(id: viewModel.searchText) {
            try? await Task.sleep(for: .milliseconds(300))
            await viewModel.loadMedicines()
        }
        .onChange(of: stockFilter) {
            viewModel.showOnlyInStock = (stockFilter == .inStock)
            Task { await viewModel.loadMedicines() }
        }
    }

    // MARK: - StockFilter

    enum StockFilter: String, CaseIterable, Identifiable {
        case all
        case inStock

        var id: String { rawValue }
    }
}
