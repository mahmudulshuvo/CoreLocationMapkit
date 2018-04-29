//
//  Annotations.swift
//  CoreLocationMapkit
//
//  Created by Shuvo on 4/27/18.
//  Copyright © 2018 Shuvo. All rights reserved.
//

import Foundation
import MapKit

class Annotations: NSObject,MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var identifier = "Pin"
    var historyText = ""
    var pizzaImage: UIImage! = nil
    init(coordinate:CLLocationCoordinate2D, title:String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
