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
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        let httpBodyText = "{\"udacity\": {\"username\": \"" + userEmail + "\", \"password\": \"" + password + "\"}}"
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBodyText.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
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
                print("Not a Dictionary")
                return
            }
            print("Return dict: \(returnDict)")
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        
    }
}






