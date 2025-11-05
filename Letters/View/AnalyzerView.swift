//
//  AnalyzerView.swift
//  Letters
//
//  Created by mizznoff on 2025/10/30.
//

import Foundation
import SwiftUI
import UIKit

public struct AnalyzerView: View {
    @Environment(\.analyzerRepository) private var analyzerRepository
    @Environment(\.storeRepository) private var storeRepository
    @Binding private var path: NavigationPath
    private var uiImage: UIImage

    public init(path: Binding<NavigationPath>, uiImage: UIImage) {
        _path = path
        self.uiImage = uiImage
    }

    public var body: some View {
        AnalyzerContentView(uiImage: uiImage, analyzerRepository: analyzerRepository, storeRepository: storeRepository)
    }
}

private struct AnalyzerContentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AnalyzerViewModel
    @State private var viewWidth: CGFloat = 0
    private let uiImage: UIImage

    fileprivate init(uiImage: UIImage, analyzerRepository: AnalyzerRepositoryProtocol, storeRepository: StoreRepositoryProtocol) {
        self.uiImage = uiImage
        _viewModel = .init(wrappedValue: .init(analyzerRepository: analyzerRepository, storeRepository: storeRepository))
    }

    fileprivate var body: some View {
        Group {
            if let words = viewModel.words {
                WordsScrollView(words: words)
                    .onGeometryChange(for: CGFloat.self, of: \.size.width) { width in
                        viewWidth = width
                    }
                    .padding(16)
            } else {
                ProgressView()
                    .onAppear {
                        viewModel.analyzeIntoWords(uiImage: uiImage)
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    viewModel.save()
                    dismiss()
                }
            }
        }
    }
}

#if DEBUG
    import SwiftData

    #Preview {
        @Previewable @State var uiImage: UIImage? = nil
        NavigationRootView { path in
            if let uiImage {
                AnalyzerView(path: path, uiImage: uiImage)
            }
        }
        .modelContainer(MockStoreRepository.shared.modelContainer)
        .environment(\.analyzerRepository, MockAnalyzerRepository.shared)
        .environment(\.storeRepository, MockStoreRepository.shared)
        .task {
            uiImage = await UIImage.mockImage()
        }
    }
#endif
