//
//  TextEditorViewModel.swift
//  Letters
//
//  Created by mizznoff on 2025/11/06.
//

import Combine
import Foundation
import SwiftUI

public final class TextEditorViewModel: NSObject, ObservableObject {
    @Published public private(set) var words: [Word]?
    @Published public private(set) var error: Error?
    
    // TODO: 動作確認が完了したら 20 ぐらいの適切な値にしておく
    private let limit: Int = 2
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
