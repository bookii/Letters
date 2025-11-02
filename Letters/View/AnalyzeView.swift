//
//  AnalyzeView.swift
//  Letters
//
//  Created by mizznoff on 2025/10/30.
//

import Foundation
import SwiftUI

public struct AnalyzeView: View {
    @StateObject private var viewModel: AnalyzeViewModel
    @State private var viewWidth: CGFloat = 0

    public init(uiImage: UIImage) {
        _viewModel = .init(wrappedValue: .init(uiImage: uiImage))
    }

    public var body: some View {
        if let letterImages = viewModel.letterImages {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                    ForEach(letterImages.indices, id: \.self) { index in
                        Image(uiImage: letterImages[index])
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
                    viewModel.analyze()
                }
        }
    }
}

#if DEBUG
    // #Preview {
//    AnalyzeView(uiImage: )
    // }
#endif
