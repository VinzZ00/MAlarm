//
//  ViewModel.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 19/05/23.
//

import Foundation
import CoreLocation
import MapKit
import EventKit

class AppViewModel : ObservableObject {
    @Published var showForm : Bool = false;
    
    @Published var tappedCoordinate: CLLocationCoordinate2D?
    @Published var locationManager : LocationManager = LocationManager();
    @Published var locationName : String = "";
    @Published var selectedTransport : Int = 0;
    @Published var searchedLocationName : String = "";
    @Published var searchPage : Bool = false;
    @Published var locRegion : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
    
    @Published var showDetail : Bool = false;
    
    @Published var estimatedTime : Int = 0;
    
    @Published var eventStore : EKEventStore = EKEventStore()
    
    
    func getETA(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion: @escaping (MKDirections.ETAResponse?, Error?) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculateETA { (response, error) in
            completion(response, error)
        }
    }
}


