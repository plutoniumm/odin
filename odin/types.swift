//
//  types.swift
//  odin
//
//  Created by Manav Seksaria on 17/01/25.
//

import Foundation
import AppKit

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let pubDate: Date
    var imageName: NSImage?
}

struct FeedSource {
    let name: String
    let type: FeedType
    let url: String
    var blocklist: [String] = []
    let imageName: NSImage
}

enum FeedType {
    case rss
    case reddit
}
