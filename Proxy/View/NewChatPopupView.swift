//
//  NewChatPopupView.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import SwiftUI

struct NewChatPopupView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showCreateGroupChat = false

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var filteredFriends: [AppUser] {
        if searchText.isEmpty {
            return viewModel.friends
        } else {
            return viewModel.friends.filter {
                $0.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("New Chat")
                        .font(.system(size: 28, weight: .bold))

                    Spacer()

                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 18)

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search friends...", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(14)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 18)

                VStack(spacing: 0) {
                    Button {
                        showCreateGroupChat = true
                    } label: {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(brandOrange.opacity(0.15))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(brandOrange)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Create Group Chat")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("Start a chat with multiple friends")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 76)
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        if filteredFriends.isEmpty {
                            Text("No friends found")
                                .foregroundColor(.secondary)
                                .padding(.top, 40)
                        } else {
                            ForEach(filteredFriends) { friend in
                                NavigationLink(
                                    destination: ChatView(
                                        user: friend,
                                        onRemovedFriend: {}
                                    )
                                ) {
                                    HStack(spacing: 14) {
                                        AsyncImage(url: URL(string: friend.profilePicURL)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
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

                                        Text(friend.username)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .padding(.leading, 76)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateGroupChat) {
                CreateGroupChatView()
                    .environmentObject(viewModel)
            }
        }
    }
}
