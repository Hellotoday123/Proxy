//
//  GroupChatDetailView.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import Foundation
import SwiftUI

struct GroupChatDetailView: View {
    let group: GroupChat

    @EnvironmentObject var viewModel: AppViewModel

    @State private var messageText = ""
    @State private var initialUnreadCount: Int = 0
    @State private var firstUnreadMessageID: String? = nil

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var body: some View {
        VStack(spacing: 0) {

            NavigationLink(destination: GroupChatInfoView(group: group).environmentObject(viewModel)) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(brandOrange.opacity(0.15))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(brandOrange)
                        )

                    Text(group.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .buttonStyle(.plain)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if viewModel.groupMessages.isEmpty {
                            Text("No messages yet")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        } else {
                            ForEach(viewModel.groupMessages) { message in

                                if message.id == firstUnreadMessageID {
                                    HStack {
                                        Divider()

                                        Text("Unread Messages")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)

                                        Divider()
                                    }
                                    .padding(.vertical, 8)
                                    .id("UNREAD_DIVIDER")
                                }

                                messageBubble(message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if let lastID = viewModel.groupMessages.last?.id {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.groupMessages.count) { _ in
                    updateFirstUnreadMessageID()

                    if let lastID = viewModel.groupMessages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Message...", text: $messageText)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color(.systemGray6))
                    .cornerRadius(22)

                Button {
                    viewModel.sendGroupMessage(to: group, text: messageText)
                    messageText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(brandOrange)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
        }
        .onAppear {
            initialUnreadCount = viewModel.unreadGroupCounts[group.id ?? ""] ?? 0
            viewModel.fetchGroupMessages(for: group)
            viewModel.markGroupAsRead(group)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                updateFirstUnreadMessageID()
            }
        }
    }

    @ViewBuilder
    private func messageBubble(_ message: GroupMessage) -> some View {
        if message.isSystemMessage {
            HStack {
                Spacer()

                Text(message.text)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5).opacity(0.7))
                    .cornerRadius(12)
                    .opacity(0.7)

                Spacer()
            }
        } else {
            HStack {
                if message.senderID == viewModel.currentUser?.id {
                    Spacer()

                    Text(message.text)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(brandOrange)
                        .cornerRadius(16)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.senderName)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(message.text)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .cornerRadius(16)
                    }

                    Spacer()
                }
            }
        }
    }

    private func updateFirstUnreadMessageID() {
        guard initialUnreadCount > 0 else {
            firstUnreadMessageID = nil
            return
        }

        let currentUserID = viewModel.currentUser?.id

        let unreadEligibleMessages = viewModel.groupMessages.filter { message in
            message.senderID != currentUserID
        }

        guard !unreadEligibleMessages.isEmpty else {
            firstUnreadMessageID = nil
            return
        }

        let count = min(initialUnreadCount, unreadEligibleMessages.count)
        let unreadSlice = unreadEligibleMessages.suffix(count)

        firstUnreadMessageID = unreadSlice.first?.id
    }
}
