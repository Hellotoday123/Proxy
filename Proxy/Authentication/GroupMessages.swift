//
//  GroupMessages.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import Foundation
import FirebaseFirestore

extension AppViewModel {

    func fetchGroupMessages(for group: GroupChat) {
        guard let groupID = group.id else { return }

        groupMessageListeners[groupID]?.remove()

        groupMessageListeners[groupID] = db.collection("groupChats")
            .document(groupID)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching group messages: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else {
                    self.groupMessages = []
                    return
                }

                self.groupMessages = snapshot.documents.compactMap { doc in
                    let data = doc.data()

                    guard
                        let senderID = data["senderID"] as? String,
                        let senderName = data["senderName"] as? String,
                        let text = data["text"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        return nil
                    }

                    return GroupMessage(
                        id: doc.documentID,
                        senderID: senderID,
                        senderName: senderName,
                        text: text,
                        timestamp: timestamp.dateValue(),
                        isSystemMessage: data["isSystemMessage"] as? Bool ?? false
                    )
                }
            }
    }

    func sendGroupMessage(to group: GroupChat, text: String) {
        guard let groupID = group.id else { return }
        guard let currentUser = currentUser else { return }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let messageData: [String: Any] = [
            "senderID": currentUser.id,
            "senderName": currentUser.username,
            "text": trimmed,
            "timestamp": Timestamp(date: Date()),
            "isSystemMessage": false
        ]

        db.collection("groupChats")
            .document(groupID)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending group message: \(error.localizedDescription)")
                    return
                }

                var updates: [String: Any] = [:]
                for memberID in group.memberIDs where memberID != currentUser.id {
                    updates["unreadCounts.\(memberID)"] = FieldValue.increment(Int64(1))
                }
                updates["unreadCounts.\(currentUser.id)"] = 0

                self.db.collection("groupChats")
                    .document(groupID)
                    .updateData(updates) { error in
                        if let error = error {
                            print("Error updating unread counts: \(error.localizedDescription)")
                        }
                    }
            }
    }

    func sendGroupSystemMessage(to group: GroupChat, text: String, actorUserID: String? = nil) {
        guard let groupID = group.id else { return }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let messageData: [String: Any] = [
            "senderID": "system",
            "senderName": "System",
            "text": trimmed,
            "timestamp": Timestamp(date: Date()),
            "isSystemMessage": true
        ]

        db.collection("groupChats")
            .document(groupID)
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending system message: \(error.localizedDescription)")
                    return
                }

                var updates: [String: Any] = [:]
                for memberID in group.memberIDs {
                    if memberID != actorUserID {
                        updates["unreadCounts.\(memberID)"] = FieldValue.increment(Int64(1))
                    }
                }

                if let actorUserID {
                    updates["unreadCounts.\(actorUserID)"] = 0
                }

                self.db.collection("groupChats")
                    .document(groupID)
                    .updateData(updates) { error in
                        if let error = error {
                            print("Error updating system unread counts: \(error.localizedDescription)")
                        }
                    }
            }
    }
}
