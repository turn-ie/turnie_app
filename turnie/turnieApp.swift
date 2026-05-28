//
//  turnieApp.swift
//  turnie
//
//  Created by 坂村空介 on 2025/11/03.
//

import SwiftUI
import SwiftData

@main
struct turnieApp: App {
    @StateObject private var bleManager = BLEManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
        }
    }
}
