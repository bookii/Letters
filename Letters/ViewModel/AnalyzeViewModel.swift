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

public final class AnalyzeViewModel: NSObject, ObservableObject {
    @Published public var letterImages: [UIImage]?
    private let uiImage: UIImage

    public init(uiImage: UIImage) {
        self.uiImage = uiImage
    }

    public func analyze() {
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let self = self else { return }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                letterImages = []
                return
            }

            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else {
                    continue
                }
                let tokenizer = NLTokenizer(unit: .word)
                tokenizer.string = candidate.string
                tokenizer.enumerateTokens(in: candidate.string.startIndex ..< candidate.string.endIndex) { range, _ in
                    guard let box = try? candidate.boundingBox(for: range)?.boundingBox,
                          let letterImage = self.cropImage(self.uiImage, with: box)
                    else {
                        return true
                    }
                    self.letterImages = (self.letterImages ?? []) + [letterImage]
                    return true
                }
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ja", "en"]
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.1
        guard let cgImage = uiImage.cgImage else {
            letterImages = []
            return
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            letterImages = []
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
