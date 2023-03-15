//
//  ChatViewModel.swift
//  Chat
//
//  Created by 杨志远 on 2023/3/6.
//

import Foundation
import AppKit

let API_KEY = "API_KEY"
let API_URL = "API_URL"

class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var lastMessage: String = ""
    @Published private(set) var lastMessageID: String = ""
    @Published private(set) var isWorking: Bool = false
    @Published var apiKey: String = ""
    @Published var apiURL: String = ""
    @Published var chatErr: ChatError = .none

    var usingMarkdown: Bool = true

    private lazy var api = ChatAPI(apiKey: apiKey)

    var messageFeed = MessageFeed()
    
    init() {
        apiKey = UserDefaults.standard.string(forKey: API_KEY) ?? ""
    }

    @discardableResult
    func sendMessage(_ message: String) throws -> ChatMessage {
        if message.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ChatError.noQuestion
        }

        if apiKey.isEmpty {
            throw ChatError.noAPIKey
        }

        if isWorking {
            throw ChatError.isWorking
        }
        isWorking = true
        let chat = ChatMessage(role: .user, message: message, isReceived: false)
        messages.append(chat)
        lastMessageID = chat.id
        lastMessage = message
        request(question: message)
        return chat
    }

    func request(question: String) {
        Task {
            do {
                let stream = try await api.sendMessage(question)
                let chat = await ChatMessage(role: .assistant, message: messageFeed.message, isReceived: true)
                DispatchQueue.main.async {
                    self.lastMessageID = chat.id
                    self.messages.append(chat)
                }
                for try await line in stream {
                    await messageFeed.append(line: line)
                    let newMessage = await messageFeed.message
                    DispatchQueue.main.async {
                        var last = self.messages.last!
                        last.message = newMessage
                        self.messages[self.messages.count - 1] = last
                        self.lastMessage = newMessage
                    }
                }
                await messageFeed.reset()
                DispatchQueue.main.async {
                    self.isWorking = false
                }
            } catch {
                await messageFeed.reset()
                DispatchQueue.main.async {
                    self.isWorking = false
                    self.chatErr = .request(message: error.localizedDescription)
                }
            }
        }
    }

    func cacheAPIKey() {
        // Re init
        api = ChatAPI(apiKey: apiKey)
        UserDefaults.standard.set(apiKey, forKey: API_KEY)
        UserDefaults.standard.set(apiURL, forKey: API_URL)
    }
    
    func clearHistory() {
        messages.removeAll()
        lastMessage = ""
        lastMessageID = ""
        api.clearHistory()
    }
    
    func copyMessage(_ message : ChatMessage) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.message, forType: .string)
    }
}

actor MessageFeed {
    var message: String = """
    """

    func append(line: String) {
        message += line
    }

    func reset() {
        message.removeAll()
    }
}
