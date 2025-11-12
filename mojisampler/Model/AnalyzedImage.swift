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
public final class AnalyzedImage: Identifiable, @unchecked Sendable {
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
        private nonisolated(unsafe) static var _mockAnalyzedImage: AnalyzedImage?
        static func mockAnalyzedImage() async -> AnalyzedImage {
            if let _mockAnalyzedImage {
                return _mockAnalyzedImage
            }
            let analyzedImage = await AnalyzedImage(words: Word.mockWords())
            _mockAnalyzedImage = analyzedImage
            return analyzedImage
        }
    #endif
}
