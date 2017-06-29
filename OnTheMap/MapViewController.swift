//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-08-21.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var manager = CLLocationManager()
    
    var appDelegate: AppDelegate!
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    
        // For use in foreground
        
        // Do any additional setup after loading the view.
        locationData()
        
    }
    
    func locationData() {
        
        let mapClient = MapClient()
        
        mapClient.taskForGETMethod("locationData", view: self, button: nil ){ (result,error) in
            
            if let error = error {
                print(error)

            }
       
            else {
                
                guard let dictionary :NSDictionary = result as? NSDictionary else{
                    print("Not a Dictionary")
                    // put in function
                    return
                }
                
                Student(studentInformation: dictionary)
                

                self.addPins()
                
            }
            
        }
        
    }
    
    func addPins(){
        
        var annotations = [MKPointAnnotation]()
        
        if let locations = Student.information["results"] as? [[String:AnyObject]]{
            
            for dictionary in locations{
              
                var first = ""
                var last = ""
                var lat = 0.00
                var long = 0.00
                var mediaURL = ""
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                if(dictionary["latitude"] != nil ) {
                    lat = CLLocationDegrees(dictionary["latitude"] as! Double)
                }
                
                if(dictionary["longitude"] != nil ) {
                    long = CLLocationDegrees(dictionary["longitude"] as! Double)
                }
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                if  (dictionary["firstName"] != nil)  {
                    first = dictionary["firstName"] as! String
                }
                
                if (dictionary["lastName"] != nil ) {
                    last = dictionary["lastName"] as! String
                }
                
                if(dictionary["mediaURL"] != nil ){
                    mediaURL = dictionary["mediaURL"] as! String
                }
                
                Student.firstName.append(first)
                Student.lastName.append(last)
                Student.mediaURL.append(mediaURL)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
            
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
    
        }
        
        else {
            
            print("error")
        }
 
    }
    
    fileprivate func removePins(){
        
        let annotations = [MKPointAnnotation]()
        
        for annotation in annotations {
                self.mapView.removeAnnotation(annotation)
            }
        
    }
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
     
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if(verifyUrl(toOpen)){
                    app.openURL(URL(string: toOpen)!)
                }
                
                else {
                    print("not valid URL")
                }
            }
        }
    }
    
    
    func verifyUrl (_ urlString: String?) -> Bool {
        //Check for nil
        // create NSURL instance
        if let url = URL(string: urlString!) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        }
        
        return false
    }
    
    
    @IBAction func postLocation(_ sender: AnyObject) {
        
            self.checkUserLocation()
    }
    
    
    fileprivate func checkUserLocation() {
        
      let mapClient = MapClient()
        
        mapClient.taskForGETMethod("userLocation", view: self, button: nil){ (result,error) in
                
               let  studentInfo = result
                
                if((studentInfo?["results"]!! as AnyObject).count != 0 ){
                            
                           DispatchQueue.main.async(execute: {
                            let results = studentInfo?["results"] as? [[String:AnyObject]]
                                for result in results!{
                                guard let objectKey = result["objectId"] as? String else {
                                    return
                                }
                           
                                Student.objectkey = objectKey
                                
                                }
                                
                            let alert = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler:self.goUserLocationView))
                            self.present(alert, animated: true, completion: nil)
                          
                            })
                            
                        }
                else {
                            
                   self.goUserLocationView("go" as AnyObject)
                   Student.overrite = false
                }
               
            }

}
    
    func goUserLocationView(_ sender: AnyObject) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserLocationViewNav") as!
            UINavigationController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        let latitude: Double = location.coordinate.latitude
        let longitude: Double = location.coordinate.longitude
        Student.latitude = latitude
        Student.longitude = longitude
    }
    
    
    @IBAction func logOut(_ sender: AnyObject) {
        
        let request = NSMutableURLRequest(url: self.appDelegate.udacityURLFromParameters(nil, apiHost: "udacity" , withPathExtension: "/session"))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (data != nil) else {
                
                print("Connection error")
                
                DispatchQueue.main.async(execute: {
                    
                    let alert = UIAlertController(title: "Error Message", message: "Connection Error. Please try again when you have access to the internet", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                    self.present(alert, animated: true, completion: nil)
                    
                })
                return
            }

            
            if error != nil { // Handle error…
                return
            }
           let newData = data?.subdata(in:5..<(data?.count)! - 5) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue))
            
            let loginViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(loginViewControllerObj!, animated: true)
        }
        task.resume()
    
        
    }
    
    @IBAction func reloadMapData(_ sender: AnyObject) {
            removePins()
            manager.startUpdatingLocation()
            locationData()
        
    }

}
