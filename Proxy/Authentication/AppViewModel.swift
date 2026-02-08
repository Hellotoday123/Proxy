//
//  AppViewModel.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreData

@MainActor
class AppViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    @Published var friends: [AppUser] = []
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var db = Firestore.firestore()
    private let viewContext = PersistenceController.shared.container.viewContext
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task { await fetchCurrentUser() }
    }
    
    // MARK: - Authentication
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchCurrentUser()
        } catch {
            self.errorMessage = "Login failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func signUp(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Create new User Model
            let newUser = AppUser(
                id: result.user.uid,
                email: email,
                username: username,
                profilePicURL: "https://via.placeholder.com/150"
            )
            
            // Save to Firestore
            try await db.collection("users").document(result.user.uid).setData(newUser.dictionary)
            
            self.currentUser = newUser
            saveUserToCoreData(user: newUser)
            
        } catch {
            self.errorMessage = "Signup failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
        self.friends = []
    }
    
    // MARK: - Firestore & CoreData
    func fetchCurrentUser() async {
        guard let uid = userSession?.uid else { return }
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            if let data = snapshot.data() {
                // Manually mapping if needed, or use Codable
                var user = try snapshot.data(as: AppUser.self)
                self.currentUser = user
                
                // Sync with CoreData
                saveUserToCoreData(user: user)
                
                // Fetch Friend details
                if !user.friendIDs.isEmpty {
                    await fetchFriends(ids: user.friendIDs)
                }
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
    
    private func saveUserToCoreData(user: AppUser) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CachedUser")
        request.predicate = NSPredicate(format: "id == %@", user.id ?? "")
        
        do {
            let results = try viewContext.fetch(request)
            let cachedUser = results.first ?? NSEntityDescription.insertNewObject(forEntityName: "CachedUser", into: viewContext)
            
            cachedUser.setValue(user.id, forKey: "id")
            cachedUser.setValue(user.username, forKey: "username")
            cachedUser.setValue(user.profilePicURL, forKey: "profilePicURL")
            
            try viewContext.save()
            print("User cached to CoreData successfully")
        } catch {
            print("CoreData Error: \(error)")
        }
    }
    
    // MARK: - Profile Updates
    func updateProfilePic(url: String) async {
        guard let uid = currentUser?.id else { return }
        do {
            try await db.collection("users").document(uid).updateData(["profilePicURL": url])
            self.currentUser?.profilePicURL = url
            if let user = self.currentUser {
                saveUserToCoreData(user: user)
            }
        } catch {
            errorMessage = "Failed to update profile pic."
        }
    }
    
    // MARK: - Friends Logic
    func sendFriendRequest(to targetEmail: String) async {
        // In a real app, query by email to find the ID

        let targetID = targetEmail
        
        guard let myID = currentUser?.id else { return }
        
        do {
            try await db.collection("users").document(targetID).updateData([
                "pendingRequests": FieldValue.arrayUnion([myID])
            ])
            print("Request sent to \(targetID)")
        } catch {
            errorMessage = "User not found"
        }
    }
    
    func acceptFriendRequest(from userID: String) async {
        guard let myID = currentUser?.id else { return }
        do {
            let batch = db.batch()
            let myRef = db.collection("users").document(myID)
            let theirRef = db.collection("users").document(userID)
            
            batch.updateData([
                "pendingRequests": FieldValue.arrayRemove([userID]),
                "friendIDs": FieldValue.arrayUnion([userID])
            ], forDocument: myRef)
            
            batch.updateData([
                "friendIDs": FieldValue.arrayUnion([myID])
            ], forDocument: theirRef)
            
            try await batch.commit()
            await fetchCurrentUser()
        } catch {
            errorMessage = "Failed to accept friend"
        }
    }
    
    func fetchFriends(ids: [String]) async {
        guard !ids.isEmpty else { return }
        do {
 
            let snapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: ids)
                .getDocuments()
            
            self.friends = snapshot.documents.compactMap { try? $0.data(as: AppUser.self) }
        } catch {
            print("Error fetching friends list")
        }
    }
}
