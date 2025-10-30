//
//  IndexViewModel.swift
//  Letters
//
//  Created by mizznoff on 2025/10/29.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI
import UIKit

public final class IndexViewModel: NSObject, ObservableObject {
    @Published public var uiImage: UIImage?
    @Published public var pickerItem: PhotosPickerItem? {
        didSet {
            guard let pickerItem else {
                uiImage = nil
                return
            }
            pickerItem.loadTransferable(type: Data.self) { result in
                Task { @MainActor in
                    guard pickerItem == self.pickerItem else {
                        return
                    }
                    switch result {
                    case let .success(data):
                        if let data, let uiImage = UIImage(data: data) {
                            self.uiImage = uiImage
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}
