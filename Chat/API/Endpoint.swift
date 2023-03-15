//
//  Endpoint.swift
//  Chat
//
//  Created by 杨志远 on 2023/3/8.
//

import Foundation


enum Endpoint {
    case chatCompletions
}

extension Endpoint {
    var path: String {
        switch self {
        case .chatCompletions:
            return "/v1/chat/completions"
        }
    }
    
    var method: String {
        switch self {
        case .chatCompletions:
            return "POST"
        }
    }
    
    func baseURL() -> String {
        switch self {
        case .chatCompletions:
            if let url = UserDefaults.standard.string(forKey: API_URL),!url.isEmpty {
                return url
            }
            return "https://api.openai.com"
        }
    }
}
