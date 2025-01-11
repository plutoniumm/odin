import SwiftUI

struct ContentView: View {
    @StateObject private var feedFetcher = FeedFetcher()

    var body: some View {
        NavigationSplitView {
            List(feedFetcher.feedItems) { item in
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
            .navigationTitle("RSS Feeds")
            .toolbar {
                ToolbarItem {
                    Button(action: feedFetcher.fetchFeeds) {
                        if feedFetcher.isLoading {
                            ProgressView()
                        } else {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .alert("Error", isPresented: .constant(feedFetcher.errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    feedFetcher.errorMessage = nil
                }
            } message: {
                Text(feedFetcher.errorMessage ?? "Unknown error")
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear {
            feedFetcher.fetchFeeds()
        }
    }
}

#Preview {
    ContentView()
}
