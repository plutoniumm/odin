//
//  odinApp.swift
//  odin
//
//  Created by Manav Seksaria on 11/01/25.
//

import Foundation
import MarkdownUI
import SwiftUI
import Cocoa

struct ContentView: View {
    @StateObject private var feedFetcher = FeedFetcher()

    let size: CGFloat = 36;
    var body: some View {
        List(feedFetcher.feedItems) { item in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(nsImage: item.imageName!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.headline)
                        HStack {
                            Text(item.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(
                                item.pubDate,
                                format: Date.FormatStyle(date: .long, time: .shortened)
                            )
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }

              Markdown(item.description)
                    .font(.body)
                    .lineLimit(3)
                    .truncationMode(.tail)
//                    .markdownImageProvider(.webImage)
            }
            .padding(.vertical, 4)
            .onTapGesture(count: 2) {
                if let url = URL(string: item.link) {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .navigationTitle("Odin")
        .toolbar {
            ToolbarItem {
              Button(action: {Task{ feedFetcher.fetchFeeds }}) {
                  if feedFetcher.loading < 1 {
                    ProgressView(value: feedFetcher.loading)
                        .progressViewStyle(CircularProgressViewStyle())
                  } else {
                      Label("Refresh", systemImage: "arrow.clockwise")
                  }
              }
            }

        }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .alert("Error", isPresented: .constant(feedFetcher.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                feedFetcher.errorMessage = nil
            }
        } message: {
            Text(feedFetcher.errorMessage ?? "Unknown error")
        }
        .onAppear {
          Task{ await feedFetcher.fetchFeeds() }
        }
    }
}

#Preview {
    ContentView()
}

@main
struct odinApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
