//
//  UnlockLabel.swift
//  Swift-GestureUnlock
//
//  Created by csj on 15/6/18.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import UIKit

extension CALayer{
    func shake(){
        var kfa = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        var s = 5
        
        kfa.values = [-5,0,5,0,-5,0,5,0]
        
        println(kfa.values)
        
        kfa.duration = 0.3
        
        kfa.repeatCount = 2
        
        kfa.removedOnCompletion = true
        
        self.addAnimation(kfa, forKey: "shake")
    }
}
class UnlockLabel: UILabel {
    static let frame = CGRect(
        x: 0,
        y: UIScreen.mainScreen().bounds.size.height * 1.45 / 5,
        width: UIScreen.mainScreen().bounds.size.width,
        height: 14)

    override init(frame: CGRect?) {
        var nframe = frame ?? UnlockLabel.frame
        super.init(frame: nframe)
        self.text = "test"
        self.textColor = CircleState.white
        //self.numberOfLines = 0
        //self.sizeToFit()
        self.font = UIFont.systemFontOfSize(14.0)
        self.textAlignment = NSTextAlignment.Center
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func showNormalMsg(msg: String){
        self.text = msg
        self.textColor = CircleState.white
    }
    func showWarnMsg(msg: String){
        self.text = msg
        self.textColor = CircleState.red
    }
    func showWarnMsgAndShake(msg: String){
        self.text = msg
        self.textColor = CircleState.red
        self.layer.shake()
    }
    
}
