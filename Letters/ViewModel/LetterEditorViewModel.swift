//
//  LetterEditorViewModel.swift
//  Letters
//
//  Created by mizznoff on 2025/11/06.
//

import Combine
import Foundation
import SwiftUI

public final class LetterEditorViewModel: NSObject, ObservableObject {
    @Published public var isSaveCompletionAlertPresented: Bool = false

    public func saveImage(_ uiImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(onSaveImage), nil)
    }

    @objc public func onSaveImage(_: UIImage, didFinishSavingWithError _: Error?, contextInfo _: UnsafeMutableRawPointer?) {
        isSaveCompletionAlertPresented = true
    }
}
