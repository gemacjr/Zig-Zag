//
//  GameViewController.swift
//  Zig Zag
//
//  Created by Ed McCormic on 4/10/17.
//  Copyright © 2017 Swiftbeard. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

struct  bodyNames {
    static let Person = 0x1 >> 1
    static let Coin = 0x1 >> 2
}

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    let scene = SCNScene()
    let cameraNode = SCNNode()
    
    var person = SCNNode()
    
    let firstBox = SCNNode()
    
    var goingLeft = Bool()
    
    var tempBox = SCNNode()
    
    var prevBoxNumber = Int()
    
    var boxNumber = Int()
    
    var firstOne = Bool()
    
    override func viewDidLoad() {
        self.createScene()
    }
    
    func fadeIn(node : SCNNode) {
        
        node.opacity = 0
        node.runAction(SCNAction.fadeIn(duration: 0.5))
    }
    
    func createCoin(box : SCNNode) {
        
        let spin = SCNAction.rotate(by: CGFloat(M_PI * 2), around: SCNVector3Make(0, 0.5, 0), duration: 0.5)
        
        let randomNumber = arc4random() % 8
        
        if randomNumber == 3 {
            let coinScene = SCNScene(named: "coin.dae")
            let coin = coinScene?.rootNode.childNode(withName: "Coin", recursively: true)
            coin?.position = SCNVector3Make(box.position.x, box.position.y + 1, box.position.z)
            coin?.scale = SCNVector3Make(0.2, 0.2, 0.2)
            
            coin?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: SCNPhysicsShape(node: coin!, options: nil))
            
            scene.rootNode.addChildNode(coin!)
            coin?.runAction(SCNAction.repeatForever(spin))
            
        }
        
    }
    
    func fadeOut(node : SCNNode) {
        
        let move = SCNAction.move(to: SCNVector3Make(node.position.x, node.position.y - 2, node.position.z), duration: 0.5)
        node.runAction(move)
        node.runAction(SCNAction.fadeOut(duration: 0.5))
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
        
        let deleteBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber)", recursively: true)
        
        let currentBox = self.scene.rootNode.childNode(withName: "\(prevBoxNumber + 1)", recursively: true)
        
        if (deleteBox?.position.x)! > person.position.x + 1 || (deleteBox?.position.z)! > person.position.z + 1 {
            
            prevBoxNumber += 1
            
            deleteBox?.removeFromParentNode()
            
            createBox()
        }
        
        if person.position.x > (currentBox?.position.x)! - 0.5 && person.position.x < (currentBox?.position.x)! + 0.5 || person.position.z > (currentBox?.position.z)! - 0.5 && person.position.z < (currentBox?.position.z)! + 0.5 {
            
            
            // On Platform
            
        }else {
            
            die()
            
        }
    }
    
    func die() {
        
        
        person.runAction(SCNAction.move(to: SCNVector3Make(person.position.x, person.position.y - 10 , person.position.z), duration: 0.5))
        
        let wait = SCNAction.wait(duration: 0.5) // 1/2 second
        
        let sequence = SCNAction.sequence([wait, SCNAction.run({
            
            node in
            
            self.scene.rootNode.enumerateChildNodes({
                node, stop in
                
                
                node.removeFromParentNode()
                
            })
            
            
            
            
        }), SCNAction.run({
            
            node in
            
            self.createScene()
            
        })])
        
        
    }
    
    
    func createBox() {
      
        tempBox = SCNNode(geometry: firstBox.geometry)
        let prevBox = scene.rootNode.childNode(withName: "\(boxNumber)", recursively: true)
        
        boxNumber += 1
        
        tempBox.name = "\(boxNumber)"
        
        let randomNumber = arc4random() % 2
        
        switch randomNumber {
        case 0:
            tempBox.position = SCNVector3Make((prevBox?.position.x)! - firstBox.scale.x, (prevBox?.position.y)!, (prevBox?.position.z)!)
            
            if firstOne == true {
                firstOne = false
                goingLeft = false
            }
            break
        case 1:
            tempBox.position = SCNVector3Make((prevBox?.position.x)!, (prevBox?.position.y)!, (prevBox?.position.z)! - firstBox.scale.z)
            
            if firstOne == true {
                firstOne = false
                goingLeft = true
            }
            break
            
        default:
            
            break
        }
        
        self.scene.rootNode.addChildNode(tempBox)
        createCoin(box: tempBox)
        
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if goingLeft  == false {
            
            person.removeAllActions()
            person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-100, 0, 0), duration: 20)))
            goingLeft = true
            
        }else {
           
            person.removeAllActions()
            person.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(0, 0, -100), duration: 20)))
            goingLeft = false
            
        }
    }
    
    func createScene(){
        
        self.view.backgroundColor = UIColor.white
        
        boxNumber = 0
        prevBoxNumber = 0
        
        
        
        let sceneView = self.view as! SCNView
        sceneView.delegate = self
        sceneView.scene = scene
        
        //Create Person
        let personGeo = SCNSphere(radius: 0.2)
        person = SCNNode(geometry: personGeo)
        let personMat = SCNMaterial()
        personMat.diffuse.contents = UIColor.red
        personGeo.materials = [personMat]
        person.position = SCNVector3Make(0, 1.1, 0)
        scene.rootNode.addChildNode(person)
        
        //Create camera
        
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 3
        cameraNode.position = SCNVector3Make(20, 20, 20)
        cameraNode.eulerAngles = SCNVector3Make(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: person)
        constraint.isGimbalLockEnabled = true
        self.cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)
        person.addChildNode(cameraNode)
        
        //Create Box
        
        let firstBoxGeo = SCNBox(width: 1, height: 1.5, length: 1, chamferRadius: 0)
        firstBox.geometry = firstBoxGeo
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 1.0)
        firstBoxGeo.materials = [boxMaterial]
        firstBox.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(firstBox)
        firstBox.name = "\(boxNumber)"
        
        for _ in 0...6 {
            createBox()
        }
        
        //Create light
        
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.directional
        light.eulerAngles = SCNVector3Make(-45, 45, 0)
        scene.rootNode.addChildNode(light)
        
        let light2 = SCNNode()
        light2.light = SCNLight()
        light2.light?.type = SCNLight.LightType.directional
        light2.eulerAngles = SCNVector3Make(45, 45, 0)
        scene.rootNode.addChildNode(light2)
        
        
    }
}
