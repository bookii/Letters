//
//  ModelContainer.swift
//  Letters
//
//  Created by mizznoff on 2025/11/02.
//

import Foundation
import SwiftData

public final class LettersModelContainer {
    public static let shared: ModelContainer = {
        let schema = Schema([
            Word.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private init() {}
}
