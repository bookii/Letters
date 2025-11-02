//
//  StoreRepository.swift
//  Letters
//
//  Created by mizznoff on 2025/11/02.
//

import Foundation
import SwiftData
import SwiftUI

extension EnvironmentValues {
    @Entry var storeRepository: StoreRepositoryProtocol = StoreRepository.shared
}

public protocol StoreRepositoryProtocol {
    var modelContainer: ModelContainer { get }
    func save(words: [Word])
}

public final class StoreRepository: StoreRepositoryProtocol {
    public static let shared = StoreRepository()
    public let modelContainer: ModelContainer
    private var modelContext: ModelContext {
        // ref: https://stackoverflow.com/questions/79195801/swiftdata-unit-testing-exc-breakpoint-on-insert
        modelContainer.mainContext
    }

    private init() {
        do {
            // TODO: 実装が一通り完了したら inStoredInMemoryOnly = false にする
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            modelContainer = try ModelContainer(for: Word.self, configurations: configuration)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    public func save(words: [Word]) {
        for word in words {
            modelContext.insert(word)
        }
    }
}
