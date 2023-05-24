//
//  DetailTodoList.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 21/05/23.
//

import SwiftUI
import CoreLocation

struct DetailTodoList: View {
    
    var todoList : TodoList
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appViewModel : AppViewModel
    @Environment(\.managedObjectContext) var moc
    
    var timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center){
                        //                    Text("\(todoList.name!.isEmpty ? "No Name" : todoList.name!)")
                        //                        .font(.system(size: 30, weight: .bold))
                        //                    .overlay(
                        //                        RoundedRectangle(cornerRadius: 10)
                        //                            .stroke(
                        //                                (colorScheme == .dark) ? .white : .black
                        //                                , lineWidth: 1)
                        //                    )
                        
                        Spacer()
                        
                        
                    }.padding(.bottom, 8)
                    
                    DatePicker(
                        "Select Time",
                        selection: .constant(todoList.dateTime!),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .padding(.bottom, 8)
                    
                    MapView(canUpdate: false)
                        .environmentObject(appViewModel)
                        .frame(height: 250)
                        .cornerRadius(10)
                        .shadow(radius: 2, x: 2, y: 1)
                        .padding(.bottom, 8)
                    
                    HStack{
                        Text("Want to go by?")
                        Spacer()
                        if let transport = todoList.transportationType {
                            Text("\(transport)")
                                .foregroundColor(.blue)
                        }
                    }.padding(.bottom, 16)
                        .foregroundColor((colorScheme == .dark) ? .white : .black)
                    
                    Text("Description")
                    //            TextEditor(text: .constant(todoList.eventDescription!))
                    //                .overlay(
                    //                    RoundedRectangle(cornerRadius: 10)
                    //                        .stroke(
                    //                            (colorScheme == .dark) ? .white : .black,
                    //                            lineWidth: 1
                    //                        )
                    //                )
                    //                .frame(height: 150)
                    //                .padding(.bottom, 16)
                    
                    VStack(alignment: .leading) {
                        HStack{
                            Text(todoList.eventDescription!)
                                .lineLimit(nil)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }.frame(height: 400)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    (colorScheme == .dark) ? .white : .black,
                                    lineWidth: 1
                                )
                        )
                        .padding(.bottom, 16)
                    
                    
                    Text("Estimated Travel time to the destination : \(appViewModel.estimatedTime) minutes")
                    
                    Button {
                        moc.delete(todoList);
                        withAnimation {
                            appViewModel.showDetail = false
                        }
                    } label: {
                        HStack{
                            Text("Delete The Todo List?")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.black)
                                .frame(width: 25, height: 25)
                        }
                        .padding()
                        .frame(height: 75)
                        .background(.red)
                        .cornerRadius(20)
                        
                    }
                }
                .padding()
                .onAppear {
                    appViewModel.getETA(source: appViewModel.locationManager.region.center, destination: CLLocationCoordinate2D(latitude: todoList.latitude, longitude: todoList.longitude)) {
                        response, err in
                        if let error  = err {
                            print("Error calculate ETA")
                        }
                        
                        var minutes : Int = 0
                        if let resp = response {
                            minutes = Int(resp.expectedTravelTime / 60)
                        }
                        
                        appViewModel.estimatedTime = minutes;
                        
                        appViewModel.tappedCoordinate = CLLocationCoordinate2D(latitude: todoList.latitude, longitude: todoList.longitude)
                        
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.width > 100 {
                                withAnimation {
                                    appViewModel.showDetail = false;
                                }
                            }
                        }
                )
                .onReceive(timer) {
                    _ in
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        appViewModel.objectWillChange.send()
                    }
                }
            }.navigationTitle(Text("\(todoList.name!.isEmpty ? "No Name" : todoList.name!)"))
        }
    }
}
