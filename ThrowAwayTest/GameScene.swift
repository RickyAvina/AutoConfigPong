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
    var square = SKSpriteNode()
    var playerLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        sessionController.delegate = self
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.isHidden = true;
        
        playerLabel.position = CGPoint(x: 0, y: -200)
        playerLabel.fontSize = 32
        playerLabel.text = "Awaiting Player..."
        self.addChild(playerLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    deinit {
        // Nil out delegate
        sessionController.delegate = nil
    }
    
    func sessionDidChangeState() {
        if sessionController.connectedPeers.count > 0 {

            if (isFirstPlayer() == true){
                playerLabel.text = "\((sessionController.firstUser)!)"
                ball.isHidden = true;
            } else {
                playerLabel.text = "\(UIDevice.current.name)"
                ball.isHidden = false;
                ball.physicsBody?.applyImpulse(CGVector(dx: -2, dy: -2))
            }
            
            do {
                let myString : NSString = "a" as NSString
                let myData = myString.data(using: String.Encoding.utf8.rawValue)
                
                try sessionController.sess().send(myData! as Data, toPeers: sessionController.connectedPeers, with: .reliable)
            } catch let error as NSError{
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                let currentViewController :
                    UIViewController=UIApplication.shared.keyWindow!.rootViewController!
                currentViewController.present(ac, animated: true, completion: nil)
            }

        }
        
        if sessionController.disconnectedPeers.count > 0 {
            playerLabel.text = "Awaiting player..."
        }
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
}
