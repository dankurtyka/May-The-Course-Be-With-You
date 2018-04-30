//
//  CourseDetailViewController.swift
//  May The Course Be With You
//
//  Created by Daniel Kurtyka on 4/29/18.
//  Copyright © 2018 Daniel Kurtyka. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import Contacts

class CourseDetailViewController: UIViewController {

    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraButton: UIButton!
    
    
    
    var course: Course!
    var courseInt: Int!
    var photos: Photos!
    var photo: Photo!
    let regionDistance: CLLocationDistance = 750
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        imagePicker.delegate = self
        
        photos = Photos()
        
        if let courseInt = courseInt {
            course = courses[courseInt]
            nameField.text = course.name
            nameField.isEnabled = false
            nameField.backgroundColor = UIColor.clear
            addressField.text = course.address
            addressField.isEnabled = false
            addressField.backgroundColor = UIColor.clear
            textView.text = course.notes
            saveBarButton.title = ""
            cancelBarButton.title = ""
            navigationController?.setToolbarHidden(true, animated: true)
        } else {
            course = Course()
            nameField.addBorder(borderWidth: 0.5, cornerRadius: 5.0)
            addressField.addBorder(borderWidth: 0.5, cornerRadius: 5.0)
            getLocation()
        }
        

        let region = MKCoordinateRegionMakeWithDistance(course.coordinate, regionDistance, regionDistance)
        mapView.setRegion(region, animated: true)
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameField.text = course.name
        addressField.text = course.address
        textView.text = course.notes
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(course)
        mapView.setCenter(course.coordinate, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        course.name = nameField.text!
        course.address = addressField.text!
        course.notes = textView.text!
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var confirmPressed: UIButton!
    
    @IBAction func saveText(_ sender: Any) {
        courses[courseInt].notes = textView.text
    }
    
    @IBAction func textFieldEditingDidBegin(_ sender: UITextField) {
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if nameField.text == "" {
            saveBarButton.isEnabled = false
        } else {
            saveBarButton.isEnabled = true
        }
    }
    
    @IBAction func textFieldReturnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
        course.name = nameField.text!
        course.address = addressField.text!
        course.notes = textView.text!
        updateUserInterface()
    }
    @IBAction func textFieldEditingDidEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
        course.name = nameField.text!
        course.address = addressField.text!
        course.notes = textView.text!
        updateUserInterface()
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.accessCamera()
        }
        let libraryAction = UIAlertAction(title: "Library", style: .default) { _ in
            self.accessLibrary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func lookupPlaceButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

extension CourseDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Course else {
            return nil
        }
        let identifier = "Marker"
        var annotationView: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let launchOptions = [MKLaunchOptionsMapCenterKey: course.coordinate]
        course.mapItem().openInMaps(launchOptions: launchOptions)
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is MKUserLocation {
                view.isEnabled = false
            }
        }
    }
}

extension CourseDetailViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        course.name = place.name
        course.address = place.formattedAddress ?? ""
        course.coordinate = place.coordinate
        dismiss(animated: true, completion: nil)
        updateUserInterface()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension CourseDetailViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .restricted:
            showAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app.")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        let settingsActions = UIAlertAction(title: "Settings", style: .default) {
            value in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsActions)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard course.name == "" else {
            return
        }
        let geoCoder = CLGeocoder()
        var name = ""
        var address = ""
        currentLocation = locations.last
        let currentLatitude = currentLocation.coordinate.latitude
        let currentLongitude = currentLocation.coordinate.longitude
        course.coordinate = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
            if placemarks != nil {
                let placemark = placemarks?.last
                name = (placemark?.name)!
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            } else {
                print("Error retrieving place. error code: \(error!)")
            }
            self.course.name = name
            self.course.address = address
            self.updateUserInterface()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
}
}

extension CourseDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return course.pic.count
//        return photos.photoArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! CoursePhotosCollectionViewCell
        photoCell.photo = course.pic[indexPath.row]
        return photoCell
    }
}

extension CourseDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photo = Photo()
        photo.image = info[UIImagePickerControllerOriginalImage] as! UIImage
//        photos.photoArray.append(photo)
        course.pic.append(photo)
        dismiss(animated: true) {
            self.collectionView.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(title: "Camera Not Available", message: "There is no camera available on this device")
        }
        
    }
}

