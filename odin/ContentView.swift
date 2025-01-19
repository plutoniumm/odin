import MarkdownUI
import SwiftUI
import Cocoa

struct ContentView: View {
    @StateObject private var feedFetcher = FeedFetcher()

    let size: CGFloat = 25;
    var body: some View {
        List(feedFetcher.feedItems) { item in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                  Image(nsImage: item.imageName!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.pubDate, format: Date.FormatStyle(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

              Markdown(item.description)
//                    .font(.body)
//                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            .onTapGesture(count: 2) {
                if let url = URL(string: item.link) {
                    if NSWorkspace.shared.open(url) {
                        print("default browser was successfully opened")
                    }
                }
            }
        }
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
        .onAppear {
            feedFetcher.fetchFeeds()
        }
    }
}

#Preview {
    ContentView()
}
