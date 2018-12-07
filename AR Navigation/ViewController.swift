//
//  ViewController.swift
//  ARNavigation
//
//  Created by Murphy Zheng on 2018/12/5.
//  Copyright © 2018 mieasy. All rights reserved.
//

import UIKit
import SceneKit
import MapKit

@available(iOS 11.0, *)
class ViewController: UIViewController {
    let sceneLocationView = SceneLocationView()
    let mapView = MKMapView()
    
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = false
    
    var centerMapOnUserLocation: Bool = true
    
    ///Whether to display some debugging data
    ///This currently display the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = true
    
    var adjustNorthByTappingSidesOfScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.locationDelegate = self as? SceneLocationViewDelegate
        // Set to true to display am arrow wjoch points north.
        sceneLocationView.orientToTrueNorth = false
        sceneLocationView.showAxesNode = true
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }
        buildData().forEach {
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
        }
        view.addSubview(sceneLocationView)
        
        // Map view
        if !showMapView {
            mapView.delegate = self as? MKMapViewDelegate
            mapView.showsUserLocation = true
            mapView.isHidden = true
            view.addSubview(mapView)
        }
        
        // Update user location and show distance from current location to nodes added
        updateUserLocationTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.updateUserLocation), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.frame
        mapView.frame = CGRect(x: 0.0, y: self.view.frame.height / 2, width: self.view.frame.width, height: self.view.frame.height / 2)
    }
    
    @objc func updateUserLocation() {
        guard let currentLocation = sceneLocationView.currentLocation() else {
            return
        }
        
        DispatchQueue.main.async {
            if let bestEstimate = self.sceneLocationView.bestLocationEstimate(), let position = self.sceneLocationView.currentScenePosition() {
                print("------------------------------------")
                print("Fetch current location")
                print("Best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accurace: \(bestEstimate.location.horizontalAccuracy)")
                print("current position: \(position)")
                
                let translation = bestEstimate.translatedLocation(to: position)
                print("translation: \(translation)")
                print("translated location: \(currentLocation)")
                print("------------------------------------")
                
                // Location nodes
                for node in self.sceneLocationView.locationNodes {
                    let distance = currentLocation.distance(from: node.location)
                    var distanceStr: String = String(format: "%.0fm", distance)
                    if distance >= 1000 {
                        distanceStr = String(format: "%.1fkm", (distance/1000))
                    }
                    node.distance = distanceStr
                    node.distanceLabel.text = distanceStr
                }
            }
        }
    }
    
}

// MARK: - Data init
@available(iOS 11.0, *)
private extension ViewController {
    func buildData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []
        
        let defaultDistance: String = "10m"
        let imageName: String = "bubble"
        
        let huanghelou = buildNode(latitude: 30.544621, longtitude: 114.302532, altitude: 10.0, imageName: imageName, title: "黄鹤楼", distance: defaultDistance)
        nodes.append(huanghelou)
        
        let donghu = buildNode(latitude: 30.567554, longtitude: 114.375306, altitude: 6.0, imageName: imageName, title: "东湖", distance: defaultDistance)
        nodes.append(donghu)
        
        return nodes
    }
    
    func buildNode(latitude: CLLocationDegrees, longtitude: CLLocationDegrees, altitude: CLLocationDistance, imageName: String, title: String, distance: String) -> LocationAnnotationNode {
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longtitude), altitude: altitude)
        let image = UIImage(named: imageName)!
        
        return LocationAnnotationNode(location: location, image: image, title: title, distance: distance)
    }
}


