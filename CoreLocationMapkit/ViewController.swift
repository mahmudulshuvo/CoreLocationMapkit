//
//  ViewController.swift
//  CoreLocationMapkit
//
//  Created by Shuvo on 4/26/18.
//  Copyright © 2018 Shuvo. All rights reserved.
//


import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: Variables and outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var changeAngel: UIButton!
    @IBOutlet weak var cameraType: UIButton!
    
    var locationCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 40.8367321,    longitude: 14.2468856)
    var camera = MKMapCamera()
    var pitch = 0
    var isOn = false
    var locationManager = CLLocationManager()
    var heading = 0.0
    var startPoint = MKMapItem()
    var endPoint = MKMapItem()
    let onRampCoordinate = CLLocationCoordinate2DMake(37.3346, -122.0345)
    
    
    func getCoordinate( address:String, completionHandler: @escaping(CLLocationCoordinate2D?,String, NSError?)->Void){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0]{
                    let coordinate = placemark.location?.coordinate
                    let location = placemark.locality! + " " + placemark.isoCountryCode!
                    completionHandler(coordinate, location, nil)
                    return
                }
            }
            completionHandler(nil, "", error as NSError?)
        }
    }
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        //setupLocationService()
        //updateMyRegion(regionSpan: 100.0)
        //AnnotationsHistory.init()
        mapView.addAnnotations(AnnotationsHistory().annotations)
        addOverlays()
        addPolylines()
        updateMyRegion(regionSpan: 10.0)
    }
    
    
    // MARK: Location Service functions
    
    func setupLocationService() {
        print("on setup location service")
        switch CLLocationManager.authorizationStatus()
        {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways:
            enableLocationService()
            break
        case .denied:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
        
    }
    
    func enableLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        
        if CLLocationManager.headingAvailable(){
            locationManager.startUpdatingHeading()
        } else {
            print("heading not available")
        }
        monitorRegion(center: onRampCoordinate, radius: 100.0, id: "On ramp")
        
    }
    
    func disableLocationService() {
        locationManager.stopUpdatingLocation()
    }
    
    func monitorRegion(center:CLLocationCoordinate2D, radius:CLLocationDistance, id:String){
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
                let region = CLCircularRegion(center: center, radius: radius, identifier: id)
                region.notifyOnExit = true
                region.notifyOnEntry = true
                locationManager.startMonitoring(for: region)
                
            }
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func changeCameraAngel(_ sender: UIButton) {
        pitch = (pitch+15) % 90
        changeAngel.setTitle("\(pitch)º", for: .normal)
        mapView.camera.pitch = CGFloat(pitch)
    }
    
    @IBAction func here(_ sender: UIButton) {
        setupLocationService()
    }
    
    @IBAction func find(_ sender: UIButton) {
       /* let address = "2121 N. Clark St. IL"
        getCoordinate(address: address) { (coordinate, location, error) in
            if let coordinate = coordinate{
                self.mapView.camera.centerCoordinate = coordinate
                self.mapView.camera.altitude = 1000.0
                let pin = Annotations(coordinate: coordinate, title: address, subtitle: location)
                self.mapView.addAnnotation(pin)
            }
        }*/
        /*let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Pizza"
        updateMyRegion(regionSpan: 500)
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error ==  nil {
                if let response = response {
                    for mapItems in response.mapItems {
                        let name = mapItems.name
                        let coordinate = mapItems.placemark.coordinate
                        let street = mapItems.placemark.thoroughfare
                        let annotation = Annotations(coordinate: coordinate, title: name, subtitle: street)
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }*/
        let annotations = AnnotationsHistory().annotations
        //let bevH = annotations[4].coordinate
        //let chat = annotations[3].coordinate
        let chic = annotations[2].coordinate
        let ney = annotations[1].coordinate
        //findDirection(start: bevH, end: chat)
        findDirection(start: chic, end: ney)
        
    }
    @IBAction func changeMapType(_ sender: UIButton) {
        
        switch mapView.mapType {
        case .standard:
            mapView.mapType = .satellite
            sender.setTitle("Satelli.", for: .normal)
        case .satellite:
            mapView.mapType = .satelliteFlyover
            sender.setTitle("Sat.fly.", for: .normal)
        case .satelliteFlyover:
            mapView.mapType = .hybrid
            sender.setTitle("Hybrid", for: .normal)
        case .hybrid:
            mapView.mapType = .hybridFlyover
            sender.setTitle("Hy.fly", for: .normal)
        case .hybridFlyover:
            mapView.mapType = .mutedStandard
            sender.setTitle("Muted", for: .normal)
        default:
            mapView.mapType = .standard
            sender.setTitle("stand", for: .normal)
        }
    }
    
    
    @IBAction func changeFeatures(_ sender: UIButton) {
        disableLocationService()
        isOn = !mapView.showsPointsOfInterest
        mapView.showsPointsOfInterest = isOn
        mapView.showsScale = isOn
        mapView.showsCompass = isOn
        mapView.showsTraffic = isOn
    }
    

    @IBAction func locationSegController(_ sender: UISegmentedControl) {
        
        disableLocationService()
        let index = sender.selectedSegmentIndex
        switch index {
            
        case 0: // Naples: 40.8367321,14.2468856
            locationCoordinate = CLLocationCoordinate2D.init(latitude: 40.8367321,longitude: 14.2468856)
            updateCameraView(heading: 45.0, altitude: 200.0)
            return
        case 1: // New York: 40.7216294 , -73.995453
            locationCoordinate = CLLocationCoordinate2DMake(40.7216294, -73.995453)
            updateCameraView(heading: 10.0, altitude: 200.0)
            return
        case 2: // Chicago: 41.892479 , -87.6267592
            locationCoordinate = CLLocationCoordinate2D.init(latitude: 41.892479,longitude: -87.6267592)
            updateCameraView(heading: 0.0, altitude: 200.0)
            return
        case 3: // Chatham: 42.4056555,-82.1860369
            locationCoordinate = CLLocationCoordinate2D.init(latitude: 42.4056555,longitude: -82.1860369)
            updateCameraView(heading: 180.0, altitude: 200.0)
            return
        case 4: // Beverly Hills: 34.0674607,-118.3977309
            locationCoordinate = CLLocationCoordinate2D.init(latitude: 34.0674607,longitude: -118.3977309)
            updateCameraView(heading: 90.0, altitude: 200.0)
            return
        default: // Naples: 40.8367321,14.2468856
            locationCoordinate = CLLocationCoordinate2D.init(latitude: 40.8367321,longitude: 14.2468856)
            updateCameraView(heading: 45.0, altitude: 200.0)
            return
        }
        updateMyRegion(regionSpan: 10.0)
    }
    
    // MARK: Adding polylines overlays and necessary functions
    func updateMyRegion(regionSpan:CLLocationDistance)  {
        let region = MKCoordinateRegionMakeWithDistance(locationCoordinate, regionSpan, regionSpan)
        mapView.region = region
    }
    
    func updateCameraView(heading:CLLocationDirection, altitude:CLLocationDistance) {
        camera.centerCoordinate = locationCoordinate
        camera.heading = heading
        camera.pitch = 0.0
        changeAngel.setTitle("0º", for: .normal)
        cameraType.setTitle("Stand.", for: .normal)
        camera.altitude = altitude
        mapView.camera = camera
        mapView.mapType = .standard
        pitch = 0
    }
    
    func addPolylines() {
        var locationCoordinate = [CLLocationCoordinate2D]()
        for location in AnnotationsHistory().annotations {
            locationCoordinate.append(location.coordinate)
        }
        let myPolyline = MKPolyline(coordinates: locationCoordinate, count: locationCoordinate.count)
        mapView.addOverlays([myPolyline])
    }
    
    func addOverlays() {
        let radius = 10.0
        for location in mapView.annotations {
            let circle = MKCircle(center: location.coordinate, radius: radius)
            mapView.add(circle)
        }
    }
    
    func findDirection(start:CLLocationCoordinate2D, end:CLLocationCoordinate2D) {
        let request = MKDirectionsRequest()
        startPoint = MKMapItem(placemark: MKPlacemark(coordinate: start))
        endPoint = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.source = startPoint
        request.destination = endPoint
        request.requestsAlternateRoutes = true
        request.transportType = .transit
        let direction = MKDirections(request: request)
        if request.transportType == .transit{
            direction.calculateETA(completionHandler: { (response, error) in
                let annotation = Annotations(coordinate: end, title: "Destination", subtitle: "No Transit Available")
                if let response = response{
                    annotation.subtitle = String(format: "%4.2f minutes", response.expectedTravelTime/60.0)
                    
                }
                annotation.identifier = "Transit"
                self.mapView.addAnnotation(annotation)
            })
            
            return
        }
        
        direction.calculate { (response, error) in
            if let error = error as? MKError{
                print("\(error.errorCode) \(error.localizedDescription)")
                return
            }
            if let response = response {
                let routes = response.routes
                for route in routes {
                    let polyline  = route.polyline
                    polyline.title = "Routes"
                    self.mapView.add(polyline)
                }
                let destination = response.destination.placemark.coordinate
                let route = routes.first!
                var routeDescription = route.name + "\(route.expectedTravelTime/60.0) min \(route.distance/1609.34) miles"
                let annotation = Annotations(coordinate: destination, title: "Destination", subtitle: routeDescription)
                for routeStep in route.steps {
                    routeDescription += routeStep.instructions + " .Go \(routeStep.distance/1609.34) mi \n"
                    print("\(routeDescription)")
                }
                annotation.historyText = routeDescription
                self.mapView.addAnnotation(annotation)
            }

        }
    }
    
    // MARK: Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("Authorized")
            //break
        case .denied, .restricted:
            print("Not Authorized")
            //break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationLast = locations.last!
        locationCoordinate = locationLast.coordinate
        let displayString = "\(locationLast.timestamp) Coord:\(locationCoordinate) Alt:\(locationLast.altitude)"
        print(displayString)
        updateMyRegion(regionSpan: 200)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let circularRegion = region as! CLCircularRegion
        if circularRegion.identifier == "On ramp"{
            let alert = UIAlertController(title: "Pizza History", message: "You are on the ramp", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let circularRegion = region as! CLCircularRegion
        if circularRegion.identifier == "On ramp"{
            let alert = UIAlertController(title: "Pizza History", message: "You are on the freeway", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Mapview Delegates
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKAnnotationView()
        guard let annotation = annotation as? Annotations
            else{
                return nil
        }
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) as? MKPinAnnotationView {
            annotationView = dequedView
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
        }
        
        if annotation.title == "Destination"{
            annotationView.image = UIImage(named: "destination")
        }else{
            annotationView.image = UIImage(named: "pizza pin")
        }
        annotationView.canShowCallout = true
        let paragraph = UILabel()
        paragraph.numberOfLines = 1
        paragraph.font = UIFont.preferredFont(forTextStyle: .caption1)
        paragraph.text = annotation.subtitle
        paragraph.adjustsFontSizeToFitWidth = true
        annotationView.detailCalloutAccessoryView = paragraph
        annotationView.leftCalloutAccessoryView = UIImageView(image: annotation.pizzaImage)
        annotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! Annotations
        if annotation.identifier == "Transit" {
            endPoint.name = "Pizza Pot Pie"
            startPoint.name = "Deep Dish Pizza"
            MKMapItem.openMaps(with: [endPoint,startPoint], launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit])
        }
        let vc = AnnotationDetailViewController(nibName: "AnnotationDetailViewController", bundle: nil)
        vc.annotation = view.annotation as! Annotations
        present(vc, animated: true, completion: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let polyline = overlay as? MKPolyline {
            let polyrenderer = MKPolylineRenderer(polyline: polyline)
            if polyline.title == "Routes" {
                polyrenderer.strokeColor = UIColor.blue
                polyrenderer.lineWidth =  3.0
                return polyrenderer
            }
           // polyrenderer.fillColor = UIColor.blue
            polyrenderer.strokeColor = UIColor.red
            polyrenderer.lineDashPattern = [20,10,2,10]
            polyrenderer.lineWidth = 3.0
            return polyrenderer
        }
        
        if let circle = overlay as? MKCircle {
            let circlerenderer = MKCircleRenderer(circle: circle)
            circlerenderer.fillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
            circlerenderer.strokeColor = UIColor.blue
            circlerenderer.lineWidth = 1.0
            return circlerenderer
        }
        return MKCircleRenderer(overlay: overlay)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

