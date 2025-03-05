import Foundation
import Combine
import AppKit

@MainActor
class FeedFetcher: ObservableObject {
  @Published var feedItems: [RSSItem] = []
  @Published var loading: Double = 0.0
  @Published var errorMessage: String?
  

  private var feedSources: [FeedSource] = defaultSources()

  func fetchFeeds() async {
    loading = (1/Double(feedSources.count));
    errorMessage = nil

    var combined: [RSSItem] = []

    await withTaskGroup(of: (String, Result<[RSSItem], Error>).self) { group in
      for source in feedSources {
        group.addTask {
          do {

            let items: [RSSItem]
            switch source.type {
            case .rss:
                items = try await getRSS(source: source)
            case .reddit:
                items = try await getReddit(source: source)
            }
            return (source.name, .success(items))
          } catch {
            return (source.name, .failure(error))
          }
        }
      }

      for await (sourceName, result) in group {
          switch result {
              case .success(let items):
                let filtered = self.process(items, blocklist: feedSources.first { $0.name == sourceName }?.blocklist ?? [])
                combined.append(contentsOf: filtered)
              case .failure(let error):
                self.errorMessage = error.localizedDescription
                print(sourceName, error.localizedDescription)
          }
        }
    }

    self.feedItems = combined.sorted { $0.pubDate > $1.pubDate }
    self.loading = 1
  }

  private func process(_ items: [RSSItem], blocklist: [String]) -> [RSSItem] {
    let limitDate = Date().addingTimeInterval(-7 * 86400) // 7 days ago

    return items.filter { item in
      if (item.description.count > 500) || (item.pubDate <= limitDate) {
        return false
      }

      let isBlocked = blocklist.contains { blockWord in
        item.title.contains(blockWord) || item.description.contains(blockWord)
      }
      if isBlocked { return false }

      return true
    }
  }
}
