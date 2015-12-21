//
//  OTMListViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/20/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

class OTMListViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var tableViewController: OTMTableViewController!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableViewController = OTMTableViewController.init(style:UITableViewStyle.Plain)
        self.tableViewController.tableView = self.tableView
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func reloadList ()
    {
        if self.activityIndicator != nil {
             self.activityIndicator.startAnimating()
        }
        if self.tableViewController != nil {
            self.tableViewController.reloadStudentList()
        }
    }
    
    func refreshTableView ()
    {
        if self.activityIndicator != nil {
            self.activityIndicator.stopAnimating()
        }
        if self.tableViewController != nil {
            self.tableViewController.refreshStudentList()
        }
    }
}
