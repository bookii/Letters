//
//  LettersApp.swift
//  Letters
//
//  Created by mizznoff on 2025/10/27.
//

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
        .environment(\.analyzerRepository, AnalyzerRepository.shared)
        .environment(\.storeRepository, StoreRepository.shared)
    }
}
