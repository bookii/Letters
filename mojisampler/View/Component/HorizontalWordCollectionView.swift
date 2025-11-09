//
//  HorizontalWordCollectionView.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/06.
//

import Foundation
import UIKit

public final class HorizontalWordCollectionView: UICollectionView {
    public init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: Self.createFlowLayout())
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        collectionViewLayout = Self.createFlowLayout()
        setup()
    }

    private static func createFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.sectionInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        return flowLayout
    }

    private func setup() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = .clear
        contentInsetAdjustmentBehavior = .never
    }
}

extension HorizontalWordCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        // TODO: width を flexible にする
        return CGSize(width: height, height: height)
    }
}
