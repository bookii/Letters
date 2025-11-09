//
//  IndexView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/10/27.
//

import PhotosUI
import SwiftUI

public struct IndexView: View {
    @Environment(\.storeService) private var storeService
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        IndexContentView(path: $path, storeService: storeService)
    }
}

private struct IndexContentView: View {
    private enum Destination: Hashable {
        case extractor(uiImage: UIImage)
        case textTextEditor
    }

    @StateObject private var viewModel: IndexViewModel
    @Binding private var path: NavigationPath

    init(path: Binding<NavigationPath>, storeService: StoreServiceProtocol) {
        _path = path
        _viewModel = .init(wrappedValue: .init(storeService: storeService))
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
                path.append(Destination.extractor(uiImage: uiImage))
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .extractor(uiImage):
                ExtractorView(path: $path, uiImage: uiImage)
            case .textTextEditor:
                TextEditorView(path: $path)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    path.append(Destination.textTextEditor)
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
                    .environment(\.extractorService, MockExtractorService.shared)
                    .environment(\.storeService, MockStoreService.shared)

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
