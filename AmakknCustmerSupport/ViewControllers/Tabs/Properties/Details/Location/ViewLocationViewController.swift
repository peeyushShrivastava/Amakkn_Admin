//
//  ViewLocationViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 30/12/20.
//

import UIKit
import MapKit

class ViewLocationViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var ibMapView: MKMapView!

    var locationManager = CLLocationManager()
    var location: DetailsLocationModel?
    var arguments = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Explore"
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        updateMaps()
    }

    private func updateMaps() {
        guard let model = location, let latitude = Double(model.latitude ?? "0"), let longitude = Double(model.longitde ?? "0") else { return }

        
        let userCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
                   
        let annotation = MKPointAnnotation()
        annotation.coordinate = userCoordinate

        ibMapView.delegate = self
        ibMapView.mapType = .satellite
        ibMapView.addAnnotation(annotation)
        ibMapView.setCamera(mapCamera, animated: false)
    }
}

// MARK: - CLLocationManager Delegate
extension ViewLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }

        arguments.append(location.latitude)
        arguments.append(location.longitude)

        locationManager.stopUpdatingLocation()
    }
}

// MARK: - Init Self
extension ViewLocationViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .properties
    }
}
