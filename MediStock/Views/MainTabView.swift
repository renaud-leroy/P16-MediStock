import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                AisleListView()
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("Aisles")
                    .accessibilityLabel("Rayons")
                    .accessibilityHint("Afficher la liste des rayons")
                
            }
            NavigationStack {
                AllMedicinesView()
            }
            .tabItem {
                Image(systemName: "square.grid.2x2")
                Text("All Medicines")
                    .accessibilityLabel("Tous les médicaments")
                    .accessibilityHint("Afficher tous les médicaments")
                
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
