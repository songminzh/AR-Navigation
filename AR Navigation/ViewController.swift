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
        updateUserLocationTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                                       target: self,
                                                       selector: #selector(ViewController.updateUserLocation),
                                                       userInfo: nil,
                                                       repeats: true)
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
        
        let 北京 = buildNode(latitude: 30.585214, longtitude: 114.295336, altitude: 10.0, imageName: imageName, title: "北京", distance: defaultDistance)
        nodes.append(北京)
        
        let 上海 = buildNode(latitude: 31.190874, longtitude: 121.518626, altitude: 60.0, imageName: imageName, title: "上海", distance: defaultDistance)
        nodes.append(上海)
        
        let 南京 = buildNode(latitude: 32.126003, longtitude: 118.881907, altitude: 140.0, imageName: imageName, title: "南京", distance: defaultDistance)
        nodes.append(南京)
        
        let 杭州 = buildNode(latitude: 30.208442, longtitude: 120.244212, altitude: 180.0, imageName: imageName, title: "杭州", distance: defaultDistance)
        nodes.append(杭州)
        
        let 香港 = buildNode(latitude: 22.377168, longtitude: 114.267649, altitude: 300.0, imageName: imageName, title: "香港", distance: defaultDistance)
        nodes.append(香港)
        
        let 台北 = buildNode(latitude: 24.793382, longtitude: 121.650462, altitude: 180.0, imageName: imageName, title: "台北", distance: defaultDistance)
        nodes.append(台北)
        
        return nodes
    }
    
    func buildNode(latitude: CLLocationDegrees, longtitude: CLLocationDegrees, altitude: CLLocationDistance, imageName: String, title: String, distance: String) -> LocationAnnotationNode {
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longtitude), altitude: altitude)
        let image = UIImage(named: imageName)!
        
        return LocationAnnotationNode(location: location, image: image, title: title, distance: distance)
    }
}


