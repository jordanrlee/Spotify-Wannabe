//
//  Song.swift
//  Spotify clone
//
//  Created by Jordan on 7/24/22.
//

import Foundation
import SQLite3

struct Song: Identifiable {
    var id = UUID()
    var theSong: String
    var theArtist: String
    var favorite: Bool
}

class Songs : ObservableObject {
    @Published var songs: [Song] = []
    var database: OpaquePointer?
    init (sqlUrl: URL){
        if sqlite3_open(sqlUrl.path, &database) != SQLITE_OK {
            print("can't open database")
        }
        sqlite3_exec(database,
        """
        CREATE TABLE IF NOT EXISTS Songs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT,
        songName TEXT,
        artistName TEXT,
        favorite INT)
        """, nil, nil, nil)
        var queryStatement: OpaquePointer?
        if sqlite3_prepare(database,
                           "SELECT * FROM Songs",
                           -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW{
                let uuid = sqlite3_column_text(queryStatement, 1)
                let songName = sqlite3_column_text(queryStatement, 2)
                let artistName = sqlite3_column_text(queryStatement, 3)
                let favorite = sqlite3_column_int(queryStatement, 4)
                songs.append(
                    Song(
                        id: UUID(uuidString: String(cString: uuid!))!,
                        theSong: String(cString: songName!),
                        theArtist: String(cString: artistName!),
                        favorite: Bool(truncating: favorite as NSNumber)
                    )
                )
            }
        }
    }

    func append(_ song: Song){
       if sqlite3_exec(database,
       """
       INSERT INTO Songs
       (uuid, songName, artistName, favorite)
       VALUES
       (
       '\(song.id.uuidString)',
       '\(song.theSong)',
       '\(song.theArtist)',
       '\(song.favorite ? 1 : 0)'
       )
       """,nil, nil, nil) != SQLITE_OK{
           print("Insertion failed")
       }
        songs.append(song)
    }

    func update(newValue song: Song, index: Int){
        if sqlite3_exec(database,
        """
        UPDATE Songs
        SET
        songName = '\(song.theSong)',
        artistName = '\(song.theArtist)',
        favorite = '\(song.favorite ? 1 : 0)'
        WHERE uuid = '\(song.id.uuidString)'
        """, nil, nil, nil) != SQLITE_OK {
            print("Update failed")
        }
        songs[index] = song
    }

    func remove(atOffsets offsets: IndexSet){
        for index in offsets{
            if sqlite3_exec(database,
            """
            DELETE From Songs
            WHERE uuid = '\(songs[index].id.uuidString)'
            """, nil, nil, nil) != SQLITE_OK{
                print ("Deletion failed")
            }
        }
        songs.remove(atOffsets: offsets)
    }
   
}

