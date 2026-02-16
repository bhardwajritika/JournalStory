//
//  SharedData.swift
//  JournalStory
//
//  Created by Tarun Sharma on 10/02/26.
//

import Foundation
import UIKit
class SharedData {
    // MARK: - Properties
    
    // creates a single instance of this class, which means that the only instance of SharedData in your app is stored in the shared property. This property is marked with @MainActor to ensure that it should only be accessed from the main queue.
    @MainActor static let shared = SharedData()
    private var journalEntries: [JournalEntry] = []
    
    
    // MARK: - Initializers
    private init() {
    }
    
    
    // MARK: - Persistence
    func documentDirectory() -> URL {
        // a method to get the location where you can load or save a file on your device storage
        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask).first!
    }
    
    // load journal entries from a file on your device storage
    func loadJournalEntriesData() {
        let pathDirectory = documentDirectory()
        print(pathDirectory)
        let fileURL = pathDirectory.appendingPathComponent("journalEntriesData.json")
        do {
            let data = try Data(contentsOf: fileURL)
            let entries = try JSONDecoder().decode([JournalEntry].self, from: data)
            journalEntries = entries
        } catch {
            print("Failed to read JSON data: \(error.localizedDescription)")
        }
    }
    
    // save journal entries to a file on your device storage
    func saveJournalEntriesData() {
        let pathDirectory = documentDirectory()
        do {
            try? FileManager().createDirectory(at: pathDirectory,
                                               withIntermediateDirectories: true)
            let filePath = pathDirectory.appendingPathComponent("journalEntriesData.json")
            let json = try JSONEncoder().encode(journalEntries)
            try json.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    
    func removeSelectedJournalEntry(_ selectedJournalEntry: JournalEntry) {
        journalEntries.removeAll {
            $0.key == selectedJournalEntry.key
        }
    }

    
    
    // MARK: - Access methods
    
    func numberOfJournalEntries() -> Int {
        // returns the number of items in the journalEntries array.
        journalEntries.count
    }
    
    func journalEntry(at index: Int) -> JournalEntry {
        // returns the JournalEntry instance located at the specified index in the journalEntries array.
        journalEntries[index]
    }
    
    func allJournalEntries() -> [JournalEntry] {
        // returns a copy of the JournalEntries array.
        journalEntries
    }
    
    func addJournalEntry(_ newJournalEntry: JournalEntry) {
        // inserts the JournalEntry instance that was passed into the JournalEntries array at index 0.
        journalEntries.insert(newJournalEntry, at: 0)
    }
    func removeJournalEntry(at index: Int) {
        // removes the JournalEntry instance at the specified index from the JournalEntries array.
        journalEntries.remove(at: index)
    }
}
