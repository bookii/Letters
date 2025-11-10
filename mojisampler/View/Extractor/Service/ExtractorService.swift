//
//  ExtractorService.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/02.
//

import Foundation
import NaturalLanguage
import SwiftUI
import UIKit
import Vision

extension EnvironmentValues {
    @Entry var extractorService: ExtractorServiceProtocol = ExtractorService.shared
}

public protocol ExtractorServiceProtocol {
    func extractWords(from uiImage: UIImage) async throws -> [Word]
}

public final class ExtractorService: ExtractorServiceProtocol {
    public static let shared = ExtractorService()

    private init() {}

    public func extractWords(from uiImage: UIImage) async throws -> [Word] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { [weak self] request, _ in
                guard let self,
                      let observations = request.results as? [VNRecognizedTextObservation]
                else {
                    continuation.resume(returning: [])
                    return
                }

                let tokenizer = NLTokenizer(unit: .word)
                var words: [Word] = []
                for observation in observations {
                    guard let candidate = observation.topCandidates(1).first else {
                        continue
                    }
                    let text = candidate.string
                    tokenizer.string = text
                    tokenizer.enumerateTokens(in: text.startIndex ..< text.endIndex) { range, _ in
                        guard let box = try? candidate.boundingBox(for: range)?.boundingBox,
                              let letterImage = self.cropImage(uiImage, with: box),
                              let imageData = letterImage.jpegData(compressionQuality: 0.9)
                        else {
                            return true
                        }
                        words.append(.init(text: String(text[range]), imageData: imageData))
                        return true
                    }
                }
                continuation.resume(returning: words)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ja", "en"]
            request.usesLanguageCorrection = false
            request.minimumTextHeight = 0.1
            guard let cgImage = uiImage.cgImage else {
                continuation.resume(returning: [])
                return
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func cropImage(_ image: UIImage, with boundingBox: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let marginRatio: CGFloat = 0.05
        let expandedBox = boundingBox.insetBy(dx: -CGFloat(marginRatio) * boundingBox.width,
                                              dy: -CGFloat(marginRatio) * boundingBox.height)
        // VisionのboundingBoxは左下原点・正規化座標
        let rect = CGRect(x: expandedBox.origin.x * width,
                          y: (1 - expandedBox.origin.y - expandedBox.height) * height,
                          width: expandedBox.width * width,
                          height: expandedBox.height * height)
        guard let croppedCgImage = cgImage.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

#if DEBUG
    public final class MockExtractorService: ExtractorServiceProtocol {
        public static let shared = MockExtractorService()

        private init() {}

        public func extractWords(from _: UIImage) async throws -> [Word] {
            await Word.preloadMockWords()
            return Word.preloadedMockWords
        }
    }
#endif
