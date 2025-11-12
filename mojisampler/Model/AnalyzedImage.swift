//
//  AnalyzedImage.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/11.
//

import Foundation
import SwiftData
import UIKit

@Model
public final class AnalyzedImage: Identifiable, Sendable {
    @Attribute(.unique) public private(set) var id: UUID
    public private(set) var createdAt: Date
    public var words: [Word] {
        get {
            wordsPersistent.sorted { $0.indexInAnalyzedImage < $1.indexInAnalyzedImage }
        }
        set {
            wordsPersistent = newValue
        }
    }

    @Relationship(deleteRule: .cascade) private var wordsPersistent: [Word]

    public init(id: UUID = .init(), createdAt: Date = .init(), words: [Word]) {
        self.id = id
        self.createdAt = createdAt
        wordsPersistent = words
    }
}

public extension AnalyzedImage {
    #if DEBUG
        nonisolated(unsafe) static var preloadedMockAnalyzedImage: AnalyzedImage?

        static func preloadMockAnalyzedImage() async {
            await Word.preloadMockWords()
            preloadedMockAnalyzedImage = .init(words: Word.preloadedMockWords)
        }
    #endif
}
