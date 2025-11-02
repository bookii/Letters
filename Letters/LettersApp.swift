//
//  LettersApp.swift
//  Letters
//
//  Created by mizznoff on 2025/10/27.
//

import SwiftUI
import SwiftData

@main
public struct LettersApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            NavigationRootView { path in
                IndexView(path: path)
            }
        }
        .modelContainer(LettersModelContainer.shared)
    }
}
