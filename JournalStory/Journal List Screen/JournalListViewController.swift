//
//  ViewController.swift
//  JournalStory
//
//  Created by Tarun Sharma on 04/02/26.
//

import UIKit

class JournalListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    @IBOutlet var collectionView: UICollectionView!
    private let search = UISearchController(searchResultsController: nil)
    private var filteredTableData : [JournalEntry] = []
    
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedData.shared.loadJournalEntriesData()
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search titles"
        
        // adds the search bar to the navigation bar on the screen.
        navigationItem.searchController = search
        
        setupCollectionView()
    }
    
    override func viewWillLayoutSubviews() {
        // method to recalculate the number of columns and size of the collection view cells when the device is rotated:
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if search.isActive {
            return filteredTableData.count
        } else {
            return SharedData.shared.numberOfJournalEntries()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let journalCell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCell", for: indexPath) as! JournalListCollectionViewCell
        let journalEntry : JournalEntry
        if search.isActive {
            journalEntry = filteredTableData[indexPath.row]
        } else {
            journalEntry = SharedData.shared.journalEntry(at: indexPath.row)
        }
        if let photoData = journalEntry.photoData {
            Task {
                journalCell.photoImageView.image = UIImage(data: photoData)
            }
        }
        journalCell.dateLabel.text = journalEntry.date.formatted(.dateTime.month().day().year())
        journalCell.titleLabel.text = journalEntry.entryTitle
        return journalCell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        // menu with a single option, Delete, that appears when you tap and hold on a collection view cell.
        
        guard let indexPath = indexPaths.first else {
            return nil
        }
        let config = UIContextMenuConfiguration(previewProvider: nil) {
            (elements) -> UIMenu? in
            let delete = UIAction(title: "Delete") { (action) in
                if self.search.isActive {
                    let selectedJournalEntry = self.filteredTableData[indexPath.item]
                    self.filteredTableData.remove(at: indexPath.item)
                } else {
                    SharedData.shared.removeJournalEntry(at: indexPath.item)
                }
                SharedData.shared.saveJournalEntriesData()
                collectionView.reloadData()
            }
            return UIMenu(children: [delete])
            
        }
        return config
    }
    
    // MARK: - UICollectionViewFlowLayoutDelegate
    
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 1, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns : CGFloat
        if (traitCollection.horizontalSizeClass == .compact) {
            numberOfColumns = 1
        } else {
            numberOfColumns = 2
        }
        
        let viewWidth = collectionView.frame.width
        let inset = 10.0
        let contentWidth = viewWidth - inset * (numberOfColumns + 1)
        let cellWidth = contentWidth / numberOfColumns
        let cellHeight = 90.0
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "entryDetail" else {
            return
        }
        
        guard let journalEntryDetailViewController = segue.destination as? JournalEntryDetailViewController,
              let selectedJournalEntryCell = sender as? JournalListCollectionViewCell ,
              let indexPath = collectionView.indexPath(for: selectedJournalEntryCell)
        else {
            fatalError("Could not get indexPath")
        }
        let selectedJournalEntry : JournalEntry
        if search.isActive {
            selectedJournalEntry = filteredTableData[indexPath.row]
        } else {
            selectedJournalEntry = SharedData.shared.journalEntry(at: indexPath.row)
        }
        journalEntryDetailViewController.selectedJournalEntry = selectedJournalEntry
    }
    

    // MARK: - Methods
    @IBAction func unwindNewEntryCancel(segue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func unwindNewEntrySave(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddJournalEntryViewController,
            let newJournalEntry = sourceViewController.newJournalEntry {
            SharedData.shared.addJournalEntry(newJournalEntry)
            SharedData.shared.saveJournalEntriesData()
            collectionView.reloadData()
           
        }
    }
   
}


extension JournalListViewController : UISearchResultsUpdating {
    // MARK: - Search
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        print(searchBarText)
        filteredTableData = SharedData.shared.allJournalEntries().filter {
            entry in entry.entryTitle.lowercased().contains(searchBarText.lowercased())
        }
        collectionView.reloadData()
    }
    
    
}

