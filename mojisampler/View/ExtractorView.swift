//
//  ExtractorView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/10/30.
//

import Foundation
import SwiftUI
import UIKit

public struct ExtractorView: View {
    @Environment(\.extractorService) private var extractorService
    @Environment(\.storeService) private var storeService
    @Binding private var path: NavigationPath
    private var uiImage: UIImage

    public init(path: Binding<NavigationPath>, uiImage: UIImage) {
        _path = path
        self.uiImage = uiImage
    }

    public var body: some View {
        ExtractorContentView(uiImage: uiImage, extractorService: extractorService, storeService: storeService)
    }
}

private struct ExtractorContentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ExtractorViewModel
    @State private var viewWidth: CGFloat = 0
    private let uiImage: UIImage

    fileprivate init(uiImage: UIImage, extractorService: ExtractorServiceProtocol, storeService: StoreServiceProtocol) {
        self.uiImage = uiImage
        _viewModel = .init(wrappedValue: .init(extractorService: extractorService, storeService: storeService))
    }

    fileprivate var body: some View {
        Group {
            if let words = viewModel.words {
                WordsScrollFlowView(words: words)
                    .onGeometryChange(for: CGFloat.self, of: \.size.width) { width in
                        viewWidth = width
                    }
                    .padding(16)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("文字のサンプリング")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    viewModel.save()
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.extractWords(from: uiImage)
        }
    }
}

#if DEBUG
    import SwiftData

    #Preview {
        @Previewable @State var uiImage: UIImage? = nil
        NavigationRootView { path in
            if let uiImage {
                ExtractorView(path: path, uiImage: uiImage)
            }
        }
        .modelContainer(MockStoreService.shared.modelContainer)
        .environment(\.extractorService, MockExtractorService.shared)
        .environment(\.storeService, MockStoreService.shared)
        .task {
            uiImage = await UIImage.mockImage()
        }
    }
#endif
