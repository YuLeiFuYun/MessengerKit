//
//  MSGMessageCell.swift
//  MessengerKit
//
//  Created by Stephen Radford on 08/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import UIKit

open class MSGMessageCell: UICollectionViewCell {
    
    /// The message the cell is displaying
    open var message: MSGMessage?
    
    open var messageState: MessageState = .sending
    
    /// Provides information on how to style the cell
    open var style: MSGMessengerStyle?
    
    /// Whether the cell is the last displayed in the section.
    /// We need to know this for styles like iMessage as the final cell sometimes differs in appearance.
    open var isLastInSection: Bool = false
    
    /// Ensure this is declared as weak or you'll end up with a memory leak, kids.
    open weak var delegate: MSGMessageCellDelegate?
    
    /// The gesture recogniser for long press.
    /// This should be added to the cell's `contentView`
    open var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    /// The gesture recogniser for a tap.
    /// This should be added to the cell's `contentView`
    open var tapGestureRecognizer: UITapGestureRecognizer!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizers()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestureRecognizers()
    }
    
    open func addGestureRecognizers() {
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressReceieved(_:)))
        longPressGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(longPressGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapReceived(_:)))
        tapGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    open func setupMessageState(in imageView: UIImageView) {
        imageView.isHidden = false
        imageView.layer.removeAnimation(forKey: "transform.rotation.z")
        switch messageState {
        case .sending:
            imageView.image = UIImage(named: "loading", in: MessengerKit.bundle, compatibleWith: nil)
            
            let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnim.fromValue = 0
            rotationAnim.toValue = Double.pi * 2
            rotationAnim.repeatCount = .infinity
            rotationAnim.duration = 1
            rotationAnim.isRemovedOnCompletion = false
            imageView.layer.add(rotationAnim, forKey: "transform.rotation.z")
        case .success:
            imageView.isHidden = true
        case .failure:
            imageView.image = UIImage(named: "error", in: MessengerKit.bundle, compatibleWith: nil)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MSGMessageCell: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
}

// MARK: - MSGMessageCellDelegate Handlers

extension MSGMessageCell {
    @objc open func longPressReceieved(_ sender: UILongPressGestureRecognizer) {
        guard let message = message, sender.state == .began else { return }
        
        if let cell = self as? MSGTailCollectionViewCell {
            if let win = window!.viewWithTag(7654321) as? UIWindow {
                win.makeKeyAndVisible()
            } else {
                let screenSize = UIScreen.main.bounds.size
                let win = UIWindow(frame: CGRect(x: screenSize.width - 5, y: screenSize.height - 5, width: 5, height: 5))
                win.backgroundColor = .clear
                win.tag = 7654321
                window!.addSubview(win)
                win.makeKeyAndVisible()
            }
            
            cell.bubble.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let copyItem = UIMenuItem(title: "复制", action: #selector(cell.bubble.customCopy))
                UIMenuController.shared.menuItems = [copyItem]
                UIMenuController.shared.setTargetRect(cell.bubble.frame, in: cell.bubble.superview!)
                UIMenuController.shared.setMenuVisible(true, animated: true)
            }
        }
        
        delegate?.cellLongPressReceived(for: message)
    }
    
    @objc open func tapReceived(_ sender: UITapGestureRecognizer) {
        guard let message = message, sender.state == .ended else { return }
        delegate?.cellTapReceived(for: message)
    }
}
