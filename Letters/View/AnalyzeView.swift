//
//  AnalyzeView.swift
//  Letters
//
//  Created by mizznoff on 2025/10/30.
//

import Foundation
import SwiftUI
import UIKit

public struct AnalyzeView: View {
    @Environment(\.analyzeRepository) private var analyzeRepository
    @Environment(\.storeRepository) private var storeRepository
    @Binding private var path: NavigationPath
    private var uiImage: UIImage

    public init(path: Binding<NavigationPath>, uiImage: UIImage) {
        _path = path
        self.uiImage = uiImage
    }

    public var body: some View {
        AnalyzeContentView(uiImage: uiImage, analyzeRepository: analyzeRepository, storeRepository: storeRepository)
    }
}

private struct AnalyzeContentView: View {
    @StateObject private var viewModel: AnalyzeViewModel
    @State private var viewWidth: CGFloat = 0
    private let uiImage: UIImage

    fileprivate init(uiImage: UIImage, analyzeRepository: AnalyzeRepositoryProtocol, storeRepository: StoreRepositoryProtocol) {
        self.uiImage = uiImage
        _viewModel = .init(wrappedValue: .init(analyzeRepository: analyzeRepository, storeRepository: storeRepository))
    }

    fileprivate var body: some View {
        Group {
            if let wordImages = viewModel.words?.compactMap({ UIImage(data: $0.imageData) }) {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                        ForEach(wordImages.indices, id: \.self) { index in
                            Image(uiImage: wordImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: viewWidth / 5, maxHeight: viewWidth / 5)
                        }
                    }
                }
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
                }
            }
        }
    }
}

#if DEBUG
    // #Preview {
//    AnalyzeView(uiImage: )
    // }
#endif
