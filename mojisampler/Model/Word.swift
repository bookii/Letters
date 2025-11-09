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
    // TODO: 画像内の順番を維持できるように画像単位で保存する
    @Attribute(.unique) public private(set) var id: UUID
    public private(set) var createdAt: Date
    public private(set) var text: String
    public private(set) var imageData: Data

    public init(id: UUID = .init(), createdAt: Date = .now, text: String, imageData: Data) {
        self.id = id
        self.createdAt = createdAt
        self.text = text
        self.imageData = imageData
    }
}

public extension Word {
    #if DEBUG
        static var preloadedMockWords: [Word] {
            _preloadedMockWords ?? []
        }

        private static var _preloadedMockWords: [Word]?

        static func preloadMockWords() async {
            if _preloadedMockWords == nil {
                _preloadedMockWords = await loadMockWords()
            }
        }

        private static func loadMockWords() async -> [Word] {
            return [
                .init(text: "コメント",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/9d49450a3a24b0e7bf1ac1617c577bb0.png")!)!.jpegData(compressionQuality: 0.9)!),
                .init(text: "ほぼ",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/74a97a6d90825636b2ee1a49b1d2e8e3.png")!)!.jpegData(compressionQuality: 0.9)!),
                .init(text: "全部",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/e94048ab44be8f17ef37a60e9581dd29.png")!)!.jpegData(compressionQuality: 0.9)!),
                .init(text: "読みます",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/323175cb4113ff92e930b9f1a6c93ab5.png")!)!.jpegData(compressionQuality: 0.9)!),
            ]
        }
    #endif
}
