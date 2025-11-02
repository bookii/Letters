//
//  AnalyzeViewModel.swift
//  Letters
//
//  Created by mizznoff on 2025/10/30.
//

import Combine
import Foundation
import NaturalLanguage
import UIKit
import Vision

public final class AnalyzeViewModel: ObservableObject {
    @Published public private(set) var words: [Word]?
    @Published public private(set) var error: Error?
    private let analyzeRepository: AnalyzeRepositoryProtocol

    public init(analyzeRepository: AnalyzeRepositoryProtocol) {
        self.analyzeRepository = analyzeRepository
    }

    public func analyzeIntoWords(uiImage: UIImage) {
        Task.detached { [weak self] in
            guard let self else {
                return
            }
            do {
                let words = try await analyzeRepository.analyzeIntoWords(uiImage: uiImage)
                Task { @MainActor in
                    self.words = words
                }
            } catch {
                Task { @MainActor in
                    self.error = error
                }
            }
        }
    }
}
