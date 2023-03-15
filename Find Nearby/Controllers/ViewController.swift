//
//  ViewController.swift
//  Find Nearby
//
//  Created by Kerem Demır on 13.03.2023.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    private var places: [PlaceAnnotation] = []
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        return mapView
        
    }()
    
    lazy var searchTextField:UITextField = {
        let searchTextField = UITextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        searchTextField.placeholder = "Search"
        searchTextField.layer.cornerRadius = 10
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = .systemBackground
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchTextField.leftViewMode = .always
        searchTextField.returnKeyType = .go
        return searchTextField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
        
        configure()
    }
    
    private func configure(){
        configureUI()
        
        // For Location Manager
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
        //        locationManager?.requestAlwaysAuthorization()
        
        locationManager?.requestLocation()
    }
    
//    private func checkLocationAuthorization(){
//
//        guard let locationManager = locationManager,
//              let location = locationManager.location else {return}
//
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedAlways, .authorizedWhenInUse:
//            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//            mapView.setRegion(region, animated: true)
//        case .denied:
//            print("Locaiton servies has been denied.")
//        case .notDetermined, .restricted:
//            self.locationManager!.requestWhenInUseAuthorization()
//        @unknown default:
//            print("Unkown error. Unable to get location.")
//        }
//    }
    
        private func checkLocationAuthorization(){
            guard let locationManager = locationManager,
                  let location = locationManager.location else {return}

            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            case .denied:
                print("Locaiton servies has been denied.")
            case .notDetermined, .restricted:
                print("Location connt be determined restricted.")
            default:
                print("Unkown error. Unable to get location.")
            }
        }
    
    private func presentPlacesSheet(places: [PlaceAnnotation]){
        
        guard let locationManager = locationManager,
              let userLocation = locationManager.location
        else {return}
        
        let placesTVC = PlacesTableViewController(userLocation: userLocation, places: places)
        placesTVC.modalPresentationStyle = .pageSheet
        
        if let sheet = placesTVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesTVC, animated: true)
        }
    }
    
    private func findNearbyPlaces(by query: String){
        
        // Clear all annotations
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else {return}
            self?.places = response.mapItems.map(PlaceAnnotation.init)
            self?.places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            if let places = self?.places {
                self?.presentPlacesSheet(places: places)
            }
        }
    }
    
    private func configureUI(){
        
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(searchTextField)
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 1.2),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
    }
}

extension ViewController: MKMapViewDelegate {
    
    private func clearAllSelection(){
        self.places = self.places.map { place in
            place.isSelected = false
            return place
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        
        // Clear All Selection
        clearAllSelection()
        
        guard let selectionAnnotation = annotation as? PlaceAnnotation else {return}
        let placeAnnotation = self.places.first(where: {$0.id == selectionAnnotation.id })
        
        placeAnnotation?.isSelected = true
        presentPlacesSheet(places: self.places)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error at didFailWithError : \(error)")
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = searchTextField.text ?? ""
        if !text.isEmpty {
            textField.resignFirstResponder()
            // Find nearby places
            findNearbyPlaces(by: text)
        }
        
        return true
    }
}
