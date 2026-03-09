//
//  CreateGroupChatView.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import SwiftUI

struct UserChatInfoView: View {
    let user: AppUser
    let onRemovedFriend: () -> Void

    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showRemoveAlert = false

    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer().frame(height: 10)

                AsyncImage(url: URL(string: user.profilePicURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(brandOrange.opacity(0.15))
                        .overlay(
                            Text(String(user.username.prefix(1)).uppercased())
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(brandOrange)
                        )
                }
                .frame(width: 110, height: 110)
                .clipShape(Circle())

                Text(user.username)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)

                VStack(spacing: 14) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Open Chat")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(brandOrange)
                        .cornerRadius(16)
                    }

                    Button {
                        showRemoveAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.xmark")
                            Text("Remove Friend")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.25), lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Remove Friend?", isPresented: $showRemoveAlert) {
            Button("Cancel", role: .cancel) { }

            Button("Remove", role: .destructive) {
                Task {
                    await removeFriend()
                }
            }
        } message: {
            Text("This will remove \(user.username) from your friends list.")
        }
    }

    private func removeFriend() async {
        let friendUID = user.id
        await viewModel.removeFriend(friendID: friendUID)
        dismiss()
        onRemovedFriend()
    }
}
