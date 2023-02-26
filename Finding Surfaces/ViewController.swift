//
//  ViewController.swift
//  Finding Surfaces
//
//  Created by Vladimir on 21.02.2023.
//


import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
//MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
//MARK: - Methods
    
    /// add ship model
    /// - Returns: ASCNode associated with the model
    func loadShip()->SCNNode{
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let shipNode = scene.rootNode.clone()
        return shipNode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // enabled default lighting
        sceneView.autoenablesDefaultLighting = true
        
        // set the debug options
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal{
            // set size
            let extent = planeAnchor.extent
            let width = CGFloat(extent.x)
            let height = CGFloat(extent.z)
            
            //create geometry
            let plane = SCNPlane(width: width, height: height)
            plane.firstMaterial?.diffuse.contents = UIColor.green
            
            // create node
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            planeNode.opacity = 0.75
            
            // add node to the detected plane
            node.addChildNode(planeNode)
            node.addChildNode(loadShip())
            
            
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal{
           
            for childnode in node.childNodes {
                childnode.simdPosition = planeAnchor.center
                
                if let plane = childnode.geometry as? SCNPlane{
                    plane.width = CGFloat(planeAnchor.extent.x)
                    plane.height = CGFloat(planeAnchor.extent.z)
                }
            }
        }
    }
}
