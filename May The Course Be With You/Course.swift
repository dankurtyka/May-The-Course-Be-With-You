//
//  Course.swift
//  May The Course Be With You
//
//  Created by Daniel Kurtyka on 4/29/18.
//  Copyright © 2018 Daniel Kurtyka. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Contacts

class Course: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var notes: String
    var pic: [Photo]
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return address
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, notes: String, pic: [Photo]) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.notes = notes
        self.pic = pic
    }
    
    convenience override init() {
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, notes: "", pic: [])
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [CNPostalAddressStreetKey: subtitle]
        let placemark = MKPlacemark(coordinate: self.coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
    
}
