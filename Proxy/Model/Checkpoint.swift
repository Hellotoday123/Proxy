//
//  Checkpoint.swift
//  Proxy
//
//  Created by user285973 on 3/2/26.
//

import Foundation
import FirebaseFirestore

struct Checkpoint: Identifiable {
    let id: String
    var name: String
    var type: String
    var latitude: Double
    var longitude: Double
    var question: String
    var questionBy: String
    var questionByUsername: String
    var createdAt: Date?

    init(id: String, dict: [String: Any]) {
        self.id = id
        self.name = dict["name"] as? String ?? ""
        self.type = dict["type"] as? String ?? "park"
        self.latitude = dict["latitude"] as? Double ?? 0.0
        self.longitude = dict["longitude"] as? Double ?? 0.0
        self.question = dict["question"] as? String ?? ""
        self.questionBy = dict["questionBy"] as? String ?? ""
        self.questionByUsername = dict["questionByUsername"] as? String ?? ""
        if let ts = dict["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }
    }
}

struct CheckpointMessage: Identifiable {
    let id: String
    let userId: String
    let username: String
    let text: String
    let timestamp: Date

    init(id: String, dict: [String: Any]) {
        self.id = id
        self.userId = dict["userId"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.text = dict["text"] as? String ?? ""
        self.timestamp = (dict["timestamp"] as? Timestamp)?.dateValue() ?? Date()
    }
}
