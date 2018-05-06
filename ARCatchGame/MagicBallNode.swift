//
//  MagicBallNode.swift
//  ARCatchGame
//
//  Created by Zhang xiaosong on 2018/5/4.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

/// 子弹
class MagicBallNode: SCNNode {

    static func initMagicBallNode(nodeWith sceneName:String) -> SCNNode {
        // 从场景中提取节点
        let magicBallScene = SCNScene(named: sceneName)
        let magicBallNode = magicBallScene!.rootNode.clone()
        
        // 给节点增加物理特性
        let shape = SCNPhysicsShape(node: magicBallNode, options: nil)
        magicBallNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        
        // 关闭重力
        magicBallNode.physicsBody?.isAffectedByGravity = false
        
        // 设置类别掩码
        magicBallNode.physicsBody?.categoryBitMask = 2
        
        // 设置测试掩码
        magicBallNode.physicsBody?.contactTestBitMask = 1
        
        // 设置碰撞掩码
        magicBallNode.physicsBody?.collisionBitMask = 3
        
//        let node = magicBallNode as! MagicBallNode
        
        return magicBallNode
        
    }
    
}
