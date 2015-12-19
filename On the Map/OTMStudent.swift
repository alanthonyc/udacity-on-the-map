//
//  OTMStudent.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/18/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

struct OTMStudent {

    var createdAt: String!
    var firstName: String!
    var lastName: String!
    var latitude: Float!
    var longitude: Float!
    var mapString: String!
    var mediaURL: String!
    var objectId: String!
    var uniqueKey: String!
    var updatedAt: String!
    
    init(initDict: NSDictionary)
    {
        self.createdAt = initDict["createdAt"] as! String
        self.firstName = initDict["firstName"] as! String
        self.lastName = initDict["lastName"] as! String
        self.latitude = initDict["latitude"] as! Float
        self.longitude = initDict["longitude"] as! Float
        self.mapString = initDict["mapString"] as! String
        self.mediaURL = initDict["mediaURL"] as! String
        self.objectId = initDict["objectId"] as! String
        self.uniqueKey = initDict["uniqueKey"] as! String
        self.updatedAt = initDict["updatedAt"] as! String
    }
    
}
