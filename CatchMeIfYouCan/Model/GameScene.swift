

//
//  GameScene.swift
//  Get An Apple
//
//  Created by Hlushchenko Andrii on 12/7/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background = SKSpriteNode(imageNamed: "Background")
    var basket: SKSpriteNode!
    var apple: SKSpriteNode!
    var banana: SKSpriteNode!
    var can: SKSpriteNode!
    var successLabel: SKLabelNode!
    var gameTimer: Timer!
    var objectsTimer: Timer!
    var currentNode: SKNode?
    var updatedDuration: TimeInterval = 5.0
    let basketCategory: UInt32 = 10
    let appleCategory: UInt32 = 8
    let bananaCategory: UInt32 = 6
    let canCategory: UInt32 = 7
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    let alert = UIAlertController(title: "You are great! Lets start again!", message: "", preferredStyle: .alert)
    
    override func didMove(to view: SKView) {
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 60
        scoreLabel.position = CGPoint(x: -150, y: 500)
        score = 0
        scoreLabel.zPosition = 500
        self.addChild(scoreLabel)
        
        background.position = CGPoint(x: 0, y: 0)
        background.xScale = 1
        background.yScale = 1.32
        self.addChild(background)
        
        basket = SKSpriteNode(imageNamed: "Basket50")
        basket.position = CGPoint(x: 0, y: -480)
        basket.zPosition = 2
        basket.physicsBody = SKPhysicsBody(rectangleOf: basket.size)
        basket.physicsBody?.isDynamic = false
        basket.name = "Basket50"
        basket.setScale(1.2)
        basket.physicsBody?.categoryBitMask = basketCategory
        basket.physicsBody?.contactTestBitMask = appleCategory | bananaCategory
        basket.physicsBody?.collisionBitMask = 1
        basket.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(basket)
        
        successLabel = SKLabelNode(text: "+1")
        successLabel.fontName = "AmericanTypewriter-Bold"
        successLabel.fontColor = UIColor.green
        successLabel.fontSize = 70
        successLabel.position = CGPoint(x: 0, y: 0)
        successLabel.zPosition = 500
        successLabel.alpha = 0
        self.addChild(successLabel)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(addFruit), userInfo: nil, repeats: true)
        objectsTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(reduceDuration), userInfo: nil, repeats: true)
    }
    
    @objc func addFruit() {
        
        
        apple = SKSpriteNode(imageNamed: "Apple50")
        apple.physicsBody = SKPhysicsBody(rectangleOf: apple.size)
        apple.name = "Apple50"
        apple.physicsBody?.categoryBitMask = appleCategory
        
        banana = SKSpriteNode(imageNamed: "Banana50")
        banana.physicsBody = SKPhysicsBody(rectangleOf: banana.size)
        banana.name = "Banana50"
        banana.physicsBody?.categoryBitMask = bananaCategory
        
        can = SKSpriteNode(imageNamed: "Can50")
        can.physicsBody = SKPhysicsBody(rectangleOf: can.size)
        can.name = "Can50"
        can.physicsBody?.categoryBitMask = canCategory
        
        
        let fruits = [apple, banana, can]
        let fruit: SKSpriteNode = fruits.randomElement()!!
        let randomPos = GKRandomDistribution(lowestValue: -220, highestValue: 220)
        let pos = CGFloat(randomPos.nextInt())
        fruit.position = CGPoint(x: pos, y: 800)
        fruit.setScale(0.3)
        fruit.zPosition = 1
        fruit.physicsBody?.collisionBitMask = 1
        fruit.physicsBody?.contactTestBitMask = basketCategory
        fruit.physicsBody?.isDynamic = true
        self.addChild(fruit)
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: -800), duration: updatedDuration))
        actions.append(SKAction.removeFromParent())
        fruit.run(SKAction.sequence(actions))
    }
    
    @objc func reduceDuration () -> TimeInterval {
        
        let newReducedDuration = updatedDuration / 1.2
        updatedDuration = newReducedDuration
        return updatedDuration
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? ""}
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "Basket50" && firstNode.name == "Apple50" {
            score += 1
            firstNode.removeFromParent()
            successLabel.alpha = 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.successLabel.alpha = 0.0
            }
            
        } else if secondNode.name == "Basket50" && firstNode.name == "Banana50" {
            firstNode.removeFromParent()
            showAlert()
            dissmissAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.restartGameScene()
            }
        } else {
            secondNode.removeFromParent()
            showAlert()
            dissmissAlert()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.restartGameScene()
            }
        }
    }
    func showAlert() {
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func dissmissAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.alert.dismiss(animated: true, completion: nil)
        }
    }
    func restartGameScene() {
        let newScene = GameScene(size: self.size)
        newScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newScene.scaleMode = self.scaleMode
        let animation = SKTransition.fade(withDuration: 0.3)
        self.view?.presentScene(newScene, transition: animation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNodes = self.nodes(at: location)
            for node in touchedNodes.reversed() {
                if node.name == "Basket50" {
                    self.currentNode = node
                }
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let node = self.currentNode {
            let touchLocation = touch.location(in: self)
            node.position.x = touchLocation.x
            
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentNode = nil
    }
    override func update(_ currentTime: TimeInterval) {
        
    }
    
}
