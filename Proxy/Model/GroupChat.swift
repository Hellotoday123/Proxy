//
//  GroupChat.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-03-09.
//

import Foundation

struct GroupChat: Identifiable, Codable {
    var id: String?
    var name: String
    var memberIDs: [String]
    var createdBy: String
    var createdAt: Date
    var unreadCounts: [String: Int]
}
