//
//  OTMTabBarController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/16/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {

    var sessionId: NSString!
    var key: NSString!
    var expiration: NSString!
    var mapViewController: OTMMapViewController!
    
    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Student.Students = []
        self.loadStudentLocations()
        self.mapViewController = self.viewControllers?.first as! OTMMapViewController
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Students
    
    @IBAction func reloadStudents(sender: UIButton)
    {
        Student.Students = []
        self.mapViewController.clearMap()
        self.mapViewController.reloadMap()
        self.loadStudentLocations()
    }
    
    func loadStudentLocations()
    {
        self.callGetStudentsAPI()
    }
    
    func callGetStudentsAPI()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                print("Load Students Failure: \(error)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentDownloadFailureAlert()
                }
                return
            }
            self.loadStudentsHandler(data!)
        }
        task.resume()
    }
    
    func loadStudentsHandler(returnData: NSData)
    {
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(returnData, options:NSJSONReadingOptions(rawValue: 0))
            guard let returnDict :NSDictionary = JSON as? NSDictionary else {
                print("Load Students Failure: Invalid return dictionary.")
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentDownloadFailureAlert()
                }
                return
            }
            guard let results = returnDict["results"] as? NSArray else {
                print("Load Students: No Results Array")
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentDownloadFailureAlert()
                }
                return
            }
            print("\(results)")
            for result in results {
                let dict = result as? NSDictionary

                let student = Student.Info.init(initDict: dict!)
                Student.Students.append(student)
            }
            // TODO
            print("Count: \(Student.Students.count)")
            dispatch_async(dispatch_get_main_queue()) {
                self.mapViewController.addStudentLocations()
            }
        }
        catch let JSONError as NSError {
            print("Load Students Failure: JSON Error - \(JSONError)")
            dispatch_async(dispatch_get_main_queue()) {
                self.studentDownloadFailureAlert()
            }
        }
    }
    
    func studentDownloadFailureAlert ()
    {
        let alert = UIAlertController.init(title:"Download Failed", message:"Could not download student list.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Pins
    
    @IBAction func showAddPinView(sender: UIButton)
    {
        let pinViewController = self.storyboard?.instantiateViewControllerWithIdentifier("addPinViewController") as! OTMAddPinViewController?
        presentViewController(pinViewController!, animated: true, completion: nil)
    }
    
    // MARK: - Logout
    
    @IBAction func logoutButtonTapped(sender: UIButton)
    {
        self.logoutAndDismiss()
    }
    
    func logoutAndDismiss()
    {
        self.logout()
        self.self.dismissViewControllerAnimated(true, completion: nil)
    }

    func logout()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
}
