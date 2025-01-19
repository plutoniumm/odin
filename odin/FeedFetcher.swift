import Foundation
import Combine
import AppKit

class FeedFetcher: ObservableObject {
    @Published var feedItems: [RSSItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var feedSources: [FeedSource] = [
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

    func loadBlocklists(from jsonFilePath: String) {
        guard let data = FileManager.default.contents(atPath: jsonFilePath) else {
          print("Blocklist JSON file not found at", jsonFilePath);
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]] {
                for (name, blocklist) in json {
                    if let index = feedSources.firstIndex(where: { $0.name == name }) {
                        feedSources[index].blocklist = blocklist
                    }
                }
            }
        } catch {
            print("Error parsing blocklist JSON: \(error.localizedDescription)")
        }
    }

    func fetchFeeds() {
        isLoading = true
        errorMessage = nil

        let group = DispatchGroup()
        var combinedItems: [RSSItem] = []

        for source in feedSources {
            group.enter()
            switch source.type {
            case .rss:
                RSSTransformer.fetchFeed(urlString: source.url) { result in
                  print("Rendering ", source.name);
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let items):
                            var filteredItems = self.filterItems(items, with: source.blocklist)
                            for i in 0..<filteredItems.count {
                                filteredItems[i].imageName = source.imageName
                            }
                            combinedItems.append(contentsOf: filteredItems)
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            print(source.name, error.localizedDescription)
                        }
                        group.leave()
                    }
                }

            case .reddit:
                RedditTransformer.fetchFeed(subreddit: source.url) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let items):
                            var filteredItems = self.filterItems(items, with: source.blocklist)
                            for i in 0..<filteredItems.count {
                                filteredItems[i].imageName = source.imageName
                            }
                            combinedItems.append(contentsOf: filteredItems)
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            print(source.name, error.localizedDescription)
                        }
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            self.feedItems = combinedItems.sorted { $0.pubDate > $1.pubDate }
            self.isLoading = false
        }
    }

    private func filterItems(_ items: [RSSItem], with blocklist: [String]) -> [RSSItem] {
        return items.filter { item in
            !blocklist.contains { blockWord in
                item.title.contains(blockWord) || item.description.contains(blockWord)
            }
        }
    }
}
