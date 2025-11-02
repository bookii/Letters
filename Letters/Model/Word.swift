//
//  Word.swift
//  Letters
//
//  Created by mizznoff on 2025/11/02.
//

import Foundation
import SwiftData
import UIKit

@Model
public final class Word: Identifiable, @unchecked Sendable {
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
        static func mockWords() async -> [Word] {
            return [
                .init(text: "コメント",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/0858cfe1d2a83b64af2ec52f4895df2c.png")!)!.jpegData(compressionQuality: 0.9)!),
                .init(text: "ほぼ",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/3133d8bcd099fcf471b7b50552071fd1.png")!)!.jpegData(compressionQuality: 0.9)!),
                .init(text: "全部",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/fe2753d9d3000dfc63f98facb01cfc4a.png")!)!.jpegData(compressionQuality: 0.9)!),
                .init(text: "読みます",
                      imageData: try! await UIImage(url: .init(string: "https://i.gyazo.com/55c90bba689a573792535c586c06efdf.png")!)!.jpegData(compressionQuality: 0.9)!),
            ]
        }
    #endif
}
