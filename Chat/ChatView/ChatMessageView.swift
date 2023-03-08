//
//  ChatMessageView.swift
//  Chat
//
//  Created by 杨志远 on 2023/3/6.
//

import SwiftUI

struct ChatMessageView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    let columns = [GridItem(.flexible(minimum: 10))]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(viewModel.messages,id: \.id) { message in
                ChatMessageBubble(message: message)
            }
        }
    }
}

struct ChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageView().environmentObject(ChatViewModel())
    }
}
