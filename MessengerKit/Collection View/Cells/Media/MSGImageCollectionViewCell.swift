//
//  MSGImageCollectionViewCell.swift
//  MessengerKit
//
//  Created by Stephen Radford on 11/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Kingfisher
import Photos

class MSGImageCollectionViewCell: MSGMessageCell {
    
    @IBOutlet weak var imageView: AnimatedImageView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateImageView: UIImageView!
    
    open override var messageState: MessageState {
        didSet {
            guard stateImageView != nil else { return }
            setupMessageState(in: stateImageView)
        }
    }
    
    override public var message: MSGMessage? {
        didSet {
            guard let message = message else { return }
            
            if case let MSGMessageBody.image(image) = message.body {
                if image.images != nil {
                    imageView.image = image
                    // 若不做此设定，gif 图片在划出界面又重新显示之后会停止播放
                    imageView.animationImages = image.images
                } else {
                    imageView.image = image
                }
            } else if case let MSGMessageBody.imageFromUrl(imageUrl) = message.body {
                imageView.isUserInteractionEnabled = false
                imageView.kf.setImage(with: imageUrl, options: [.progressiveJPEG(.default)], completionHandler:  { [weak self] (result) in
                    self?.imageView.isUserInteractionEnabled = true
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        
        if #available(iOS 13, *) {
            let interaction = UIContextMenuInteraction(delegate: self)
            imageView.addInteraction(interaction)
        }
    }
}

extension MSGImageCollectionViewCell {
    public override func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        // 只有当触控点在 imageView 上时才响应手势
        let point = touch.location(in: self)
        guard imageView.frame.contains(point) else { return false }
        
        return true
    }
}

extension MSGImageCollectionViewCell: UIContextMenuInteractionDelegate {
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let share = UIAction(title: "分享",
                image: UIImage(systemName: "square.and.arrow.up")) { action in
                UIApplication.share(self.imageView.image!)
            }
            
            let save = UIAction(title: "保存", image: UIImage(systemName: "square.and.arrow.down")) { action in
                PHPhotoLibrary.shared().performChanges {
                    if case .imageFromUrl(let url) = self.message?.body {
                        let cachedURL = ImageCache.default.cachePath(forKey: url.absoluteString)
                        let data = try! Data(contentsOf: URL(fileURLWithPath: cachedURL))
                        PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
                    } else {
                        DispatchQueue.main.async {
                            PHAssetCreationRequest.creationRequestForAsset(from: self.imageView.image!)
                        }
                    }
                } completionHandler: { (isSuccess, error) in
                    guard let style = self.style as? MSGIMessageStyle else { return }
                    style.saveImageCompletionHandler?(isSuccess, error)
                }
            }
            
            let copy = UIAction(title: "拷贝", image: UIImage(systemName: "doc.on.doc")) { action in
                UIPasteboard.general.image = self.imageView.image
            }
            
            return UIMenu(title: "", children: [share, save, copy])
        }
    }
}
