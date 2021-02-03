//
//  MSGOutgoingTailCollectionViewCell.swift
//  MessengerKit
//
//  Created by Stephen Radford on 10/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import UIKit

open class MSGTailCollectionViewCell: MSGMessageCell {
    
    @IBOutlet public weak var bubble: MSGTailOutgoingBubble!
    
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stateImageView: UIImageView!
    
    override open var message: MSGMessage? {
        didSet {
            guard let message = message,
                case let MSGMessageBody.text(body) = message.body else { return }
            
            bubble.text = body
            
            if let stateImageView = stateImageView {
                setupMessageState(in: stateImageView)
            }
        }
    }
    
    override open var style: MSGMessengerStyle? {
        didSet {
            guard let message = message, let style = style as? MSGIMessageStyle else { return }
            bubble.linkTextAttributes = [
                NSAttributedString.Key.underlineColor: message.user.isSender ? style.outgoingLinkColor : style.incomingLinkColor,
                NSAttributedString.Key.foregroundColor: message.user.isSender ? style.outgoingLinkColor : style.incomingLinkColor,
                NSAttributedString.Key.underlineStyle: message.user.isSender ? style.outgoingLinkUnderlineStyle : style.incomingLinkUnderlineStyle
            ]
            bubble.font = style.font
            bubble.backgroundImageView.tintColor = message.user.isSender ? style.outgoingBubbleColor : style.incomingBubbleColor
            bubble.textColor = message.user.isSender ? style.outgoingTextColor : style.incomingTextColor
        }
    }
    
    override open var isLastInSection: Bool {
        didSet {
            guard let style = style as? MSGIMessageStyle,
            !style.alwaysDisplayTails else {
                bubble.shouldShowTail = true
                return
            }
            
            bubble.shouldShowTail = isLastInSection
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let bubbleSize = bubble.calculatedSize(in: bounds.size)
        bubbleWidthConstraint.constant = bubbleSize.width
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        isLastInSection = false
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        bubble.delegate = self
    }

}

extension MSGTailCollectionViewCell: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        delegate?.cellLinkTapped(url: URL)
        
        return false
    }
}

extension MSGTailCollectionViewCell {
    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 只有当触控点在 bubble 上时才响应手势
        let point = touch.location(in: self)
        guard bubble.frame.contains(point) else { return false }
        
        return true
    }
}
