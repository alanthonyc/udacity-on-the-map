//
//  OTMMapViewController.swift
//  On the Map
//
//  Created by A. Anthony Castillo on 12/19/15.
//  Copyright © 2015 Alon Consulting. All rights reserved.
//

import UIKit
import MapKit

class OTMMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Housekeeping
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidden = false
        self.mapView.alpha = 0.2
        self.mapView.delegate = self
    }
    
    func resetUI()
    {
        self.activityIndicator.stopAnimating()
        self.mapView.alpha = 1.0
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Map Locations

    func addStudentLocations ()
    {
        for student in Student.List {
            let coor = CLLocationCoordinate2D.init(latitude: student.latitude, longitude: student.longitude)
            let placemark = MKPlacemark.init(coordinate: coor, addressDictionary:["where":"here"])
            let pointAnnotation = MKPointAnnotation.init()
            pointAnnotation.coordinate = placemark.coordinate
            pointAnnotation.title = "\(student.firstName) \(student.lastName)"
            pointAnnotation.subtitle = student.mediaURL
            self.mapView.addAnnotation(pointAnnotation)
        }
    }
    
    func reloadMap ()
    {
        self.activityIndicator.startAnimating()
        self.mapView.alpha = 0.2
    }
    
    func clearMap ()
    {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    // MARK: - MapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as! MKPinAnnotationView?
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = true
        pinView!.rightCalloutAccessoryView = UIButton.init(type: .DetailDisclosure)
        pinView!.animatesDrop = true
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let pin = view.annotation as! MKPointAnnotation?
        let url = NSURL(string: pin!.subtitle!)
        if url != nil && url!.scheme != "" {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            self.displayURLAlert()
        }
    }
    
    func displayURLAlert()
    {
        let alert = UIAlertController.init(title:"Link Error", message:"Invalid link.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}














