//
//  PlaceDetailsViewController.swift
//  Find Nearby
//
//  Created by Kerem Demır on 14.03.2023.
//

import Foundation
import UIKit

class PlaceDetailsViewController: UIViewController {
    
    let place: PlaceAnnotation
    
    lazy var nameLabel:UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        return nameLabel
    }()
    
    lazy var adressLabel:UILabel = {
        let adressLabel = UILabel()
        adressLabel.translatesAutoresizingMaskIntoConstraints = false
        adressLabel.textAlignment = .left
        adressLabel.font = UIFont.preferredFont(forTextStyle: .body)
        adressLabel.alpha = 0.4
        return adressLabel
    }()
    
    var directionsButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Directions", for: .normal)
        return button
    }()
    
    var callButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Call", for: .normal)
        return button
    }()
    
    init(place: PlaceAnnotation){
        self.place = place
        super.init(nibName: nil, bundle: nil)
        configureUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    @objc func directionsButtonTapped(_ sender: UIButton){
        let coordinate = place.location.coordinate
        guard let url = URL(string: "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)")
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    @objc func callButtonTapped(_ sender: UIButton){

        guard let url = URL(string: "tel://\(place.phone.formatPhoneForCall)") else {return}
        UIApplication.shared.open(url)
        
    }
    
    private func configureUI(){
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        nameLabel.text = place.name
        adressLabel.text = place.adress
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(adressLabel)
        
        nameLabel.widthAnchor.constraint(equalToConstant: view.bounds.width - 20).isActive = true
        
        let contactStackView = UIStackView()
        contactStackView.translatesAutoresizingMaskIntoConstraints = false
        contactStackView.axis = .horizontal
        contactStackView.spacing = UIStackView.spacingUseSystem
        
        directionsButton.addTarget(self, action: #selector(directionsButtonTapped), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        
        contactStackView.addArrangedSubview(directionsButton)
        contactStackView.addArrangedSubview(callButton)
        
        stackView.addArrangedSubview(contactStackView)
        
        view.addSubview(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
