//
//  ChatMessage.swift
//  Chat
//
//  Created by 杨志远 on 2023/3/8.
//

import Foundation

enum ChatRole : String,Codable {
    case system
    case user
    case assistant
}

struct ChatMessage: Identifiable, Hashable, Encodable {
    let id: String = UUID().uuidString
    let role: ChatRole
    var message: String
    let isReceived: Bool
    
    enum CodingKeys: String,CodingKey {
        case role
        case message = "content"
    }
}
