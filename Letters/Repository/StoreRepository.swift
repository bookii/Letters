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

public struct StoreSortCondition<Property: Comparable> {
    public enum Order {
        case asc
        case desc
    }

    let keyPath: KeyPath<Word, Property> & Sendable
    let order: Order

    public init(keyPath: KeyPath<Word, Property>, order: Order) {
        self.keyPath = keyPath
        self.order = order
    }
}

private extension StoreSortCondition {
    var sortDescriptor: SortDescriptor<Word> {
        let sortOrder: SortOrder = switch order {
        case .asc:
            .forward
        case .desc:
            .reverse
        }
        return SortDescriptor(keyPath, order: sortOrder)
    }
}

public protocol StoreRepositoryProtocol {
    var modelContainer: ModelContainer { get }
    func save(words: [Word])
    func fetchWords<Property: Comparable>(prefix: String?, sortBy sortConditions: [StoreSortCondition<Property>], limit: Int, offset: Int) throws -> [Word]
}

extension StoreRepositoryProtocol {
    func fetchWords<Property: Comparable>(prefix: String? = nil, sortBy sortConditions: [StoreSortCondition<Property>], limit: Int, offset: Int) throws -> [Word] {
        try fetchWords(prefix: prefix, sortBy: sortConditions, limit: limit, offset: offset)
    }
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

    public func fetchWords<Property: Comparable>(prefix: String? = nil, sortBy sortConditions: [StoreSortCondition<Property>], limit: Int, offset: Int) throws -> [Word] {
        var words = FetchDescriptor<Word>(
            predicate: #Predicate { prefix == nil || $0.text.starts(with: prefix!) },
            sortBy: sortConditions.map(\.sortDescriptor)
        )
        words.fetchLimit = limit
        words.fetchOffset = offset
        return try modelContext.fetch(words)
    }
}

#if DEBUG
    public final class MockStoreRepository: StoreRepositoryProtocol {
        public static let shared = MockStoreRepository()
        public let modelContainer: ModelContainer

        private init() {
            do {
                // TODO: 実装が一通り完了したら inStoredInMemoryOnly = false にする
                let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(for: Word.self, configurations: configuration)
            } catch {
                fatalError("Failed to initialize ModelContainer: \(error)")
            }
        }

        public func save(words _: [Word]) {
            // NOP
        }

        public func fetchWords<Property: Comparable>(prefix _: String? = nil, sortBy _: [StoreSortCondition<Property>], limit _: Int, offset _: Int) throws -> [Word] {
            Word.preloadedMockWords
        }
    }
#endif
