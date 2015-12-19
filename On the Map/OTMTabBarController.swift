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
        self.self.dismissViewControllerAnimated(true, completion: nil)
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

}
