//
//  ExtractorViewModel.swift
//  mojisampler
//
//  Created by mizznoff on 2025/10/30.
//

import Combine
import Foundation
import NaturalLanguage
import UIKit
import Vision

public final class ExtractorViewModel: ObservableObject {
    @Published public private(set) var words: [Word]?
    @Published public private(set) var error: Error?
    private let extractorService: ExtractorServiceProtocol
    private let storeService: StoreServiceProtocol

    public init(extractorService: ExtractorServiceProtocol, storeService: StoreServiceProtocol) {
        self.extractorService = extractorService
        self.storeService = storeService
    }

    public func extractWords(from uiImage: UIImage) async {
        do {
            let words = try await extractorService.extractWords(from: uiImage)
            await MainActor.run {
                self.words = words
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }

    public func save() {
        guard let words else {
            // TODO: throw error
            return
        }
        do {
            try storeService.save(words: words)
        } catch {
            self.error = error
        }
    }
}
