//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-08-27.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        
        return Student.firstName.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tableView!.reloadData()
    }
    
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell")
   
        let studentFullName = Student.firstName[(indexPath as NSIndexPath).row] + " " + Student.lastName[(indexPath as NSIndexPath).row]
    
        cell?.textLabel?.text = studentFullName
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(verifyUrl(Student.mediaURL[(indexPath as NSIndexPath).row])){
            
            let url = URL(string: Student.mediaURL[(indexPath as NSIndexPath).row])!
             UIApplication.shared.openURL(url)
        }
            
        else {
            print("not valid URL")
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
    
    
    @IBAction func post(_ sender: AnyObject) {
        
        checkUserLocation()
        
    }
    
    fileprivate func checkUserLocation() {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(Student.accountKey)%22%7D"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            do {
                
                let JSON = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                
                guard let JSONData : NSDictionary = JSON as? NSDictionary else {
                    print("Not a valid sessionID")
                    // put in function
                    return
                }
                
                let  studentInfo = JSONData
                
                if((studentInfo["results"]! as AnyObject).count != 0 ){
                    
                    DispatchQueue.main.async(execute: {
                        let results = studentInfo["results"] as? [[String:AnyObject]]
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
            catch let JSONError as NSError {
                print("\(JSONError)")
            }
            
        }
        
        task.resume()
        
    }

    func goUserLocationView(_ sender: AnyObject) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserLocationViewNav") as!
        UINavigationController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    @IBAction func postLocation(_ sender: AnyObject) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(Student.accountKey)\", \"firstName\": \"\(Student.userFirstName)\", \"lastName\": \"\(Student.userLastName)\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\":\(Student.latitude), \"longitude\": \(Student.longitude)}".data(using: String.Encoding.utf8)
        
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
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        }
        task.resume()
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
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

            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdata(in: 5..<data!.count - 5) /* subset response data! */
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue))
            
            let loginViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(loginViewControllerObj!, animated: true)
        }
        task.resume()
    }
    
    
    @IBAction func refreshTable(_ sender: AnyObject) {
        
        tableView!.reloadData()
        
    }
    
    
}
