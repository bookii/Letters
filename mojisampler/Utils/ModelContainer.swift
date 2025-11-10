//
//  ModelContainer.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/10.
//

import Foundation
import SwiftData

public extension ModelContainer {
    #if DEBUG
        static let mockContainer: ModelContainer = {
            do {
                return try .init(for: Word.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            } catch {
                fatalError("Failed to init modelContainer: \(error)")
            }
        }()
    #endif
}
