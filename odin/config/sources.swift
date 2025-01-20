import Foundation
import AppKit

func defaultSources() -> [FeedSource] {
    return [
    FeedSource(
        name: "Google Project Zero",
        type: .rss,
        url: "https://googleprojectzero.blogspot.com/feeds/posts/default?alt=rss",
        imageName: NSImage(named: "p0")!
    ),
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
        name: "r/javascript",
        type: .reddit,
        url: "javascript",
        imageName: NSImage(named: "js")!
    ),
    FeedSource(
        name: "r/fortran",
        type: .reddit,
        url: "fortran",
        imageName: NSImage(named: "fortran")!
    ),
    FeedSource(
        name: "r/rust",
        type: .reddit,
        url: "rust",
        imageName: NSImage(named: "rust")!
    ),
    FeedSource(
        name: "r/zig",
        type: .reddit,
        url: "zig",
        imageName: NSImage(named: "zig")!
    ),
    FeedSource(
        name: "r/swift",
        type: .reddit,
        url: "swift",
        imageName: NSImage(named: "swift")!
    ),
    FeedSource(
        name: "r/python",
        type: .reddit,
        url: "python",
        imageName: NSImage(named: "python")!
    ),
    FeedSource(
        name: "r/MachineLearning",
        type: .reddit,
        url: "MachineLearning",
        imageName: NSImage(named: "ml")!
    ),
    FeedSource(
        name: "r/hackernews",
        type: .reddit,
        url: "hackernews",
        imageName: NSImage(named: "yc")!
    ),
]
}