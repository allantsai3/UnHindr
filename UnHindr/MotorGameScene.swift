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
import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class Marble: SKSpriteNode { }

struct PhysicsBitMask {
    static let Marble : UInt32 = 0x1 << 1
    static let Wall : UInt32 = 0x1 << 2
    static let Edge : UInt32 = 0x1 << 3
}

class MotorGameScene: SKScene, SKPhysicsContactDelegate {
    
    enum wallSpawnPoint :CaseIterable{
        case right
        case left
        //case top
        //case bottom
    }
    
    var wallPair = SKNode()
    var moveRemove = SKAction()
    var moveWalls = SKAction()
    
    var touchedWall = false
    
    var motionManager: CMMotionManager?
    var vertGapPos: CGFloat?
    var horizGapPos: CGFloat?
    var vertGapScalingFactor: CGFloat?
    var distance: CGFloat?
    var minusOrPlusNumber: CGFloat?
    var minusOrPlusBool = Bool()
    
    var timer = Timer()
    var scoreCounter = 0
    
    let scoreLabel = SKLabelNode()
    let endGameLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var quitButton = SKSpriteNode()
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        touchedWall = false
        scoreCounter = 0
        createScene()
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        physicsBody?.categoryBitMask = PhysicsBitMask.Edge
        
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 9 / 10)
        scoreLabel.fontSize = 80
        scoreLabel.fontColor = UIColor.black
        scoreLabel.text = "\(scoreCounter)"
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        endGameLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        endGameLabel.fontSize = 80
        endGameLabel.fontColor = UIColor.black
        endGameLabel.numberOfLines = 0
        endGameLabel.text = "Game Over! \nYou lasted for \(scoreCounter) seconds! \nPlay again?"
        endGameLabel.zPosition = 5
        endGameLabel.horizontalAlignmentMode = /*SKLabelHorizontalAlignmentMode*/.center
        
        
        let marble = Marble(imageNamed: "Marble")
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true )
        
        marble.position = CGPoint(x: frame.midX, y: frame.midY)
        marble.name = "Marble"
        
        
        marble.size = CGSize(width: marble.size.width / 2.5, height: marble.size.height / 2.5)
        let marbleRadius = marble.frame.width / 2.0
        marble.physicsBody = SKPhysicsBody(circleOfRadius: marbleRadius)
        marble.physicsBody?.allowsRotation = false
        marble.physicsBody?.restitution = 0
        marble.physicsBody?.friction = 0
        marble.physicsBody?.categoryBitMask = PhysicsBitMask.Marble
        marble.physicsBody?.collisionBitMask = PhysicsBitMask.Wall | PhysicsBitMask.Edge
        marble.physicsBody?.contactTestBitMask = PhysicsBitMask.Edge
        
        addChild(marble)
        
        vertGapPos = 0
        horizGapPos = 600
        
        
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
        let spawn = SKAction.run({
            () in
            if self.touchedWall == false {
            self.createWall()
            }
        })
        let delay = SKAction.wait(forDuration: 5)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let gameRunning = SKAction.repeatForever(spawnDelay)
        self.run(gameRunning)
    }
    
    override func didMove(to view: SKView){
        createScene()
    }
    
    func createButtons() {
        restartButton = SKSpriteNode(imageNamed: "Back")
        restartButton.position = CGPoint(x: self.frame.width / 3, y: self.frame.height * 2 / 5)
        restartButton.zPosition = 6
        quitButton = SKSpriteNode(imageNamed: "Cancel")
        quitButton.position = CGPoint(x: self.frame.width * 2 / 3, y: self.frame.height * 2 / 5)
        quitButton.zPosition = 6
        self.addChild(restartButton)
        self.addChild(quitButton)
    }
    
    @objc func timerAction(){
        scoreCounter += 1
        scoreLabel.text = "\(scoreCounter)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if touchedWall == true {
                if restartButton.contains(location) {
                    restartScene()
                }
                else if quitButton.contains(location) {
                    //send data to firebase and exit to wellness tests or home
                    var ref: DocumentReference? = nil
                    ref = Services.db.collection("users").document(Services.userRef!).collection("MotorGameData").addDocument(data: [
                        "Time": Timestamp(date: Date()),
                        "Score": scoreCounter
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                    
                    let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController")
                    vc.view.frame = (self.view?.frame)!
                    vc.view.layoutIfNeeded()
                    self.view?.window?.rootViewController = vc
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == PhysicsBitMask.Marble && secondBody.categoryBitMask == PhysicsBitMask.Edge || firstBody.categoryBitMask == PhysicsBitMask.Edge && secondBody.categoryBitMask == PhysicsBitMask.Marble) {
            if (touchedWall == false) {
            touchedWall = true
            timer.invalidate()
            endGameLabel.text = "Game Over! \nYou lasted for \(scoreCounter) seconds! \nPlay again?"
            endGameLabel.horizontalAlignmentMode = /*SKLabelHorizontalAlignmentMode*/.center
            endGameLabel.verticalAlignmentMode = .center
            self.addChild(endGameLabel)
            createButtons()
            }
        }
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
            self.vertGapScalingFactor = CGFloat.random(in: 3...10)
            
            topWall.size = vertSize
            bottomWall.size = vertSize
            
            vertGapPos = self.frame.height*(minusOrPlusNumber!/vertGapScalingFactor!)
            
            topWall.position = CGPoint(x: self.frame.width + topWall.frame.width/2, y: self.frame.height + self.frame.height/16 + vertGapPos!)
            bottomWall.position = CGPoint(x: self.frame.width + bottomWall.frame.width/2, y: vertGapPos! - self.frame.height/16)
            
            distance = CGFloat(self.frame.width*2)
            moveWalls = SKAction.moveBy(x: -distance!, y: 0.0, duration: TimeInterval(0.005 * distance!))
        }
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsBitMask.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsBitMask.Marble
        topWall.physicsBody?.contactTestBitMask = 0
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsBitMask.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsBitMask.Marble
        bottomWall.physicsBody?.contactTestBitMask = 0
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
