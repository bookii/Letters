//
//  IndexView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/10/27.
//

import PhotosUI
import SwiftData
import SwiftUI

public struct IndexView: View {
    private enum Destination: Hashable {
        case extractor(uiImage: UIImage)
        case textEditor
    }

    @Query private var words: [Word]
    @State public var pickerItem: PhotosPickerItem?
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        VStack(spacing: 8) {
            Text("集めた文字数: \(String(countCharacters()))")
                .font(.system(size: 24))
            WordsScrollFlowView(words: words)
        }
        .onChange(of: pickerItem) {
            guard let pickerItem else {
                return
            }
            pickerItem.loadTransferable(type: Data.self) { result in
                Task { @MainActor in
                    if pickerItem == self.pickerItem,
                       case let .success(data) = result,
                       let uiImage = data.flatMap({ UIImage(data: $0) })
                    {
                        self.path.append(Destination.extractor(uiImage: uiImage))
                    }
                }
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .extractor(uiImage):
                ExtractorView(path: $path, uiImage: uiImage)
            case .textEditor:
                TextEditorView(path: $path)
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
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("", systemImage: "plus")
                }
            }
        }
    }

    private func countCharacters() -> Int {
        return words.reduce(0) { sum, word in
            sum + word.text.count
        }
    }
}

#if DEBUG
    let previewContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Word.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        } catch {
            fatalError("Failed to init modelContainer: \(error)")
        }
    }()

    #Preview {
        NavigationRootView { path in
            IndexView(path: path)
                .environment(\.extractorService, MockExtractorService.shared)
                .environment(\.storeService, MockStoreService.shared)
                .modelContainer(previewContainer)
                .task {
                    await Word.preloadMockWords()
                    for word in Word.preloadedMockWords {
                        previewContainer.mainContext.insert(word)
                    }
                }
        }
    }
#endif
