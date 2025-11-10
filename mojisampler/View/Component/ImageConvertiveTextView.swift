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

public struct ImageConvertiveTextView: UIViewRepresentable {
    @Binding private var isFirstResponder: Bool
    @Binding private var shouldRender: Bool
    @State private var fullAttributedText: NSAttributedString = .init(string: "")
    fileprivate var onReceiveErrorAction: ((Error) -> Void)?
    private var onRenderImageAction: ((UIImage) -> Void)?

    public init(isFirstResponder: Binding<Bool>, shouldRender: Binding<Bool>) {
        _isFirstResponder = isFirstResponder
        _shouldRender = shouldRender
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 24)
        textView.delegate = context.coordinator
        textView.attributedText = fullAttributedText
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)

        let width = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.width ?? 0
        let toolbarFrame = CGRect(x: 0, y: 0, width: width, height: 44)
        let toolbar = UIToolbar(frame: toolbarFrame)
        let collectionView = HorizontalWordCollectionView(frame: toolbarFrame)
        toolbar.addSubview(collectionView)
        textView.inputAccessoryView = toolbar

        context.coordinator.textView = textView
        context.coordinator.collectionView = collectionView

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
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

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func onRenderImage(perform action: @escaping (UIImage) -> Void) -> Self {
        var view = self
        view.onRenderImageAction = action
        return view
    }

    public func onReceiveError(perform action: @escaping (Error) -> Void) -> Self {
        var view = self
        view.onReceiveErrorAction = action
        return view
    }

    public class Coordinator: NSObject {
        fileprivate weak var textView: UITextView?
        fileprivate weak var collectionView: HorizontalWordCollectionView? {
            didSet {
                collectionView?.horizontalWordCollectionViewDelegate = self
            }
        }

        private let parent: ImageConvertiveTextView

        fileprivate init(_ parent: ImageConvertiveTextView) {
            self.parent = parent
            super.init()
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
    }
}

extension ImageConvertiveTextView.Coordinator: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        collectionView?.fullAttributedText = textView.attributedText
        if let markedTextRange = textView.markedTextRange, let markedText = textView.text(in: markedTextRange) {
            collectionView?.markedText = markedText
        }
    }

    public func textViewDidBeginEditing(_: UITextView) {
        parent.isFirstResponder = true
    }

    public func textViewDidEndEditing(_: UITextView) {
        parent.isFirstResponder = false
    }
}

extension ImageConvertiveTextView.Coordinator: HorizontalWordCollectionViewDelegate {
    public func horizontalWordCollectionView(_: HorizontalWordCollectionView, shouldReplace markedText: String, with uiImage: UIImage) {
        guard let attributedText = textView?.attributedText else {
            return
        }
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let fullText = mutableAttributedText.string
        guard let range = fullText.range(of: markedText, options: .backwards) else {
            return
        }

        let nsRange = NSRange(range, in: fullText)
        let attachment = NSTextAttachment()
        attachment.image = uiImage

        let imageSize = uiImage.size
        let height: CGFloat = 32
        let scale = height / imageSize.height
        attachment.bounds = CGRect(x: 0, y: -8, width: imageSize.width * scale, height: height)

        let imageAttributedString = NSAttributedString(attachment: attachment)
        mutableAttributedText.replaceCharacters(in: nsRange, with: imageAttributedString)

        textView?.attributedText = mutableAttributedText
        textView?.font = .systemFont(ofSize: 24)
    }

    public func horizontalWordCollectionView(_: HorizontalWordCollectionView, didReceive error: Error) {
        parent.onReceiveErrorAction?(error)
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
            .task {
                await Word.preloadMockWords()
            }
    }
#endif
