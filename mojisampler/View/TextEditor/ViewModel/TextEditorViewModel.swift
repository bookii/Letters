//
//  TextEditorViewModel.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/06.
//

import Combine
import Foundation
import SwiftUI
import UIKit

public final class TextEditorViewModel: NSObject, ObservableObject {
    @Published public private(set) var savedImage: UIImage?
    @Published public private(set) var error: Error?
    private var savingImage: UIImage?

    public func saveImage(_ uiImage: UIImage) {
        savingImage = uiImage
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(onSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func onSaveImage(_: UIImage, didFinishSavingWithError error: Error?, contextInfo _: UnsafeMutableRawPointer) {
        if error == nil {
            savedImage = savingImage
        }
        self.error = error
    }
}
