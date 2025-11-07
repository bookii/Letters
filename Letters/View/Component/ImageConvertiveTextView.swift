//
//  ImageConvertiveTextView.swift
//  Letters
//
//  Created by mizznoff on 2025/11/03.
//

import Combine
import Foundation
import SwiftUI
import UIKit

public struct ImageConvertiveTextView: View {
    @Environment(\.storeRepository) private var storeRepository
    @Binding private var isFirstResponder: Bool

    public init(isFirstResponder: Binding<Bool>) {
        _isFirstResponder = isFirstResponder
    }

    public var body: some View {
        ImageConvertiveTextContentView(isFirstResponder: $isFirstResponder, storeRepository: storeRepository)
    }
}

private struct ImageConvertiveTextContentView: UIViewRepresentable {
    @StateObject fileprivate var viewModel: ImageConvertiveTextViewModel
    @Binding private var isFirstResponder: Bool

    fileprivate init(isFirstResponder: Binding<Bool>, storeRepository: StoreRepositoryProtocol) {
        _isFirstResponder = isFirstResponder
        _viewModel = .init(wrappedValue: .init(storeRepository: storeRepository))
    }

    fileprivate func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 24)
        textView.delegate = context.coordinator
        textView.attributedText = viewModel.fullAttributedText
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)

        let width = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.width ?? 0
        let toolbarFrame = CGRect(x: 0, y: 0, width: width, height: 44)
        let toolbar = UIToolbar(frame: toolbarFrame)
        let collectionView = viewModel.createWordCollectionView(frame: toolbarFrame)
        toolbar.addSubview(collectionView)
        textView.inputAccessoryView = toolbar

        context.coordinator.textView = textView
        context.coordinator.collectionView = collectionView

        return textView
    }

    fileprivate func updateUIView(_ uiView: UITextView, context _: Context) {
        Task { @MainActor in
            if isFirstResponder, !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isFirstResponder, uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    fileprivate class Coordinator: NSObject, UITextViewDelegate {
        fileprivate weak var textView: UITextView?
        fileprivate weak var collectionView: UICollectionView?
        private let parent: ImageConvertiveTextContentView
        private var cancellables = Set<AnyCancellable>()

        fileprivate init(_ parent: ImageConvertiveTextContentView) {
            self.parent = parent
            super.init()
            parent.viewModel.$fullAttributedText.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] newValue in
                guard let self, let textView = self.textView else {
                    return
                }
                if textView.attributedText != newValue {
                    textView.attributedText = newValue
                }
            }.store(in: &cancellables)
        }

        fileprivate func textViewDidChange(_ textView: UITextView) {
            parent.viewModel.updateFullAttributedText(textView.attributedText)
            if let markedTextRange = textView.markedTextRange, let markedText = textView.text(in: markedTextRange) {
                parent.viewModel.updateMarkedText(markedText)
                collectionView?.reloadData()
            }
        }

        fileprivate func textViewDidBeginEditing(_: UITextView) {
            parent.isFirstResponder = true
        }

        fileprivate func textViewDidEndEditing(_: UITextView) {
            parent.isFirstResponder = false
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var nsAttributedText = NSAttributedString(string: "")
        @Previewable @State var isFirstResponder = false

        ImageConvertiveTextView(isFirstResponder: $isFirstResponder)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(16)
            .background {
                Color.gray
                    .ignoresSafeArea()
            }
            .environment(\.storeRepository, MockStoreRepository.shared)
            .task {
                await Word.preloadMockWords()
            }
    }
#endif
