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
        case writer
    }

    @StateObject private var viewModel: IndexViewModel
    @Binding private var path: NavigationPath

    init(path: Binding<NavigationPath>, storeRepository: StoreRepositoryProtocol) {
        _path = path
        _viewModel = .init(wrappedValue: .init(storeRepository: storeRepository))
    }

    var body: some View {
        List {
            ForEach(viewModel.words ?? []) { word in
                if let uiImage = UIImage(data: word.imageData) {
                    Section {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            // TODO: 末尾表示時に追加読み込み
        }
        .onAppear {
            viewModel.refreshWords()
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
            case .writer:
                WriterView(path: $path)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    path.append(Destination.writer)
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
        NavigationRootView { path in
            IndexView(path: path)
                .environment(\.analyzerRepository, MockAnalyzerRepository.shared)
                .environment(\.storeRepository, MockStoreRepository.shared)
                .task {
                    await Word.preloadMockWords()
                }
        }
    }
#endif
