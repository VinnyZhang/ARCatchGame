//
//  ViewController.swift
//  ARCatchGame
//
//  Created by Zhang xiaosong on 2018/5/4.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation

class ViewController: ARSCNBaseViewController {

    var numLabel: UILabel!
    var magicBallBtn: UIButton!
    var findBtn: UIButton!
    var audioPlayer: AVAudioPlayer!
    var num: Int = 0
    
    /// MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMyView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// MARK: - private methods
    
    private func setupMyView() {
        
        num = 0
        
        gameView.scene.physicsWorld.contactDelegate = self
        
        numLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height - 100, width: 70.0, height: 70.0))
        self.view.addSubview(numLabel)
        numLabel.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 0.6)
        numLabel.textColor = UIColor.black
        numLabel.textAlignment = .center
        numLabel.font = UIFont(name: "System", size: 20.0)
        numLabel.layer.cornerRadius = 35.0
        numLabel.layer.masksToBounds = true
        let numStr = ""+"\(num)"
        numLabel.text = numStr
        
        magicBallBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 100.0)/2, y: self.view.frame.size.height - 150.0, width: 100.0, height: 100.0))
        magicBallBtn.setImage(UIImage(named: "magicBall"), for: .normal)
        magicBallBtn.layer.cornerRadius = 50.0
        magicBallBtn.layer.masksToBounds = true
        magicBallBtn.addTarget(self, action: #selector(shootMagicBallNodeToPetNode), for: .touchUpInside)
        self.view.addSubview(magicBallBtn)
        
        findBtn = UIButton(frame: CGRect(x:self.view.frame.size.width - 100.0, y: self.view.frame.size.height - 100.0, width: 80.0, height: 80.0))
        self.view.addSubview(findBtn)
        findBtn.setImage(UIImage(named: "find"), for: .normal)
        findBtn.layer.cornerRadius = 40.0
        findBtn.layer.masksToBounds = true
        findBtn.addTarget(self, action: #selector(addPetNodeToScnView), for: .touchUpInside)
        
        
        
    }
    
    /// 播放音乐
    ///
    /// - Parameter fileName: 音乐文件地址
    private func playAudio(fileName: String) {
        DispatchQueue.main.async {
            let url = Bundle.main.url(forResource: fileName, withExtension: "mp3")
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url!)
                self.audioPlayer.play()
            }
            catch{}
        }
    }
    
    
    /// 发射子弹
    @objc private func shootMagicBallNodeToPetNode() {
        // 播放音效
        playAudio(fileName: "shootAudio")
        // 提取魔法球节点
        let node = MagicBallNode.initMagicBallNode(nodeWith: "MagicBallScene.scn")
        let currentFrame = gameView.session.currentFrame
        let transform = SCNMatrix4((currentFrame?.camera.transform)!)
        let direction = SCNVector3Make(-1 * transform.m31, -1 * transform.m32, -1 * transform.m33)
        let position = SCNVector3Make(transform.m41, transform.m42, transform.m43)
        // 节点位置初始化
        node.position = position
        // 开始发射
        node.physicsBody?.applyForce(direction, asImpulse: true)
        gameView.scene.rootNode.addChildNode(node)
        // 6秒以后从场景中移除自己
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            node.removeFromParentNode()
        }
    }
    
    /// 添加/更新宠物位置
    @objc private func addPetNodeToScnView() {
        // x轴和y轴随机渲染角度
        let randomNum = Float(arc4random()%100) / 100.0
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(2.0 * .pi * randomNum, 1.0, 0.0, 0.0))
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(2.0 * .pi * randomNum, 0.0, 1.0, 0.0))
        let rotation = matrix_multiply(rotateX, rotateY)
        // z轴规定距离
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0 - randomNum
        // 生成位姿矩阵
        let transform = matrix_multiply(rotation, translation)
        // 添加宠物节点
        let node = PetNode.initPetNode(nodeWith: "PetScene.scn")
        node.transform = SCNMatrix4(transform)
        gameView.scene.rootNode.addChildNode(node)
    }
    
    /// 移除宠物
    ///
    /// - Parameter node: 宠物节点
    func removePetNodeWithAnimated(node: SCNNode) {
        // 播放音效
        playAudio(fileName: "successAudio")
        // 增加粒子特效
        let particleSystem = SCNParticleSystem(named: "Effects.scnp", inDirectory: nil)
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem!)
        // 初始化粒子特效节点位置
        particleNode.position = node.position
        gameView.scene.rootNode.addChildNode(particleNode)
        // 删除宠物节点
        node.removeFromParentNode()
    }
    

}

extension ViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == 1 || contact.nodeB.physicsBody?.categoryBitMask == 1 {
            // 先删除魔法球
            contact.nodeB.removeFromParentNode()
            // 产生随机数，然后用随机数判断魔法球是否捕捉到宠物节点
            let random = arc4random() % 100
            if random > 50 {
                // 分数增加
                num += 1
                // 状态更新，并且删除宠物节点
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.alertLabel.text = "恭喜你捕捉成功"
                    self.numLabel.text = "\(self.num)"
                    self.removePetNodeWithAnimated(node: contact.nodeA)
                }
            }
            else {
                // 播放逃走音效
                playAudio(fileName: "failureAudio")
                // 提示信息，并且删除宠物节点
                DispatchQueue.main.async {
                    self.alertLabel.text = "未捕捉成功"
                    contact.nodeA.removeFromParentNode()
                }
            }
            
        }
    }
    
}

