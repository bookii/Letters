//
//  ExtractorView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/10/30.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

public struct ExtractorView: View {
    @Environment(\.analyzerService) private var analyzerService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding private var path: NavigationPath
    @State private var analyzedImage: AnalyzedImage?
    @State private var error: Error?
    @State private var isErrorAlertPresented: Bool = false
    @State private var viewWidth: CGFloat = 0
    private let uiImage: UIImage

    public init(path: Binding<NavigationPath>, uiImage: UIImage) {
        _path = path
        self.uiImage = uiImage
    }

    public var body: some View {
        Group {
            if let analyzedImage {
                WordsScrollFlowView(words: analyzedImage.words)
                    .onGeometryChange(for: CGFloat.self, of: \.size.width) { width in
                        viewWidth = width
                    }
                    .padding(16)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("文字のサンプリング")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    guard let analyzedImage else {
                        return
                    }
                    modelContext.insert(analyzedImage)
                    dismiss()
                }
            }
        }
        .alert(error?.localizedDescription ?? "Unknown error", isPresented: $isErrorAlertPresented) {
            Button("OK") {
                self.error = nil
            }
        }
        .task {
            do {
                analyzedImage = try await analyzerService.analyzeWords(from: uiImage)
            } catch {
                self.error = error
            }
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var uiImage: UIImage? = nil
        NavigationRootView { path in
            if let uiImage {
                ExtractorView(path: path, uiImage: uiImage)
            }
        }
        .environment(\.analyzerService, MockAnalyzerService.shared)
        .task {
            uiImage = await UIImage.mockImage()
        }
    }
#endif
