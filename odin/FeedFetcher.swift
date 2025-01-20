import Foundation
import Combine
import AppKit

@MainActor
class FeedFetcher: ObservableObject {
  @Published var feedItems: [RSSItem] = []
  @Published var loading: Bool = false
  @Published var errorMessage: String?

  private var feedSources: [FeedSource] = defaultSources()

  func loadBlocklists(from jsonFilePath: String) {
    guard let data = FileManager.default.contents(atPath: jsonFilePath) else {
      print("Blocklist JSON file not found at", jsonFilePath)
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

  func fetchFeeds() async {
    loading = true
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
    self.loading = false
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