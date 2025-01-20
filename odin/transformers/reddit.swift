import Foundation

func getReddit(source: FeedSource) async throws -> [RSSItem] {
  let subreddit = source.url
  let redditURL = "https://www.reddit.com/r/\(subreddit)/.json?limit=20"
  guard let url = URL(string: PROXY + redditURL) else {
    return []
  }

  let (data, _) = try await URLSession.shared.data(from: url)

  if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
    let data = json["data"] as? [String: Any],
    let children = data["children"] as? [[String: Any]] {

    let items = children.compactMap { child -> RSSItem? in
      guard let childData = child["data"] as? [String: Any],
          let title = childData["title"] as? String,
          let body = childData["selftext"] as? String,
          let createdUtc = childData["created_utc"] as? Double,
          let url = childData["url"] as? String else {
        return nil
      }

      if !title.contains("https") && !body.contains("https") {
        return nil
      }

      return RSSItem(
        name: source.name,
        title: title,
        description: body,
        link: url,
        pubDate: Date(timeIntervalSince1970: createdUtc),
        imageName: source.imageName
      )
    }
    return items
  } else {
    return []
  }
}
