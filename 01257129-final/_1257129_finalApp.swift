//
//  _1257129_finalApp.swift
//  01257129-final
//
//  Created by user10 on 2025/11/26.
//

import SwiftUI
import TipKit

@main
struct _1257129_finalApp: App {
    @StateObject private var sharedData = SharedDataModel()
    @State private var showMainView = false
        
        init() {
            // TipKit 設定
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showMainView {
                    // 主程式
                    ContentView()
                        .environmentObject(sharedData)
                        .transition(.opacity) // 淡入效果
                } else {
                    // 開場動畫
                    SplashScreenView(isActive: $showMainView)
                        .zIndex(1) // 確保在最上層
                }
            }
            .animation(.easeInOut(duration: 1.0), value: showMainView) // 頁面切換動畫
        }
    }
}
