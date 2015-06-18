//
//  GestureUnlockViewController.swift
//  Swift-GestureUnlock
//
//  Created by csj on 15/6/17.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import UIKit

enum GestureUnlockState {
    case Set, Verify, Reset
}

class GestureUnlockViewController: UIViewController {
    
    var state: GestureUnlockState? {
        didSet{
            switch self.state! {
            case GestureUnlockState.Set:
                tpsw = nil
                unlockInfo?.psw = nil
                break
            default:
            break
            }
        }
    }
    var tpsw: NSString?
    var unlock: Unlock!
    // mark - state 1
    var rightBtn: UIBarButtonItem!
    var setSuc: ((NSString)->Void)?
    var unlockInfo: UnlockInfo!
    var unlockLabel: UnlockLabel!
    // mark - state 2
    var verifyResult:((Bool)->Void)?
    var wrongCnt = 0
    // mark - state 3
    var resetResult:((Bool)->Void)?
    
    func rgba(r: Int, g: Int, b: Int, a: CGFloat)->UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = rgba(13, g: 52, b: 89, a: 1)
        prepare()
        switch state! {
        case .Set:
            prepareSet()
            return
        case .Verify:
            prepareVerify()
            return
        case .Reset:
            prepareReSet()
            return
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        prepare()
        switch state! {
        case .Set:
            prepareSet()
            return
        case .Verify:
            prepareVerify()
            return
        case .Reset:
            prepareReSet()
            return
        }
    }
}
// mark - view prepare
extension GestureUnlockViewController{
    func getRightBtn()->UIBarButtonItem{
        if rightBtn == nil {
            rightBtn = UIBarButtonItem(title: "重设", style: UIBarButtonItemStyle.Done, target: self, action: "reset:")
        }
        return rightBtn
    }
    func displayRightBtn(){
        self.navigationItem.rightBarButtonItem = self.getRightBtn()
    }
    func hiddenRightBtn(){
        self.navigationItem.rightBarButtonItem = nil
    }
    func prepare(){
        if unlock == nil {
            unlock = Unlock(frame: nil)
            unlock.result = {
                (psw: NSString) in
                if psw.length < 4{
                    self.unlock.processWrong()
                    return
                }
                switch self.state!{
                case GestureUnlockState.Set:
                    self.processSet(psw)
                    return
                case GestureUnlockState.Verify:
                    self.processVerify(psw)
                    return
                case GestureUnlockState.Reset:
                    self.processReset(psw)
                    return
                }
            }
            self.view.addSubview(unlock)
        }
        if unlockLabel == nil {
            unlockLabel = UnlockLabel(frame: nil)
            self.view.addSubview(unlockLabel)
        }
    }
    func prepareSet(){
        
        self.navigationItem.title = "设置手势密码"
        if unlockInfo == nil {
            unlockInfo = UnlockInfo(frame: nil)
        }
        self.view.addSubview(unlockInfo)
        unlockLabel.showNormalMsg("绘制解锁图案")
        // mark - set子view
    }
    func prepareVerify(){
        unlockLabel.showNormalMsg("请输入手势密码")
        unlockInfo.removeFromSuperview()
    }
    func prepareReSet(){
        unlockLabel.showNormalMsg("请输入原手势密码")
        unlockInfo.removeFromSuperview()
    }
    
    func processSet(psw: NSString){
        if tpsw == nil {
            tpsw = psw
            unlock.processRight()
            unlockInfo.psw = psw
            unlockLabel.showWarnMsg("再次绘制解锁图案")
            // 子view更新
        } else if tpsw == psw{
            setSuc?(psw)
            unlock.processRight()
            navigationController?.popViewControllerAnimated(true)
        } else {
            unlock.processWrong()
            displayRightBtn()
            unlockLabel.showWarnMsgAndShake("与上次绘制不一致，请重新绘制")
        }
    }
    func processVerify(psw: NSString){
        if tpsw == psw{
            println("验证成功")
            verifyResult?(true)
            unlock.processRight()
            navigationController?.popViewControllerAnimated(true)
        } else {
            wrongCnt++
            if wrongCnt >= 5 {
                println("错误超过5次，验证失败")
                verifyResult?(false)
                unlock.processWrong()
                navigationController?.popViewControllerAnimated(true)
                return
            }
            unlockLabel.showWarnMsgAndShake("输入错误，您还有\(5-wrongCnt)输入机会")
            unlock.processWrong()
        }
    }
    func processReset(psw: NSString){
        if tpsw == psw {
            println("重置成功")
            resetResult?(true)
            tpsw = nil
            state = GestureUnlockState.Set
            unlock.processRight()
            unlockLabel.showNormalMsg("重新绘制解锁图案")
        } else {
            wrongCnt++
            if wrongCnt >= 5 {
                println("错误超过5次，验证失败")
                resetResult?(false)
                unlock.processWrong()
                navigationController?.popViewControllerAnimated(true)
                return
            }
            unlockLabel.showWarnMsgAndShake("输入错误，您还有\(5-wrongCnt)输入机会")
            unlock.processWrong()
        }
    }
    func reset(sender: AnyObject?){
        println("reset")
        tpsw = nil
        unlockInfo.psw = nil
        unlockLabel.showNormalMsg("绘制解锁图案")
        hiddenRightBtn()
        // 子view更新
    }
}