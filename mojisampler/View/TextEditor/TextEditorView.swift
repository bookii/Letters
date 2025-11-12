//
//  TextEditorView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/03.
//

import SwiftData
import SwiftUI

public struct TextEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TextEditorViewModel()
    @Binding private var path: NavigationPath
    @State private var isFirstResponder: Bool = false
    @State private var shouldRender: Bool = false
    @State private var isSaveCompletionAlertPresented: Bool = false
    @State private var isShareSheetPresented: Bool = false
    @State private var error: Error?
    @State private var isErrorAlertPresented: Bool = false

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        ImageConvertiveTextView(isFirstResponder: $isFirstResponder, shouldRender: $shouldRender)
            .onRenderImage { uiImage in
                viewModel.saveImage(uiImage)
            }
            .onReceiveError { error in
                self.error = error
                isErrorAlertPresented = true
            }
            .onReceive(viewModel.$savedImage) { newValue in
                if newValue != nil {
                    isSaveCompletionAlertPresented = true
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(16)
            .frame(maxHeight: .infinity)
            .background {
                Color.gray
                    .ignoresSafeArea()
            }
            .navigationTitle("テキストの作成")
            .navigationBarTitleDisplayMode(.inline)
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
            .alert(error?.localizedDescription ?? "Unknown error", isPresented: $isErrorAlertPresented) {
                Button("OK") {
                    self.error = nil
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
            TextEditorView(path: path)
        }
    }
#endif
