//
//  WordsScrollFlowView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/06.
//

import SwiftUI

public struct WordsScrollFlowView: View {
    private var words: [Word]
    private var onLastWordAppearAction: (() -> Void)?

    public init(words: [Word]) {
        self.words = words
    }

    public var body: some View {
        ScrollView {
            FlowLayout(alignment: .topLeading, spacing: 8) {
                ForEach(words) { word in
                    if let uiImage = UIImage(data: word.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 66)
                            .onAppear {
                                guard word.id == words.last?.id else {
                                    return
                                }
                                // TODO: 2回目以降に読み込まない不具合の修正
                                onLastWordAppearAction?()
                            }
                    }
                }
            }
        }
    }

    // MARK: - ViewModifier

    public func onLastWordAppear(perform onLastWordAppearAction: @escaping () -> Void) -> Self {
        var view = self
        view.onLastWordAppearAction = onLastWordAppearAction
        return view
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var id: UUID?
        @Previewable @State var text = ""
        VStack {
            WordsScrollFlowView(words: AnalyzedImage.preloadedMockAnalyzedImage?.words ?? [])
                .onLastWordAppear {
                    text = "Last word appeared"
                }
                .id(id)
                .task {
                    await AnalyzedImage.preloadMockAnalyzedImage()
                    id = .init()
                }
            Text(text)
        }
    }
#endif
