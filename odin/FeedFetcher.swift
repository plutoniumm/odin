import Foundation
import FeedKit
import SwiftSoup

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String // Updated to store plain text
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

                                // Parse HTML to plain text using SwiftSoup
                                let plainDescription: String
                                do {
                                    plainDescription = try SwiftSoup.parse(description).text()
                                } catch {
                                    plainDescription = description // Fallback to raw description if parsing fails
                                }

                                return RSSItem(
                                    title: title,
                                    description: plainDescription,
                                    link: link,
                                    pubDate: pubDate
                                )
                            } ?? []
                            combinedItems.append(contentsOf: items)
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            self.feedItems = combinedItems.sorted { $0.pubDate > $1.pubDate }
            self.isLoading = false
        }
    }
}
