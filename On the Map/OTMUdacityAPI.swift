//
//  OTMUdacityAPI.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/21/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

class OTMUdacityAPI: NSObject {

    func login (userEmail: String, password: String, loginHandler: (NSData?, NSURLResponse?, NSError?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        let httpBodyText = "{\"udacity\": {\"username\": \"\(userEmail)\", \"password\": \"\(password)\"}}"
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBodyText.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            loginHandler(data, response, error)
        }
        task.resume()
    }
}
