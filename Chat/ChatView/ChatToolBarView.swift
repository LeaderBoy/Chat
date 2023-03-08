//
//  ChatToolBarView.swift
//  Chat
//
//  Created by 杨志远 on 2023/3/6.
//

import AlertToast
import SwiftUI

struct ChatToolBarView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var action: ((ChatMessage) -> Void)?

    @State private var question = """
    """

    @FocusState var isFocused

    private let height: CGFloat = 37
    
    var body: some View {
        ZStack {
            HStack {
                if #available(macOS 13.0, *) {
                    TextField("Message...", text: $question, axis: .vertical)
                        .lineLimit(2 ... 4)
                        .textFieldStyle(.plain)
                        .frame(height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .cornerRadius(4)
                        .focused($isFocused)
                        .onSubmit {
                            sendMessage()
                        }
                } else {
                    TextField("Message...", text: $question)
                        .textFieldStyle(.plain)
                        .frame(height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .cornerRadius(4)
                        .focused($isFocused)
                        .onSubmit {
                            sendMessage()
                        }
                }
            }
            .padding()
        }
        .background(Color.white.opacity(0.2))
        .background(.regularMaterial)
    }

    func sendMessage() {
        do {
            let chat = try viewModel.sendMessage(question)
            question = ""
            action?(chat)
        } catch {
            if let er = error as? ChatError {
                self.viewModel.chatErr = er
            } else {
                self.viewModel.chatErr = .request(message: error.localizedDescription)
            }
        }
    }
}

struct ChatToolBarView_Previews: PreviewProvider {
    static var previews: some View {
        ChatToolBarView().environmentObject(ChatViewModel())
    }
}
