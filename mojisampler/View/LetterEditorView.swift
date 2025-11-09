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
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: LetterEditorViewModel
    @State private var isFirstResponder: Bool = false
    @State private var shouldRender: Bool = false
    @State private var isSaveCompletionAlertPresented: Bool = false
    @State private var isShareSheetPresented: Bool = false
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
            .navigationTitle("レターの編集")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shouldRender = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
            .onReceive(viewModel.$savedImage) { newValue in
                if newValue != nil {
                    isSaveCompletionAlertPresented = true
                }
            }
            .alert("レターを保存しました", isPresented: $isSaveCompletionAlertPresented) {
                Button("共有する") {
                    isShareSheetPresented = true
                }
                Button("閉じる") {
                    dismiss()
                }
            }
            .sheet(isPresented: $isShareSheetPresented) {
                if let savedImage = viewModel.savedImage {
                    ShareImageActivityView(uiImage: savedImage)
                }
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
