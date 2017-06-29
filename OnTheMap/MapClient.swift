//
//  MapClient.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-10-04.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import UIKit
import Foundation


class MapClient: NSObject {
    
    func taskForGETMethod(_ function:String, view: UIViewController, button: UIButton?, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> AnyObject {
        
        var request = NSMutableURLRequest()
        
        if(function == "session"){
            
            request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"udacity\": {\"username\": \"\(Student.userName)\", \"password\": \"\(Student.userPass)\"}}".data(using: String.Encoding.utf8)
        }
        
        
        else if (function == "userLocation"){
            
            let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(Student.accountKey)%22%7D"
            let url = URL(string: urlString)
            request = NSMutableURLRequest(url: url!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
            
            
        else if (function == "locationData"){
            request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt")!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        }
        
        
        else {
            
           request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(Student.accountKey)")!)
        
        }
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
         //let session = URLSession.shared
        /* 4. Make the request */
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in

            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
        do{
            guard (data != nil) else{
               
                print("Connection error")
                
                 DispatchQueue.main.async(execute: {
    
                let alert = UIAlertController(title: "Error Message", message: "Connection Error. Please try again when you have access to the internet", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                view.present(alert, animated: true, completion: nil)
                    
                    button!.isEnabled = false
                    
                    })
                
                return
            }
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }

      if(function == "session" || function == "userData"){
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler("newData",data: data!,completionHandlerForConvertData:completionHandlerForGET)
            }
            
        else {
            self.convertDataWithCompletionHandler("",data: data!,completionHandlerForConvertData: completionHandlerForGET)
            }
            
        }
            catch let JSONError as NSError {
            print("\(JSONError)")
            }
        }

        /* 7. Start the request */
        task.resume()
        
        return task
                
    }
    
    
        func taskForPOSTMethod(_ view: UIViewController, completionHandlerForPOST: (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
            
            let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"\(Student.accountKey)\", \"firstName\": \"\(Student.userFirstName)\", \"lastName\": \"\(Student.userLastName)\",\"mapString\": \"\(Student.mapString)\", \"mediaURL\": \"\(Student.userMediaURL)\",\"latitude\": \(Student.latitude), \"longitude\": \(Student.longitude)}".data(using: String.Encoding.utf8)
           
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard (data != nil) else {
                    print("Connection error")
                    
                    
                    DispatchQueue.main.async(execute: {
                        
                        let alert = UIAlertController(title: "Error Message", message: "Connection Error. Please try again when you have access to the internet", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                        view.present(alert, animated: true, completion: nil)
                        
                    })
                    
                    return
                    
                    }
                    
                    if error != nil { // Handle error…
                        return
                    }
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            }
            
                task.resume()
                
                return task
    }

    
    
    func taskForPUTMethod(_ view: UIViewController, completionHandlerForPOST: (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(Student.objectkey)"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Student.accountKey)\", \"firstName\": \"\(Student.userFirstName)\", \"lastName\": \"\(Student.userLastName)\",\"mapString\": \"\(Student.mapString)\", \"mediaURL\": \"\(Student.userMediaURL)\",\"latitude\": \(Student.latitude), \"longitude\": \(Student.longitude)}".data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard (data != nil) else {
               
                print("Connection error")
                
                DispatchQueue.main.async(execute: {
                    
                    let alert = UIAlertController(title: "Error Message", message: "Connection Error. Please try again when you have access to the internet", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                    view.present(alert, animated: true, completion: nil)
                    
                })
                return
            }
            
            if error != nil { // Handle error…
              
                return
            }
            
             print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        }
        
        task.resume()
        
        return task
    }
    
    
    fileprivate func convertDataWithCompletionHandler(_ function:String, data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            
           if(function == "newData"){
    
                 let newData = data.subdata(in:5..<data.count - 5)  /* subset response data! */
            print(newData)
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:Any] as AnyObject!
            }
        
           else {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any] as AnyObject!
            }
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}
