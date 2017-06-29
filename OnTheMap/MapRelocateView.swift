//
//  MapRelocateView.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-09-16.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import UIKit
import MapKit

class MapRelocateView: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userLink: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var appDelegate: AppDelegate!
    
    var connectionError = false
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.userLink.delegate = self
        
        setMapRegion()
       
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    fileprivate func setMapRegion() {
        
        let location = CLLocation(latitude: Student.latitude , longitude: Student.longitude)
        
        let regionRadius: CLLocationDistance = 2000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        
        self.mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    @IBAction func submitInfo (_ sender: AnyObject){
        
        if(userLink.text!.isEmpty){
            print("user link is empty")
        }
            
        else {
            
        Student.userMediaURL = userLink.text!
        
        if(Student.overrite){
            overrideLocation()
        }
        
        else {
            postLocation()
        }
            
        
        }
    }
    
    
    func goTo(_ sender:AnyObject){
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MapTabBarController") as!
        UITabBarController
        self.present(nextViewController, animated:true, completion:nil)
    }
    

    fileprivate func postLocation() {
        
        let mapClient = MapClient()
        
        mapClient.taskForPOSTMethod(self){ (result,error) in
            
            func displayError(_ error: String, debugLabelText: String? = nil) {
                
                print(error)
                
                performUIUpdatesOnMain {
                    
                    DispatchQueue.main.async(execute: {
                        
                        let alert = UIAlertController(title: "Error Message", message: "Login Failed(User ID). Please try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                }
            }
            
            guard (error == nil) else {
                displayError("There was an error with your request")
                return
            }
     DispatchQueue.main.async(execute: {
     let alert = UIAlertController(title: "", message: "Location successfully added", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:self.goTo))
        self.present(alert, animated: true, completion: nil)
            })
            
        }
        

        
    }
    
    
    
    fileprivate func overrideLocation() {
        
        let mapClient = MapClient()
        
        mapClient.taskForPUTMethod(self){ (result,error) in
            
           func displayError(_ error: String, debugLabelText: String? = nil) {
            
                print(error)
                
                performUIUpdatesOnMain {
                    
                    DispatchQueue.main.async(execute: {
                        
                        let alert = UIAlertController(title: "Error Message", message: "Login Failed(User ID). Please try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                }
            }
            
            guard (error == nil) else {
                displayError("There was an error with your request")
                return
            }
        
             DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "", message: "Location successfully updated", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:self.goTo))
        self.present(alert, animated: true, completion: nil)
            })
       
            
            }
        

 
    }


    

    @IBAction func dimissView(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
}
