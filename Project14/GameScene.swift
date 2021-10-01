//
//  GameScene.swift
//  Project14
//
//  Created by Keith Crooc on 2021-09-27.
//


// challenge!!
// 1. Record own voice to say 'game over' and use it
// 2. When there's a game over, show a SKLabelNode showing the final score ✅
// 3. Use SKEmitterNode to create a smoke-like effect when penguins are hit and a separate mud-like effect when they go into or come out of a hole

import SpriteKit


class GameScene: SKScene {

    var slots = [WhackSlot]()
    
    var gameScore: SKLabelNode!
    var finalScore: SKLabelNode!
    
    
    
    var popupTime = 0.85
    var numRounds = 0
    
    var score = 0 {
//        property observer
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.fontSize = 48
        gameScore.horizontalAlignmentMode = .left
        addChild(gameScore)
        
        
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
//        if we can't read touch that came in, just bail out
        let location = touch.location(in: self)
        
        let tappedNodes = nodes(at: location)
        

        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
//                print("not the right enemy")
//                here we should trigger Hit method, deduct points from score.
//                *** thing to consider: charFriend is a child and a node of the WhackSlot class
                
//                if it's hit, still register it as hit and make it go down
                score -= 5
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                
            } else if node.name == "charEnemy" {
//                print("gotcha!")
                
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            }
        }
    
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        popupTime *= 0.991
//        every 0.85 seconds, create an enemy. For each one, produce it faster and faster - decreasing by 9% each time.
        
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            gameScore.text = ""
            displayScore()
            return
        }
        
        
        
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minimumDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        
        let delay = Double.random(in: minimumDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
        
        
    }
    
    
    func displayScore() {
        finalScore = SKLabelNode(fontNamed: "Chalkduster")
        finalScore.fontSize = 48
        finalScore.text = "Your score: \(score)"
        finalScore.position = CGPoint(x: 512, y: 300)
        finalScore.zPosition = 1
        addChild(finalScore)
        
    }
    
}
