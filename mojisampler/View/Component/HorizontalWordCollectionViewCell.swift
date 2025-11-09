//
//  HorizontalWordCollectionViewCell.swift
//  mojisampler
//
//  Created by mizznoff on 2025/11/06.
//

import Foundation
import UIKit

public final class HorizontalWordCollectionViewCell: UICollectionViewCell {
    public var id: UUID!
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    private let imageView = UIImageView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
