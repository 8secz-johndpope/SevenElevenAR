//
//  ViewController.swift
//  SevenElevenAR
//
//  Created by 藤井陽介 on 2019/10/04.
//  Copyright © 2019 touyou. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet weak var arView: ARView! {
        didSet {
            arView.isHidden = deviceName.contains("iPhone 11")
        }
    }
    @IBOutlet weak var arScnView: ARSCNView! {
        didSet {
            arScnView.isHidden = !deviceName.contains("iPhone 11")
        }
    }

    private var deviceName: String = getDeviceInfo()
    private var sevenElevenNode: SCNNode!

    let imageConfiguration: ARImageTrackingConfiguration = {
        let configuration = ARImageTrackingConfiguration()
        let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        configuration.worldAlignment = .gravity
        configuration.trackingImages = images!
        configuration.maximumNumberOfTrackedImages = 1
        return configuration
    }()
    private let feedback = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !deviceName.contains("iPhone 11") {
            // iPhone 11以外だと金色のオブジェクトが出るだけ
            let scene = try! Seven.loadScene()
            arView.scene.anchors.append(scene)
        } else {
            arScnView.delegate = self

            sevenElevenNode = SCNScene(named: "art.scnassets/SevenElevenLogo.scn")?.rootNode.childNode(withName: "thumbnail", recursively: true)
            sevenElevenNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "seveneleven")

            feedback.prepare()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if deviceName.contains("iPhone 11") {
            // iPhone 11だとセブンイレブンが出る
            arScnView.session.run(imageConfiguration)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if deviceName.contains("iPhone 11") {
            arScnView.session.pause()
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return nil
        }

        switch imageAnchor.referenceImage.name {
        case "sevenAR":
            DispatchQueue.main.async {
                self.feedback.impactOccurred()
            }

            sevenElevenNode.scale = SCNVector3(0.1, 0.1, 0.1)
            let scale1 = SCNAction.scale(to: 1.5, duration: 0.2)
            let scale2 = SCNAction.scale(to: 1, duration: 0.1)
            scale2.timingMode = .easeOut
            let group = SCNAction.sequence([scale1, scale2])
            sevenElevenNode.runAction(group)
            
            return sevenElevenNode
        default:
            return nil
        }
    }

    func restartSessionWithoutDelete() {
        arScnView.session.pause()
        arScnView.session.run(imageConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        if let arError = error as? ARError {
            switch arError.errorCode {
            case 102:
                imageConfiguration.worldAlignment = .gravity
                restartSessionWithoutDelete()
            default:
                restartSessionWithoutDelete()
            }
        }
    }
}
