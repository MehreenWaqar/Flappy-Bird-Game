//
//  GameScene.swift
//  Flappy_Bird
//
//  Created by SAM on 09/05/2019.
//  Copyright © 2019 SAM. All rights reserved.
///Users/user/Downloads/bird1.atlas

import SpriteKit
import GameplayKit

struct CollisionBitMask {
    static let bird:UInt32 = 0x1 << 0
    static let pillar:UInt32 = 0x1 << 1
    static let coin:UInt32 = 0x1 << 2
    static let ground:UInt32 =  0x1 << 3
}


class GameScene: SKScene,  SKPhysicsContactDelegate{
    

    var tt: CGFloat!
    var level: String = ""
    var score = Int(0)
    var score_lbl = SKLabelNode()
    var highscore_lbl = UserDefaults().integer(forKey: "easy")
    var highscore_lbl_med = UserDefaults().integer(forKey: "medium")
    var highscore_lbl_hard = UserDefaults().integer(forKey: "hard")

    var play_tap = SKLabelNode()
    var hurdles = SKNode()
    var move_Remove = SKAction()
    
    let birdAtlas = SKTextureAtlas(named:"bird1")
    var bird_sprites = Array<Any>()
    var bird = SKSpriteNode()
    var repeatActionBird = SKAction()
    
    var Game_Started: Bool = false
    var Game_End: Bool = false
    
    
    
    func create_MainGame(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.ground
        self.physicsBody?.collisionBitMask = CollisionBitMask.bird
        self.physicsBody?.contactTestBitMask = CollisionBitMask.bird
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        for i in 0..<2
        {
            let bg = SKSpriteNode(imageNamed: "bg")
            bg.anchorPoint = CGPoint.init(x: 0, y: 0)
            bg.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            bg.name = "background"
            bg.size = (self.view?.bounds.size)!
            self.addChild(bg)
        }
 
        bird_sprites.append(birdAtlas.textureNamed("bird1"))
        bird_sprites.append(birdAtlas.textureNamed("bird2"))
        bird_sprites.append(birdAtlas.textureNamed("bird3"))
        bird_sprites.append(birdAtlas.textureNamed("bird4"))
        self.bird = player()
        self.addChild(bird)
        
        let animateBird = SKAction.animate(with: self.bird_sprites as! [SKTexture], timePerFrame: 0.1)
        self.repeatActionBird = SKAction.repeatForever(animateBird)
        score_lbl = showscore()
        self.addChild(score_lbl)

    
        play_tap = create_Playtap()
        self.addChild(play_tap)
    }
    
    
    
    override func didMove(to view: SKView) {
        print(level)
        chooselevel()
        create_MainGame()

     
    }

    func chooselevel(){
        if(level == "easy"){
            tt = 0.008
        }
        if(level == "medium"){
            tt = 0.004
        }
        if(level == "hard"){
            tt = 0.0029
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if Game_Started == false{
            Game_Started =  true
            bird.physicsBody?.affectedByGravity = true

            play_tap.removeFromParent()
            self.bird.run(repeatActionBird)

            let loop = SKAction.run({
                () in
                self.hurdles = self.create_hurdles()
                self.addChild(self.hurdles)
            })
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([loop, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            let distance = CGFloat(self.frame.width + hurdles.frame.width + 300)
            let movePillars = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(tt * distance))
            let removePillars = SKAction.removeFromParent()
            move_Remove = SKAction.sequence([movePillars, removePillars])

            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 180))
        } else {
            if Game_End == false {
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 180))
            }
        }

        }
    
    func scoreActivity(){
        self.removeAllChildren()
        self.removeAllActions()
        Game_End = false
        Game_Started = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "VC") as! ScoreViewController
        
   
        if highscore_lbl < Int(score_lbl.text!)! || highscore_lbl_med < Int(score_lbl.text!)! || highscore_lbl_hard < Int(score_lbl.text!)!{
            if(level == "easy"){
                UserDefaults.standard.set(score, forKey: "easy")
            }
            if(level == "medium"){
                UserDefaults.standard.set(score, forKey: "medium")
            }
            if(level == "hard"){
                UserDefaults.standard.set(score, forKey: "hard")
            }
            }
        if(level == "easy"){
            vc.high_score = (UserDefaults().integer(forKey: "easy"))
        }
        if(level == "medium"){
            vc.high_score = (UserDefaults().integer(forKey: "medium"))
        }
        if(level == "hard"){
            vc.high_score = (UserDefaults().integer(forKey: "hard"))
        }
            
//        vc.high_score = (UserDefaults().integer(forKey: "HIGHSCORE"))
        vc.your_score = score
        UIView.transition(with: self.view!, duration: 0.3, options: .transitionFlipFromRight, animations:
            {
                self.view?.window?.rootViewController = vc
        }, completion: { completed in
            
        })
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if firstBody.categoryBitMask == CollisionBitMask.bird && secondBody.categoryBitMask == CollisionBitMask.pillar || firstBody.categoryBitMask == CollisionBitMask.pillar && secondBody.categoryBitMask == CollisionBitMask.bird || firstBody.categoryBitMask == CollisionBitMask.bird && secondBody.categoryBitMask == CollisionBitMask.ground || firstBody.categoryBitMask == CollisionBitMask.ground && secondBody.categoryBitMask == CollisionBitMask.bird{
            enumerateChildNodes(withName: "hurdles", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if Game_End == false{
                Game_End = true
                self.bird.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.bird && secondBody.categoryBitMask == CollisionBitMask.coin {
            score += 1
            score_lbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.coin && secondBody.categoryBitMask == CollisionBitMask.bird {
            score += 1
            score_lbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if Game_Started == true{
            if Game_End == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
            }
            else{
                scoreActivity()
            }
        }
    }
    
    
    
    func player() -> SKSpriteNode {
        //1
        let bird = SKSpriteNode(texture: SKTextureAtlas(named:"bird1").textureNamed("bird1"))
        bird.size = CGSize(width: 120, height: 90)
        bird.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        //2
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 2
        bird.physicsBody?.restitution = 0
        //3
        bird.physicsBody?.categoryBitMask = CollisionBitMask.bird
        bird.physicsBody?.collisionBitMask = CollisionBitMask.pillar | CollisionBitMask.ground
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.pillar | CollisionBitMask.coin | CollisionBitMask.ground
        //4
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        
        return bird
    }
    
    func showscore() -> SKLabelNode {
        let scorelbl = SKLabelNode()
        scorelbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6)
        scorelbl.text = "\(score)"
        scorelbl.zPosition = 5
        scorelbl.fontSize = 50
        scorelbl.fontName = "Chalkboard se"
        scorelbl.fontColor = UIColor(red: CGFloat(0 / 255.0), green: CGFloat(0 / 255.0), blue: CGFloat(0 / 255.0), alpha: CGFloat(1))

        return scorelbl
    }
    
    func create_Playtap() -> SKLabelNode {
        let play = SKLabelNode()
        play.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 100)
        play.text = "Tap to play"
        play.fontName = "Chalkboard se"
        play.fontColor = UIColor(red: 60/255, green: 79/255, blue: 145/255, alpha: 1.0)
        play.zPosition = 5
        play.fontSize = 20
       
        return play
    }
    func create_hurdles() -> SKNode  {
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.size = CGSize(width: 40, height: 40)
        coin.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = CollisionBitMask.coin
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.contactTestBitMask = CollisionBitMask.bird
        coin.color = SKColor.blue
        // 2
        hurdles = SKNode()
        hurdles.name = "hurdles"
        
        let up_hurdle = SKSpriteNode(imageNamed: "hurdle")
        let down_hurdle = SKSpriteNode(imageNamed: "hurdle")
        
        up_hurdle.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 550)
        up_hurdle.setScale(0.6)
        up_hurdle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: up_hurdle.size.width - 75, height: up_hurdle.size.height - 60))
        up_hurdle.physicsBody?.categoryBitMask = CollisionBitMask.pillar
        up_hurdle.physicsBody?.collisionBitMask = CollisionBitMask.bird
        up_hurdle.physicsBody?.contactTestBitMask = CollisionBitMask.bird
        up_hurdle.physicsBody?.isDynamic = false
        up_hurdle.physicsBody?.affectedByGravity = false
        
        
        
        down_hurdle.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 550)
        down_hurdle.setScale(0.6)
        down_hurdle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: down_hurdle.size.width - 75, height: down_hurdle.size.height - 60))
        down_hurdle.physicsBody?.categoryBitMask = CollisionBitMask.pillar
        down_hurdle.physicsBody?.collisionBitMask = CollisionBitMask.bird
        down_hurdle.physicsBody?.contactTestBitMask = CollisionBitMask.bird
        down_hurdle.physicsBody?.isDynamic = false
        down_hurdle.physicsBody?.affectedByGravity = false
        
        up_hurdle.zRotation = CGFloat(Double.pi)
        
        hurdles.addChild(up_hurdle)
        hurdles.addChild(down_hurdle)
        
        hurdles.zPosition = 1
        let rand = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        let rr = CGFloat((200 - -200) + (-200))
        let randomPosition = rand * rr
        hurdles.position.y = hurdles.position.y +  randomPosition
        hurdles.addChild(coin)
        
        hurdles.run(move_Remove)
        
        return hurdles
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
}
