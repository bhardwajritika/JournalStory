//
//  JournalEntryDetailViewController.swift
//  JournalStory
//
//  Created by Tarun Sharma on 09/02/26.
//

import UIKit
import MapKit

class JournalEntryDetailViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var ratingView: RatingView!
    var selectedJournalEntry: JournalEntry?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        dateLabel.text = selectedJournalEntry?.date.formatted(.dateTime.day().month(.wide).year())
        ratingView.rating = selectedJournalEntry?.rating ?? 0
        titleLabel.text = selectedJournalEntry?.entryTitle
        bodyTextView.text = selectedJournalEntry?.body
        if let photoData = selectedJournalEntry?.photoData {
            photoImageView.image = UIImage(data: photoData)
        }
        getMapSnapshot()
        
    }
    
    // MARK: - Private methods
    private func getMapSnapshot() {
        guard let lat = selectedJournalEntry?.latitude, let
                long = selectedJournalEntry?.longitude else {
            self.mapImageView.image = nil
            return
        }
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(latitude: lat, longitude: long),
                                            span: MKCoordinateSpan(latitudeDelta: 0.01,
                                                                   longitudeDelta: 0.01))
        options.size = CGSize(width: 300, height: 300)
        options.preferredConfiguration =   MKStandardMapConfiguration()
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let snapshot {
                self.mapImageView.image = snapshot.image
            } else if let error {
                print("snapshot error: \(error.localizedDescription)")
            }
        }
    }
                   

    // MARK: - Table view data source

}
