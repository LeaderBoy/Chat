//
//  ChatView.swift
//  Chat
//
//  Created by 杨志远 on 2023/3/6.
//

import AlertToast
import Combine
import SwiftUI

struct ChatView: View {
    @StateObject var viewModel = ChatViewModel()
    @State var showAlert: Bool = false
    @State private var showToast = false
    @State private var bindings: Set<AnyCancellable> = []

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .trailing) {
                Button(action: {
                    showAlert.toggle()
                }) {
                    Image(systemName: "plus")
                }.padding([.top, .trailing], 10)

                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ChatMessageView()
                                .padding(.horizontal)
                                .environmentObject(viewModel)
                        }
                        .onChange(of: viewModel.lastMessage) { _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.lastMessageID, anchor: .bottom)
                            }
                        }
                    }

                    ChatToolBarView().environmentObject(viewModel)
                }
            }
            
            Button(action: {
                NSApplication.shared.terminate(self)
            }) {
                Image(systemName: "power")
            }
            .buttonStyle(.borderless)
            .padding([.bottom, .trailing], 10)
        }
        .alert(R.Text.yourApiKey, isPresented: $showAlert, actions: {
            SecureField(R.Text.apiKey, text: $viewModel.apiKey)
            // Any view other than Button would be ignored
            Button(R.Text.done, action: {
                showAlert = false
                viewModel.cacheAPIKey()
            })
            Button(R.Text.cancel, role: .cancel, action: {
                showAlert = false
            })
        }) {
            Text(R.Text.apiKeyDesc)
        }.toast(isPresenting: $showToast) {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.chatErr.message)
        }.onAppear {
            bindToast()
        }
    }

    func bindToast() {
        viewModel.$chatErr
            .filter { $0 != .none }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.showToast = true
            }.store(in: &bindings)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
