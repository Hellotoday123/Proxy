//
//  ProxyApp.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-02-05.
//

import SwiftUI
import CoreData

@main
struct ProxyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
