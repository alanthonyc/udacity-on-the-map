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

    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.loginButtonView.layer.cornerRadius = 4
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
        self.callUdacityLoginAPI(userEmail!, password: password!)
    }
    
    func callUdacityLoginAPI(userEmail:String, password:String)
    {
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        let httpBodyText = "{\"udacity\": {\"username\": \"\(userEmail)\", \"password\": \"\(password)\"}}"
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBodyText.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
            }
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* drop first five characters */
            self.loginHandler(newData)
        }
        task.resume()
    }
    
    func loginHandler(returnData: NSData)
    {
        // print(NSString(data: returnData, encoding: NSUTF8StringEncoding))
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
        let alert = UIAlertController.init(title:"Login Failed", message:"Invalid email or password.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}






