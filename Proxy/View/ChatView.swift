//
//  ChatView.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//

import SwiftUI
import Combine

struct ChatView: View {
    let user: AppUser
    let onRemovedFriend: () -> Void

    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var messageText = ""
    @State private var showUserInfo = false

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        Spacer(minLength: 20)

                        if viewModel.chatMessages.isEmpty {
                            Text("No messages yet")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .padding(.top, 40)
                        } else {
                            ForEach(viewModel.chatMessages) { message in
                                messageBubble(message)
                                    .id(message.id)
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .onAppear {
                    viewModel.fetchMessages(for: user)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if let lastID = viewModel.chatMessages.last?.id {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.chatMessages.count) { _ in
                    if let lastID = viewModel.chatMessages.last?.id {
                        withAnimation { proxy.scrollTo(lastID, anchor: .bottom) }
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Type a message...", text: $messageText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(22)

                Button {
                    guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    viewModel.sendMessage(text: messageText, toUser: user)
                    messageText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(brandOrange)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .top) {
            topBar
        }
        .sheet(isPresented: $showUserInfo) {
            NavigationStack {
                UserChatInfoView(
                    user: user,
                    onRemovedFriend: {
                        showUserInfo = false
                        onRemovedFriend()
                    }
                )
                .environmentObject(viewModel)
            }
        }
    }

    @ViewBuilder
    private func messageBubble(_ message: Message) -> some View {
        HStack {
            if message.fromId == viewModel.currentUser?.id {
                Spacer()
                Text(message.text)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(brandOrange)
                    .cornerRadius(16)
            } else {
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
                Spacer()
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
            }

            Spacer()

            Text(user.username)
                .font(.system(size: 20, weight: .bold))
                .lineLimit(1)

            Spacer()

            Button {
                showUserInfo = true
            } label: {
                AsyncImage(url: URL(string: user.profilePicURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(brandOrange.opacity(0.15))
                        .overlay(
                            Text(String(user.username.prefix(1)).uppercased())
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(brandOrange)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Color(.systemBackground))
    }
}
