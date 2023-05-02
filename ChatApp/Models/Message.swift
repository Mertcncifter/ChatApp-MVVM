//
//  Message.swift
//  ChatApp
//
//  Created by mert can çifter on 26.04.2023.
//

import Foundation
import MessageKit

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var getMessage: String {
        switch self {
        case .text(let messageText):
            return messageText
        case .attributedText(_):
            return ""
        case .photo(let mediaItem):
            return mediaItem.url?.absoluteString ?? ""
        case .video(let mediaItem):
            return mediaItem.url?.absoluteString ?? ""
        case .location(_):
            return ""
        case .emoji(_):
            return ""
        case .audio(_):
            return ""
        case .contact(_):
            return ""
        case .linkPreview(_):
            return ""
        case .custom(_):
            return ""
        }
    }
}
