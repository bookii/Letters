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
    private enum Destination: Hashable {
        case analyze(uiImage: UIImage)
    }

    @Binding private var path: NavigationPath
    @Query(sort: \Word.createdAt) private var words: [Word]
    @StateObject private var viewModel = IndexViewModel()
    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        List(words) { word in
            if let uiImage = UIImage(data: word.imageData) {
                Section {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .onReceive(viewModel.$uiImage) { uiImage in
            if let uiImage {
                path.append(Destination.analyze(uiImage: uiImage))
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .analyze(uiImage):
                AnalyzeView(uiImage: uiImage)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(selection: $viewModel.pickerItem, matching: .images) {
                    Label("", systemImage: "plus")
                }
            }
        }
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            IndexView(path: path)
                .modelContainer(LettersModelContainer.shared)
        }
    }
#endif
