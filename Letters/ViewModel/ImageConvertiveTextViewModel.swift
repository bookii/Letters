//
//  ImageConvertiveTextViewModel.swift
//  Letters
//
//  Created by mizznoff on 2025/11/06.
//

import Combine
import Foundation
import SwiftUI
import UIKit

public final class ImageConvertiveTextViewModel: NSObject, ObservableObject {
    @Published public private(set) var fullAttributedText: NSAttributedString = .init(string: "")
    @Published public private(set) var error: Error?
    private var markedText: String = ""
    private var candidateWords: [Word] = []

    public var onReplaceMarkedTextWithImage: ((Word) -> Void)?

    fileprivate let cellIdentifier = "HorizontalWordCollectionViewCell"
    private let storeRepository: StoreRepositoryProtocol

    public init(storeRepository: StoreRepositoryProtocol) {
        self.storeRepository = storeRepository
    }

    public func createWordCollectionView(frame: CGRect) -> HorizontalWordCollectionView {
        let collectionView = HorizontalWordCollectionView(frame: frame)
        collectionView.register(HorizontalWordCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }

    public func updateFullAttributedText(_ attributedText: NSAttributedString) {
        fullAttributedText = attributedText
    }

    public func updateMarkedText(_ markedText: String) {
        self.markedText = markedText
        updateCandidateWords()
    }

    private func updateCandidateWords() {
        if markedText.isEmpty {
            candidateWords = []
        } else {
            do {
                candidateWords = try storeRepository.fetchWords(prefix: markedText, sortBy: [.init(keyPath: \.text, order: .desc)], limit: 10, offset: 0)
            } catch {
                candidateWords = []
                self.error = error
            }
        }
    }

    public func replaceMarkedTextWithImage(selectedWord: Word) {
        guard !markedText.isEmpty, let uiImage = UIImage(data: selectedWord.imageData) else {
            return
        }

        let mutableAttributedText = NSMutableAttributedString(attributedString: fullAttributedText)
        let fullText = mutableAttributedText.string
        guard let range = fullText.range(of: markedText, options: .backwards) else {
            return
        }

        let nsRange = NSRange(range, in: fullText)
        let attachment = NSTextAttachment()
        attachment.image = .init(data: selectedWord.imageData)

        let imageSize = uiImage.size
        let height: CGFloat = 32
        let scale = height / imageSize.height
        attachment.bounds = CGRect(x: 0, y: -8, width: imageSize.width * scale, height: height)

        let imageAttributedString = NSAttributedString(attachment: attachment)
        mutableAttributedText.replaceCharacters(in: nsRange, with: imageAttributedString)

        fullAttributedText = mutableAttributedText
    }
}

extension ImageConvertiveTextViewModel: UICollectionViewDataSource {
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        candidateWords.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HorizontalWordCollectionViewCell else {
            fatalError("Failed to cast cell")
        }
        let candidateWord = candidateWords[indexPath.row]
        cell.id = candidateWord.id
        cell.image = UIImage(data: candidateWord.imageData)
        return cell
    }
}

extension ImageConvertiveTextViewModel: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let word = candidateWords.first(where: { $0.id == candidateWords[indexPath.row].id }) else {
            return
        }
        replaceMarkedTextWithImage(selectedWord: word)
        candidateWords = []
        collectionView.reloadData()
    }
}
