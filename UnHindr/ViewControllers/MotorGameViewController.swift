/*
 File: [MotorGameViewController]
 Creators: [Jake]
 Date created: [10/11/2019]
 Date updated: [10/11/2019]
 Updater name: [Jake]
 File description: [Controls the MotorGame View]
 */

import UIKit
import SpriteKit
import GameplayKit

class MotorGameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from MotorGameScene.sks
            if let scene = SKScene(fileNamed: "MotorGameScene") {
                scene.scaleMode = .resizeFill
                
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}


