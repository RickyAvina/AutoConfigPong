//  THIS IS THE ONE I WANT
//  GameScene.swift
//  ThrowAwayTest
//
//  Created by Maricela Avina on 12/26/16.
//  Copyright © 2016 InternTeam. All rights reserved.
//

import SpriteKit
import GameplayKit
import MultipeerConnectivity

class GameScene: SKScene, SessionControllerDelegate {
    
    let sessionController = SessionController()
    
    var ball = SKSpriteNode()
    var player = SKSpriteNode()
    var square = SKSpriteNode()
    var playerLabel = SKLabelNode()
    
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        sessionController.delegate = self
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.isHidden = true;
        
        player = self.childNode(withName: "player") as! SKSpriteNode
        
        leftWall = self.childNode(withName: "leftWall") as! SKSpriteNode
        rightWall = self.childNode(withName: "rightWall") as! SKSpriteNode
        
        playerLabel.position = CGPoint(x: 0, y: -200)
        playerLabel.fontSize = 32
        playerLabel.text = "Awaiting Player..."
        self.addChild(playerLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (ball.position.y > frame.height) && !sessionController.hasRecievedData {
            sessionController.hasRecievedData = true
            do {
                
                print("DATA SENT")
                
                let pointToSend : CGPoint = CGPoint(x: ball.position.x, y: frame.height)
                let arrayToSend : [Any] = [pointToSend, ball.physicsBody?.velocity.dx ?? 20, ball.physicsBody?.velocity.dy ?? 20]
                let data : Data = NSKeyedArchiver.archivedData(withRootObject: arrayToSend)
                
                try sessionController.sess().send(data, toPeers: sessionController.connectedPeers, with: .reliable)
            } catch let error as NSError{
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                let currentViewController :
                    UIViewController=UIApplication.shared.keyWindow!.rootViewController!
                currentViewController.present(ac, animated: true, completion: nil)
            }

        }
    }
    
    deinit {
        // Nil out delegate
        sessionController.delegate = nil
    }
    
    func sessionDidChangeState() {
        if sessionController.connectedPeers.count > 0 {

            if (isFirstPlayer() == true){
                playerLabel.text = "\((sessionController.firstUser)!)"
                ball.isHidden = true;   // should b true
            } else {
                playerLabel.text = "\(UIDevice.current.name)"
                ball.isHidden = false;
                ball.physicsBody?.applyImpulse(CGVector(dx: -13, dy: -13))
            }
        }
        
        if sessionController.disconnectedPeers.count > 0 {
            playerLabel.text = "Awaiting player..."
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self) // location of finger
            
            player.run(SKAction.moveTo(x: location.x, duration: 0.2)) // finger lag
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self) // location of finger
            player.run(SKAction.moveTo(x: location.x, duration: 0.2))  // finger lag
        }
    }
    
    func didRecievePos(data: Data) {
        let newData = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Any]
        print("NEW DATA")
        
        let ballLoc = newData.first! as! CGPoint
        let ballVel = CGVector(dx: newData[1] as! Double, dy: newData[2] as! Double)
        changeBall(loc: ballLoc, vel: ballVel)
    }
    
    func isFirstPlayer() -> Bool {
        print("**********************")
        print("Me: \(UIDevice.current.name)\nOther: \(sessionController.connectedPeers.first?.displayName)\nFirst: \(sessionController.firstUser)")
        
        if ((sessionController.firstUser)! == UIDevice.current.name){
            print("returned true")
            return true
        }
            print("returned false")
           return false
    }
    
    func changeBall(loc: CGPoint, vel: CGVector){
        ball.position = loc
        ball.physicsBody?.velocity = CGVector(dx: -vel.dx, dy: -vel.dy)
        ball.isHidden = false
    }
}
