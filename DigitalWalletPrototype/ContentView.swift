import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DigitalWalletView()
                .tabItem {
                    Label("Wallet", systemImage: "creditcard")
                }
            
            TrackingView()
                .tabItem {
                    Label("Where is?", systemImage: "location")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
