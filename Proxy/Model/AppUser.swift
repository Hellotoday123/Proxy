//
//  AppUser.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//

//
//  AppUser.swift
//  Pulse
//
//  Created by Ping & Kevin
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {

    @DocumentID var id: String?
  
    var userUUID: String
    var email: String
    var username: String
    var profilePicURL: String
    var friendIDs: [String]
    var pendingRequests: [String]
    
    // Standard Init
    init(id: String? = nil, email: String, username: String, profilePicURL: String) {
        self.id = id
        self.userUUID = UUID().uuidString // Generates a unique UUID
        self.email = email
        self.username = username
        self.profilePicURL = profilePicURL
        self.friendIDs = []
        self.pendingRequests = []
    }
    
    // Helper for Firestore dictionary conversion
    var dictionary: [String: Any] {
        return [
            "userUUID": userUUID,
            "email": email,
            "username": username,
            "profilePicURL": profilePicURL,
            "friendIDs": friendIDs,
            "pendingRequests": pendingRequests
        ]
    }
}
