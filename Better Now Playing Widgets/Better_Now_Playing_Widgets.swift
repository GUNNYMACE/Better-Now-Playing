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
        SimpleEntry(date: .now, currentMusicData: MusicMetaData(songTitle: "Fetching Song", songArtist: "Fetching Artist", songAlbumTitle: "Fetching Album"))
    }
    
    //The Main Data for the Widget.
    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void
    ) {
        var entries: [SimpleEntry] = []
        //Make a TEMP TIMELINE
        //(Updates on timer.)
        let currentDate = Date()
        for hourOffset in 0 ..< 10 {
            //Get Time
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            //Get Data
        var entry: SimpleEntry = SimpleEntry(date: entryDate, currentMusicData: MusicMetaData(songTitle: "Data Failure", songArtist: "-", songAlbumTitle: "data failed to load"))
            
            if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.betternowplaying.datashare") {
                let fileURL = sharedContainerURL.appendingPathComponent("MMDData.json")
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    let incomingData = try JSONDecoder().decode(MusicMetaData.self, from: data)
                        //Make Entry
                    entry = SimpleEntry(date: entryDate, currentMusicData: MusicMetaData(songTitle: incomingData.title ?? "-", songArtist: incomingData.artist ?? "Update Data", songAlbumTitle: incomingData.album ?? "-"))
                } catch {
                    fatalError("Error reading file: \(error)")
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
        let entry = SimpleEntry(date: .now, currentMusicData: MusicMetaData(songTitle: "SNAPSHOT", songArtist: "SNAPSHOT", songAlbumTitle: "SNAPSHOT"))
        completion(entry)
    }
}

//The Data for the Widget.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let currentMusicData: MusicMetaData
}
struct Better_Now_Playing_WidgetsEntryView : View {
    var entry: Provider.Entry
    var musicData: Provider.Entry
    
    var body: some View {
        HStack {
            //Image(systemName: "music.note")
            VStack(alignment: .leading) {
                Text(musicData.currentMusicData.title ?? "-")
                Text(musicData.currentMusicData.artist ?? "No Song Currently Playing")
                Text(musicData.currentMusicData.album ?? "-")
            }
        }
    }
}
@main
struct Better_Now_Playing_Widgets: Widget {
    let kind: String = "Better_Now_Playing_Widgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Better_Now_Playing_WidgetsEntryView(entry: entry, musicData: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular])
    }
}
#Preview(as: .accessoryRectangular) {
    Better_Now_Playing_Widgets()
} timeline: {
    SimpleEntry(date: .now, currentMusicData: MusicMetaData(songTitle: "Starless", songArtist: "King Chrimson", songAlbumTitle: "Red (Expanded & Remastered)"))
    SimpleEntry(date: .now, currentMusicData: MusicMetaData(songTitle: "Unsainted", songArtist: "Slipknot", songAlbumTitle: "?"))
}

