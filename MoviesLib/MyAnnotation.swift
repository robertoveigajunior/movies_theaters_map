//
//  MyAnnotation.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import Foundation
import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func getAnnotationView() -> MKAnnotationView {
        let annotationView = MKAnnotationView(annotation: self, reuseIdentifier: "Theater")
        annotationView.canShowCallout = true
        annotationView.image = UIImage(named: "theaterIcon")
        
//        let imageView = UIImageView(image: UIImage(named: "theaterIcon"))
//        imageView.frame.origin.y = -200
//        annotationView.addSubview(imageView)
//        
//        UIView.animate(withDuration: 1) {
//            imageView.frame.origin.y = 0
//        }
        
        return annotationView
    }
    
}
