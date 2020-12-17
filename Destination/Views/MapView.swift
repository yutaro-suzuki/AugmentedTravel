//
//  MapView.swift
//  Destination
//
//  Created by Yutaro Suzuki on 2020/12/08.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    let mapView = MKMapView()
    var locationManager = CLLocationManager()
    var pointAnnotation = MKPointAnnotation()
    @EnvironmentObject var model: DestinationModel
    
    func makeUIView(context: Context) -> MKMapView {
        locationManager.delegate = context.coordinator
        locationManager.requestWhenInUseAuthorization()
        
        var region = mapView.region
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.delegate = context.coordinator
        
        pointAnnotation.coordinate = region.center
        pointAnnotation.title = "destination"
        pointAnnotation.subtitle = model.distanceStr
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
        var parent: MapView
        var longTapRecognizer = UILongPressGestureRecognizer()
        
        init(_ parent: MapView) {
            self.parent = parent
            super.init()
            
            self.longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
            self.longTapRecognizer.delegate = self
            self.parent.mapView.addGestureRecognizer(self.longTapRecognizer)
        }
        
        /*public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
            //controll the conflict of some gesture recognizers
            return true
        }*/
                
        @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                parent.mapView.removeAnnotation(parent.pointAnnotation)
                parent.model.distance = -1
                parent.model.isSet = false
            } else if sender.state == .ended {
                let tapPoint = sender.location(in: parent.mapView)
                let center = parent.mapView.convert(tapPoint, toCoordinateFrom: parent.mapView)
                
                let lonStr = center.longitude.description
                let latStr = center.latitude.description
                print("lon : " + lonStr)
                print("lat : " + latStr)
                
                parent.pointAnnotation.coordinate = center
                parent.mapView.addAnnotation(parent.pointAnnotation)
                parent.model.isSet = true
                
                parent.model.distance = getDiscance(parent.mapView.userLocation.coordinate, center)
                parent.model.degree = getDegree(parent.mapView.userLocation.coordinate, center)
            }
        }
        
        func getDiscance(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> CLLocationDistance {
            let aLoc: CLLocation = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let bLoc: CLLocation = CLLocation(latitude: b.latitude, longitude: b.longitude)
            let distance = bLoc.distance(from: aLoc)
            //print("distance between \(bLoc) and \(aLoc): \(distance)")
            print("distance: \(distance)")
            return distance
        }
        
        func getDegree(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
            let dlat = b.latitude - a.latitude
            let dlon = b.longitude - a.longitude
            let degree = atan(dlon / dlat) * 180 / Double.pi
            //print("degree: \(degree)")
            return degree
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
             let status = manager.authorizationStatus
             switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    parent.locationManager.startUpdatingLocation()
                    parent.locationManager.startUpdatingHeading()
                    self.parent.mapView.userTrackingMode = .follow
                    break
                case .notDetermined, .denied, .restricted:
                    print("[locationManagerDidChangeAuthorization]: using location is not allowed")
                    break
               default:
                    break
             }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
            //let lonStr = (locations.last?.coordinate.longitude.description)!
            //let latStr = (locations.last?.coordinate.latitude.description)!
            guard locations.last != nil, parent.model.isSet else { return }
            parent.model.distance = getDiscance(locations.last!.coordinate,
                                                parent.pointAnnotation.coordinate)
            parent.model.degree = getDegree(locations.last!.coordinate,
                                            parent.pointAnnotation.coordinate)
            //parent.pointAnnotation.subtitle = "\(parent.distance) m from here"
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
            parent.model.deviceHeading = heading.trueHeading
        }
    }
}


/*struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(<#Binding<CLLocationCoordinate2D>#>)
    }
}*/
