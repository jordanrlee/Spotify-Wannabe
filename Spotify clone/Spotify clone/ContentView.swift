//
//  ContentView.swift
//  Spotify clone
//
//  Created by Jordan on 7/24/22.
//

import SwiftUI

struct CheckboxStyle : ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            // create the checkbox style for the app, in this version, I used a star because it made more sense for the app to favorite it with a filled star or no fill on default.
            
//            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            if configuration.isOn {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "star")
                    .foregroundColor(.gray)
            }
            configuration.label
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

extension ToggleStyle where Self == CheckboxStyle {
    static var checkboxStyle : CheckboxStyle { CheckboxStyle() }
}

struct ContentView: View {
    var body: some View {
        TabView {
            // create the symbols for the tappable views
            ListView()
                .tabItem {
                    Label("Song Database", systemImage: "shippingbox.fill")
                }
            NavigationView {
                UserView()
            }
                .tabItem {
                    Label("Spotify Playlist", systemImage: "desktopcomputer")
                }
        }
    }
}

struct ListView: View {
    @EnvironmentObject var songs: Songs
    var songName = "Song Name"
    var artistName = "Artist name"
    var Title = "Spotify Clone"
    var body: some View {
        NavigationView {
            List{
                ForEach(Array(songs.songs.enumerated()), id: \.element.theSong) {
                index, song in
                    Toggle(isOn: .constant(false)) {
                        NavigationLink {
                            // the nav link to EditSong view
                            EditSong(songIndex: index)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(song.theSong)
                                Text(song.theArtist)
                                .font(.caption)
                            }
                        }
                    }
                    .toggleStyle(.checkboxStyle)
                }
                .onDelete{
                    offset in
                    songs.remove(atOffsets: offset)
                }
            }
            .navigationTitle(Title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                //Toggle("Show Only Favorite Songs", isOn: $showOnlyFavorites)
                //    .padding(10)
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink("Add") {
                        EditSong()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Songs(
                sqlUrl: Bundle.main.url(
                    forResource: "SongDatabase",
                    withExtension: "sqlite")!
            ))
    }
}
