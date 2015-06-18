//
//  ViewController.swift
//  Swift-GestureUnlock
//
//  Created by csj on 15/6/15.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    func rgba(r: Int, g: Int, b: Int, a: CGFloat)->UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = rgba(13, g: 52, b: 89, a: 1) //UIColor(red: 13, green: 52, blue: 89, alpha: 1)
        
//        unlock = Unlock(frame: nil)
//        
//        unlock.result = {
//            (resultStr) in
//            self.unlock.turnNormalAndDisappear()
//            println(resultStr)
//        }
//        
//        self.view.addSubview(unlock)
//        
        var btn = UIButton()
        btn.frame = CGRect(x: 0,y: 0,width: 50,height: 50)
        btn.setTitle("hehe", forState: UIControlState.Normal)
        btn.addTarget(self, action: "clicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
        
        btn = UIButton()
        btn.frame = CGRect(x: 100,y: 100,width: 100,height: 30)
        btn.setTitle("设置", forState: UIControlState.Normal)
        btn.addTarget(self, action: "set:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(btn)
        
        btn = UIButton()
        btn.frame = CGRect(x: 100,y: 130,width: 100,height: 30)
        btn.setTitle("验证", forState: UIControlState.Normal)
        btn.addTarget(self, action: "verify:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(btn)
        
        btn = UIButton()
        btn.frame = CGRect(x: 100,y: 160,width: 100,height: 30)
        btn.setTitle("重设", forState: UIControlState.Normal)
        btn.addTarget(self, action: "reset:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(btn)
        
    }
    
    var nextView: GestureUnlockViewController = GestureUnlockViewController()
    var psw: NSString!
    func set(sender: AnyObject){
        nextView.state = GestureUnlockState.Set
        nextView.setSuc = {
            (psw) in
            self.psw = psw
        }
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    func verify(sender: AnyObject){
        nextView.state = GestureUnlockState.Verify
        nextView.tpsw = psw ?? "0125"
        nextView.verifyResult = {
            (result) in
            if result {
                println("验证密码成功！！！！！！！！")
            } else {
                println("尝试5次验证密码都失败了")
            }
        }
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    func reset(sender: AnyObject){
        var nextView = GestureUnlockViewController()
        nextView.state = GestureUnlockState.Reset
        nextView.tpsw = psw ?? "0125"
        nextView.resetResult = {
            (result) in
            if result {
                self.psw = nil
                println("清空密码了")
            } else {
                println("尝试5次修改密码都失败了")
            }
        }
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    var unlock: Unlock!
    func clicked(sender: AnyObject){
        unlock.circles.enumerateObjectsUsingBlock{
            (_circle, idx, stop) in
            var circle = _circle as! Circle
            circle.state = CircleState.Error
        }
    }
}

