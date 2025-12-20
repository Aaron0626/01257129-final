import SwiftUI
import TipKit

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1: 自創角色
            CharacterCreatorView()
                .tabItem {
                    Label("創生之座", systemImage: "sparkles")
                }
            
            // Tab 2: 聖遺物鑑定
            ArtifactScannerView()
                .tabItem {
                    Label("聖遺物鑑定", systemImage: "bonjour")
                }
            
            // Tab 3: 戰術模擬
            TacticalSimView()
                .tabItem {
                    Label("幽境危戰", systemImage: "shield.righthalf.filled")
                }
        }
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SharedDataModel())
}
