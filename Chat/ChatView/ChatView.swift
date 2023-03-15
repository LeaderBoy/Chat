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
    @State var showAPIKeyAlert: Bool = false
    @State var showHistoryAlert: Bool = false
    @State private var showToast = false
    @State private var bindings: Set<AnyCancellable> = []

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                HStack {
                    Button(action: {
                        showAPIKeyAlert.toggle()
                    }) {
                        Image(systemName: "plus")
                    }.buttonStyle(.borderless)
                    
                    Spacer()
                    
                    Button(action: {
                        showHistoryAlert.toggle()
                    }) {
                        Image(systemName: "trash")
                    }.buttonStyle(.borderless)
                }
                .padding(10)
                .background(Color.white.opacity(0.2))
                .background(.regularMaterial)

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
        
        // History Alert
        .alert(R.Text.clearHistory, isPresented: $showHistoryAlert, actions: {
            // Any view other than Button would be ignored
            Button(R.Text.done, action: {
                showHistoryAlert = false
                viewModel.clearHistory()
            })
            Button(R.Text.cancel, role: .cancel, action: {
                showHistoryAlert = false
            })
        }) {
            Text(R.Text.clearHistoryDesc)
        }
        
        // API Key alert
        .alert(R.Text.yourApiKey, isPresented: $showAPIKeyAlert, actions: {
            
            TextField(text: $viewModel.apiURL, prompt: .init(R.Text.apiUrlPrompt)) {}
            SecureField(R.Text.apiKey, text: $viewModel.apiKey)
            // Any view other than Button would be ignored
            Button(R.Text.done, action: {
                showAPIKeyAlert = false
                viewModel.cacheAPIKey()
            })
            Button(R.Text.cancel, role: .cancel, action: {
                showAPIKeyAlert = false
            })
        }) {
            Text(R.Text.apiKeyDesc)
        }
        
        // Message
        .toast(isPresenting: $showToast) {
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
