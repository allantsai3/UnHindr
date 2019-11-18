/*
 File: [MotorGameScene]
 Creators: [Jake]
 Date created: [10/11/2019]
 Date updated: [17/11/2019]
 Updater name: [Jake]
 File description: [Controls the Motor Game Wellness test]
 */

import SpriteKit
import CoreMotion
import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Category to track physics properties of entities involved in the Motor Game
struct PhysicsCategory {
    static let Marble : UInt32 = 0x1 << 1
    static let Wall : UInt32 = 0x1 << 2
    static let Edge : UInt32 = 0x1 << 3
}

class MotorGameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Enumerator holding cases describing which side of the screen the walls will spawn from
    enum wallSpawnPoint :CaseIterable{
        case right
        case left
    }
    
    var accessibleElements: [UIAccessibilityElement] = []
    
    var marble = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveRemove = SKAction()
    var moveWalls = SKAction()
    
    var gameStarted = false
    var touchedEdge = false
    
    var motionManager: CMMotionManager?
    var gapPos: CGFloat?
    var gapScalingFactor: CGFloat?
    var distance: CGFloat?
    var minusOrPlusNumber: CGFloat?
    var minusOrPlusBool = Bool()
    
    var timer = Timer()
    var scoreCounter = 0
    
    let startGameLabel = SKLabelNode()
    let scoreLabel = SKLabelNode()
    let endGameLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var quitButton = SKSpriteNode()
    
    // MARK: - Restarts scene: removes all current children and actions, resets touchedEdge and scoreCounter, calls createScene()
    // Input:
    //      1. None
    // Output:
    //      1. None
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        //RetryButton.alpha = 0
        gameStarted = false
        touchedEdge = false
        scoreCounter = 0
        createScene()
    }
    
    // MARK: - Creates the scene, initializes physics for the world, screen edge, and marble. Initializes start game, score, and end game labels, adds score label to scene.
    // Input:
    //      1. None
    // Output:
    //      1. Marble is on screen and affected by phone tilt after screen is tapped, score label is on screen.
    func createScene() {
        isAccessibilityElement = false
        startGameLabel.isAccessibilityElement = true
        endGameLabel.isAccessibilityElement = true
        restartButton.isAccessibilityElement = true
        quitButton.isAccessibilityElement = true
        
        
        self.physicsWorld.contactDelegate = self
        
        //Sets the physics body of the screen edge
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        physicsBody?.categoryBitMask = PhysicsCategory.Edge
        
        //Initializes the start game label
        startGameLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 2 / 3)
        startGameLabel.fontSize = 60
        startGameLabel.fontColor = UIColor.black
        startGameLabel.numberOfLines = 0
        startGameLabel.text = "Tilt your screen to control the marble,\ntry to last as long a possible without \ntouching the edge of the screen.\nTap to begin!"
        startGameLabel.accessibilityValue = "Tilt your screen to control the marble,\ntry to last as long a possible without \ntouching the edge of the screen.\nTap to begin!"
        startGameLabel.zPosition = 5
        startGameLabel.horizontalAlignmentMode = .center
        self.addChild(startGameLabel)
        
        //Initializes the score label and places it in the scene
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 9 / 10)
        scoreLabel.fontSize = 80
        scoreLabel.fontColor = UIColor.black
        scoreLabel.text = "\(scoreCounter)"
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        //Initializes the end game label
        endGameLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 2 / 3)
        endGameLabel.fontSize = 80
        endGameLabel.fontColor = UIColor.black
        endGameLabel.numberOfLines = 0
        endGameLabel.text = "Game Over! \nYou lasted for \(scoreCounter) second(s)! \nPlay again?"
        endGameLabel.zPosition = 5
        endGameLabel.horizontalAlignmentMode = .center
        
        //Initializes the marble to be moved by the user. Initializes its physics body properties and places it in the scene
        marble = SKSpriteNode(imageNamed: "Marble")
        marble.position = CGPoint(x: frame.midX, y: frame.midY)
        marble.name = "Marble"
        marble.size = CGSize(width: marble.size.width / 2.5, height: marble.size.height / 2.5)
        let marbleRadius = marble.frame.width / 2.0
        marble.physicsBody = SKPhysicsBody(circleOfRadius: marbleRadius)
        marble.physicsBody?.affectedByGravity = false
        marble.physicsBody?.allowsRotation = false
        marble.physicsBody?.categoryBitMask = PhysicsCategory.Marble
        marble.physicsBody?.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Edge
        marble.physicsBody?.contactTestBitMask = PhysicsCategory.Edge
        
        addChild(marble)
        
        gapPos = 0
    }
    
    override func didMove(to view: SKView){
        createScene()
    }
    
    // MARK: - Creates "Retry" and "Quit" buttons that restart the game, and save score and timestamp to database while exiting to the home screen.
    // Input:
    //      1. None
    // Output:
    //      1. "Retry" and "Quit" buttons appear on the screen
    func createEndGameButtons() {
        
        restartButton = SKSpriteNode(imageNamed: "Retry")
        restartButton.position = CGPoint(x: self.frame.width / 4, y: self.frame.height * 2 / 5)
        restartButton.size = CGSize(width: self.frame.width * 5 / 14, height: self.frame.height / 10)
        restartButton.zPosition = 6
        restartButton.accessibilityLabel = "RestartButton"
        print(restartButton.frame.origin.x)
        print(restartButton.frame.origin.y)
        quitButton = SKSpriteNode(imageNamed: "Quit")
        quitButton.position = CGPoint(x: self.frame.width * 3 / 4, y: self.frame.height * 2 / 5)
        quitButton.size = CGSize(width: self.frame.width * 5 / 14, height: self.frame.height / 10)
        quitButton.zPosition = 6
        quitButton.accessibilityLabel = "QuitButton"
        self.addChild(restartButton)
        self.addChild(quitButton)
    }
    
    // MARK: - Increments the score counter and label for every timer interval
    // Input:
    //      1. None
    // Output:
    //      1. Score counter increased by 1 and updated score is displayed to the screen in the score label
    @objc func timerAction(){
        scoreCounter += 1
        scoreLabel.text = "\(scoreCounter)"
    }
    
    // MARK: - Detects touches on the screen, starts control of marble through screen tilt, starts incrementing the score and starts wall spawning controls functionality of "Retry" and "Quit" buttons
    // Input:
    //      1. Touches on the screen
    //      2. UI Event
    // Output:
    //      1. If the screen is tapped at the start of the game, the startGame label disappears, the marble is controlled with screen tilt, the score counter starts incrementing, and walls start spawning
    //      2. The game is restarted if "Retry" button is tapped
    //      3. Score and Timestamp data are sent to database and screen is transitioned to Home Menu if "Quit" button is tapped

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            gameStarted = true
            marble.physicsBody?.affectedByGravity = true
            startGameLabel.removeFromParent()
            //Enables marble to be controlled by screen tilt
            motionManager = CMMotionManager()
            motionManager?.startAccelerometerUpdates()
            //Creates the timer to increment the score label every 1 second.
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true )
            
            //Repeadedly spawn walls as long as the marble hasn't touched the edge of the screen
            let spawn = SKAction.run({
                () in
                if self.touchedEdge == false {
                self.createWall()
                }
            })
            let delay = SKAction.wait(forDuration: 4)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let gameRunning = SKAction.repeatForever(spawnDelay)
            self.run(gameRunning)
        }
        else {
            for touch in touches {
                let location = touch.location(in: self)
                if touchedEdge == true {
                    //If the user taps the "Retry" button, restart the game
                    if restartButton.contains(location) {
                        restartScene()
                    }
                    //If the user taps the "Quit" button, save score and timestamp data to Firebase and exit to the Home Menu
                    else if quitButton.contains(location) {
                        var ref: DocumentReference? = nil
                        ref = Services.motorGameRef
                            .addDocument(data: [
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
    }
    
    // MARK: - Detects contact between physics bodies in the Physcis World
    // Input:
    //      1. Contact between two physics bodies
    // Output:
    //      1. If contact happened between the marble and an edge of the screen, stop all movement, display end game text and call createEndGameButtons()
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == PhysicsCategory.Marble && secondBody.categoryBitMask == PhysicsCategory.Edge || firstBody.categoryBitMask == PhysicsCategory.Edge && secondBody.categoryBitMask == PhysicsCategory.Marble) {
            if (touchedEdge == false) {
            touchedEdge = true
            timer.invalidate()
            marble.physicsBody?.affectedByGravity = false
            marble.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            for child in 0..<(self.children.count) {
                self.children[child].isPaused = true
                }
            endGameLabel.text = "Game Over! \nYou lasted for \(scoreCounter) seconds! \nPlay again?"
            endGameLabel.horizontalAlignmentMode = .center
            endGameLabel.verticalAlignmentMode = .center
            self.addChild(endGameLabel)
            createEndGameButtons()
            }
        }
    }
    
    // MARK: - Creates walls with a gap for the marble to pass through and initializes their physics properties, randomizes the height of the gap and the spawn point of the walls (left or right side of screen), causes walls to move across the screen
    // Input:
    //      1. None
    // Output:
    //      1. A wall with a gap of random height is spawned randomly on either side of the screen and moves to the opposite side of the screen at a specified speed.
    func createWall() {
        wallPair = SKNode()
        
        //Create top and bottom wall Sprite nodes to be added to a single "WallPair" node
        let topWall = SKSpriteNode(imageNamed: "wallVert")
        let bottomWall = SKSpriteNode(imageNamed: "wallVert")
        
        //Set size of the walls
        let size = CGSize(width: topWall.size.width * 2, height: self.frame.height*2)
        topWall.size = size
        bottomWall.size = size
        
        //Randomly pick height of the gap in the walls
        self.minusOrPlusBool = Bool.random()
        self.minusOrPlusNumber = self.minusOrPlusBool ? 1 : -1
        self.gapScalingFactor = CGFloat.random(in: 3...10)
        gapPos = self.frame.height*(minusOrPlusNumber!/gapScalingFactor!)
        
        //Randomly choose left or right side of screen to spawn a wall
        let randomWallSpawnPoint = wallSpawnPoint.allCases.randomElement()
        
        //
        switch randomWallSpawnPoint {
        case .some(.right):
            topWall.position = CGPoint(x: self.frame.width + topWall.frame.width/2, y: self.frame.height + self.frame.height/16 + gapPos!)
            bottomWall.position = CGPoint(x: self.frame.width + bottomWall.frame.width/2, y: gapPos! - self.frame.height/16)
        
            distance = CGFloat(self.frame.width*2)
            moveWalls = SKAction.moveBy(x: -distance!, y: 0.0, duration: TimeInterval(0.005 * distance!))
            
        case .some(.left):
            topWall.position = CGPoint(x: -topWall.frame.width/2, y: self.frame.height + self.frame.height/16 + gapPos!)
            bottomWall.position = CGPoint(x: -bottomWall.frame.width/2, y: gapPos! - self.frame.height/16)
            
            distance = CGFloat(self.frame.width*2)
            moveWalls = SKAction.moveBy(x: distance!, y: 0.0, duration: TimeInterval(0.005 * distance!))

        case .none:
            topWall.position = CGPoint(x: self.frame.width + topWall.frame.width/2, y: self.frame.height + self.frame.height/16 + gapPos!)
            bottomWall.position = CGPoint(x: self.frame.width + bottomWall.frame.width/2, y: gapPos! - self.frame.height/16)
            
            distance = CGFloat(self.frame.width*2)
            moveWalls = SKAction.moveBy(x: -distance!, y: 0.0, duration: TimeInterval(0.005 * distance!))
        }
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Marble
        topWall.physicsBody?.contactTestBitMask = 0
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.Marble
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
        // accelerometer data is constantly read to change the gravity of the world to enable control of the marble through screen tilt
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * Constants.motorGameGravityScaler, dy: accelerometerData.acceleration.y * Constants.motorGameGravityScaler)
        }
    }
    
    
    
    
    
    // MARK: - The fllowing code was taken from Stack Overflow: Written by Dominique Vial, https://stackoverflow.com/questions/34293575/is-it-possible-to-use-xcode-ui-testing-on-an-app-using-spritekit/42676977#42676977
    // The code's purpose is to make elements of Sprite Kit accessbile to XCUITest for the purpose of UI testing.
    
    override func accessibilityElementCount() -> Int {
        initAccessibility()
        return accessibleElements.count
    }
    
    override func accessibilityElement(at index: Int) -> Any? {
        initAccessibility()
        if (index < accessibleElements.count) {
            return accessibleElements[index]
        }
        else {
            return nil
        }
    }
    
    override func index(ofAccessibilityElement element: Any) -> Int {
        initAccessibility()
        return accessibleElements.index(of: element as! UIAccessibilityElement)!
    }
    
    func initAccessibility() {
        if accessibleElements.count == 0 {
            let elemForEndGameLabel = UIAccessibilityElement(accessibilityContainer: self.view!)
            var frameForEndGameLabel = endGameLabel.frame
            frameForEndGameLabel.origin = (view?.convert(frameForEndGameLabel.origin, from: self))!
            frameForEndGameLabel.origin.y = frameForEndGameLabel.origin.y - frameForEndGameLabel.size.height
            elemForEndGameLabel.accessibilityLabel = "EndGameLabel"
            elemForEndGameLabel.accessibilityFrame = frameForEndGameLabel
            elemForEndGameLabel.accessibilityTraits = UIAccessibilityTraits.staticText
            accessibleElements.append(elemForEndGameLabel)
            
            let elemForStartGameLabel = UIAccessibilityElement(accessibilityContainer: self.view!)
            var frameForStartGameLabel = startGameLabel.frame
            frameForStartGameLabel.origin = (view?.convert(frameForStartGameLabel.origin, from: self))!
            frameForStartGameLabel.origin.y = frameForStartGameLabel.origin.y - frameForStartGameLabel.size.height
            elemForStartGameLabel.accessibilityLabel = "StartGameLabel"
            elemForStartGameLabel.accessibilityFrame = frameForStartGameLabel
            elemForStartGameLabel.accessibilityTraits = UIAccessibilityTraits.staticText
            accessibleElements.append(elemForStartGameLabel)
            
            let elemForRestartButton = UIAccessibilityElement(accessibilityContainer: self.view!)
            var frameForRestartButton = restartButton.frame
            frameForRestartButton.origin = (view?.convert(frameForRestartButton.origin, from: self))!
            frameForRestartButton.origin.y = frameForRestartButton.origin.y - frameForRestartButton.size.height
            elemForRestartButton.accessibilityLabel = "RestartButton"
            elemForRestartButton.accessibilityFrame = frameForRestartButton
            elemForRestartButton.accessibilityTraits = UIAccessibilityTraits.button
            accessibleElements.append(elemForRestartButton)
            
            let elemForQuitButton = UIAccessibilityElement(accessibilityContainer: self.view!)
            var frameForQuitButton = quitButton.frame
            frameForQuitButton.origin = (view?.convert(frameForQuitButton.origin, from: self))!
            frameForQuitButton.origin.y = frameForQuitButton.origin.y - frameForQuitButton.size.height
            elemForQuitButton.accessibilityLabel = "QuitButton"
            elemForQuitButton.accessibilityFrame = frameForQuitButton
            elemForQuitButton.accessibilityTraits = UIAccessibilityTraits.button
            accessibleElements.append(elemForQuitButton)
        }
    }
 
}

