//
//  LetterEditorView.swift
//  Letters
//
//  Created by mizznoff on 2025/11/03.
//

import SwiftData
import SwiftUI

public struct LetterEditorView: View {
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        LetterEditorContentView(path: $path)
    }
}

private struct LetterEditorContentView: View {
    @Environment(\.displayScale) private var displayScale
    @StateObject private var viewModel: LetterEditorViewModel
    @State private var nsAttributedText: NSAttributedString = .init(string: "")
    @State private var isFirstResponder: Bool = false
    @State private var shouldRender: Bool = false
    @Binding private var path: NavigationPath

    fileprivate init(path: Binding<NavigationPath>) {
        _path = path
        _viewModel = .init(wrappedValue: .init())
    }

    fileprivate var body: some View {
        ImageConvertiveTextView(isFirstResponder: $isFirstResponder, shouldRender: $shouldRender)
            .onRenderImage { uiImage in
                viewModel.saveImage(uiImage)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(16)
            .frame(maxHeight: .infinity)
            .background {
                Color.gray
                    .ignoresSafeArea()
            }
            .navigationTitle("メッセージの作成")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shouldRender = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
            .alert("メッセージ画像を保存しました", isPresented: $viewModel.isSaveCompletionAlertPresented) {
                Button("OK") {}
            }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            LetterEditorView(path: path)
        }
        .environment(\.storeRepository, MockStoreRepository.shared)
    }
#endif
