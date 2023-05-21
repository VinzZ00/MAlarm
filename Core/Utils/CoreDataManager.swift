//
//  CoreDataManager.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 20/05/23.
//

import Foundation
import CoreData

class CoreDataManager : ObservableObject {
    
    let container : NSPersistentContainer = NSPersistentContainer(name: "CoreDataModel")
    
    init() {
        container.loadPersistentStores {
            description, error in
            
            if let err = error {
                print("Error loading Core Data, \(err.localizedDescription)")
            } else {
                print("Core Data Successfully Loaded, with description : \n\(description.description)")
            }
        }
    }
}
