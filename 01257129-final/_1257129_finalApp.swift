//
//  _1257129_finalApp.swift
//  01257129-final
//
//  Created by user10 on 2025/11/26.
//

import SwiftUI

@main
struct _1257129_finalApp: App {
    @StateObject private var sharedData = SharedDataModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sharedData)
        }
    }
}
