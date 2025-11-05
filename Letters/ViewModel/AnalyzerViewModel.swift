//
//  AnalyzerViewModel.swift
//  Letters
//
//  Created by mizznoff on 2025/10/30.
//

import Combine
import Foundation
import NaturalLanguage
import UIKit
import Vision

public final class AnalyzerViewModel: ObservableObject {
    @Published public private(set) var words: [Word]?
    @Published public private(set) var error: Error?
    private let analyzerRepository: AnalyzerRepositoryProtocol
    private let storeRepository: StoreRepositoryProtocol

    public init(analyzerRepository: AnalyzerRepositoryProtocol, storeRepository: StoreRepositoryProtocol) {
        self.analyzerRepository = analyzerRepository
        self.storeRepository = storeRepository
    }

    public func analyzeIntoWords(uiImage: UIImage) {
        Task {
            do {
                let words = try await analyzerRepository.analyzeIntoWords(uiImage: uiImage)
                await MainActor.run {
                    self.words = words
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }

    public func save() {
        guard let words else {
            // TODO: throw error
            return
        }
        do {
            try storeRepository.save(words: words)
        } catch {
            self.error = error
        }
    }
}
