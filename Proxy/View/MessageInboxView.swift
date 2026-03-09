//
//  MessageInboxView.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//

import SwiftUI
import FirebaseFirestore

struct MessagesInboxView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showNewChatSheet = false
    @State private var selectedTab = 0
    @State private var selectedFriend: AppUser? = nil
    @State private var showChat = false

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading chats...")
            } else {
                ZStack(alignment: .bottomTrailing) {
                    Color(.systemGroupedBackground).ignoresSafeArea()

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            friendRequestsSection
                            tabPickerSection

                            if selectedTab == 0 {
                                recentChatsSection
                            } else {
                                groupChatsSection
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 110)
                    }

                    Button {
                        showNewChatSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 62, height: 62)
                            .background(brandOrange)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
                    }
                    .padding(.trailing, 22)
                    .padding(.bottom, 95)

                    NavigationLink(
                        destination: Group {
                            if let friend = selectedFriend {
                                ChatView(
                                    user: friend,
                                    onRemovedFriend: {
                                        showChat = false
                                        selectedFriend = nil
                                    }
                                )
                                .environmentObject(viewModel)
                            }
                        },
                        isActive: $showChat
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
        }
        .navigationTitle("Messages")
        .refreshable {
            viewModel.fetchCurrentUser()
            viewModel.fetchGroupChats()
            viewModel.fetchAllUsers()
        }
        .onAppear {
            viewModel.fetchGroupChats()
            viewModel.fetchAllUsers()
        }
        .sheet(isPresented: $showNewChatSheet) {
            NewChatPopupView()
                .environmentObject(viewModel)
                .presentationDetents([.fraction(0.78), .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var friendRequestsSection: some View {
        let pendingRequesters = viewModel.currentUser?.pendingRequests ?? []

        return Group {
            if !pendingRequesters.isEmpty {
                sectionHeader("Friend Requests", icon: "person.badge.clock.fill")

                ForEach(pendingRequesters, id: \.self) { requesterID in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(brandOrange.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(String(getUsername(for: requesterID).prefix(1)).uppercased())
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(brandOrange)
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(getUsername(for: requesterID))
                                .font(.system(size: 15, weight: .semibold))
                            Text("Wants to be your friend")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 8) {

                            HStack(spacing: 8) {

                                Button {
                                    Task { await viewModel.rejectFriendRequest(from: requesterID) }
                                } label: {
                                    Text("Decline")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.red)
                                        .lineLimit(1)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(12)
                                }

                                Button {
                                    Task { await viewModel.acceptFriendRequest(from: requesterID) }
                                } label: {
                                    Text("Accept")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(brandOrange)
                                        .cornerRadius(12)
                                }
                            }
                            .fixedSize()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }

    private var tabPickerSection: some View {
        Picker("Message Type", selection: $selectedTab) {
            Text("Chats").tag(0)
            Text("Groups").tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var recentChatsSection: some View {
        Group {
            sectionHeader("Chats", icon: "bubble.left.and.bubble.right.fill")

            if viewModel.friends.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No friends yet. Add some in 'People'!")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            } else {
                ForEach(viewModel.friends) { friend in
                    Button {
                        selectedFriend = friend
                        showChat = true
                    } label: {
                        HStack(spacing: 14) {
                            AsyncImage(url: URL(string: friend.profilePicURL)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Circle()
                                    .fill(brandOrange.opacity(0.15))
                                    .overlay(
                                        Text(String(friend.username.prefix(1)).uppercased())
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(brandOrange)
                                    )
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 3) {
                                Text(friend.username)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("Tap to chat")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var groupChatsSection: some View {
        Group {
            sectionHeader("Group Chats", icon: "person.3.fill")

            if viewModel.groupChats.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No group chats yet.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            } else {
                ForEach(viewModel.groupChats) { group in
                    HStack(spacing: 14) {
                        NavigationLink(destination: GroupChatInfoView(group: group)) {
                            Circle()
                                .fill(brandOrange.opacity(0.15))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "person.3.fill")
                                        .foregroundColor(brandOrange)
                                )
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: GroupChatDetailView(group: group)) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(group.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text("\(group.memberIDs.count) members")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                UnreadBadge(
                                    count: viewModel.unreadGroupCounts[group.id ?? ""] ?? 0
                                )

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(brandOrange)
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }

    private func getUsername(for id: String) -> String {
        if let user = viewModel.allUsers.first(where: { $0.id == id }) {
            return user.username
        }

        if let friend = viewModel.friends.first(where: { $0.id == id }) {
            return friend.username
        }

        return "User"
    }
}
