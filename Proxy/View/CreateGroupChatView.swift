//
//  CreateGroupChatView.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import SwiftUI

struct CreateGroupChatView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedFriendIDs: Set<String> = []
    @State private var groupName = ""

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var filteredFriends: [AppUser] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return viewModel.friends
        }

        return viewModel.friends.filter {
            $0.username.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var selectedFriends: [AppUser] {
        viewModel.friends.filter { selectedFriendIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(brandOrange)

                    Spacer()

                    Text("New Group")
                        .font(.headline)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Create") {
                        viewModel.createGroupChat(
                            name: groupName,
                            selectedFriendIDs: Array(selectedFriendIDs)
                        ) { success in
                            if success {
                                dismiss()
                            } else {
                                print("Failed to create group")
                            }
                        }
                    }
                    .foregroundColor(selectedFriendIDs.isEmpty ? .gray : brandOrange)
                    .fontWeight(.semibold)
                    .disabled(selectedFriendIDs.isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                HStack(spacing: 10) {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(brandOrange)

                    TextField("Group name (optional)", text: $groupName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color(.systemGray6))
                .cornerRadius(14)
                .padding(.horizontal)

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search friends", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color(.systemGray6))
                .cornerRadius(14)
                .padding(.horizontal)

                if !selectedFriends.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Selected")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedFriends) { friend in
                                    VStack(spacing: 8) {
                                        ZStack(alignment: .topTrailing) {
                                            AsyncImage(url: URL(string: friend.profilePicURL)) { image in
                                                image.resizable().scaledToFill()
                                            } placeholder: {
                                                Circle()
                                                    .fill(brandOrange.opacity(0.15))
                                                    .overlay(
                                                        Text(String(friend.username.prefix(1)).uppercased())
                                                            .font(.system(size: 16, weight: .bold))
                                                            .foregroundColor(brandOrange)
                                                    )
                                            }
                                            .frame(width: 58, height: 58)
                                            .clipShape(Circle())

                                            Button {
                                                selectedFriendIDs.remove(friend.id)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .background(Color.white.clipShape(Circle()))
                                            }
                                            .offset(x: 4, y: -4)
                                        }

                                        Text(friend.username)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .frame(width: 70)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Friends")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredFriends) { friend in
                                Button {
                                    toggleSelection(for: friend)
                                } label: {
                                    GroupFriendSelectionRow(
                                        friend: friend,
                                        isSelected: selectedFriendIDs.contains(friend.id),
                                        brandOrange: brandOrange
                                    )
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .padding(.leading, 84)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .background(Color.white)
        }
    }

    private func toggleSelection(for friend: AppUser) {
        if selectedFriendIDs.contains(friend.id) {
            selectedFriendIDs.remove(friend.id)
        } else {
            selectedFriendIDs.insert(friend.id)
        }
    }
}

struct GroupFriendSelectionRow: View {
    let friend: AppUser
    let isSelected: Bool
    let brandOrange: Color

    var body: some View {
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
            .frame(width: 52, height: 52)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(friend.username)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(isSelected ? "Selected" : "Tap to add")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(isSelected ? brandOrange : .gray.opacity(0.45))
        }
        .padding(.vertical, 12)
    }
}
