//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-08-27.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import UIKit
import MapKit

struct Student {
    
    static var information =  NSDictionary()
    static var firstName = [String]()
    static var lastName = [String]()
    static var mediaURL = [String]()
    static var sessionID = String()
    static var accountKey = String()
    static var userData = NSDictionary()
    static var userFirstName = String()
    static var userLastName = String()
    static var longitude = Double()
    static var latitude = Double()
    static var overrite = true
    static var mapString = String()
    static var objectkey = String()
    static var userMediaURL = String()
    static var userName = String()
    static var userPass = String()
    
    init(studentInformation: NSDictionary) {
        
        Student.information = studentInformation
    }

}