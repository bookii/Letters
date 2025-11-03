//
//  IndexView.swift
//  Letters
//
//  Created by mizznoff on 2025/10/27.
//

import PhotosUI
import SwiftData
import SwiftUI

public struct IndexView: View {
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        IndexContentView(path: $path)
    }
}

private struct IndexContentView: View {
    private enum Destination: Hashable {
        case analyzer(uiImage: UIImage)
        case editor
    }

    @Query(sort: \Word.createdAt) private var words: [Word]
    @StateObject private var viewModel = IndexViewModel()
    @Binding private var path: NavigationPath

    init(path: Binding<NavigationPath>) {
        _path = path
    }

    var body: some View {
        List {
            ForEach(words) { word in
                if let uiImage = UIImage(data: word.imageData) {
                    Section {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
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
            case .editor:
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    path.append(Destination.editor)
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
                .modelContainer(MockStoreRepository.shared.modelContainer)
                .environment(\.analyzerRepository, MockAnalyzerRepository.shared)
                .environment(\.storeRepository, MockStoreRepository.shared)
        }
    }
#endif
