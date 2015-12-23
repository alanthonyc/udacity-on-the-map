//
//  OTMTabBarController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/16/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController, CloseAddPinView {

    // MARK: - Properties
    
    // MARK: --- View Controllers
    var mapViewController: OTMMapViewController!
    var listViewController: OTMListViewController!
    
    // MARK: --- Student Info
    var api: OTMUdacityAPI!
    var firstName: String!
    var lastName: String!
    
    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.api = OTMUdacityAPI ()
        Student.List = []
        self.loadStudentLocations()
        self.mapViewController = self.viewControllers?.first as! OTMMapViewController
        self.listViewController = self.viewControllers?.last as! OTMListViewController
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Students
    
    @IBAction func refreshButtonTapped(sender: UIButton)
    {
        self.reloadStudents()
    }
    
    func reloadStudents()
    {
        Student.List = []
        self.mapViewController.clearMap()
        self.mapViewController.reloadMap()
        if self.listViewController.tableView != nil {
            self.listViewController.reloadList()
        }
        self.loadStudentLocations()
    }
    
    // MARK: --- Call API to Load Students
    
    func loadStudentLocations()
    {
        self.api.loadStudents({(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.loadStudentsCompletion(data, response:response, error:error)
        })
    }

    // MARK: --- API Completion Handlers
    
    func loadStudentsCompletion (data:NSData?, response:NSURLResponse?, error:NSError?)
    {
        if error != nil { // Handle error...
            print("Load Students Failure: \(error)")
            dispatch_async(dispatch_get_main_queue()) {
                self.studentDownloadFailureAlert()
            }
            return
        }
        self.loadStudentsHandler(data!)
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
            for result in results {
                let dict = result as? NSDictionary

                let student = Student.Info.init(initDict: dict!)
                Student.List.append(student)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.mapViewController.addStudentLocations()
                if self.listViewController.tableView != nil {
                    self.listViewController.refreshTableView()
                }
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
        pinViewController?.firstName = self.firstName
        pinViewController?.lastName = self.lastName
        pinViewController?.delegate = self
        presentViewController(pinViewController!, animated: true, completion: nil)
    }
    
    func closeAddPinView()
    {
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.reloadStudents()
        }
    }
    
    // MARK: - Logout
    
    @IBAction func logoutButtonTapped(sender: UIButton)
    {
        self.logoutAndDismiss()
    }
    
    func logoutAndDismiss()
    {
        self.api.logout()
        self.self.dismissViewControllerAnimated(true, completion: nil)
    }
}
