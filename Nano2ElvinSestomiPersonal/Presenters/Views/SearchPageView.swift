//
//  SearchPageView.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 20/05/23.
//

import SwiftUI
import MapKit
import Combine

struct SearchView: View {
    @State var searchText: String = ""
    @ObservedObject var searchCompleterObserver: SearchCompleterObserver
    @EnvironmentObject var appViewModel : AppViewModel
    let geoCoder : CLGeocoder = CLGeocoder();
    
    @State var showMap : Bool = false;
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        let completer = MKLocalSearchCompleter()
        completer.resultTypes = .address
        searchCompleterObserver = SearchCompleterObserver(completer: completer)
    }
    
    var body: some View {
        if showMap {
            MapView()
                .transition(.slide)
        } else {
            NavigationView{
                VStack {
                    TextField((appViewModel.locationName != "") ? appViewModel.locationName : "Search" , text: $searchText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    (colorScheme == .dark) ? .white.opacity(0.6) : .gray.opacity(0)
                                    , lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .onChange(of: searchText, perform: { value in
                            searchCompleterObserver.completer.queryFragment = value
                        })
                    if searchCompleterObserver.completions.isEmpty {
                        Button{
                            withAnimation {
                                showMap = true
                            }
                        } label: {
                            HStack{
                                Spacer()
                                Text("Find It on map?")
                                    .font(.system(size: 20))
                                    .foregroundColor((colorScheme == .dark) ? .gray.opacity(0.6) : .black.opacity(0.6))
                                    .padding()
                                Spacer()
                            }
                            .background((colorScheme == .dark) ? .white.opacity(0.2) : .gray.opacity(0.2))
                            .cornerRadius(20)
                        }.padding()
                    }
                    List(searchCompleterObserver.completions, id: \.self) { completion in
                        Text(completion.title)
                            .onTapGesture {
                                // Handle selection of autocomplete result
                                // You can access the coordinate using completion.coordinate
                                
                                searchText = completion.title
                                appViewModel.searchedLocationName = searchText
                                
                                appViewModel.locationName = searchText
                                geoCoder.geocodeAddressString(appViewModel.searchedLocationName) { (placemarks, error) in
                                    if let error = error {
                                        print("Geocoding error: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    guard let placemark = placemarks?.first else {
                                        print("No coordinates found for the place name.")
                                        return
                                    }
                                    
                                    if let coordinate = placemark.location?.coordinate {
                                        appViewModel.locRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
                                        
                                        appViewModel.tappedCoordinate = coordinate;
                                        
                                        print(coordinate)
                                    }
                                }
                                withAnimation {
                                    appViewModel.searchPage = false;
                                }
                            }
                    }
                }.padding(.vertical)
                    .navigationBarItems(leading:
                                            Button{
                        withAnimation {
                            appViewModel.searchPage = false;
                        }
                    } label : {
                        Text("Back")
                    }
                    )
                    .navigationTitle("Search Page")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

class SearchCompleterObserver: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var completer: MKLocalSearchCompleter
    
    @Published var completions: [MKLocalSearchCompletion] = []
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle error
        print("Autocomplete error: \(error.localizedDescription)")
    }
}


