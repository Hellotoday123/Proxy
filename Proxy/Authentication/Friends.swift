//
//  Friends.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-02-08.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

extension AppViewModel {
    
    func fetchAllUsers() {
        db.collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("DEBUG: Failed to fetch users: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                self.allUsers = documents.compactMap { doc in
                    AppUser(id: doc.documentID, dict: doc.data())
                }
            }
        }
    }
    // MARK: - Friends Logic

    func sendFriendRequest(to targetEmail: String) async {
        guard let myID = currentUser?.id else { return }

        do {
            let querySnapshot = try await db.collection("users")
                .whereField("email", isEqualTo: targetEmail)
                .getDocuments()

            guard let document = querySnapshot.documents.first else {
                errorMessage = "User with email \(targetEmail) not found."
                return
            }

            let targetID = document.documentID

            try await db.collection("users").document(targetID).updateData([
                "pendingRequests": FieldValue.arrayUnion([myID])
            ])

            await MainActor.run {
                if let index = self.allUsers.firstIndex(where: { $0.id == targetID }) {
                    if !self.allUsers[index].pendingRequests.contains(myID) {
                        self.allUsers[index].pendingRequests.append(myID)
                    }
                }
            }

            print("DEBUG: Request Sent to \(targetID)")

        } catch {
            errorMessage = "Failed: \(error.localizedDescription)"
        }
    }

    func acceptFriendRequest(from requesterID: String) async {
        guard let myID = currentUser?.id else { return }

        let batch = db.batch()
        let myRef = db.collection("users").document(myID)
        let requesterRef = db.collection("users").document(requesterID)

        batch.updateData([
            "friendIDs": FieldValue.arrayUnion([requesterID]),
            "pendingRequests": FieldValue.arrayRemove([requesterID])
        ], forDocument: myRef)

        batch.updateData([
            "friendIDs": FieldValue.arrayUnion([myID])
        ], forDocument: requesterRef)

        do {
            try await batch.commit()
            fetchCurrentUser()
        } catch {
            print("DEBUG: Error accepting request")
        }
    }
    
    func withdrawFriendRequest(to targetUserID: String) async {
        guard let myID = currentUser?.id else { return }

        do {
            try await db.collection("users").document(targetUserID).updateData([
                "pendingRequests": FieldValue.arrayRemove([myID])
            ])

            print("DEBUG: Friend request withdrawn from \(targetUserID)")
        } catch {
            print("DEBUG: Failed to withdraw request: \(error.localizedDescription)")
        }
    }

    func rejectFriendRequest(from requesterID: String) async {
        guard let myID = currentUser?.id else { return }

        do {
            try await db.collection("users").document(myID).updateData([
                "pendingRequests": FieldValue.arrayRemove([requesterID])
            ])

            fetchCurrentUser()

            print("DEBUG: Friend request declined")

        } catch {
            print("DEBUG: Error rejecting request")
        }
    }

    func removeFriend(friendID: String) async {
        guard let currentUID = currentUser?.id else {
            print("DEBUG: No current user ID")
            return
        }

        do {
            let currentUserRef = db.collection("users").document(currentUID)
            let friendRef = db.collection("users").document(friendID)

            try await currentUserRef.updateData([
                "friendIDs": FieldValue.arrayRemove([friendID])
            ])

            try await friendRef.updateData([
                "friendIDs": FieldValue.arrayRemove([currentUID])
            ])

            await MainActor.run {
                self.friends.removeAll { $0.id == friendID }
            }

            fetchCurrentUser()
            fetchGroupChats()

            print("DEBUG: Friend removed successfully")
        } catch {
            print("DEBUG: Failed to remove friend: \(error.localizedDescription)")
        }
    }
    
}
