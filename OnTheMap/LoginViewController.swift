//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Rola Kitaphanich on 2016-09-01.
//  Copyright © 2016 Rola Kitaphanich. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debug: UILabel!
    
    fileprivate var userName = ""
    fileprivate var userPass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        configureUI()
        
        subscribeToNotification(NSNotification.Name.UIKeyboardWillShow.rawValue, selector: #selector(keyboardWillShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardWillHide.rawValue, selector: #selector(keyboardWillHide))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidShow.rawValue, selector: #selector(keyboardDidShow))
        subscribeToNotification(NSNotification.Name.UIKeyboardDidHide.rawValue, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    @IBAction func LoginPressed(_ sender: AnyObject) {
        
        userDidTap(self)
        
        if userEmail.text!.isEmpty || userPassword.text!.isEmpty {
            debug.text = "Username or Password Empty."
        } else {
            userName = userEmail.text!
            userPass = userPassword.text!
            Student.userName = userName
            Student.userPass = userPass
            setUIEnabled(false)
            authenticateLogin()
        }
    }
 
    fileprivate func completeLogin() {
            performUIUpdatesOnMain {
                self.debug.text = ""
                self.setUIEnabled(true)
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapTabBarController") as! UITabBarController
                self.present(controller, animated: true, completion: nil)
            }
        }
    
    
    fileprivate func authenticateLogin() {
        
        getSessionUserID()
    }
        
    fileprivate func getSessionUserID() {
       
        let mapClient = MapClient()
        
        mapClient.taskForGETMethod("session",view: self, button:loginButton) {(result,error) in
            
            print(result)
            
            func displayError(_ error: String, debugLabelText: String? = nil) {
                    print(error)
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.debug.text = "Account not found or invalid credentials."
                        
                        DispatchQueue.main.async(execute: {
                            
                            let alert = UIAlertController(title: "Error Message", message: "Account not found or invalid credentials. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                            self.present(alert, animated: true, completion: nil)
                            
                        })
                    }
                }
            
            guard let JSONData : NSDictionary = result as? NSDictionary else {
                print("Not a valid sessionID")
                // put in function
                return
            }
            
            
            guard (JSONData["error"] == nil ) else {
             displayError("There was an error with your request")
             return
             }
            
            if let results = result as? [String:AnyObject]{
                Student.sessionID =  (results["session"]?["id"] as? String)!
                Student.accountKey = (results["account"]?["key"] as? String)!

                self.getUserData()
            }
            
                }
  
    }
    
    fileprivate func getUserData() {
        
        let mapClient = MapClient()
        
        mapClient.taskForGETMethod("userData", view: self, button: loginButton){ (result,error) in
        
        func displayError(_ error: String, debugLabelText: String? = nil) {
            
            print(error)
            
            performUIUpdatesOnMain {
                    
                    self.setUIEnabled(true)
                    
                    self.debug.text = "Login Failed (User ID)."
                    
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
            

            guard let JSONData : NSDictionary = result as? NSDictionary else {
                print("Not a valid sessionID")
                // put in function
                return
            }
            
            
            Student.userData =  JSONData
            
            self.extractUserInfo()
            self.completeLogin()
        }
        
    }
    
    
    func extractUserInfo() {
        
        if let result = Student.userData as? [String:AnyObject]{
        
        Student.userFirstName = (result["user"]?["first_name"] as? String)!
        Student.userLastName = (result["user"]?["last_name"] as? String)!
            
        }
        
    }
    
    
    @IBAction func signUp(_ sender: AnyObject) {
        let app = UIApplication.shared
        app.openURL(URL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            imageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            imageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    
    fileprivate func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
      fileprivate func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    
    @IBAction func userDidTap(_ sender: AnyObject) {
        resignIfFirstResponder(userEmail)
        resignIfFirstResponder(userPassword)
    }
}

extension LoginViewController {
    
    fileprivate func setUIEnabled(_ enabled: Bool) {
        userEmail.isEnabled = enabled
        userPassword.isEnabled = enabled
        loginButton.isEnabled = enabled
        debug.text = ""
        debug.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    fileprivate func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(userEmail)
        configureTextField(userPassword)
    }
    
    fileprivate func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

extension LoginViewController {
    
    fileprivate func subscribeToNotification(_ notification: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: notification), object: nil)
    }
    
    fileprivate func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
