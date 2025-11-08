//
//  IndexView.swift
//  Letters
//
//  Created by mizznoff on 2025/10/27.
//

import PhotosUI
import SwiftUI

public struct IndexView: View {
    @Environment(\.storeRepository) private var storeRepository
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        IndexContentView(path: $path, storeRepository: storeRepository)
    }
}

private struct IndexContentView: View {
    private enum Destination: Hashable {
        case analyzer(uiImage: UIImage)
        case textEditor
    }

    @StateObject private var viewModel: IndexViewModel
    @Binding private var path: NavigationPath

    init(path: Binding<NavigationPath>, storeRepository: StoreRepositoryProtocol) {
        _path = path
        _viewModel = .init(wrappedValue: .init(storeRepository: storeRepository))
    }

    fileprivate var body: some View {
        VStack(spacing: 8) {
            if let lettersCount = viewModel.lettersCount {
                Text("集めた文字数: \(String(lettersCount))")
                    .font(.system(size: 24))
            }
            WordsScrollFlowView(words: viewModel.words ?? [])
                .onLastWordAppear {
                    viewModel.loadMoreWords()
                }
        }
        .onAppear {
            viewModel.reloadWords()
        }
        .onReceive(viewModel.$uiImage) { uiImage in
            if let uiImage {
                path.append(Destination.analyzer(uiImage: uiImage))
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .analyzer(uiImage):
                AnalyzerView(path: $path, uiImage: uiImage)
            case .textEditor:
                LetterEditorView(path: $path)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    path.append(Destination.textEditor)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(selection: $viewModel.pickerItem, matching: .images) {
                    Label("", systemImage: "plus")
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var hasPreloaded = false
        NavigationRootView { path in
            if hasPreloaded {
                IndexView(path: path)
                    .environment(\.analyzerRepository, MockAnalyzerRepository.shared)
                    .environment(\.storeRepository, MockStoreRepository.shared)

            } else {
                ProgressView()
            }
        }
        .task {
            await Word.preloadMockWords()
            hasPreloaded = true
        }
    }
#endif
