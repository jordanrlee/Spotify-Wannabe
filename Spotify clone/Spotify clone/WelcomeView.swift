//
//  WelcomeView.swift
//  Spotify clone
//
//  Created by Jordan on 7/24/22.
//

import SwiftUI

struct UserModel: Codable {
    var uri: String
    var name: String
    struct PlaylistModel: Codable {
        var uri: String
        var name: String
        var image_url: String
    }
    var public_playlists: [UserModel.PlaylistModel]
}

struct UserView: View {
    @State var user: UserModel?
    
    var body: some View {
        List(user?.public_playlists ?? [], id: \.uri) { playlist in
            NavigationLink {
//                Text(playlist.name)
                // Here I needed to parse the JSON inspected info and seperate the string into each piece I need.
                // a simple seperate was used and seperated by ":"
                PlaylistView(playlistId: playlist.uri.components(separatedBy: ":").last!)
            } label: {
                HStack {
                    AsyncImage(
                        url: URL(string: "https://i.scdn.co/image/\( playlist.image_url.components(separatedBy: ":").last!)"),
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                        },
                        placeholder: {
                            ProgressView()
                        })
                    Text(playlist.name)
                }
            }
        }
        .task {
            await getUserProfile()
        }
    }
    
    func getUserProfile() async {
        // add the user profile of my choosing by getting it from the spotify profile
        let url = URL(string: "https://spotify23.p.rapidapi.com/user_profile/?id=31pbtohmlmpa6dppcsl5tb4cz5ky")
        
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
                    try user = JSONDecoder().decode(UserModel.self, from: data)
                } catch {
                    print(error)
                }
            }
        }
        dataTask.resume()
    }
}

//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView{
//            UserView()
//        }
//    }
//}
