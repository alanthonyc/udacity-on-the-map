//
//  OTMAddPinViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/16/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

class OTMAddPinViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissAddPin(sender: UIButton)
    {
        self.self.dismissViewControllerAnimated(true, completion: nil)
    }
}
