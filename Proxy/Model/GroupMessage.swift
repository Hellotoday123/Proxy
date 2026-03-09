//
//  GroupMessage.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import Foundation

struct GroupMessage: Identifiable, Codable {
    var id: String?
    var senderID: String
    var senderName: String
    var text: String
    var timestamp: Date
    var isSystemMessage: Bool
}
