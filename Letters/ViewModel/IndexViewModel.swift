//
//  IndexViewModel.swift
//  Letters
//
//  Created by mizznoff on 2025/10/29.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI
import UIKit

public final class IndexViewModel: NSObject, ObservableObject {
    @Published public private(set) var words: [Word]? {
        didSet {
            lettersCount = words?.reduce(0, { sum, word in
                sum + word.text.count
            })
        }
    }
    @Published public private(set) var lettersCount: Int?
    @Published public private(set) var error: Error?
    @Published public var uiImage: UIImage?

    @Published public var pickerItem: PhotosPickerItem? {
        didSet {
            guard let pickerItem else {
                uiImage = nil
                return
            }
            pickerItem.loadTransferable(type: Data.self) { result in
                Task { @MainActor in
                    guard pickerItem == self.pickerItem else {
                        return
                    }
                    switch result {
                    case let .success(data):
                        if let data, let uiImage = UIImage(data: data) {
                            self.uiImage = uiImage
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    // TODO: 動作確認が完了したら 20 ぐらいの適切な値にしておく
    private let limit: Int = 20
    private var offset: Int = 0
    private var hasNoMoreWords: Bool = false
    private let storeRepository: StoreRepositoryProtocol

    public init(storeRepository: StoreRepositoryProtocol) {
        self.storeRepository = storeRepository
    }

    public func reloadWords() {
        do {
            hasNoMoreWords = false
            offset = 0
            let fetchedWords = try storeRepository.fetchWords(sortBy: [.init(keyPath: \.createdAt, order: .desc)], limit: limit, offset: offset)
            words = fetchedWords
            offset += limit
            if fetchedWords.isEmpty {
                hasNoMoreWords = true
            }
        } catch {
            self.error = error
        }
    }

    public func loadMoreWords() {
        do {
            if hasNoMoreWords {
                return
            }
            let fetchedWords = try storeRepository.fetchWords(sortBy: [.init(keyPath: \.createdAt, order: .desc)], limit: limit, offset: offset)
            words = (words ?? []) + fetchedWords
            offset += limit
            if fetchedWords.isEmpty {
                hasNoMoreWords = true
            }
        } catch {
            self.error = error
        }
    }
}
