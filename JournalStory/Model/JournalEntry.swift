//
//  JournalEntry.swift
//  JournalStory
//
//  Created by Tarun Sharma on 09/02/26.
//

import UIKit
import Foundation
import MapKit



class JournalEntry: NSObject, MKAnnotation, Codable {
    // MARK: - Properties
    let key  = UUID().uuidString
    let date: Date
    let rating: Int
    let entryTitle: String
    let body: String
    let photoData: Data?
    let latitude: Double?
    let longitude: Double?
    
    
    // MARK: - Initialization
    init?(rating: Int, title: String, body: String, photo: UIImage? = nil , latitude: Double? = nil, longitude: Double? = nil) {
        if title.isEmpty || body.isEmpty || rating < 0 || rating > 5 {
            return nil
        }
        
        self.date = Date()
        self.rating = rating
        self.entryTitle = title
        self.body = body
        self.photoData = photo?.jpegData(compressionQuality: 1.0)
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    // MARK: - MKAnnotation
    var coordinate: CLLocationCoordinate2D {
        guard let lat = latitude, let long = longitude else {
            return CLLocationCoordinate2D()
        }
        return CLLocationCoordinate2D(latitude: lat,   longitude: long)
    }
    
    var title: String? {
        date.formatted(.dateTime.day().month().year())
    }
    
    var subtitle: String? {
        entryTitle
    }
    
}

// MARK: - Sample data
extension JournalEntry {
    static func createSampleJournalEntryData() -> [JournalEntry] {
        let photo1 = UIImage(systemName: "sun.max")
        let photo2 = UIImage(systemName: "cloud")
        let photo3 = UIImage(systemName: "cloud.sun")
        guard let journalEntry1 =  JournalEntry(rating: 5,
                                                title: "Good",
                                                body: "Today is a good day",
                                                photo: photo1,
                                                latitude: 37.3348,
                                                longitude: -122.0312) else {
            fatalError("Unable to instantiate journalEntry1")
        }
        guard let journalEntry2 = JournalEntry(rating: 0,
                                               title: "Bad",
                                               body: "Today is a bad day",
                                               photo: photo2,
                                               latitude: 37.3318,
                                               longitude: -122.0312) else {
            fatalError("Unable to instantiate journalEntry2")
        }
        
        guard let journalEntry3 = JournalEntry(rating: 3,
                                               title: "Ok",
                                               body: "Today is an Ok day",
                                               photo: photo3,
                                               latitude: 37.3388,
                                               longitude: -122.0312) else {
            fatalError("Unable to instantiate journalEntry3")
        }
        return [journalEntry1, journalEntry2, journalEntry3]
    }
}
