//
//  ImageConvertiveTextView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/03.
//

import Combine
import Foundation
import SwiftUI
import UIKit

public struct ImageConvertiveTextView: View {
    @Environment(\.storeService) private var storeService
    private var onRenderImageAction: ((UIImage) -> Void)?
    @Binding private var isFirstResponder: Bool
    @Binding private var shouldRender: Bool

    public init(isFirstResponder: Binding<Bool>, shouldRender: Binding<Bool>) {
        _isFirstResponder = isFirstResponder
        _shouldRender = shouldRender
    }

    public var body: some View {
        ImageConvertiveTextContentView(isFirstResponder: $isFirstResponder, shouldRender: $shouldRender, storeService: storeService)
            .onRenderImage { uiImage in
                onRenderImageAction?(uiImage)
            }
    }

    public func onRenderImage(perform action: @escaping (UIImage) -> Void) -> Self {
        var view = self
        view.onRenderImageAction = action
        return view
    }
}

private struct ImageConvertiveTextContentView: UIViewRepresentable {
    private var onRenderImageAction: ((UIImage) -> Void)?
    @StateObject fileprivate var viewModel: ImageConvertiveTextViewModel
    @Binding private var isFirstResponder: Bool
    @Binding private var shouldRender: Bool

    fileprivate init(isFirstResponder: Binding<Bool>, shouldRender: Binding<Bool>, storeService: StoreServiceProtocol) {
        _isFirstResponder = isFirstResponder
        _shouldRender = shouldRender
        _viewModel = .init(wrappedValue: .init(storeService: storeService))
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

    fileprivate func updateUIView(_ uiView: UITextView, context: Context) {
        Task { @MainActor in
            if isFirstResponder, !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isFirstResponder, uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
        if shouldRender {
            if let uiImage = context.coordinator.render() {
                onRenderImageAction?(uiImage)
            }
            Task { @MainActor in
                shouldRender = false
            }
        }
    }

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    fileprivate func onRenderImage(perform action: @escaping (UIImage) -> Void) -> Self {
        var view = self
        view.onRenderImageAction = action
        return view
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
                    textView.font = .systemFont(ofSize: 24)
                }
            }.store(in: &cancellables)
        }

        fileprivate func render() -> UIImage? {
            guard let textView else {
                return nil
            }
            let selectedTextRange = textView.selectedTextRange
            textView.selectedTextRange = nil
            let width = textView.bounds.width
            let height = textView.sizeThatFits(.init(width: width, height: .greatestFiniteMagnitude)).height
            let render = UIGraphicsImageRenderer(size: .init(width: width, height: height))
            let image = render.image { context in
                textView.layer.render(in: context.cgContext)
                textView.selectedTextRange = selectedTextRange
            }
            return image
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
        @Previewable @State var shouldRender = false

        ImageConvertiveTextView(isFirstResponder: $isFirstResponder, shouldRender: $shouldRender)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(16)
            .background {
                Color.gray
                    .ignoresSafeArea()
            }
            .environment(\.storeService, MockStoreService.shared)
            .task {
                await Word.preloadMockWords()
            }
    }
#endif
