import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var medicineViewModel: MedicineStockViewModel

    var body: some View {
        Group {
            if session.session != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            session.listen()
        }
        .onDisappear {
            session.unbind()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionStore())
    }
}
