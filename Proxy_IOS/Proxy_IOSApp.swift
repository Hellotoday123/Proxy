//
//  Proxy_IOSApp.swift
//  Proxy_IOS
//
//  Created by user285973 on 2/8/26.
//

import SwiftUI

@main
struct Proxy_IOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
