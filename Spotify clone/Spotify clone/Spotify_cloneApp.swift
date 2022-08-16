//
//  Spotify_cloneApp.swift
//  Spotify clone
//
//  Created by Jordan on 7/24/22.
//

import SwiftUI

@main
struct Spotify_cloneApp: App {
    @StateObject var songs: Songs
    @StateObject var dataController = DataController()
    
    init() {
        guard let url = Bundle.main.url(
            forResource: "SongDatabase",
            withExtension: "sqlite") else
        {
            print("cant find the database")
            abort()
        }
        _songs = StateObject(wrappedValue: Songs(sqlUrl: url))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // add the functionality to the Items for content view!!
                .environmentObject(songs)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
