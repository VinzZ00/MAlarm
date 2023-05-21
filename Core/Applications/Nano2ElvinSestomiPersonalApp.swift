//
//  Nano2ElvinSestomiPersonalApp.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 19/05/23.
//

import SwiftUI

@main
struct Nano2ElvinSestomiPersonalApp: App {
    
    @StateObject private var coreDataManager : CoreDataManager = CoreDataManager();
    
    var body: some Scene {
        WindowGroup {
//            testing()
            ToDoListView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}

//struct testing : View {
//    var body: some View {
//        Text("12.00")
//            .font(.system(size: 16, weight: .light, design: .rounded)) //Default font style for Clock
//    }
//}
