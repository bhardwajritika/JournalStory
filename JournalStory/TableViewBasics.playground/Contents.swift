import UIKit // imports the API for creating iOS apps.

import PlaygroundSupport // enables the playground to display a live view,


class TableViewExampleController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView?
    var journalEntries: [[String]] = [
        ["sun.max","12 Sept 2024","Nice weather today"],
        ["cloud.rain","13 Sept 2024","Heavy rain today"],
        ["cloud.sun","14 Sept 2024","It's cloudy out"]
    ]
    
    func createTableView() {
        // This creates a new table view instance and assigns it to tableView.
        tableView = UITableView(frame: CGRect(x: 0, y: 0,
                                              width: view.frame.width,
                                              height: view.frame.height))
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.backgroundColor = .white
        tableView?.register(UITableViewCell.self,
                            forCellReuseIdentifier: "cell")
        view.addSubview(tableView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bounds = CGRect(x: 0, y: 0, width: 375,
                             height: 667)
        createTableView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journalEntries.count // this will make the table view display three rows.
    
    }
    
    // To make the table view display journal entry details in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This statement creates a new table view cell or reuses an existing table view cell and assigns it to cell.
        let cell = tableView.dequeueReusableCell(withIdentifier:
                                                    "cell", for: indexPath)
        
       //  assigns the first element in the journalEntries array to journalEntry.
        let journalEntry = journalEntries[indexPath.row]
        
        // retrieves the default content configuration for the table view cell’s style and assigns it to a variable, content.
        var content = cell.defaultContentConfiguration()
        
        // These statements update content with details from journalEntry,
        content.image = UIImage(systemName: journalEntry[0])
        content.text = journalEntry[1]
        content.secondaryText = journalEntry[2]
        
        // The last line assigns content to the table view cell’s contentConfiguration property.
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // This removes the journalEntries element corresponding to the table view cell that the user swiped left on and reloads the table view.
        if editingStyle == .delete {
            journalEntries.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // This method will get the journalEntries array element corresponding to the tapped row and print it to the Debug area.
        let selectedJournalEntry = journalEntries[indexPath.row]
        print(selectedJournalEntry)
    }
}

PlaygroundPage.current.liveView = TableViewExampleController()

