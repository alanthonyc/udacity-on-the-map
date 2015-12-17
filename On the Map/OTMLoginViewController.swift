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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButtonView.layer.cornerRadius = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
