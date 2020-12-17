//
//  CameraView.swift
//  Destination
//
//  Created by Yutaro Suzuki on 2020/12/08.
//

import SwiftUI
import ARKit
import SceneKit
import SpriteKit

struct CameraView: UIViewRepresentable {
    @EnvironmentObject var model: DestinationModel
    var sceneView: ARSCNView = ARSCNView(frame: .zero)
    
    func makeUIView(context: Context) -> UIView {
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator
        sceneView.automaticallyUpdatesLighting = true
        
        let conf = ARWorldTrackingConfiguration()
        conf.isLightEstimationEnabled = true
        sceneView.session.run(conf, options: [.resetTracking, .removeExistingAnchors])
        return sceneView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: CameraView
        var targetNode: SCNNode = SCNNode()
        var device: SCNNode = SCNNode()
        
        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
            self.parent.sceneView.scene.rootNode.addChildNode(device)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {}

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let sceneTransform = parent.sceneView.pointOfView?.transform else { return }
            device.transform = sceneTransform
            if parent.model.isSet {
                targetNode.removeFromParentNode()
                createTargetNode()
                parent.sceneView.scene.rootNode.addChildNode(targetNode)
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {}
        
        
        var scale: CGFloat = 1
        func createTargetNode() {
            self.targetNode = SCNNode()
            scale = CGFloat(parent.model.distance / 10)
            let geometry = SCNPlane(width: 1 * scale, height: 1.25 * scale)
            let image = UIImage(named: "pin")
            geometry.firstMaterial?.diffuse.contents = image
            targetNode.geometry = geometry
            targetNode.position = computeTargetCoordinate()
            //targetNode.rotation = SCNVector4(0, 1, 0, 90 - parent.model.degree)
            targetNode.orientation = device.orientation
            
            //print("position: \(targetNode.position), rotation: \(targetNode.rotation)")
            print("position: \(targetNode.position), scale: \(scale)")
            
            targetNode.addChildNode(createTextNode())
        }
        
        func createTextNode() -> SCNNode {
            let text = SCNText(string: parent.model.distanceStr, extrusionDepth: 0.0)
            text.font = UIFont.boldSystemFont(ofSize: 0.3 * scale)
            text.materials.first?.diffuse.contents = UIColor.orange
            
            let textNode = SCNNode(geometry: text)
            let (min, max) = (textNode.boundingBox)
            let textBoundsWidth = (max.x - min.x)
            let textBoundsheight = (max.y - min.y)
            textNode.pivot = SCNMatrix4MakeTranslation(textBoundsWidth/2 + min.x,
                                                       textBoundsheight/2 + min.y,
                                                       0)
            textNode.position = SCNVector3(0, 0.8 * scale, 0)
            //print(parent.model.distanceStr)
            return textNode
        }
        
        func computeTargetCoordinate() -> SCNVector3 {
            let deg = (parent.model.degree - parent.model.deviceHeading) * Double.pi / 180
            let x = parent.model.distance * cos(deg) + Double(device.worldPosition.x)
            let y = 0.0 + Double(device.worldPosition.y)
            let len = parent.model.distance > 100 ? 100 : parent.model.distance
            let z = len * sin(deg) + Double(device.worldPosition.z)
            //let ztmp = parent.model.distance > 100 ? -100 : parent.model.distance * sin(deg) + Double(device.worldPosition.z)
            return SCNVector3(x, y, z)
        }
    }
}

/*struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(distanceStr: <#Binding<String>#>)
    }
}*/
