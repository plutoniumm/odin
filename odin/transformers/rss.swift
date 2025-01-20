import Foundation
import FeedKit
import SwiftSoup

func getRSS(source: FeedSource) async throws -> [RSSItem] {
  let urlString = source.url
  guard let url = URL(string: urlString) else {
    return []
  }

  let parser = FeedParser(URL: url)

  do {
    let feed = try parser.parse().get().rssFeed

    let items = feed?.items?.compactMap { item -> RSSItem? in
      guard
        let title = item.title,
        let description = item.description,
        let link = item.link,
        let pubDate = item.pubDate
      else { return nil }

      var desc: String = description
      do {
        desc = try SwiftSoup.parse(description).text()
      } catch {}

      return RSSItem(
        name: source.name,
        title: title,
        description: desc,
        link: link,
        pubDate: pubDate,
        imageName: source.imageName
      )
    } ?? []
    return items

  } catch {
    return []
  }
}
