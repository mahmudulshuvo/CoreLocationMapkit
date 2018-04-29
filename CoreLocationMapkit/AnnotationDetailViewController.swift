//
//  AnnotationDetailViewController.swift
//  PizzaHistoryMap
//
//  Created by Steven Lipton on 7/20/17.
//  Copyright © 2017 Steven Lipton. All rights reserved.
//

import UIKit
import MapKit

class AnnotationDetailViewController: UIViewController {
    var annotation:Annotations!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pizzaPhoto: UIImageView!
    @IBOutlet weak var historyText: UITextView!
    
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func placemark(annotation:Annotations, completionHandler: @escaping (CLPlacemark?) -> Void){
        let coordinate = annotation.coordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemarks = placemarks{
                completionHandler(placemarks.first)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = annotation.title
        pizzaPhoto.image = annotation.pizzaImage
        historyText.text = annotation.historyText
        placemark(annotation: annotation) { (placemark) in
            if let placemark = placemark{
                var locationString = ""
                if let city = placemark.locality{
                    locationString += city + " "
                }
                if let state = placemark.administrativeArea{
                    locationString += state + " "
                }
                if let country = placemark.country{
                    locationString += country
                }
                self.historyText.text = locationString + "\n\n" + self.annotation.historyText
            } else {
                print("Not found")
            }
        }
        
    }

    

}
