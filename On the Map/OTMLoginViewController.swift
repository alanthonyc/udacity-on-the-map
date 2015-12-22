//
//  OTMLoginViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/17/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

class OTMLoginViewController: UIViewController {
    
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var api: OTMUdacityAPI!

    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.loginButtonView.layer.cornerRadius = 4
        self.api = OTMUdacityAPI ()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Login
    
    @IBAction func loginButtonTapped(sender: UIButton)
    {
        self.loginToUdacity()
    }
    
    func loginToUdacity()
    {
        let userEmail = self.emailTextField.text
        let password = self.passwordTextField.text
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        self.api.login(userEmail!, password:password!, loginCompletion:{ (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.loginCompletion(data, response:response, error:error)
        })
    }
    
    func loginCompletion (data:NSData?, response:NSURLResponse?, error:NSError?)
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
        }
        if error != nil { // Networking Error
            dispatch_async(dispatch_get_main_queue()) {
                self.alertNetworkError()
            }
            return
        }
        let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* drop first five characters */
        self.loginHandler(newData)
    }
    
    func loginHandler(returnData: NSData)
    {
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(returnData, options:NSJSONReadingOptions(rawValue: 0))
            guard let returnDict :NSDictionary = JSON as? NSDictionary else {
                print("Login Failure: Invalid return dictionary.")
                dispatch_async(dispatch_get_main_queue()) {
                    self.alertLoginFailure()
                }
                return
            }
            guard
                let account = returnDict["account"] as? NSDictionary,
                let session = returnDict["session"] as? NSDictionary,
                let key = account["key"]! as? String,
                let registered = account["registered"]! as? Bool,
                let sessionId = session["id"]! as? String,
                let expiration = session["expiration"]! as? String else {
                    print("Login Failure: Missing dictionary element.")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.alertLoginFailure()
                    }
                    return
                }
            dispatch_async(dispatch_get_main_queue()) {
                if registered {
                    let navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("navigationController") as! UINavigationController?
                    let tabBarController = navigationController?.viewControllers[0] as! OTMTabBarController?
                    tabBarController?.key = key
                    tabBarController?.sessionId = sessionId
                    tabBarController?.expiration = expiration
                    self.presentViewController(navigationController!, animated: true, completion: nil)
                    
                } else {
                    self.alertLoginFailure()
                }
            }
        }
        catch let JSONError as NSError {
            print("Login Failure: JSON Error - \(JSONError)")
            self.alertLoginFailure()
        }
    }
    
    func alertLoginFailure ()
    {
        self.displayErrorAlert("Invalid email or password.")
    }
    
    func alertNetworkError ()
    {
        self.displayErrorAlert("Network error.")
    }
    
    func displayErrorAlert (message: String)
    {
        let alert = UIAlertController.init(title:"Login Failed", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}






