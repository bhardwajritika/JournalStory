//
//  MapViewController.swift
//  JournalStory
//
//  Created by Tarun Sharma on 09/02/26.
//

import UIKit
import MapKit
import CoreLocation
import CoreLocationUI

class MapViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var locationTask : Task<Void, Error>?
    private var selectedAnnotation: JournalEntry?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        fetchUserLocation()
    }

}

extension MapViewController : MKMapViewDelegate  {
    // MARK: - CoreLocation
    
    private func fetchUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.navigationItem.title = "Getting location..."
        self.locationTask = Task {
            for try await update in CLLocationUpdate.liveUpdates() {
                if let location = update.location  {
                    updateMapWithLocation(location)
                } else if update.authorizationDenied {
                    failedToGetLocation(message: "Check Location Services settings for JRNL in Setting> Privacy & Security.")
                } else if update.locationUnavailable {
                    failedToGetLocation(message: "Location Unavailable")
                }
            }
        }
    }
    
    private func updateMapWithLocation(_ location: CLLocation) {
        
        let interval = location.timestamp.timeIntervalSinceNow
        if abs(interval) < 30 {
            self.locationTask?.cancel()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            navigationItem.title = "Map"
            mapView.region = MKCoordinateRegion(center:CLLocationCoordinate2D(latitude: lat,
                                                                           longitude: long),
                                                span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                       longitudeDelta: 0.01))
            mapView.addAnnotations(SharedData.shared.allJournalEntries())
        }
    }
    private func failedToGetLocation(message: String) {
        self.locationTask?.cancel()
        navigationItem.title = "Location not found"
        let alertController = UIAlertController(title:
                                                    "Failed to get location", message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        // reuse identifier for the MKAnnotationView instance.
        let identifier = "mapAnnotation"
        
        // checks to see if the annotation is a JournalEntry
        guard annotation is JournalEntry else {
            return nil
        }
        
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView.annotation = annotation
            return annotationView
        } else {
           // executed if there are no existing MKAnnotationView instances that can be reused.
            let annotationView = MKMarkerAnnotationView(annotation:annotation, reuseIdentifier:identifier)
            
            // The MKAnnotationView instance is configured with a callout. When you tap a pin on the map, a callout bubble will appear showing the title (journal entry date), subtitle (journal entry title), and a button.
            annotationView.canShowCallout = true
            let calloutButton = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = calloutButton
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // triggered when the user taps the callout bubble button.
        guard let annotation = mapView.selectedAnnotations.first
        else {
            return
        }
        selectedAnnotation = annotation as? JournalEntry
        self.performSegue(withIdentifier: "showMapDetail",
                          sender: self)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "showMapDetail" else {
            fatalError("Unexpected segue identifier")
        }
        guard let entryDetailViewController = segue.destination   as? JournalEntryDetailViewController else {
            fatalError("Unexpected view controller")
        }
        entryDetailViewController.selectedJournalEntry = selectedAnnotation
    }
    
}
