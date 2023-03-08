//
//  ChatApp.swift
//  Chat
//
//  Created by 杨志远 on 2023/3/6.
//

import SwiftUI

@main
struct ChatApp: App {
    var body: some Scene {
        MenuBarExtra("ChatGPT", systemImage: "brain") {
            ContentView()
                .background(Color.gray.opacity(0.1))
                .frame(width: 400,height: 600)
        }.menuBarExtraStyle(.window)
    }
}
