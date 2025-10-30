//
//  NavigationRootView.swift
//  Letters
//
//  Created by mizznoff on 2025/10/29.
//

import SwiftUI

public struct NavigationRootView<Content: View>: View {
    @State private var path = NavigationPath()
    private let content: (Binding<NavigationPath>) -> Content

    public init(@ViewBuilder content: @escaping (Binding<NavigationPath>) -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $path) {
            content($path)
        }
    }
}

#if DEBUG
    #Preview {
        NavigationRootView { path in
            IndexView(path: path)
        }
    }
#endif
