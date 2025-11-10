//
//  MojiSamplerApp.swift
//  mojisampler
//
//  Created by mizznoff on 2025/10/27.
//

import SwiftData
import SwiftUI

@main
public struct MojisamplerApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            NavigationRootView { path in
                IndexView(path: path)
            }
        }
        .environment(\.extractorService, ExtractorService.shared)
        .modelContainer(ModelContainer.shared)
    }
}
