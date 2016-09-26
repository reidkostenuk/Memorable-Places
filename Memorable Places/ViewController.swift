//
//  ViewController.swift
//  Memorable Places
//
//  Created by Reid Kostenuk on 2016-07-27.
//  Copyright © 2016 App Monkey. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var placeIndex = 0
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(placeIndex)
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpgr)
        
        if placeIndex == -1 {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        } else {
        
            //Get place details and display on map
            
            //This is to make sure that nothing happens if user presses an index that is not valid
            if places.count > placeIndex {
                
                if let name = places[placeIndex]["name"] {
                    
                    if let lat = places[placeIndex]["lat"] {
                        
                        if let lon = places[placeIndex]["lon"] {
                            
                            // place exists with all the proper details.
                            
                            if let latitude = Double(lat) {
                                
                                if let longitude = Double(lon) {
                                    
                                    let latDelta: CLLocationDegrees = 0.05
                                    let longDelta: CLLocationDegrees = 0.05
                                    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    let region = MKCoordinateRegion(center: location, span: span)
                                    
                                    map.setRegion(region, animated: true)
                                    
                                    let annotation = MKPointAnnotation()
                                    annotation.title = name
                                    annotation.coordinate = location
                                    map.addAnnotation(annotation)
                                    
                                }
                                
                            }
                            
                        }
                        
                        else { print("Longitude could not be found") }
                        
                    }
                    
                    else { print("Latitude could not be found") }
                    
                }
                
                else { print("Name could not be found") }
                
            }
            
        }
        
    }
    
    func longpress(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {

            let touchPoint = gestureRecognizer.location(in: self.map)
            let coordinate = map.convert(touchPoint, toCoordinateFrom: self.map)
            let annotation = MKPointAnnotation()
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            var address = ""
            
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                
                if error != nil {
                    
                    print(error)
                    //annotation.title = "Address cannot be found"
                    
                }
                else {
                    
                    if let placemark = placemarks?[0] {
                        
                        if placemark.thoroughfare != nil {
                            address += placemark.thoroughfare! + " "
                        }
                        
                        if placemark.subThoroughfare != nil {
                            address += placemark.subThoroughfare! + "\n"
                        }
                        
                        if placemark.subLocality != nil {
                            address += placemark.subLocality! + "\n"
                        }
                        
                        if placemark.subAdministrativeArea != nil {
                            address += placemark.subAdministrativeArea! + "\n"
                        }
                        
                        if placemark.postalCode != nil {
                            address += placemark.postalCode! + "\n"
                        }
                        
                        if placemark.country != nil {
                            address += placemark.country! + "\n"
                        }
                        
                        annotation.coordinate = coordinate
                        annotation.title = address
                        self.map.addAnnotation(annotation)
                        
                        places.append(["name": address, "lat": String(latitude), "lon": String(longitude)])
                        
                        UserDefaults.standard.set(places, forKey: "places")
                        
                    }
                }
                
                if address == "" {
                    
                    address = "Added \(NSDate())"
                    
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

