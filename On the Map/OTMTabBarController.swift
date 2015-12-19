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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: UIButton)
    {
        self.logoutAndDismiss()
    }
    
    @IBAction func showAddPinView(sender: UIButton)
    {
        let pinViewController = self.storyboard?.instantiateViewControllerWithIdentifier("addPinViewController") as! OTMAddPinViewController?
        presentViewController(pinViewController!, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
