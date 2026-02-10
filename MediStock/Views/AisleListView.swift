import SwiftUI

struct AisleListView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var authSession: SessionStore
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Aisle loading…")
            } else {
                List {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        NavigationLink(destination: MedicineListView(aisle: aisle)) {
                            Text(aisle)
                                .accessibilityLabel(aisle)
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


