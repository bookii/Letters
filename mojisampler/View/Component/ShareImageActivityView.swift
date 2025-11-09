//
//  ShareImageActivityView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/08.
//

import Foundation
import SwiftUI
import UIKit

public struct ShareImageActivityView: UIViewControllerRepresentable {
    private let uiImage: UIImage

    public init(uiImage: UIImage) {
        self.uiImage = uiImage
    }

    public func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
    }

    public func updateUIViewController(_: UIActivityViewController, context _: Context) {
        // NOP
    }
}
