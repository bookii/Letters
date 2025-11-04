//
//  WriterView.swift
//  Letters
//
//  Created by mizznoff on 2025/11/03.
//

import SwiftData
import SwiftUI

public struct WriterView: View {
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        WriterContentView(path: $path)
    }
}

private struct WriterContentView: View {
    @State private var nsAttributedText: NSAttributedString = .init(string: "")
    @State private var isFirstResponder: Bool = false
    @Binding private var path: NavigationPath

    fileprivate init(path: Binding<NavigationPath>) {
        _path = path
    }

    fileprivate var body: some View {
        TextViewRepresentable(nsAttributedText: $nsAttributedText, isFirstResponder: $isFirstResponder)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(16)
            .frame(maxHeight: .infinity)
            .background {
                Color.gray
                    .ignoresSafeArea()
            }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            WriterView(path: path)
        }
        .environment(\.analyzerRepository, MockAnalyzerRepository.shared)
        .environment(\.storeRepository, MockStoreRepository.shared)
    }
#endif
