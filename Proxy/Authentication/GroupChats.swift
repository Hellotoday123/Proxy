//
//  GroupChats.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import Foundation
import FirebaseFirestore

extension AppViewModel {

    func createGroupChat(name: String, selectedFriendIDs: [String], completion: @escaping (Bool) -> Void) {
        guard let currentUserID = currentUser?.id else {
            completion(false)
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "New Group" : trimmedName

        let memberIDs = Array(Set(selectedFriendIDs + [currentUserID]))

        var unreadCounts: [String: Int] = [:]
        for memberID in memberIDs {
            unreadCounts[memberID] = 0
        }

        let data: [String: Any] = [
            "name": finalName,
            "memberIDs": memberIDs,
            "createdBy": currentUserID,
            "createdAt": Timestamp(date: Date()),
            "unreadCounts": unreadCounts
        ]

        db.collection("groupChats").addDocument(data: data) { error in
            if let error = error {
                print("Error creating group chat: \(error.localizedDescription)")
                completion(false)
            } else {
                self.fetchGroupChats()
                completion(true)
            }
        }
    }

    func fetchGroupChats() {
        guard let currentUserID = currentUser?.id else { return }

        db.collection("groupChats")
            .whereField("memberIDs", arrayContains: currentUserID)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching group chats: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.groupChats = []
                    self.unreadGroupCounts = [:]
                    return
                }

                let chats: [GroupChat] = documents.compactMap { doc in
                    let data = doc.data()

                    guard
                        let name = data["name"] as? String,
                        let memberIDs = data["memberIDs"] as? [String],
                        let createdBy = data["createdBy"] as? String,
                        let createdAt = data["createdAt"] as? Timestamp
                    else {
                        return nil
                    }

                    let unreadCounts = data["unreadCounts"] as? [String: Int] ?? [:]

                    return GroupChat(
                        id: doc.documentID,
                        name: name,
                        memberIDs: memberIDs,
                        createdBy: createdBy,
                        createdAt: createdAt.dateValue(),
                        unreadCounts: unreadCounts
                    )
                }

                self.groupChats = chats

                var newUnreadMap: [String: Int] = [:]
                for chat in chats {
                    guard let groupID = chat.id else { continue }
                    newUnreadMap[groupID] = chat.unreadCounts[currentUserID] ?? 0
                }
                self.unreadGroupCounts = newUnreadMap
            }
    }

    func markGroupAsRead(_ group: GroupChat) {
        guard
            let groupID = group.id,
            let currentUserID = currentUser?.id
        else { return }

        db.collection("groupChats")
            .document(groupID)
            .updateData([
                "unreadCounts.\(currentUserID)": 0
            ]) { error in
                if let error = error {
                    print("Error marking group as read: \(error.localizedDescription)")
                } else {
                    self.unreadGroupCounts[groupID] = 0
                }
            }
    }
}
