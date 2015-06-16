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
        
        unlock = Unlock(frame: nil)
        
        self.view.addSubview(unlock)
        
        
        var btn = UIButton()
        btn.frame = CGRect(x: 0,y: 0,width: 50,height: 50)
        btn.setTitle("hehe", forState: UIControlState.Normal)
        btn.addTarget(self, action: "clicked:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(btn)
        
    }
    var unlock: Unlock!
    func clicked(sender: AnyObject){
        unlock.circles.enumerateObjectsUsingBlock{
            (_circle, idx, stop) in
            var circle = _circle as! Circle
            circle.state = CircleState.Error
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

