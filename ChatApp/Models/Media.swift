//
//  Media.swift
//  ChatApp
//
//  Created by mert can çifter on 28.04.2023.
//

import MessageKit
import UIKit

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
