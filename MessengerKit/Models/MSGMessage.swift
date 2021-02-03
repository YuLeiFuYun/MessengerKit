//
//  MSGMessage.swift
//  MessengerKit
//
//  Created by Stephen Radford on 08/06/2018.
//  Copyright © 2018 Cocoon Development Ltd. All rights reserved.
//

import Foundation

public enum MessageState: Int {
    case sending
    case success
    case failure
}

/// Represents a message within MessengerKit.
public class MSGMessage: NSObject{
    
    /// A unique identifier for the message.
    /// This is used to cache bubble sizes for the messenger.
    public let id: Int
    
    /// The body of the message.
    public let body: MSGMessageBody
    
    /// The user that sent the message.
    public let user: MSGUser
    
    /// The time that the message was sent.
    public var sentAt: String
    
    /// message state
    public var state: MessageState {
        didSet {
            guard state != oldValue else { return }
            NotificationCenter.default.post(name: .messageStateChanged, object: id)
        }
    }
    
    public init(id: Int, body: MSGMessageBody, user: MSGUser, sentAt: String, state: MessageState = .sending) {
        self.id = id
        self.body = body
        self.user = user
        self.sentAt = sentAt
        self.state = state
    }
    
}
