import Foundation
import AppKit

func defaultSources() -> [FeedSource] {
    return [
//    FeedSource(
//        name: "Google Project Zero",
//        type: .rss,
//        url: "https://googleprojectzero.blogspot.com/feeds/posts/default?max-results=3&alt=rss",
//        imageName: NSImage(named: "p0")!
//    ),
    FeedSource(
        name: "The Pudding",
        type: .rss,
        url: "https://pudding.cool/rss.xml",
        imageName: NSImage(named: "pudding")!
    ),
    FeedSource(
        name: "Terry Tao",
        type: .rss,
        url: "https://mathstodon.xyz/@tao.rss",
        imageName: NSImage(named: "ttao")!
    ),
    FeedSource(
        name: "Quanta Mag: Mathematics",
        type: .rss,
        url: "https://www.quantamagazine.org/mathematics/feed/",
        imageName: NSImage(named: "quanta")!
    ),
    FeedSource(
        name: "Quanta Mag: Physics",
        type: .rss,
        url: "https://www.quantamagazine.org/physics/feed/",
        imageName: NSImage(named: "quanta")!
    ),
    FeedSource(
        name: "Quanta Mag: Computer Science",
        type: .rss,
        url: "https://www.quantamagazine.org/computer-science/feed/",
        imageName: NSImage(named: "quanta")!
    ),
    FeedSource(
        name: "Nautilus",
        type: .rss,
        url: "https://nautil.us/feed/",
        imageName: NSImage(named: "nautilus")!
    ),
    FeedSource(
        name: "Reddit Integrated",
        type: .reddit,
        url: "user/xplutonium/m/home",
        imageName: NSImage(named: "yc")!
    ),
]
}
