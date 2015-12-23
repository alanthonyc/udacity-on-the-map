//
//  OTMListViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/20/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

class OTMListViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var tableViewController: OTMTableViewController!
    
    // MARK: - Housekeeping

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableViewController = OTMTableViewController.init(style:UITableViewStyle.Plain)
        self.tableViewController.tableView = self.tableView
        self.tableViewController.refreshStudentList()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Load Info
    
    func reloadList ()
    {
        self.activityIndicator.startAnimating()
        self.tableViewController.reloadStudentList()
    }
    
    func refreshTableView ()
    {
        self.activityIndicator.stopAnimating()
        self.tableViewController.refreshStudentList()
    }
}
