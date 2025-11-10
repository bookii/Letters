//
//  TextEditorView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/03.
//

import SwiftData
import SwiftUI

public struct TextEditorView: View {
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        TextEditorContentView(path: $path)
    }
}

private struct TextEditorContentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TextEditorViewModel
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
            .navigationTitle("テキストの作成")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shouldRender = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
            .alert("テキスト画像を保存しました", isPresented: $isSaveCompletionAlertPresented) {
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
            .onReceive(viewModel.$savedImage) { newValue in
                if newValue != nil {
                    isSaveCompletionAlertPresented = true
                }
            }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            TextEditorView(path: path)
        }
        .environment(\.storeService, MockStoreService.shared)
    }
#endif
