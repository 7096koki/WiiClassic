//
//  WiiClassicApp.swift
//  Shared
//
//  Created by あんどうこうき on 2025/08/16.
//

import SwiftUI

@main
struct WiiClassicApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            WiiMenu()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
