import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                AisleListView()
            }
            .tabItem {
                Image(systemName: "square.stack")
                Text("Aisles")
                    .accessibilityLabel("Rayons")
                    .accessibilityHint("Afficher la liste des rayons")
            }
            NavigationStack {
                AllMedicinesView()
            }
            .tabItem {
                Image(systemName: "pills")
                Text("All Medicines")
                    .accessibilityLabel("Tous les médicaments")
                    .accessibilityHint("Afficher tous les médicaments")
            }
        }
        .tint(.pink)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
