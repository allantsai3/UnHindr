
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

struct PhysicsBitMask {
    static let Marble : UInt32 = 0x1 << 1
    static let Wall : UInt32 = 0x1 << 2
}

class MotorGameScene: SKScene {
    
    enum wallSpawnPoint :CaseIterable{
        case right
        case left
        //case top
        //case bottom
    }
    
    var wallPair = SKNode()
    var moveRemove = SKAction()
    var moveWalls = SKAction()
    
    var motionManager: CMMotionManager?
    var vertGapPos: CGFloat?
    var horizGapPos: CGFloat?
    var vertGapScalingFactor: CGFloat?
    var distance: CGFloat?
    var minusOrPlusNumber: CGFloat?
    var minusOrPlusBool = true
    
    override func didMove(to view: SKView){
        //let background = SKSpriteNode(imageNamed: "White")
        //background.position = CGPoint(x: frame.midX, y: frame.midY)
        //background.alpha = 1
       // background.zPosition = -1
        //addChild(background)
        
        let marble = Marble(imageNamed: "Marble")

        
        marble.position = CGPoint(x: frame.midX, y: frame.midY)
        marble.name = "Marble"

        
        marble.size = CGSize(width: marble.size.width / 2.5, height: marble.size.height / 2.5)
        let marbleRadius = marble.frame.width / 2.0
        marble.physicsBody = SKPhysicsBody(circleOfRadius: marbleRadius)
        marble.physicsBody?.allowsRotation = false
        marble.physicsBody?.restitution = 0
        marble.physicsBody?.friction = 0
        marble.physicsBody?.categoryBitMask = PhysicsBitMask.Marble
        marble.physicsBody?.collisionBitMask = PhysicsBitMask.Wall
        marble.physicsBody?.contactTestBitMask = PhysicsBitMask.Wall
        
        addChild(marble)
        
        vertGapPos = 0
        horizGapPos = 600
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
        let spawn = SKAction.run({
            () in
            
            self.createWall()
        })
        let delay = SKAction.wait(forDuration: 5)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let gameRunning = SKAction.repeatForever(spawnDelay)
        self.run(gameRunning)
        
        //self.createWall()
        
//        let distance = CGFloat(self.frame.width + wallPair.frame.width)
//        let moveWalls = SKAction.moveBy(x: -distance, y: 0.0, duration: TimeInterval(0.008 * distance))
//        let removeWalls = SKAction.removeFromParent()
//        moveRemove = SKAction.sequence([moveWalls, removeWalls])
        //let moveRemoveForever = SKAction.repeatForever(moveRemove)
        //self.run(moveRemoveForever)
    }
    

    func createWall() {
        wallPair = SKNode()
        
        let topWall = SKSpriteNode(imageNamed: "wallVert")
        let bottomWall = SKSpriteNode(imageNamed: "wallVert")
        
        let vertSize = CGSize(width: topWall.size.width * 2, height: self.frame.height*2)
        
        self.minusOrPlusBool = Bool.random()
        self.minusOrPlusNumber = self.minusOrPlusBool ? 1 : -1
        
        let randomWallSpawnPoint = wallSpawnPoint.allCases.randomElement()
        
        switch randomWallSpawnPoint {
        case .some(.right):
            self.vertGapScalingFactor = CGFloat.random(in: 3...10)
        
            topWall.size = vertSize
            bottomWall.size = vertSize
        
            vertGapPos = self.frame.height*(minusOrPlusNumber!/vertGapScalingFactor!)
        
            topWall.position = CGPoint(x: self.frame.width + topWall.frame.width/2, y: self.frame.height + self.frame.height/16 + vertGapPos!)
            bottomWall.position = CGPoint(x: self.frame.width + bottomWall.frame.width/2, y: vertGapPos! - self.frame.height/16)
        
            distance = CGFloat(self.frame.width*2)
            moveWalls = SKAction.moveBy(x: -distance!, y: 0.0, duration: TimeInterval(0.005 * distance!))
            
        case .some(.left):
            self.vertGapScalingFactor = CGFloat.random(in: 3...10)
            
            topWall.size = vertSize
            bottomWall.size = vertSize
            
            vertGapPos = self.frame.height*(minusOrPlusNumber!/vertGapScalingFactor!)
            
            topWall.position = CGPoint(x: -topWall.frame.width/2, y: self.frame.height + self.frame.height/16 + vertGapPos!)
            bottomWall.position = CGPoint(x: -bottomWall.frame.width/2, y: vertGapPos! - self.frame.height/16)
            
            distance = CGFloat(self.frame.width*2)
            moveWalls = SKAction.moveBy(x: distance!, y: 0.0, duration: TimeInterval(0.005 * distance!))
//        case .some(.top):
//            print("sup")
//        case .some(.bottom):
//            print("sup")
        case .none:
            print("sup")
        }
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsBitMask.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsBitMask.Marble
        topWall.physicsBody?.contactTestBitMask = PhysicsBitMask.Marble
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsBitMask.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsBitMask.Marble
        bottomWall.physicsBody?.contactTestBitMask = PhysicsBitMask.Marble
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        
        topWall.setScale(0.5)
        bottomWall.setScale(0.5)
        
        wallPair.zPosition = 2
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        self.addChild(wallPair)
        
        let removeWalls = SKAction.removeFromParent()
        moveRemove = SKAction.sequence([moveWalls, removeWalls])
        wallPair.run(moveRemove)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 3, dy: accelerometerData.acceleration.y * 3)
        }
    }
}
