//
//  OTMAddPinViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/16/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol CloseAddPinViewProtocol
{
    func closeAddPinView ()->Void
}

class OTMAddPinViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var findButtonBaseView: UIView!
    @IBOutlet weak var cancelButtonBaseView: UIView!
    @IBOutlet weak var locationEntryBaseView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findLocationBaseView: UIView!
    @IBOutlet weak var urlEntryView: UIView!
    @IBOutlet weak var submitButtonBaseView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var locationCoordinates: CLLocationCoordinate2D!
    var firstName: String!
    var lastName: String!
    var delegate: CloseAddPinViewProtocol!

    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.findButtonBaseView.layer.cornerRadius = 4.0
        self.locationEntryBaseView.layer.cornerRadius = 8.0
        self.cancelButtonBaseView.layer.cornerRadius = 4.0
        self.cancelButtonBaseView.layer.borderWidth = 0.5
        self.cancelButtonBaseView.layer.borderColor = UIColor.orangeColor().CGColor
        self.locationTextField.isFirstResponder()
        self.urlEntryView.alpha = 0.0
        self.urlEntryView.backgroundColor = UIColor.clearColor()
        self.submitButtonBaseView.layer.cornerRadius = 4.0
        self.mapView.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton)
    {
        self.self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Geolocation
    
    @IBAction func findButtonTapped(sender: UIButton)
    {
        self.geocodeAddress(self.locationTextField.text!)
    }
    
    func geocodeAddress(locationString: String)
    {
        self.mapView.alpha = 0.2
        self.findLocationBaseView.alpha = 0.4
        self.headerView.alpha = 0.0
        self.activityIndicator.startAnimating()
        let geo = CLGeocoder ()
        geo.geocodeAddressString(locationString, completionHandler: { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.geoLocationCompletion(placemarks, error: error)
            })
        })
    }
    
    func geoLocationCompletion (placemarks:[CLPlacemark]?, error:NSError?)
    {
        self.activityIndicator.stopAnimating()
        self.mapView.alpha = 1.0
        if error != nil {
            self.findLocationBaseView.alpha = 1.0
            self.displayGeocodingAlert("Could not find location.")
            return
        }
        self.findLocationBaseView.alpha = 0.0
        self.urlEntryView.alpha = 1.0
        let pm = MKPlacemark.init(placemark: placemarks![0])
        self.mapView.addAnnotation(pm)
        self.locationCoordinates = pm.coordinate
        let region = MKCoordinateRegionMakeWithDistance(locationCoordinates, 400, 400);
        self.mapView.region = region
    }
    
    func displayGeocodingAlert (message: String)
    {
        let alert = UIAlertController.init(title:"Location Error", message:message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Get and post URL
    
    @IBAction func submitButtonTapped (sender:UIButton)
    {
        self.postUserInfo()
    }
    
    func postUserInfo()
    {
        self.mapView.alpha = 0.2
        self.activityIndicator.startAnimating()
        let api = OTMUdacityAPI ()
        api.postStudent(self.firstName, lastName: self.lastName, locationString: self.locationTextField.text!, urlString: self.urlTextField.text!, longitude: self.locationCoordinates.longitude, latitude: self.locationCoordinates.latitude) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            self.postStudentsCompletion(data, response: response, error: error)
        }
    }
    
    func postStudentsCompletion (data:NSData?, response:NSURLResponse?, error:NSError?)
    {
        self.activityIndicator.stopAnimating()
        self.mapView.alpha = 1.0
        self.delegate.closeAddPinView()
    }
    
    // MARK: - MapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "locationPin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as! MKPinAnnotationView?
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.animatesDrop = true
        return pinView
    }
}



















