//
//  ContentView.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 19/05/23.
//

import SwiftUI
import MapKit
import EventKit

struct place : Identifiable {
    var id : UUID = UUID()
    var name : String
    var coordinate : CLLocationCoordinate2D
}

struct FormView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var appViewModel : AppViewModel
    
    @State var eventName : String = "";
    @State var eventDescription : String = "";
    @State var selectedTime : Date = Date();
    
    var availableTransportation : [String] = ["Walking", "Car"];
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if (appViewModel.searchPage) {
            VStack{
                SearchView()
                    .transition(.move(edge: .bottom))
                    .environmentObject(appViewModel)
            }
        } else {
            VStack {
                HStack(alignment: .center){
                    Text("Fill your to do list form")
                        .font(.system(size : 20, weight: .bold))
                        .foregroundColor(
                            (colorScheme == .dark) ? .white : .black
                        )
                    
                    Spacer()
                    
                    Button {
                        
                        let tdlist : TodoList = TodoList(context: moc)
                        tdlist.id = UUID()
                        tdlist
                            .dateTime = selectedTime
                        tdlist.name = eventName
                        tdlist.eventDescription = eventDescription
                        tdlist.status = "Incomplete"
                        tdlist.transportationType = (appViewModel.selectedTransport == 0) ? "Walking" : "Car"
                        tdlist.latitude = appViewModel.tappedCoordinate?.latitude ?? appViewModel.locationManager.region.center.latitude
                        tdlist.longitude = appViewModel.tappedCoordinate?.longitude ?? appViewModel.locationManager.region
                            .center.longitude
                        
                        
                        do {
                            try moc.save()
                        } catch let err {
                            print("Saving failed with description ", err.localizedDescription)
                        }
                        
                        appViewModel.getETA(source: appViewModel.locationManager.region.center, destination: appViewModel.tappedCoordinate!) {
                            response, err in
                            if let error  = err {
                                print("Error calculate ETA, with Description : \(error.localizedDescription)")
                            }
                            //
                            //                                    //                                    var minutes : Int = 0
                            if let resp = response {
                                
                                var calendar : Calendar = Calendar.current
                                
                                
                                
                                var dateComponent = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: selectedTime.addingTimeInterval(-resp.expectedTravelTime))
                                
                                
                                
                                scheduleAlarm(coordinate: appViewModel.tappedCoordinate!, day: dateComponent.day!, month: dateComponent.month!, year: dateComponent.year!, hour: dateComponent.hour!, minute: dateComponent.minute!, title: eventName, description: eventDescription)
                                
                                print("alarm scheduled")
                            }
                            //Event Kit
                            
                            
                            //                        appViewModel.eventStore.requestAccess(to: .event) {
                            //                            granted, error in
                            //                            if granted {
                            //
                            //                                let reminder = EKReminder(eventStore: appViewModel.eventStore)
                            //                                reminder.title  = eventName
                            //                                reminder.calendar = appViewModel.eventStore.defaultCalendarForNewReminders()
                            //
                            //                                //                                var etaTime : Double = 0;
                            //
                            //                                appViewModel.getETA(source: appViewModel.locationManager.region.center, destination: appViewModel.tappedCoordinate!) {
                            //                                    response, err in
                            //                                    if let error  = err {
                            //                                        print("Error calculate ETA, with Description : \(error.localizedDescription)")
                            //                                    }
                            //
                            //                                    //                                    var minutes : Int = 0
                            //                                    if let resp = response {
                            //                                        var reminderTime = self.selectedTime
                            //
                            //                                        reminderTime.addTimeInterval(-(resp.expectedTravelTime))
                            //
                            //                                        let dueDateTime = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
                            //
                            //                                        reminder.dueDateComponents = dueDateTime
                            //
                            //                                        var calendar = Calendar.current
                            //
                            //                                        var event : EKEvent = EKEvent(eventStore: appViewModel.eventStore)
                            //                                        event.calendarItemIdentifier
                            //                                        event.title = eventName
                            //                                        event.calendar = appViewModel.eventStore.defaultCalendarForNewEvents
                            //                                        event.startDate = self.selectedTime
                            //
                            //                                        event.endDate = self.selectedTime.addingTimeInterval(3600*60)
                            //
                            //
                            //                                        let timeAlarm : EKAlarm = EKAlarm(absoluteDate: self.selectedTime)
                            //
                            //                                        timeAlarm.relativeOffset = -resp.expectedTravelTime
                            //
                            //
                            //
                            //
                            //                                        event.addAlarm(timeAlarm)
                            //
                            //
                            //
                            //
                            //                                        do {
                            //                                            try appViewModel.eventStore.save(reminder, commit: true)
                            //                                            try appViewModel.eventStore.save(event, span: .thisEvent)
                            //                                            scheduleLocalNotification(for: reminder)
                            //
                            //
                            //                                            print("Reminder and alarm created successfully")
                            //                                        } catch {
                            //                                            print("Error creating reminder: \(error.localizedDescription)")
                            //                                        }
                            //                                    }
                            //
                            //                                }
                            //
                            //                            } else {
                            //                                print("Access denied")
                            //                            }
                            //                        }
                            
                            withAnimation {
                                appViewModel.showForm = false;
                            }
                        }
                    } label: {
                        Text("Done")
                            .font(.system(size : 16, weight: .regular))
                            .foregroundColor(Color(hue: 0.653, saturation: 0.89, brightness: 1.0))
                        
                    }
                }.padding(.bottom, 16)
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        TextField("Input the Event Name ", text: $eventName)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        (colorScheme == .dark) ? .white : .black
                                        , lineWidth: 1)
                            )
                            .padding(.bottom, 8)
                        
                        DatePicker(
                            "Select Time",
                            selection: $selectedTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .padding(.bottom, 8)
                        
                        TextField((appViewModel.locationName != "") ? appViewModel.locationName : "Search", text: $appViewModel.locationName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation {
                                    appViewModel.searchPage = true
                                }
                            }
                        
                        if let locCoordinate = appViewModel.tappedCoordinate {
                            
                            //                            var annotations : [place] = [place(name: appViewModel.searchedLocationName, coordinate: locCoordinate)]
                            //
                            //                            Map(coordinateRegion: $appViewModel.locRegion, annotationItems: annotations) {
                            //                                MapPin(coordinate: $0.coordinate)
                            //                            }
                            //                            .frame(height: 250)
                            //                            .cornerRadius(20)
                            
                            MapView(canUpdate: false)
                                .environmentObject(appViewModel)
                                .frame(height: 250)
                                .cornerRadius(10)
                                .shadow(radius: 2, x: 2, y: 1)
                                .padding(.bottom, 8)
                            
                        }
                        
                        HStack{
                            Text("Want to go by?")
                            Spacer()
                            Picker("Transportation type", selection: $appViewModel.selectedTransport) {
                                ForEach(0..<availableTransportation.count, id : \.self) {
                                    idx in
                                    Text(availableTransportation[idx]).tag(idx)
                                }
                            }.pickerStyle(.menu)
                        }.padding(.bottom, 8)
                        
                        Text("Description")
                        TextEditor(text: $eventDescription)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        (colorScheme == .dark) ? .white : .black,
                                        lineWidth: 1
                                    )
                            )
                            .frame(height: 150)
                    }
                }
                Spacer()
            }
            .padding()
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            withAnimation {
                                appViewModel.showForm = false;
                            }
                        }
                    }
            )
            
        }
    }
}
    
