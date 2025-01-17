import Foundation
import Combine

class FeedFetcher: ObservableObject {
    @Published var feedItems: [RSSItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var feedSources: [FeedSource] = [
        FeedSource(name: "Quanta Magazine", type: .rss, url: "https://www.quantamagazine.org/quanta/feed/"),
        FeedSource(name: "Nautilus", type: .rss, url: "https://nautil.us/feed/"),
        FeedSource(name: "r/javascript", type: .reddit, url: "javascript"),
        FeedSource(name: "r/fortran", type: .reddit, url: "fortran")
    ]

    func loadBlocklists(from jsonFilePath: String) {
        guard let data = FileManager.default.contents(atPath: jsonFilePath) else {
            print("Blocklist JSON file not found.")
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
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let items):
                            let filteredItems = self.filterItems(items, with: source.blocklist)
                            combinedItems.append(contentsOf: filteredItems)
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                        }
                        group.leave()
                    }
                }

            case .reddit:
                RedditTransformer.fetchFeed(subreddit: source.url) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let items):
                            let filteredItems = self.filterItems(items, with: source.blocklist)
                            combinedItems.append(contentsOf: filteredItems)
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
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
