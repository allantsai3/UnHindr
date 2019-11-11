
/*
 File: [MotorGameScene]
 Creators: [Jake]
 Date created: [10/11/2019]
 Date updated: [10/11/2019]
 Updater name: [Jake]
 File description: []
 */
import SpriteKit
import CoreMotion

class Marble: SKSpriteNode { }

class MotorGameScene: SKScene {
    
    var motionManager: CMMotionManager?
    
    override func didMove(to view: SKView){
        //let background = SKSpriteNode(imageNamed: "White")
        //background.position = CGPoint(x: frame.midX, y: frame.midY)
        //background.alpha = 1
       // background.zPosition = -1
        //addChild(background)
        let marble = Marble(imageNamed: "Marble")

        
        marble.position = CGPoint(x: frame.midX, y: frame.midY)
        marble.name = "Marble"
        marble.size = CGSize(width: marble.size.width / 4.0, height: marble.size.height / 4.0)
        let marbleRadius = marble.frame.width/2
        
        marble.physicsBody = SKPhysicsBody(circleOfRadius: marbleRadius)
        marble.physicsBody?.allowsRotation = false
        marble.physicsBody?.restitution = 0
        marble.physicsBody?.friction = 0
        
        addChild(marble)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 3, dy: accelerometerData.acceleration.y * 3)
        }
    }
}
