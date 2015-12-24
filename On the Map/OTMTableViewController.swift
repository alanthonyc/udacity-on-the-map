//
//  OTMTableViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/20/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit

protocol TableViewAlertProtocol
{
    func displayURLAlert()
}

class OTMTableViewController: UITableViewController {
    
    var delegate: TableViewAlertProtocol!
    
    // MARK: - Properties
    
    var studentArray: [StudentInformation]!
    
    // MARK: - Housekeeping

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.studentArray = Student.List
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func resetUI()
    {
        self.tableView.alpha = 1.0
    }
    
    // MARK: - Load Students
    
    func reloadStudentList()
    {
        self.tableView.alpha = 0.2
    }
    
    func refreshStudentList ()
    {
        self.studentArray = Student.List
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Student.List.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell", forIndexPath: indexPath)
        let student = self.studentArray[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL)"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let student = self.studentArray[indexPath.row]
        let url = NSURL(string: student.mediaURL)
        if url != nil && url!.scheme != "" {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            self.delegate.displayURLAlert()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
