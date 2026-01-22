import SwiftUI

struct AisleListView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var authSession: SessionStore
    @State private var showLogoutAlert: Bool = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Chargement des rayons…")
            } else {
                List {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        NavigationLink(destination: MedicineListView(aisle: aisle)) {
                            Text(aisle)
                                .accessibilityLabel("\(aisle)")
                                .accessibilityHint("Afficher les médicaments de ce rayon")
                        }
                    }
                }
            }
        }
        .navigationTitle("Aisles")
        .task {
            isLoading = true
            await viewModel.loadAisles()
            isLoading = false
        }
    }
}

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView()
            .environmentObject(MedicineStockViewModel(repository: FirestoreMedicineRepository()))
    }
}
