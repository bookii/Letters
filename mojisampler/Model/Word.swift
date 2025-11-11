//
//  Word.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/02.
//

import Foundation
import SwiftData

@Model
public final class Word: Identifiable, Sendable {
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
