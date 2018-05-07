//
//  PetNode.swift
//  ARCatchGame
//
//  Created by Zhang xiaosong on 2018/5/4.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

/// 宠物节点
class PetNode: SCNNode {
    

    class func initPetNode(nodeWith sceneName:String) -> SCNNode {
        // 从场景中提取节点
        let petScene = SCNScene(named: sceneName)
        let petNode = petScene!.rootNode.childNodes[1].clone()
        
        // 给节点增加物理特性
        let shape = SCNPhysicsShape(node: petNode, options: nil)
        
//        let myNode = PetNode()
//        myNode.geometry = petNode.geometry
        petNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        // 关闭重力
        petNode.physicsBody?.isAffectedByGravity = false
        
        // 设置类别掩码
        petNode.physicsBody?.categoryBitMask = 1
        
        // 设置测试掩码
        petNode.physicsBody?.contactTestBitMask = 2
        
        // 设置碰撞掩码
        petNode.physicsBody?.collisionBitMask = 3

        return petNode
        
    }
    
}
