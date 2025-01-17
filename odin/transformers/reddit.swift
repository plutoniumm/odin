import Foundation

class RedditTransformer {
    static func fetchFeed(subreddit: String, completion: @escaping (Result<[RSSItem], Error>) -> Void) {
        let proxyURL = "https://x.manav.ch/p2/proxy?url="
        let redditURL = "https://www.reddit.com/r/\(subreddit)/.json?limit=10"
        guard let url = URL(string: proxyURL + redditURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let children = data["children"] as? [[String: Any]] {

                    let items = children.compactMap { child -> RSSItem? in
                        guard let childData = child["data"] as? [String: Any],
                              let title = childData["title"] as? String,
                              let createdUtc = childData["created_utc"] as? Double,
                              let permalink = childData["permalink"] as? String,
                              let url = childData["url"] as? String else {
                            return nil
                        }

                        let body = (childData["selftext"] as? String) ?? ""
                        if !title.contains("http") && !body.contains("http") {
                            return nil
                        }

                        let link = "https://www.reddit.com\(permalink)"
                        return RSSItem(
                            title: title,
                            description: body,
                            link: url,
                            pubDate: Date(timeIntervalSince1970: createdUtc)
                        )
                    }
                    completion(.success(items))
                } else {
                    completion(.success([]))
                }

            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
