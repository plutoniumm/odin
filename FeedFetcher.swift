import Foundation
import FeedKit

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let pubDate: Date
}

class FeedFetcher: ObservableObject {
    @Published var feedItems: [RSSItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetchFeeds() {
        isLoading = true
        errorMessage = nil

        let feedURLs = [
            "https://www.quantamagazine.org/quanta/feed/",
            "https://nautil.us/feed/"
        ]

        let group = DispatchGroup()
        var combinedItems: [RSSItem] = []

        for urlString in feedURLs {
            guard let url = URL(string: urlString) else {
                errorMessage = "Invalid feed URL: \(urlString)"
                continue
            }

            group.enter()
            let parser = FeedParser(URL: url)

            parser.parseAsync { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let feed):
                        if let rssFeed = feed.rssFeed {
                            let items: [RSSItem] = rssFeed.items?.compactMap { item in
                                guard
                                    let title = item.title,
                                    let description = item.description,
                                    let link = item.link,
                                    let pubDate = item.pubDate
                                else {
                                    return nil
                                }
                                return RSSItem(title: title, description: description, link: link, pubDate: pubDate)
                            } ?? []
                            combinedItems.append(contentsOf: items)
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                    group.leave()
                }
            }
          
          // show in console
          NSLog("%s", urlString);
        }

        group.notify(queue: .main) {
            self.feedItems = combinedItems.sorted { $0.pubDate > $1.pubDate }
            self.isLoading = false
        }
    }
}
