//
//  TextViewRepresentable.swift
//  Letters
//
//  Created by mizznoff on 2025/11/03.
//

import Foundation
import SwiftUI
import UIKit

public struct TextViewRepresentable: UIViewRepresentable {
    private var onKeyboardToolbarLastWordAppearAction: (() -> Void)?
    @Binding private var nsAttributedText: NSAttributedString
    @Binding private var isFirstResponder: Bool

    public init(nsAttributedText: Binding<NSAttributedString>, isFirstResponder: Binding<Bool>) {
        _nsAttributedText = nsAttributedText
        _isFirstResponder = isFirstResponder
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.attributedText = nsAttributedText
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.textContainerInset = .init(top: 16, left: 8, bottom: 16, right: 8)
        
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: textView.frame.size.width, height: 44))
        let label = UILabel(frame: .init(x: 0, y: 0, width: textView.frame.size.width, height: 44))
        label.text = "test"
        toolbar.addSubview(label)
        textView.inputAccessoryView = toolbar

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context _: Context) {
        if uiView.attributedText != nsAttributedText {
            uiView.attributedText = nsAttributedText
        }

        Task { @MainActor in
            if isFirstResponder, !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isFirstResponder, uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        private let parent: TextViewRepresentable

        fileprivate init(_ parent: TextViewRepresentable) {
            self.parent = parent
        }

        public func textViewDidChange(_ textView: UITextView) {
            parent.nsAttributedText = textView.attributedText
        }

        public func textViewDidBeginEditing(_: UITextView) {
            parent.isFirstResponder = true
        }

        public func textViewDidEndEditing(_: UITextView) {
            parent.isFirstResponder = false
        }
    }
    
    // MARK: - ViewModifier
    
    public func onKeyboardToolbarLastWordAppear(perform action: @escaping () -> Void) -> Self {
        var view = self
        view.onKeyboardToolbarLastWordAppearAction = action
        return view
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var nsAttributedText = NSAttributedString(string: "")
        @Previewable @State var isFirstResponder = false

        TextViewRepresentable(nsAttributedText: $nsAttributedText, isFirstResponder: $isFirstResponder)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(16)
            .background {
                Color.gray
                    .ignoresSafeArea()
            }
    }
#endif
