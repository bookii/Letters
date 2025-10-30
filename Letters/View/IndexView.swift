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
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = IndexViewModel()
    @Query private var items: [Item] = []
    public init(path: Binding<NavigationPath>) {
        _path = path
    }
    
    public var body: some View {
        VStack {
            PhotosPicker(selection: $viewModel.pickerItem) {
                Text("アルバムから選択する")
            }
        }
        .onReceive(viewModel.$uiImage) { uiImage in
            if let uiImage {
                path.append(Destination.analyze(uiImage: uiImage))
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            EmptyView()
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

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            IndexView(path: path)
                .modelContainer(for: Item.self, inMemory: true)
        }
    }
#endif
