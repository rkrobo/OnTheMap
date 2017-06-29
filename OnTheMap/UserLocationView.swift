//
//  UserInfoView.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-09-16.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import UIKit
import MapKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class UserLocationView: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var userLocation: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.userLocation.delegate = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func findOnMapPressed(_ sender: AnyObject) {
        
        if(userLocation.text!.isEmpty){
            print("user location is empty")
        }
        
        else {
            
            activityIndicator.startAnimating()
    
            Student.mapString = userLocation.text!
            
            forwardGeocoding()
            
            
        }
        
    }
    
    func forwardGeocoding() {
        
        let address = userLocation.text
        
        
        
        CLGeocoder().geocodeAddressString(address!, completionHandler: { (placemarks, error) in
            
            if error != nil {
                
                print(error)
                
                self.activityIndicator.stopAnimating()
                
                let alert = UIAlertController(title: "", message: "There was an error. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            if placemarks?.count > 0 {
                
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                Student.latitude = coordinate!.latitude
                Student.longitude = coordinate!.longitude
                
                let delay = 2.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.activityIndicator.stopAnimating()
                }
                let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MapRelocateViewNav") as! UINavigationController
                self.present(nextViewController, animated:true, completion:nil)
            }
        })
        
        
       
    }
    
    @IBAction func dimissView(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
