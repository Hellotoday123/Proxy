//
//  Message.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//
//
//  Message.swift
//  Pulse
//
//  Created by Ping & Kevin
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    
    let senderID: String
    let text: String
    let timestamp: Date
    
    // Default init generates a UUID
    init(id: String = UUID().uuidString, senderID: String, text: String, timestamp: Date = Date()) {
        self.id = id
        self.senderID = senderID
        self.text = text
        self.timestamp = timestamp
    }
    
    var dictionary: [String: Any] {
        return [
            "senderID": senderID,
            "text": text,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}
