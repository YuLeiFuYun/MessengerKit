//
//  MSGIMessageStyle.swift
//  MessengerKit
//
//  Created by Stephen Radford on 10/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

/// Styles the `MSGMessengerViewController` to be similar in style to iMessage.
public struct MSGIMessageStyle: MSGMessengerStyle {
    
    public var collectionView: MSGCollectionView.Type = MSGImessageCollectionView.self
    
    public var inputView: MSGInputView.Type = MSGImessageInputView.self
    
    public var headerHeight: CGFloat = 12
    
    public var footerHeight: CGFloat = 30
    
    public var backgroundColor: UIColor = .white
    
    public var inputViewBackgroundColor: UIColor = .white
    
    public var inputTextViewBackgroundColor : UIColor = .white
    
    public var font: UIFont = .preferredFont(forTextStyle: .body)
    
    public var inputFont: UIFont = .systemFont(ofSize: 14)
    
    public var inputTextColor: UIColor = .darkText
    
    public var inputPlaceholder: String = "Type something..."
    
    public var inputPlaceholderTextColor: UIColor = .lightGray
    
    public var inputLeadingConstant: CGFloat = 0
    
    public var inputTrailingConstant: CGFloat = 0
    
    public var outgoingTextColor: UIColor = .white
    
    public var incomingTextColor: UIColor = .darkText
    
    public var outgoingLinkColor: UIColor = .white
    
    public var incomingLinkColor: UIColor = UIColor(hue:0.58, saturation:0.81, brightness:0.95, alpha:1.00)

    public var outgoingLinkUnderlineStyle: NSNumber = 1

    public var incomingLinkUnderlineStyle: NSNumber = 1
    
    public var webImageSize: ((URL) -> CGSize)?
    
    public var saveImageCompletionHandler: ((Bool, Error?) -> Void)?
    
    public func size(for message: MSGMessage, in collectionView: UICollectionView) -> CGSize {
        var size: CGSize!
        
        switch message.body {
        case .text(let body):
            let bubble = MSGTailOutgoingBubble()
            bubble.text = body
            bubble.font = font
            let bubbleSize = bubble.calculatedSize(in: CGSize(width: collectionView.bounds.width, height: .infinity))
            size = CGSize(width: collectionView.bounds.width, height: bubbleSize.height)
        case .emoji:
            size = CGSize(width: collectionView.bounds.width, height: 60)
        case .image(let image):
            size = calculateDisplaySize(for: image.size)
        case .imageFromUrl(let url):
            if let imageSize = webImageSize?(url) {
                size = calculateDisplaySize(for: imageSize)
            } else {
                size = CGSize(width: 269, height: 175)
            }
        default:
            size = CGSize(width: collectionView.bounds.width, height: 175)
        }
        
        return size
    }
    
    private func calculateDisplaySize(for originalSize: CGSize) -> CGSize {
        let originalWidth = originalSize.width
        let originalHeight = originalSize.height
        
        let minWidth: CGFloat = 80
        let maxWidth = UIScreen.main.bounds.width * 0.67
        let maxHeight = UIScreen.main.bounds.height * 0.25
        
        if originalWidth <= maxWidth && originalHeight <= maxHeight {
            return originalSize
        } else if originalWidth <= maxWidth && originalHeight > maxHeight {
            if originalWidth <= minWidth {
                return CGSize(width: originalWidth, height: maxHeight)
            } else {
                let hScaleFactor = maxHeight / originalHeight
                let scaleFactor = (originalWidth * hScaleFactor < minWidth)
                    ? minWidth / originalWidth
                    : hScaleFactor
                return CGSize(width: originalWidth * scaleFactor, height: maxHeight)
            }
        } else if originalWidth > maxWidth && originalHeight <= maxHeight {
            let scaleFactor = maxWidth / originalWidth
            return CGSize(width: maxWidth, height: originalHeight * scaleFactor)
        } else {
            // originalWidth > maxWidth && originalHeight > maxHeight
            let wScaleFactor = maxWidth / originalWidth
            let hScaleFactor = maxHeight / originalHeight
            let scaleFactor = (hScaleFactor <= wScaleFactor)
                ? hScaleFactor
                : wScaleFactor
            
            if originalWidth * scaleFactor < minWidth {
                return CGSize(width: minWidth, height: maxHeight)
            } else {
                return CGSize(
                    width: originalWidth * scaleFactor,
                    height: originalHeight * scaleFactor
                )
            }
        }
    }
    
    // MARK: - Custom Properties
    
    /// The color of the bubble when its outgoing
    public var outgoingBubbleColor: UIColor = UIColor(hue:0.58, saturation:0.81, brightness:0.95, alpha:1.00)
    
    /// The color of the bubble when its incoming
    public var incomingBubbleColor: UIColor = UIColor(hue:0.67, saturation:0.02, brightness:0.92, alpha:1.00)
    
    /// If set to true then tails will be displayed on every cell
    /// and not use the final cell in the section.
    public var alwaysDisplayTails: Bool = false
    
    /// The font used by header views
    public var headerFont: UIFont = UIFont.systemFont(ofSize: 10)
    
    /// The text color used by header views
    public var headerTextColor: UIColor = UIColor(hue:0.67, saturation:0.03, brightness:0.58, alpha:1.00)
    
    /// The font used by footer views
    public var footerFont: UIFont = UIFont.systemFont(ofSize: 10)
    
    /// The text color used by footer views
    public var footerTextColor: UIColor = UIColor(hue:0.67, saturation:0.03, brightness:0.58, alpha:1.00)
    
}
