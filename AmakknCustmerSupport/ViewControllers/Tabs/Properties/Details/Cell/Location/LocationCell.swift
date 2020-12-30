//
//  LocationCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 30/12/20.
//

import UIKit
import MapKit

// MARK: - Location Delegate
protocol DetailsLocationDelegate {
    func neighbourhoodDidTap(at location: DetailsLocationModel?)
}

class LocationCell: UICollectionViewCell, ConfigurableCell, MKMapViewDelegate {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibAddressLabel: UILabel!
    @IBOutlet weak var ibMapView: MKMapView!
    @IBOutlet weak var ibNeighbourhoodButton: UIButton!

    var locationManager = CLLocationManager()
    var arguments = [Double]()

    var locationModel: DetailsLocationModel?
    var delegate: DetailsLocationDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        ibTitleLabel.text = "Edit_Profile_Location".localized()

        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func configure(data details: DetailsLocationModel?) {
        locationModel = details

        updateUI()
    }

    private func updateUI() {
        guard let model = locationModel else { return }

        ibAddressLabel.text = model.address

        updateMaps()
    }

    private func updateMaps() {
        guard let model = locationModel, let latitude = Double(model.latitude ?? "0"), let longitude = Double(model.longitde ?? "0") else { return }

        
        let userCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
                   
        let annotation = MKPointAnnotation()
        annotation.coordinate = userCoordinate

        ibMapView.delegate = self
        ibMapView.mapType = .satellite
        ibMapView.addAnnotation(annotation)
        ibMapView.isUserInteractionEnabled = false
        ibMapView.setCamera(mapCamera, animated: false)

        self.ibMapView.bringSubviewToFront(ibNeighbourhoodButton)
    }
}

// MARK: - Button Actions
extension LocationCell {
    @IBAction func neighbourhoodButtonTapped(_ sender: UIButton) {
        delegate?.neighbourhoodDidTap(at: locationModel)
    }
}

// MARK: - CLLocationManager Delegate
extension LocationCell: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }

        arguments.append(location.latitude)
        arguments.append(location.longitude)

        locationManager.stopUpdatingLocation()
    }
}
