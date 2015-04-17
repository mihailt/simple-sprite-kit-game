//
//  GameScene.swift
//  Game
//
//  Created by Mihails Tumkins on 27/02/15.
//  Copyright (c) 2015 Mihails Tumkins. All rights reserved.
//

import SpriteKit
import AVFoundation

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int = -1
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        if index != -1 {
            self.removeAtIndex(index)
        }
    }
}

enum GameState {
    case Menu
    case Play
    case Over
}

struct PhysicsCategory {
    static let None:UInt32 = 0
    static let Block:UInt32 = 0b1 // 1
    static let Enemy:UInt32 = 0b10 // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var state = GameState.Menu
    var score = 0
    var scoreLabel: SKLabelNode!
    var descriptionLabel: SKLabelNode!
    var gameObjects:[SKSpriteNode] = []
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    var lastGenTime:NSTimeInterval = 0
    
    var actionLayer:SKSpriteNode!
    
    var audioPlayer:AVAudioPlayer!
    var pewSound:SKAction!
    var overSound:SKAction!
    var scoreSound:SKAction!

    var colors = [UIColor.turquoiseColor(),
        UIColor.greenSeaColor(),
        UIColor.emeraldColor(),
        UIColor.nephritisColor(),
        UIColor.peterRiverColor(),
        UIColor.belizeHoleColor(),
        UIColor.amethystColor(),
        UIColor.wisteriaColor(),
        UIColor.sunflowerColor(),
        UIColor.orangeColor(),
        UIColor.carrotColor(),
        UIColor.pumpkinColor(),
        UIColor.alizarinColor(),
        UIColor.pomergranateColor()]
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor.blackColor()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        let path = NSBundle.mainBundle().pathForResource("loop3", ofType: "wav")
        let url = NSURL.fileURLWithPath(path!)
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
 
        pewSound = SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false)
        overSound = SKAction.playSoundFileNamed("over.wav", waitForCompletion: false)
        scoreSound = SKAction.playSoundFileNamed("levelup.wav", waitForCompletion: false)

        actionLayer = SKSpriteNode(color: UIColor.nephritisColor(), size: size)
        actionLayer.anchorPoint = CGPointZero
        addChild(actionLayer)
        
        changeBackgroundColor()

        scoreLabel = SKLabelNode(text: "\(score)")
        scoreLabel.position = CGPointMake(size.width/2, size.height/2)
        scoreLabel.fontSize = 144
        scoreLabel.alpha = 0.6
        actionLayer.addChild(scoreLabel)

        descriptionLabel = SKLabelNode(text: "Swipe left or right.")
        descriptionLabel.position = CGPointMake(scoreLabel.position.x, scoreLabel.position.y - scoreLabel.frame.height/2)
        descriptionLabel.fontSize = 36
        actionLayer.addChild(descriptionLabel)

   
        var light = SKLightNode()
        light.categoryBitMask = 1
        light.falloff = 1
        light.ambientColor = UIColor.whiteColor()
        light.lightColor = UIColor.yellowColor()
        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        light.position = CGPointMake(size.width/2, size.height/2)
        actionLayer.addChild(light)

        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)

    }
    func swipedRight(sender:UISwipeGestureRecognizer) {
        if state != GameState.Play {
            state = GameState.Play
            score = 0
            scoreLabel.text =  "\(self.score)"
            
            descriptionLabel.runAction(SKAction.fadeOutWithDuration(0.5))
        }
        
        runAction(pewSound)

        var touchLocation = sender.locationInView(sender.view)
        touchLocation = convertPointFromView(touchLocation)

        let block = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(20, 20))
        block.name = "block"
        block.position = CGPointMake(0, touchLocation.y)
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.dynamic = true
        block.physicsBody?.categoryBitMask = PhysicsCategory.Block
        block.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        block.shadowCastBitMask = 1
        actionLayer.addChild(block)
        gameObjects.append(block)
        
        let moveUpAction = SKAction.moveTo(CGPointMake(size.width, touchLocation.y), duration: 0.8)
        let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.8)
        let group = SKAction.group([moveUpAction,rotateAction])
        block.runAction(group, completion:{
            self.gameObjects.removeObject(block)
            block.removeFromParent()
            self.shakeCamera(0.4)
            self.score++
            self.runAction(self.scoreSound)
            self.scoreLabel.text =  "\(self.score)"

            if self.score % 10 == 0{
                self.changeBackgroundColor()
            }
        })
    }
    func swipedLeft(sender:UISwipeGestureRecognizer) {
        if state != GameState.Play {
            state = GameState.Play
            score = 0
            scoreLabel.text =  "\(self.score)"
            
            descriptionLabel.runAction(SKAction.fadeOutWithDuration(0.5))
        }
        
        runAction(pewSound)

        var touchLocation = sender.locationInView(sender.view)
        touchLocation = convertPointFromView(touchLocation)

        let block = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(20, 20))
        block.name = "block"
        block.position = CGPointMake(size.width, touchLocation.y)
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.dynamic = true
        block.physicsBody?.categoryBitMask = PhysicsCategory.Block
        block.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        block.shadowCastBitMask = 1
        actionLayer.addChild(block)
        gameObjects.append(block)

        let moveUpAction = SKAction.moveTo(CGPointMake(0, touchLocation.y), duration: 0.8)
        let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.8)
        let group = SKAction.group([moveUpAction,rotateAction])
        block.runAction(group, completion:{
            self.gameObjects.removeObject(block)
            block.removeFromParent()
            self.shakeCamera(0.4)
            self.score++
            self.runAction(self.scoreSound)
            self.scoreLabel.text =  "\(self.score)"
            
            if self.score % 10 == 0{
                self.changeBackgroundColor()
            }
        })
    }
    func addEnemy() {
        let x = CGFloat.random(min:size.width * 0.2, max:size.width * 0.8)
        
        let enemy = SKSpriteNode(color: UIColor.wetAsphaltColor(), size: CGSizeMake(40, 40))
        enemy.name = "enemy"
        enemy.position = CGPointMake(x, size.height)
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Block
        enemy.shadowCastBitMask = 1
        actionLayer.addChild(enemy)
        gameObjects.append(enemy)

        let d = CGFloat.random(min:2.0, max:3.0)
        
        let moveRight = SKAction.moveTo(CGPointMake(x, 0), duration: NSTimeInterval(d))
        let rotateAction = SKAction.rotateByAngle(d * CGFloat(M_PI), duration: NSTimeInterval(d))

        let group = SKAction.group([moveRight,rotateAction])
        enemy.runAction(group)
        enemy.runAction(group, completion:{
            self.gameObjects.removeObject(enemy)
            enemy.removeFromParent()
        })
    
    }
    
    func changeBackgroundColor() {
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        actionLayer.color = colors[randomIndex]
        
    }
    
    func clearGameObjects() {
        for (index, value) in enumerate(gameObjects) {
            let node = value as SKSpriteNode;
            node.removeFromParent()
        }
        gameObjects.removeAll(keepCapacity: false)
    }

    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        // dt * 1000  = millis since last update
        
        if state == GameState.Play {
            lastGenTime += dt
            let et = CGFloat.random(min:0.5, max:1.5)
            if CGFloat(lastGenTime) >= et {
                lastGenTime = 0
                addEnemy()
            }
        }

    }

    func splash(duration:Float) {
        let splashLayer = SKSpriteNode(color: UIColor.whiteColor(), size: size)
        splashLayer.anchorPoint = CGPointZero
        actionLayer.addChild(splashLayer)
        let action = SKAction.fadeOutWithDuration(NSTimeInterval(duration))
        splashLayer.runAction(action, completion:{
            splashLayer.removeFromParent()
        })
    }

    func shakeCamera(duration:Float) {
        
        let amplitudeX:Float = 10;
        let amplitudeY:Float = 6;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for index in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveByX(CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.EaseOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversedAction());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        actionLayer.runAction(actionSeq);
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        state = GameState.Over
        runAction(overSound)
        splash(1)
        shakeCamera(1)
        clearGameObjects()
        descriptionLabel.runAction(SKAction.fadeInWithDuration(0.5))
    }
}
