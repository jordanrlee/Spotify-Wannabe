//
//  PlaylistView.swift
//  Spotify clone
//
//  Created by Jordan on 7/25/22.
//
/*
 This page utilizes the RapidAPI to access the SpotifyAPI and run the tasks coded.
 I needed to parse the url for specific pieces such as the image, the playlist url, and the track information.
 */

import SwiftUI

struct PlaylistModel: Codable {
    struct ItemModel: Codable {
        struct TrackModel: Codable {
            struct AlbumModel: Codable {
                struct ImageModel: Codable {
                    var url: URL
                }
                var images: [ImageModel]
            }
            var album: AlbumModel
            struct ArtistModel: Codable {
                var id: String
                var name: String
            }
            var artists: [ArtistModel]
            var id: String
            var name: String
        }
        var track: TrackModel
    }
    var items: [ItemModel]
}

struct PlaylistView: View {
    var playlistId: String
    @State var playlist: PlaylistModel?
    @Environment(\.managedObjectContext) var objectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id)]) var tracks: FetchedResults<Track>
    
    var body: some View {
        List(playlist?.items ?? [], id: \.track.id) { item in
            Toggle(isOn: .init(
                get: {
                    tracks.filter({$0.id == item.track.id}).first?.favorite ?? false
                }, set: { favorite in
                    tracks.filter({$0.id == item.track.id}).first?.favorite = favorite
                    try? objectContext.save()
                })) {
                HStack {
                    // parse the JSON for the image
                    AsyncImage(
                        url: item.track.album.images.first!.url,
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                    VStack(alignment: .leading) {
                        // get the track name from the playlist
                        Text(item.track.name)
                        // get the artist from the track from the playlist
                        Text(item.track.artists.map({$0.name}).formatted(.list(type: .and)))
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            .task {
                if tracks.filter({$0.id == item.track.id}).count == 0 {
                    // create the track favorites
                    let track = Track(context: objectContext)
                    track.id = item.track.id
                    track.favorite = false
                    print("\(String(describing: track.id)) added to database")
                    try! objectContext.save()
                }
            }
        }
        .toggleStyle(.checkboxStyle)
        .task {
            await getPlaylistTracks()
        }
    }
    
    func getPlaylistTracks() async {
        let url = URL(string: "https://spotify23.p.rapidapi.com/playlist_tracks/?id=\(playlistId)")
        
        var request = URLRequest(url: url!)
        request.addValue("eb4cd4d4d7mshc5a2edd5b4c5e73p10bfdejsn07049408fee8", forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("spotify23.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
//            print(response)
//            print(String(decoding: data!, as: UTF8.self))
            if let data = data {
                do {
                    try playlist = JSONDecoder().decode(PlaylistModel.self, from: data)
                } catch {
                    print(error)
                }
            }
        }
        dataTask.resume()
    }
}

//struct PlaylistView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaylistView()
//    }
//}
