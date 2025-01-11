//
//  ContentView.swift
//  odin
//
//  Created by Manav Seksaria on 11/01/25.
//

import SwiftUI
import FeedKit

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let pubDate: Date
}

struct ContentView: View {
    @State private var feedItems: [RSSItem] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationSplitView {
            List(feedItems) { item in
                NavigationLink {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.description)
                            .font(.body)
                        Spacer()
                        Link("Read More", destination: URL(string: item.link)!)
                    }
                    .padding()
                } label: {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.pubDate, format: Date.FormatStyle(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .navigationTitle("Quanta RSS Feed")
            .toolbar {
                ToolbarItem {
                    Button(action: fetchFeed) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear {
            fetchFeed()
        }
    }

    private func fetchFeed() {
        isLoading = true
        errorMessage = nil

        guard let feedURL = URL(string: "https://www.quantamagazine.org/quanta/feed/") else {
            errorMessage = "Invalid feed URL"
            isLoading = false
            return
        }

        let parser = FeedParser(URL: feedURL)

        parser.parseAsync { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let feed):
                    if let rssFeed = feed.rssFeed {
                        feedItems = rssFeed.items?.compactMap { item in
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
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
