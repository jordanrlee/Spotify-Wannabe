//
//  EditSong.swift
//  Spotify clone
//
//  Created by Jordan on 7/24/22.
//

import SwiftUI
struct EditSong: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var songs: Songs
    @State var tempSong: Song = Song(theSong: "", theArtist: "", favorite: false)
    var songIndex: Int?
    var body: some View {
        NavigationView {
            VStack{
                HStack {
                    Text("Song Name: ")
                    TextField("Enter a song name..", text: $tempSong.theSong)
                }
                
                HStack {
                    Text("Artist Name: ")
                    TextField("Enter an artist name..", text: $tempSong.theArtist)
                }
                Spacer()
            }
            .padding()
            .toolbar{
                ToolbarItem(placement: .cancellationAction)
                {
                    Button("Cancel", action:{dismiss()})
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("Save"){
                        if songIndex == nil{
                            songs.append(tempSong)
                        }else{
                            songs.update(newValue: tempSong, index: songIndex!)
                        }
                        dismiss()
                    }
                }
            }
            .navigationTitle(songIndex == nil ? "Add New Song" : "Edit Song")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            if songIndex != nil{
                tempSong = songs.songs[songIndex!]
            }
        }
    }
}
struct EditSong_Previews: PreviewProvider {
    static var previews: some View {
        EditSong()
    }
}
