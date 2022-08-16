//
//  Model.swift
//  Spotify clone
//
//  Created by Jordan on 7/25/22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Model")
    
    init() {
        container.loadPersistentStores { _, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }
}
