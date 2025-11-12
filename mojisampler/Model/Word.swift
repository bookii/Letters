//
//  Word.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/02.
//

import Foundation
import SwiftData
import UIKit

@Model
public final class Word: Identifiable, @unchecked Sendable {
    @Attribute(.unique) public private(set) var id: UUID
    public private(set) var text: String
    public private(set) var imageData: Data
    public private(set) var indexInAnalyzedImage: Int

    public init(id: UUID = .init(), text: String, imageData: Data, indexInAnalyzedImage: Int) {
        self.id = id
        self.text = text
        self.imageData = imageData
        self.indexInAnalyzedImage = indexInAnalyzedImage
    }
}

public extension Word {
    #if DEBUG
        private struct UnstructuredWord {
            let text: String
            let imageURL: URL
        }

        static var preloadedMockWords: [Word] {
            _preloadedMockWords ?? []
        }

        private nonisolated(unsafe) static var _preloadedMockWords: [Word]?

        static func preloadMockWords() async {
            if _preloadedMockWords == nil {
                _preloadedMockWords = await loadMockWords()
            }
        }

        private static func loadMockWords() async -> [Word] {
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
            return words
        }
    #endif
}
