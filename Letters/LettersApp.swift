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

    public var body: some Scene {
        WindowGroup {
            NavigationRootView { path in
                IndexView(path: path)
            }
        }
        .modelContainer(StoreRepository.shared.modelContainer)
        .environment(\.analyzeRepository, AnalyzeRepository.shared)
        .environment(\.storeRepository, StoreRepository.shared)
    }
}
