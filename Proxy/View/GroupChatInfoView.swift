//
//  GroupChatInfoView.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import SwiftUI
import FirebaseFirestore

struct GroupChatInfoView: View {
    let group: GroupChat

    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showRenameSheet = false
    @State private var showAddMembersSheet = false
    @State private var newGroupName = ""

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var memberUsers: [AppUser] {
        var combined: [AppUser] = []

        if let currentUser = viewModel.currentUser {
            combined.append(currentUser)
        }

        combined.append(contentsOf: viewModel.friends)
        combined.append(contentsOf: viewModel.allUsers)

        var uniqueUsers: [AppUser] = []
        var seenIDs = Set<String>()

        for user in combined {
            if !seenIDs.contains(user.id) {
                seenIDs.insert(user.id)
                uniqueUsers.append(user)
            }
        }

        return uniqueUsers.filter { group.memberIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerCard
                actionButtons
                membersCard
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(group.name)
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .sheet(isPresented: $showRenameSheet) {
            RenameGroupChatView(
                newGroupName: $newGroupName,
                onSave: {
                    renameGroupChat()
                }
            )
            .presentationDetents([.fraction(0.28)])
        }
        .sheet(isPresented: $showAddMembersSheet) {
            AddMembersToGroupView(group: group)
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(brandOrange.opacity(0.15))
                    .frame(width: 110, height: 110)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(brandOrange)
            }
            .padding(.top, 6)

            Text(group.name)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            Text("\(group.memberIDs.count) members")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial)
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            actionButton(icon: "person.badge.plus", title: "Add") {
                showAddMembersSheet = true
            }

            actionButton(icon: "pencil", title: "Rename") {
                newGroupName = group.name
                showRenameSheet = true
            }

            NavigationLink(destination: GroupChatDetailView(group: group)) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(brandOrange.opacity(0.14))
                            .frame(width: 56, height: 56)

                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(brandOrange)
                    }

                    Text("Chat")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func actionButton(icon: String, title: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill((isDestructive ? Color.red : brandOrange).opacity(0.14))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isDestructive ? .red : brandOrange)
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var membersCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Group Members")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 18)
                .padding(.top, 18)

            if memberUsers.isEmpty {
                ForEach(group.memberIDs, id: \.self) { memberID in
                    fallbackMemberRow(memberID)

                    if memberID != group.memberIDs.last {
                        dividerInset
                    }
                }
            } else {
                ForEach(memberUsers) { user in
                    memberRow(user)

                    if user.id != memberUsers.last?.id {
                        dividerInset
                    }
                }
            }

            Divider()
                .padding(.leading, 78)

            Button {
                leaveGroupChat()
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.14))
                            .frame(width: 52, height: 52)

                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Leave Group Chat")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.red)

                        Text("Remove yourself from this group")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private func memberRow(_ user: AppUser) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: user.profilePicURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle()
                    .fill(brandOrange.opacity(0.15))
                    .overlay(
                        Text(String(user.username.prefix(1)).uppercased())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(brandOrange)
                    )
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Text(user.id == viewModel.currentUser?.id ? "You" : "Member")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private func fallbackMemberRow(_ memberID: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(brandOrange.opacity(0.15))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(brandOrange)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(memberID == viewModel.currentUser?.id ? "You" : "Member")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Text(memberID)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private var dividerInset: some View {
        Divider()
            .padding(.leading, 78)
            .padding(.trailing, 14)
    }

    private func leaveGroupChat() {
        guard
            let groupID = group.id,
            let currentUser = viewModel.currentUser
        else { return }

        let updatedMembers = group.memberIDs.filter { $0 != currentUser.id }

        if updatedMembers.isEmpty {
            viewModel.db.collection("groupChats").document(groupID).delete { error in
                if let error = error {
                    print("Error deleting empty group:", error.localizedDescription)
                } else {
                    print("Group deleted because no members left")
                    viewModel.fetchGroupChats()
                    dismiss()
                }
            }
        } else {
            viewModel.db.collection("groupChats").document(groupID).updateData([
                "memberIDs": updatedMembers,
                "unreadCounts.\(currentUser.id)": FieldValue.delete()
            ]) { error in
                if let error = error {
                    print("Error leaving group:", error.localizedDescription)
                } else {
                    print("Left group successfully")

                    viewModel.sendGroupSystemMessage(
                        to: group,
                        text: "\(currentUser.username) left the group.",
                        actorUserID: currentUser.id
                    )

                    viewModel.fetchGroupChats()
                    dismiss()
                }
            }
        }
    }

    private func renameGroupChat() {
        guard let groupID = group.id else { return }

        let trimmed = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let oldName = group.name

        viewModel.db.collection("groupChats").document(groupID).updateData([
            "name": trimmed
        ]) { error in
            if let error = error {
                print("Error renaming group:", error.localizedDescription)
            } else {
                print("Group renamed successfully")

                viewModel.sendGroupSystemMessage(
                    to: group,
                    text: "Group name changed from \"\(oldName)\" to \"\(trimmed)\".",
                    actorUserID: viewModel.currentUser?.id
                )

                showRenameSheet = false
                viewModel.fetchGroupChats()
            }
        }
    }
}

struct RenameGroupChatView: View {
    @Binding var newGroupName: String
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Group name", text: $newGroupName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Change Group Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(brandOrange)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .foregroundColor(brandOrange)
                    .fontWeight(.semibold)
                    .disabled(newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct AddMembersToGroupView: View {
    let group: GroupChat

    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedFriendIDs: Set<String> = []

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var availableFriends: [AppUser] {
        viewModel.friends.filter { !group.memberIDs.contains($0.id) }
    }

    var filteredFriends: [AppUser] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return availableFriends
        }

        return availableFriends.filter {
            $0.username.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
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

                if filteredFriends.isEmpty {
                    Spacer()
                    Text("No friends available to add")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredFriends) { friend in
                                Button {
                                    toggleSelection(for: friend)
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
                                        .frame(width: 52, height: 52)
                                        .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(friend.username)
                                                .font(.headline)
                                                .foregroundColor(.black)

                                            Text(selectedFriendIDs.contains(friend.id) ? "Selected" : "Tap to add")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        Image(systemName: selectedFriendIDs.contains(friend.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedFriendIDs.contains(friend.id) ? brandOrange : .gray.opacity(0.45))
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .padding(.leading, 84)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(brandOrange)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addMembersToGroup()
                    }
                    .foregroundColor(selectedFriendIDs.isEmpty ? .gray : brandOrange)
                    .fontWeight(.semibold)
                    .disabled(selectedFriendIDs.isEmpty)
                }
            }
        }
    }

    private func toggleSelection(for friend: AppUser) {
        if selectedFriendIDs.contains(friend.id) {
            selectedFriendIDs.remove(friend.id)
        } else {
            selectedFriendIDs.insert(friend.id)
        }
    }

    private func addMembersToGroup() {
        guard let groupID = group.id else { return }

        let addedUsers = viewModel.friends.filter { selectedFriendIDs.contains($0.id) }
        let updatedMembers = Array(Set(group.memberIDs + Array(selectedFriendIDs)))

        var unreadCountsUpdates: [String: Any] = [:]
        for id in selectedFriendIDs {
            unreadCountsUpdates["unreadCounts.\(id)"] = 0
        }

        viewModel.db.collection("groupChats").document(groupID).updateData([
            "memberIDs": updatedMembers
        ].merging(unreadCountsUpdates) { _, new in new }) { error in
            if let error = error {
                print("Error adding members:", error.localizedDescription)
            } else {
                print("Members added successfully")

                let names = addedUsers.map { $0.username }.joined(separator: ", ")
                if !names.isEmpty {
                    viewModel.sendGroupSystemMessage(
                        to: group,
                        text: "\(names) joined the group.",
                        actorUserID: viewModel.currentUser?.id
                    )
                }

                viewModel.fetchGroupChats()
                dismiss()
            }
        }
    }
}
