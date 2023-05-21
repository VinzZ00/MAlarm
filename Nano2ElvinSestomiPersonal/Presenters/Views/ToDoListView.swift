//
//  ToDoListView.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 20/05/23.
//

import SwiftUI
import CoreLocation
import CoreData

struct ToDoListView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "dateTime", ascending: false)]) var todoLists : FetchedResults<TodoList>
    @State var todolist : TodoList?
    @StateObject var appViewModel : AppViewModel = AppViewModel()
    @Environment(\.managedObjectContext) var moc;

    //    private var fetchedResultsController: NSFetchedResultsController<TodoList>? {
//        didSet {
//            performFetch()
//        }
//    }
//
//    init() {
//        performFetch()
//    }
    
//    private func performFetch() {
//        fetchedResultsController?.managedObjectContext.performAndWait {
//            do {
//                try fetchedResultsController?.performFetch()
//            } catch {
//                // Handle fetch error
//            }
//        }
//    }
    
    
    var body: some View {
        if appViewModel.showForm {
            withAnimation {
                FormView()
                    .onAppear{
                        appViewModel.tappedCoordinate = nil
                        appViewModel.locationName = ""
                    }
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
            }
        } else if (appViewModel.showDetail) {
            DetailTodoList(todoList: todolist!)
                .transition(.move(edge: .trailing))
                .environmentObject(appViewModel)
        } else {
            VStack(){
                HStack{
                    Text("Todo List")
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                    Button{
                        withAnimation {
                            appViewModel.showForm = true;
                        }
                    } label: {
                        Text("+")
                            .font(.system(size: 30, weight: .bold))
                    }
                }.padding(.horizontal, 20)
                //                    .padding(.top, 20)
                ScrollView(.vertical) {
                    ForEach(todoLists) {
                        tdlist in
                        listComponent(todoList: tdlist)
                            .onTapGesture {
                                appViewModel.tappedCoordinate = CLLocationCoordinate2D(latitude: tdlist.latitude, longitude: tdlist.longitude)
                                self.todolist = tdlist
                                withAnimation {
                                    appViewModel.showDetail = true
                                }
                            }
                    }
                }
            }
            .transition(.move(edge: .leading))
            .onAppear {
                
                //                if let tdlist = todoLists.first {
                //                    tdlist.status = "Completed"
                //                }
                
                let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
                
                do {
                    let results = try moc.fetch(fetchRequest)
                    for entity in results {
                        // Update the entity here
                        if let date = entity.dateTime {
                            if Date().compare(date) == .orderedDescending {
                                entity.status = "Complete"
                            } else {
                                entity.status = "Incomplete"
                            }
                        }
                    }
                    do {
                        try moc.save()
                        // Successfully saved
                    } catch {
                        print("error Updating data")
                        
                    }
                    
                } catch {
                    print("erorr Fetching data")
                }
                
//                performFetch()
                
                try? moc.save();
            }
        }
    }
}
