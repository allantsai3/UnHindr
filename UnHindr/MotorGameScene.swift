/*
 File: [MotorGameScene]
 Creators: [Jake]
 Date created: [10/11/2019]
 Date updated: [10/11/2019]
 Updater name: [Jake]
 File description: []
 */

import SpriteKit

class Marble: SKSpriteNode { }

class MotorGameScene: SKScene {
    override func didMove(to view: SKView){
        let background = SKSpriteNode(imageNamed: "White")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
        
        let marble = Marble(imageNamed: "Marble")
        //let marbleRadius = marble.frame.width/2.0
        
        marble.position = CGPoint(x: frame.midX, y: frame.midY)
        marble.name = "Marble"
        addChild(marble)
        
        
    }
    
    override func update(_ currentTime: TimeInterval){
        
    }
}


