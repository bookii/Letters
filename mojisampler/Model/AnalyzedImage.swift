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
        wordsPersistent.sorted { $0.indexInAnalyzedImage < $1.indexInAnalyzedImage }
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
        private struct UnstructuredWord {
            let text: String
            let imageURL: URL
        }

        static var preloadedMockAnalyzedImage: AnalyzedImage?

        static func preloadMockAnalyzedImage() async {
            if preloadedMockAnalyzedImage == nil {
                let unstructuredWords: [UnstructuredWord] = [
                    .init(text: "コメント", imageURL: .init(string: "https://i.gyazo.com/9d49450a3a24b0e7bf1ac1617c577bb0.png")!),
                    .init(text: "ほぼ", imageURL: .init(string: "https://i.gyazo.com/74a97a6d90825636b2ee1a49b1d2e8e3.png")!),
                    .init(text: "全部", imageURL: .init(string: "https://i.gyazo.com/e94048ab44be8f17ef37a60e9581dd29.png")!),
                    .init(text: "読みます", imageURL: .init(string: "https://i.gyazo.com/323175cb4113ff92e930b9f1a6c93ab5.png")!),
                ]
                var words: [Word] = []
                for index in unstructuredWords.indices {
                    let unstructuredWord = unstructuredWords[index]

                    do {
                        if let image = try await UIImage(url: unstructuredWord.imageURL),
                           let imageData = image.jpegData(compressionQuality: 0.9)
                        {
                            words.append(.init(text: unstructuredWord.text, imageData: imageData, indexInAnalyzedImage: index))
                        }
                    } catch {
                        continue
                    }
                }
                preloadedMockAnalyzedImage = .init(words: words)
            }
        }
    #endif
}
