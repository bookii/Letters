//
//  LettersApp.swift
//  Letters
//
//  Created by mizznoff on 2025/10/27.
//

import SwiftData
import SwiftUI

@main
public struct LettersApp: App {
    public init() {}

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    public var body: some Scene {
        WindowGroup {
            NavigationRootView { path in
                IndexView(path: path)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
