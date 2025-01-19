import Foundation
import FeedKit
import SwiftSoup

class RSSTransformer {
    static func fetchFeed(urlString: String, completion: @escaping (Result<[RSSItem], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        let parser = FeedParser(URL: url)

        parser.parseAsync { result in
            switch result {
            case .success(let feed):
                if let rssFeed = feed.rssFeed {
                    let items = rssFeed.items?.compactMap { item -> RSSItem? in
                        guard
                            let title = item.title,
                            let description = item.description,
                            let link = item.link,
                            let pubDate = item.pubDate
                        else { return nil }

                        var desc: String
                        do {
                            desc = try SwiftSoup.parse(description).text()
                        } catch {
                            desc = description
                        }
                        let len = min(desc.count, 500)

                        desc = String(desc[..<desc.index(desc.startIndex, offsetBy: len)])

                        return RSSItem(
                            title: title,
                            description: desc,
                            link: link,
                            pubDate: pubDate
                        )
                    } ?? []
                    completion(.success(items))
                } else {
                    completion(.success([]))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
