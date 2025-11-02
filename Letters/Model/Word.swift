//
//  Word.swift
//  Letters
//
//  Created by mizznoff on 2025/11/02.
//

import Foundation
import SwiftData

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
