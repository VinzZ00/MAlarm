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
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center){
                Text("\(todoList.name!.isEmpty ? "No Name" : todoList.name!)")
                    .font(.system(size: 30, weight: .bold))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(
//                                (colorScheme == .dark) ? .white : .black
//                                , lineWidth: 1)
//                    )
                
                Spacer()
                
                Button {
                    moc.delete(todoList);
                    withAnimation {
                        appViewModel.showDetail = false
                    }
                } label: {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.red)
                        .frame(width: 25, height: 25)
                }
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
            
            Text("Description")
            TextEditor(text: .constant(todoList.eventDescription!))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            (colorScheme == .dark) ? .white : .black,
                            lineWidth: 1
                        )
                )
                .frame(height: 150)
                .padding(.bottom, 16)
            
            Text("Estimated Travel time to the destination : \(appViewModel.estimatedTime) minutes")
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
    }
}
