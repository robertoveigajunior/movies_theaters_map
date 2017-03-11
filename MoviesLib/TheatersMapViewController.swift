//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheatersMapViewController: UIViewController {
    
    var elementName: String!
    var theater: Theater!
    var theaters: [Theater] = []
    let annotationReusable = "TheaterPin"
    let aiLoading = UIActivityIndicatorView()
    var poiAnnotations: [MKPointAnnotation] = []
    
    lazy var locationManager = CLLocationManager()
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.mapType = .standard
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.loadXML()
        self.requestLocation()
    }
    
    // MARK: - Methods
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                print("Usuário já autorizou!")
                self.monitorUserLocation()
            case .notDetermined:
                print("Usuário ainda não autorizou!")
                self.locationManager.requestWhenInUseAuthorization()
            case .denied:
                print("Usuário negou autorização!")
            case .restricted:
                print("O acesso do GPS está bloqueado nesse device")
            default:
                break
            }
        }
    }
    
    func loadXML() {
        if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension:"xml"),
            let xmlParser = XMLParser(contentsOf: xmlURL) {
            xmlParser.delegate = self
            xmlParser.parse()
            self.addTheatersToMap()
        }
    }
    
    func addTheatersToMap() {
        
        for theater in self.theaters {
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            let annotation = MyAnnotation(coordinate:coordinate)
            annotation.title = theater.name
            annotation.subtitle = theater.url
            self.mapView.addAnnotation(annotation)
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
    func monitorUserLocation() {
        //self.locationManager.startUpdatingLocation()
    }
    
    func getRoute(destination: CLLocationCoordinate2D) {
        let request = MKDirectionsRequest()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.locationManager.location!.coordinate))
        
        let directions = MKDirections(request: request)
        directions.calculate { (respose, err) in
            if err == nil {
                guard let response = respose else { return }
                let route = response.routes.first!
                print("Nome: ",route.name)
                print("Distancia: ",route.distance)
                print("Duração: ",route.expectedTravelTime)
                
                for step in route.steps {
                    print("Em \(step.distance) metros, \(step.instructions)")
                }
                
                self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                
                
            } else {
                print("Error: ", err!)
            }
        }
    }
}

// MARK: XMLParserDelegate
extension TheatersMapViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("Start: ", elementName)
        self.elementName = elementName
        if elementName == "Theater" {
            self.theater = Theater()
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let content = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !content.isEmpty {
            print("Content: ", content)
            
            switch self.elementName {
            case "name":
                self.theater.name = content
            case "address":
                self.theater.address = content
            case "url":
                self.theater.url = content
            case "latitude":
                self.theater.latitude = Double(content)!
            case "longitude":
                self.theater.longitude = Double(content)!
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("End: ", elementName)
        
        if elementName == "Theater" {
            self.theaters.append(self.theater)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Total de cinemas: ", self.theaters.count)
    }
    
}

// MARK: - MKMapViewDelegate
extension TheatersMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            renderer.lineWidth = 6.0
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView!
        
        if annotation is MKPinAnnotationView {
            annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: self.annotationReusable) as! MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: self.annotationReusable)
                (annotationView as! MKPinAnnotationView).canShowCallout = true
                (annotationView as! MKPinAnnotationView).pinTintColor = .black
                (annotationView as! MKPinAnnotationView).animatesDrop = true
            } else {
                annotationView?.annotation = annotation
            }
        } else if annotation is MyAnnotation {
            annotationView = (annotation as! MyAnnotation).getAnnotationView()
            let btLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            btLeft.setImage(UIImage(named: "car"), for: .normal)
            let btRight = UIButton(type: UIButtonType.detailDisclosure)
            
            annotationView.leftCalloutAccessoryView = btLeft
            annotationView.rightCalloutAccessoryView = btRight
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            self.getRoute(destination: view.annotation!.coordinate)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.url = view.annotation!.subtitle!
            self.present(vc, animated: true, completion: nil)
        }
        self.mapView.removeOverlays(mapView.overlays)
        self.mapView.deselectAnnotation(view.annotation, animated: true)
        
    }
}

// MARK: - CLLocationManagerDelegate
extension TheatersMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Acabou de autorizar!!!")
            self.monitorUserLocation()
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        /*
         let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1500, 1500)
         mapView.setRegion(region, animated: true)
         */
    }
}

// MARK: - UISearchBarDelegate
extension TheatersMapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = self.mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { ( response: MKLocalSearchResponse?, error: Error?) in
            if error == nil {
                guard let response = response else {return}
                self.poiAnnotations.removeAll()
                for item in response.mapItems {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    self.poiAnnotations.append(annotation)
                }
                self.mapView.addAnnotations(self.poiAnnotations)
            }
            searchBar.resignFirstResponder()
        }
    }
}




