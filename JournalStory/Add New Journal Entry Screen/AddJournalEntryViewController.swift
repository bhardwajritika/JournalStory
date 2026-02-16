//
//  AddJournalEntryViewController.swift
//  JournalStory
//
//  Created by Tarun Sharma on 09/02/26.
//

import UIKit
import CoreLocation
import CoreLocationUI

class AddJournalEntryViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var getLocationSwitch: UISwitch!
    @IBOutlet var getLocationSwitchLabel: UILabel!
    @IBOutlet var ratingView: RatingView!
    var newJournalEntry: JournalEntry?
    
    private let locationManager = CLLocationManager()
    private var locationTask : Task<Void, Error>?
    private var currentLocation: CLLocation?



    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        bodyTextView.delegate = self
        updateSaveButtonState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let title = titleTextField.text ?? ""
        let body = bodyTextView.text ?? ""
        let photo = photoImageView.image
        let rating = ratingView.rating
        let lat = currentLocation?.coordinate.latitude
        let long = currentLocation?.coordinate.longitude
        newJournalEntry = JournalEntry(rating: rating, title: title, body: body, photo: photo, latitude: lat,
                                       longitude: long)

    }
    
    // MARK: - Actions
    @IBAction func locationSwitchValueChanged(_ sender: UISwitch) {
        if getLocationSwitch.isOn {
            getLocationSwitchLabel.text = "Getting location..."
            fetchUserLocation()
        } else {
            currentLocation = nil
            getLocationSwitchLabel.text = "Get location"
            self.locationTask!.cancel()
        }
    }
 

    @IBAction func getPhoto(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        // conditional compilation block.
        // the image picker controller will use the photo library when running in Simulator and will use the camera when running on an actual device.
        #if targetEnvironment(simulator)
        imagePickerController.sourceType = .photoLibrary
        #else
        imagePickerController.sourceType = .camera
        imagePickerController.showsCameraControls = true
        #endif
        
        
        present(imagePickerController, animated: true)  // presents the image picker controller on the screen.
    }
}


extension AddJournalEntryViewController: UITextViewDelegate, UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    
    func textFieldShouldReturn(_ textField: UITextField) ->  Bool {
        // triggered when the user taps the Return key
        textField.resignFirstResponder() // dismisses the keyboard
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // It is called the moment the user starts editing a text field.
        saveButton.isEnabled = false  // Save button becomes disabled
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    // MARK: - Private methods
    private func updateSaveButtonState() {
        let textFieldText = titleTextField.text ?? ""
        let textViewText = bodyTextView.text ?? ""
        let textIsValid = !textFieldText.isEmpty &&
        !textViewText.isEmpty
        if getLocationSwitch.isOn {
            saveButton.isEnabled = textIsValid
            && currentLocation != nil
        } else {
            saveButton.isEnabled = textIsValid
        }
    }
    
    //MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // detect the newline character and manually dismiss the keyboard when the user presses Return
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
}

extension AddJournalEntryViewController : CLLocationManagerDelegate {
    // MARK: - CoreLocation
    
    private func fetchUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        self.locationTask = Task {
            for try await update in
                    CLLocationUpdate.liveUpdates() {
                if let location = update.location  {
                    updateCurrentLocation(location)
                } else if update.authorizationDenied {
                    failedToGetLocation(message: "Check Location Services settings for JRNL in Settings > Privacy & Security.")
                } else if update.locationUnavailable {
                    failedToGetLocation(message: "Location Unavailable")
                }
            }
        }
    }
    
    private func updateCurrentLocation(_ location: CLLocation) {
        let interval = location.timestamp.timeIntervalSinceNow
        if abs(interval) < 30 {
            self.locationTask!.cancel()
            getLocationSwitchLabel.text = "Done"
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            currentLocation = CLLocation(latitude: lat,
                                         longitude: long)
            updateSaveButtonState()
        }
    }
    
    private func failedToGetLocation(message: String) {
        self.locationTask!.cancel()
        getLocationSwitch.setOn(false, animated: true)
        getLocationSwitchLabel.text = "Get location"
        let alertController = UIAlertController(title:
                                                    "Failed to get location", message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:
                .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
 
   
}

extension AddJournalEntryViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        else { return }
       
        let smallerImage = selectedImage.preparingThumbnail(of: CGSize(width: 300, height: 300))
        photoImageView.image = smallerImage
        dismiss(animated: true)
        
    }

}
