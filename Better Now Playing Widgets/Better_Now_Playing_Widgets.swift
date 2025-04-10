//
//  Better_Now_Playing_Widgets.swift
//  Better Now Playing Widgets
//
//  Created by Mason Likens on 10/29/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    //Shows when loading the data for the widget.
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, songTitle: "Fetching Song", songArtist: "Fetching Artist", albumTitle: "Fetching Album", artwork: UIImage(named: "DownsizedBlank"))
    }
    
    //The Main Data for the Widget.
    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void
    ) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        for hourOffset in 0 ..< 10 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            var entry = SimpleEntry(date: entryDate, songTitle: "Data Failure", songArtist: "-", albumTitle: "data failed to load", artwork: UIImage(named: "DownsizedBlank"))
            
            if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.betternowplaying.datashare") {
                let fileURL = sharedContainerURL.appendingPathComponent("MMDData.json")
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    let incomingData = try JSONDecoder().decode([String: String].self, from: data)
                    
                    // Load the image from the file path
                    let artwork: UIImage?
                    if let artworkPath = incomingData["artworkPath"] {
                        let artworkFileURL = sharedContainerURL.appendingPathComponent(artworkPath)
                        if let imageData = try? Data(contentsOf: artworkFileURL) {
                            artwork = UIImage(data: imageData)
                        } else {
                            artwork = UIImage(named: "MusicBlank") // Default image
                        }
                    } else {
                        artwork = UIImage(named: "MusicBlank") // Default image
                    }
                    
                    entry = SimpleEntry(
                        date: entryDate,
                        songTitle: incomingData["title"] ?? "-",
                        songArtist: incomingData["artist"] ?? "Update Data",
                        albumTitle: incomingData["album"] ?? "-",
                        artwork: artwork
                    )
                } catch {
                    print("Error reading file: \(error)")
                }
            }
            
            entries.append(entry)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
    
    //Shows when selecting a widget in the gallery.
    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        let entry = SimpleEntry(date: .now, songTitle: "Your Song", songArtist: "Right", albumTitle: "Here", artwork: UIImage(named: "DownsizedBlank"))
        completion(entry)
    }
}

//The Data for the Widget.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let songTitle: String
    let songArtist: String
    let albumTitle: String
    let artwork: UIImage?
}

struct AccessoryRectangularWidget: Widget {
    let kind: String = "AccessoryRectangularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HStack {
                Image(uiImage: entry.artwork ?? UIImage(named: "DownsizedBlank")!)
                    .resizable()
                    .scaledToFit()
                    //.frame(width: 50, height: 50) // Adjust size for rectangular widget
                    .clipShape(RoundedRectangle(cornerRadius: 15)) // Rounded rectangle for artwork
            
                VStack(alignment: .leading) {
                    Text(entry.songTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text(entry.songArtist)
                        .font(.caption2)
                        .lineLimit(1)
                    Text(entry.albumTitle)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
            .padding()
            .containerBackground(Color.clear, for: .widget)
        }
        .configurationDisplayName("Rectangle Info")
        .description("Displays the current song information in a rectangular format.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct ArtworkOnlyCircularWidget: Widget {
    let kind: String = "ArtworkOnlyCircularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ZStack {
                Image(uiImage: entry.artwork ?? UIImage(named: "DownsizedBlank")!)
                    .resizable()
                    .scaledToFill()
                    //.frame(width: 30, height: 30) // Adjust size for rectangular widget
                    .clipShape(RoundedRectangle(cornerRadius: 45)) // Rounded rectangle for artwork
            }
            .containerBackground(Color.clear, for: .widget) // Adopt container background
        }
        .configurationDisplayName("Circle Artwork")
        .description("Displays the current song's album artwork in a circular format.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct AccessoryCornerWidget: Widget {
    let kind: String = "AccessoryCornerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ZStack {
                Image(uiImage: entry.artwork ?? UIImage(named: "DownsizedBlank")!)
                    .resizable()
                    .scaledToFit()
                    //.frame(width: 50, height: 50) // Adjust size for rectangular widget
                    .clipShape(RoundedRectangle(cornerRadius: 8)) // Rounded rectangle for artwork
                    .tint(nil)
            }
            .containerBackground(Color.clear, for: .widget)
            .widgetLabel(entry.songTitle)
        }
        .configurationDisplayName("Corner Artwork W/ Song Title")
        .description("Displays circular artwork with song name wrapping around the clock.")
        .supportedFamilies([.accessoryCorner])
    }
}

struct AccessoryInlineWidget: Widget {
    let kind: String = "AccessoryInlineWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HStack {
                Text("\(entry.songTitle), By: \(entry.songArtist)")
                    .font(.body)
                    //.lineLimit(1)
            }
        }
        .configurationDisplayName("Inline Title & Artist")
        .description("Displays the current song name and artist.")
        .supportedFamilies([.accessoryInline])
    }
}

@main
struct Better_Now_Playing_Widgets: WidgetBundle {
    var body: some Widget {
        AccessoryRectangularWidget()
        ArtworkOnlyCircularWidget()
        AccessoryCornerWidget()
        AccessoryInlineWidget()
    }
}

#Preview(as: .accessoryCircular) {
    ArtworkOnlyCircularWidget()
} timeline: {
    SimpleEntry(date: .now, songTitle: "Starless", songArtist: "King Crimson", albumTitle: "Red (Expanded & Remastered)", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Unsainted", songArtist: "Slipknot", albumTitle: "?", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Reallly Long Name Testing Type Truncation", songArtist: "buh man the 3rd one hehehaha", albumTitle: "?", artwork: UIImage(named: "DownsizedBlank"))
}

#Preview(as: .accessoryRectangular) {
    AccessoryRectangularWidget()
} timeline: {
    SimpleEntry(date: .now, songTitle: "Starless", songArtist: "King Crimson", albumTitle: "Red (Expanded & Remastered)", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Unsainted", songArtist: "Slipknot", albumTitle: "WompWomp", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Reallly Long Name Testing Type Truncation", songArtist: "buh man the 3rd one hehehaha", albumTitle: "?", artwork: UIImage(named: "DownsizedBlank"))
}

#Preview(as: .accessoryCorner) {
    AccessoryCornerWidget()
} timeline: {
    SimpleEntry(date: .now, songTitle: "Starless", songArtist: "King Crimson", albumTitle: "Red (Expanded & Remastered)", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Unsainted", songArtist: "Slipknot", albumTitle: "?", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Reallly Long Name Testing Type Truncation", songArtist: "buh man the 3rd one hehehaha", albumTitle: "?", artwork: UIImage(named: "DownsizedBlank"))
}

#Preview(as: .accessoryInline) {
    AccessoryInlineWidget()
} timeline: {
    SimpleEntry(date: .now, songTitle: "Starless", songArtist: "King Crimson", albumTitle: "Red (Expanded & Remastered)", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Unsainted", songArtist: "Slipknot", albumTitle: "?", artwork: UIImage(named: "DownsizedBlank"))
    SimpleEntry(date: .now, songTitle: "Reallly Long Name Testing Type Truncation", songArtist: "buh man the 3rd one hehehaha", albumTitle: "?", artwork: UIImage(named: "DownsizedBlank"))
}
