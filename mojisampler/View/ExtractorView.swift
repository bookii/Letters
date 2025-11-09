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
    @Environment(\.extractorRepository) private var extractorRepository
    @Environment(\.storeRepository) private var storeRepository
    @Binding private var path: NavigationPath
    private var uiImage: UIImage

    public init(path: Binding<NavigationPath>, uiImage: UIImage) {
        _path = path
        self.uiImage = uiImage
    }

    public var body: some View {
        ExtractorContentView(uiImage: uiImage, extractorRepository: extractorRepository, storeRepository: storeRepository)
    }
}

private struct ExtractorContentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ExtractorViewModel
    @State private var viewWidth: CGFloat = 0
    private let uiImage: UIImage

    fileprivate init(uiImage: UIImage, extractorRepository: ExtractorRepositoryProtocol, storeRepository: StoreRepositoryProtocol) {
        self.uiImage = uiImage
        _viewModel = .init(wrappedValue: .init(extractorRepository: extractorRepository, storeRepository: storeRepository))
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
        .modelContainer(MockStoreRepository.shared.modelContainer)
        .environment(\.extractorRepository, MockExtractorRepository.shared)
        .environment(\.storeRepository, MockStoreRepository.shared)
        .task {
            uiImage = await UIImage.mockImage()
        }
    }
#endif
