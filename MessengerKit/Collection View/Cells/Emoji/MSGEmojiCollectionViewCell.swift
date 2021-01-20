//
//  MSGEmojiCollectionViewCell.swift
//  MessengerKit
//
//  Created by Stephen Radford on 11/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class MSGEmojiCollectionViewCell: MSGMessageCell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var chatState: UIImageView!
    
    open override var messageState: MessageState {
        didSet {
            guard chatState != nil else { return }
            setupMessageState(in: chatState)
        }
    }
    
    override var message: MSGMessage? {
        didSet {
            guard let message = message,
                case let MSGMessageBody.emoji(body) = message.body else { return }
            
            textLabel.text = body
        }
    }
    
}

extension MSGEmojiCollectionViewCell {
    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 只有当触控点在 bubble 上时才响应手势
        let point = touch.location(in: self)
        guard textLabel.frame.contains(point) else { return false }
        
        return true
    }
}
