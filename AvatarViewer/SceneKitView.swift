//
//  SceneKitView.swift
//  AvatarViewer
//
//  Created by Richard Woollcott on 21/10/2023.
//

import Foundation

import SwiftUI
import SceneKit

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.autoenablesDefaultLighting = true
        
        let scene = SCNScene(named: "art.scnassets/rich1.scn")!
        
        // create and add a camera to the scene
        _ = setupCamera(for: scene)
                
        // create and add a light to the scene
        setupLighting(for: scene)
             
        // Setup our scene view:
        setupSceneView(with: scene, sceneView: scnView)
        
        return scnView
    }
    
    func setupCamera(for scene: SCNScene!) -> SCNNode {
            // Create and add a camera to the scene:
            let cameraNode = SCNNode()
            
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            scene.rootNode.addChildNode(cameraNode)

            return cameraNode
        }
        
        func setupLighting(for scene: SCNScene!) {
            // Create and add a light to the scene:
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
            scene.rootNode.addChildNode(lightNode)
            
            // Create and add an ambient light to the scene:
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = .ambient
            //ambientLightNode.light!.color = UIColor.darkGray
            ambientLightNode.light!.color = UIColor.lightGray.withAlphaComponent(0.5)
            scene.rootNode.addChildNode(ambientLightNode)
        }
        
    func setupSceneView(with scene: SCNScene!, sceneView: SCNView) {
            // retrieve the SCNView
            //let sceneView = self.view as! SCNView
            
            // set the scene to the view
            sceneView.scene = scene
            
            // allows the user to manipulate the camera
            sceneView.allowsCameraControl = true
            
            // show statistics such as fps and timing information
            sceneView.showsStatistics = true
            
            // configure the view
            //sceneView.backgroundColor = UIColor.black
            sceneView.backgroundColor = UIColor.white
        
            // add a tap gesture recognizer
            //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            //sceneView.addGestureRecognizer(tapGesture)
        }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }
}
struct SceneKitView2: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.autoenablesDefaultLighting = true

        let scene = SCNScene(named: "art.scnassets/rich1.scn")!
        scnView.scene = scene

        // Add a camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        scene.rootNode.addChildNode(cameraNode)

        // Set the camera as point of view for the SCNView
        scnView.pointOfView = cameraNode

        // Orbit camera setup
        //let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pan(gesture:)))
        //scnView.addGestureRecognizer(panGesture)

        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var accumulatedRotationInX: Float = 0.0
        var accumulatedRotationInY: Float = 0.0
        
        var lastPanLocation: CGPoint = .zero
        
        func multiply(_ q1: SCNQuaternion, _ q2: SCNQuaternion) -> SCNQuaternion {
            return SCNVector4(
                q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y,
                q1.w*q2.y - q1.x*q2.z + q1.y*q2.w + q1.z*q2.x,
                q1.w*q2.z + q1.x*q2.y - q1.y*q2.x + q1.z*q2.w,
                q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z
            )
        }

        @objc func pan(gesture: UIPanGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }

            let translation = gesture.translation(in: scnView)
            let newAngleY = Float(translation.x) * Float.pi / 180.0 * 0.5  // Adjust multiplier for sensitivity
            let newAngleX = Float(-translation.y) * Float.pi / 180.0 * 0.5

            if gesture.state == .changed || gesture.state == .ended {
                accumulatedRotationInX += newAngleX
                accumulatedRotationInY += newAngleY

                // Apply the rotations
                if let cameraNode = scnView.pointOfView {
                    let rotationAroundX = SCNQuaternion(x: cos(accumulatedRotationInX / 2), y: 0, z: sin(accumulatedRotationInX / 2), w: 0)
                    let rotationAroundY = SCNQuaternion(x: 0, y: cos(accumulatedRotationInY / 2), z: 0, w: sin(accumulatedRotationInY / 2))
                    //let combinedRotation = rotationAroundX.multiply(rotationAroundY)
                    let combinedRotation = multiply(rotationAroundX, rotationAroundY)

                    cameraNode.orientation = combinedRotation
                }
            }
        }

        /*
        @objc func pan(gesture: UIPanGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }
            
            let translation = gesture.translation(in: scnView)
            let newAngleY = Float(translation.x) * Float.pi / 180.0
            let newAngleX = Float(-translation.y) * Float.pi / 180.0
            
            if let cameraNode = scnView.pointOfView {
                if gesture.state == .changed {
                    let currentEulerX = cameraNode.eulerAngles.x
                    let currentEulerY = cameraNode.eulerAngles.y
                    
                    cameraNode.eulerAngles = SCNVector3(currentEulerX + newAngleX, currentEulerY + newAngleY, cameraNode.eulerAngles.z)
                }
                
                if gesture.state == .ended {
                    lastPanLocation = CGPoint(x: CGFloat(cameraNode.eulerAngles.x), y: CGFloat(cameraNode.eulerAngles.y))
                }
            }
        }*/
    }

}



struct SceneKitView1: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.autoenablesDefaultLighting = true
        
        // Load your .dae or .scn model here
        //let scene = SCNScene(named: "art.scnassets/rich1.scn")!
        //scnView.scene = scene
        if let scene = SCNScene(named: "art.scnassets/rich1.scn") {
            scnView.scene = scene
        } else {
            print("Failed to load the scene.")
        }

        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }
}
