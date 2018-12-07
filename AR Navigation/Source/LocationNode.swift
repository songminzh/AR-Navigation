//
//  LocationNode.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

///A location node can be added to a scene using a coordinate.
///Its scale and position should not be adjusted, as these are used for scene layout purposes
///To adjust the scale and position of items within a node, you can add them to a child node and adjust them there
open class LocationNode: SCNNode {
    /// Location can be changed and confirmed later by SceneLocationView.
    public var location: CLLocation!

    /// A general purpose tag that can be used to find nodes already added to a SceneLocationView
    public var tag: String?
    
    // distance
    public var distance: String?
    
    public var distanceLabel = UILabel()

    ///Whether the location of the node has been confirmed.
    ///This is automatically set to true when you create a node using a location.
    ///Otherwise, this is false, and becomes true once the user moves 100m away from the node,
    ///except when the locationEstimateMethod is set to use Core Location data only,
    ///as then it becomes true immediately.
    public var locationConfirmed = false

    ///Whether a node's position should be adjusted on an ongoing basis
    ///based on its' given location.
    ///This only occurs when a node's location is within 100m of the user.
    ///Adjustment doesn't apply to nodes without a confirmed location.
    ///When this is set to false, the result is a smoother appearance.
    ///When this is set to true, this means a node may appear to jump around
    ///as the user's location estimates update,
    ///but the position is generally more accurate.
    ///Defaults to true.
    public var continuallyAdjustNodePositionWhenWithinRange = true

    ///Whether a node's position and scale should be updated automatically on a continual basis.
    ///This should only be set to false if you plan to manually update position and scale
    ///at regular intervals. You can do this with `SceneLocationView`'s `updatePositionOfLocationNode`.
    public var continuallyUpdatePositionAndScale = true

    public init(location: CLLocation?) {
        self.location = location
        self.locationConfirmed = location != nil
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class LocationAnnotationNode: LocationNode {
    ///An image to use for the annotation
    ///When viewed from a distance, the annotation will be seen at the size provided
    ///e.g. if the size is 100x100px, the annotation will take up approx 100x100 points on screen.
    public let image: UIImage

    ///Subnodes and adjustments should be applied to this subnode
    ///Required to allow scaling at the same time as having a 2D 'billboard' appearance
    public let annotationNode: SCNNode

    ///Whether the node should be scaled relative to its distance from the camera
    ///Default value (false) scales it to visually appear at the same size no matter the distance
    ///Setting to true causes annotation nodes to scale like a regular node
    ///Scaling relative to distance may be useful with local navigation-based uses
    ///For landmarks in the distance, the default is correct
    public var scaleRelativeToDistance = false
    

    public init(location: CLLocation?, image: UIImage, title: String, distance: String) {
        self.image = image
        
        let frame: CGRect = CGRect(x:0.0, y:0.0, width:200.0, height:82.0)
        let bgImageView = UIImageView.init(frame: frame)
        bgImageView.image = image
        
        let titleLabel = UILabel.init(frame: CGRect(x: 0.0, y: 0.0, width: 120.0, height: 60.0))
        titleLabel.textColor = UIColor.darkText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        titleLabel.text = title
        titleLabel.textAlignment = NSTextAlignment.center
        bgImageView.addSubview(titleLabel)
        
        let distanceLabel = UILabel.init(frame: CGRect(x: 120.0, y: 0.0, width: 80.0, height: 60.0))
        distanceLabel.textColor = UIColor.init(red: 19.0/255.0, green: 115.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        distanceLabel.font = UIFont.systemFont(ofSize: 16.0)
        distanceLabel.text = distance
        distanceLabel.textAlignment = NSTextAlignment.center
        bgImageView.addSubview(distanceLabel)
        

        let plane = SCNPlane(width: frame.size.width/100, height: frame.size.height/100)
        plane.firstMaterial!.diffuse.contents = bgImageView
        plane.firstMaterial!.lightingModel = .constant

        annotationNode = SCNNode()
        annotationNode.geometry = plane

        super.init(location: location)
        
        self.name = title
        self.distance = distance
        self.distanceLabel = distanceLabel

        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]

        addChildNode(annotationNode)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
