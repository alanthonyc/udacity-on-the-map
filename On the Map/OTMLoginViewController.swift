//
//  OTMLoginViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/17/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class OTMLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    weak var facebookLoginButton: UIButton!
    var api: OTMUdacityAPI!
    var account: NSDictionary!
    var session: NSDictionary!

    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        self.loginButtonView.layer.cornerRadius = 4
        self.api = OTMUdacityAPI ()
        let fbLoginButton = FBSDKLoginButton ()
        fbLoginButton.center = self.view.center
        fbLoginButton.center.y += 112
        fbLoginButton.delegate = self
        self.facebookLoginButton = fbLoginButton
        self.view.addSubview(fbLoginButton)
    }
    
    override func viewDidDisappear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.hideActivityIndicators()
            self.facebookLoginButton.userInteractionEnabled = true
            self.facebookLoginButton.alpha = 1.0
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI
    
    func hideUdacityLogin ()
    {
        self.emailTextField.alpha = 0.2
        self.passwordTextField.alpha = 0.2
        self.loginButtonView.alpha = 0.2
        self.loginButtonView.userInteractionEnabled = false
    }
    
    func showUdacityLogin ()
    {
        self.emailTextField.alpha = 1.0
        self.passwordTextField.alpha = 1.0
        self.loginButtonView.alpha = 1.0
        self.loginButtonView.userInteractionEnabled = true
    }
    
    func displayActivityIndicators ()
    {
        self.hideUdacityLogin()
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicators ()
    {
        self.activityIndicator.hidden = true
        self.showUdacityLogin()
        self.activityIndicator.stopAnimating()
    }
    
    // MARK: - Login
    
    // MARK: --- Udacity Login
    
    @IBAction func loginButtonTapped(sender: UIButton)
    {
        self.loginToUdacity()
    }
    
    func loginToUdacity()
    {
        let userEmail = self.emailTextField.text
        let password = self.passwordTextField.text
        self.displayActivityIndicators()
        self.facebookLoginButton.userInteractionEnabled = false
        self.facebookLoginButton.alpha = 0.2
        self.api.login(userEmail!, password:password!, loginCompletion:{ (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.udacityLoginCompletion(data, response:response, error:error)
        })
    }
    
    func udacityLoginCompletion (data:NSData?, response:NSURLResponse?, error:NSError?)
    {
        if error != nil { // Networking Error
            dispatch_async(dispatch_get_main_queue()) {
                self.alertNetworkError()
            }
            return
        }
        let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* drop first five characters */
        self.loginHandler(newData)
    }

    // MARK: --- Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.displayActivityIndicators()
            self.facebookLoginButton.userInteractionEnabled = false
            self.facebookLoginButton.alpha = 0.2
        }
        if error != nil {
            return
        }
        if result.isCancelled == false {
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            self.api.facebookLogin(token) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                self.facebookLoginCompletion(data, response: response, error: error)
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.hideActivityIndicators()
                self.facebookLoginButton.userInteractionEnabled = true
                self.facebookLoginButton.alpha = 1.0
            }
        }
    }
    
    func facebookLoginCompletion (data:NSData?, response:NSURLResponse?, error:NSError?)
    {
        if error != nil {
            print("udacity facebook login error")
            return
        }
        let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
        self.loginHandler(newData)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("logged out")
    }
    
    // MARK: --- Login Handler
    
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
                let session = returnDict["session"] as? NSDictionary else {
                    print("Login Failure: Missing dictionary element.")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.alertLoginFailure()
                    }
                    return
            }
            self.account = account
            self.session = session
            self.getUserInfo((self.account["key"] as? String)!)
        }
        catch let JSONError as NSError {
            print("Login Failure: JSON Error - \(JSONError)")
            self.alertLoginFailure()
        }
    }
    
    // MARK: --- Login Alerts
    
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
    
    // MARK: - Get User Info
    
    func getUserInfo (userKey: String)
    {
        self.api.getStudent(userKey as String, completion: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.getUserCompletion(data, response:response, error:error)
        })
    }
    
    func getUserCompletion (data:NSData?, response:NSURLResponse?, error:NSError?)
    {
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0))
            guard let returnDict :NSDictionary = JSON as? NSDictionary else {
                print("Get User Failure: Invalid return dictionary.")
                return
            }
            guard
                let user = returnDict["user"] as? NSDictionary,
                let firstName = user["first_name"]! as? String,
                let lastName = user["last_name"]! as? String else {
                    print("Get User Failure: Missing dictionary element.")
                    return
            }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                let navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("navigationController") as! UINavigationController?
                let tabBarController = navigationController?.viewControllers[0] as! OTMTabBarController?
                tabBarController?.firstName = firstName
                tabBarController?.lastName = lastName
                self.presentViewController(navigationController!, animated: true, completion: nil)
            }
        }
        catch let JSONError as NSError {
            print("Get User Info Failure: JSON Error - \(JSONError)")
        }
    }
}






