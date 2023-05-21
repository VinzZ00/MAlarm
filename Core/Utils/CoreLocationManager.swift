//
//  LocationManager.swift
//  Nano2ElvinSestomiPersonal
//
//  Created by Elvin Sestomi on 19/05/23.
//


import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var region = MKCoordinateRegion();
    private let manager = CLLocationManager()
    
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
    }
    
    //        locations.last?.coordinate.longitude ini lgsung pake map makanya jdi $0,
    //        $0 == locations.last == CLLocation (sudah bukan array).
            
    //        Func ini akan dijalankan setiap kali ada location baru yang terdeteksi gitu
    //    https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Retrieval Error")
        print(error.localizedDescription)
    }
    
    func startMonitoringGeofence(coordinate : CLLocationCoordinate2D) {
           let radius = 100.0 // Radius of the geofence in meters

           let region = CLCircularRegion(center: coordinate, radius: radius, identifier: "Geofence")

           region.notifyOnEntry = true
           region.notifyOnExit = true

           manager.startMonitoring(for: region)
       }

       func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
           print("Entered geofence!")
           triggerAlarm {
               print("Alarm has been triggered")
           }
       }

       func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
           print("Exited geofence!")
           triggerAlarm {
               // Run your custom function or code here
               print("Custom function executed on alarm trigger")
           }
       }

       func triggerAlarm(completion: (() -> Void)?) {
           let content = UNMutableNotificationContent()
           content.title = "Geofence Alert"
           content.body = "You have entered/exited the geofence."

           let request = UNNotificationRequest(identifier: "GeofenceNotification", content: content, trigger: nil)
           UNUserNotificationCenter.current().add(request) { error in
               if let error = error {
                   print("Error scheduling geofence notification: \(error.localizedDescription)")
               } else {
                   completion?() // Invoke the custom function or closure
               }
           }
       }

}

