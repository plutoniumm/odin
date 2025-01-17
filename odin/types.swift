//
//  types.swift
//  odin
//
//  Created by Manav Seksaria on 17/01/25.
//

import Foundation

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let pubDate: Date
}

struct FeedSource {
    let name: String
    let type: FeedType
    let url: String
    var blocklist: [String] = []
}

enum FeedType {
    case rss
    case reddit
}
