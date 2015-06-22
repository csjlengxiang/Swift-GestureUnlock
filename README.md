# Swift-GestureUnlock
swift版支付宝解锁仿造

写的时候源码参照：https://github.com/iosdeveloperpanc/PCGestureUnlock 写的,后来写着写着渐入佳境就按照自己思路来的  <br>

功能跟上述源码差不多，但是代码短很多很多，大概650行代码<br>

使用方法：
在viewLoad中初始化，GestureUnlockViewController，主要有3个托管，设置成功，验证结果，重设结果
      var psw: String!
      var nextView: GestureUnlockViewController!
      override func viewDidLoad() {
       nextView = GestureUnlockViewController()
        nextView.setSuc = {
            (psw) in
            println("设置密码为 \(psw)")
            self.psw = psw
        }
        nextView.verifyResult = {
            (result) in
            if result {
                println("验证密码成功！！！！！！！！")
            } else {
                println("尝试5次验证密码都失败了")
            }
        }
        nextView.resetResult = {
            (result) in
            if result {
                self.psw = nil
                println("清空密码了")
            } else {
                println("尝试5次修改密码都失败了")
            }
        }
    }
    
    //然后就是3个按钮对应的action
    func set(sender: AnyObject){
        nextView.state = GestureUnlockState.Set
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    func verify(sender: AnyObject){
        nextView.state = GestureUnlockState.Verify
        nextView.tpsw = psw ?? "0125"
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    func reset(sender: AnyObject){
        nextView.state = GestureUnlockState.Reset
        nextView.tpsw = psw ?? "0125"
        self.navigationController?.pushViewController(nextView, animated: true)
    }




回头上图！
设置<br>
![](https://github.com/csjlengxiang/Swift-GestureUnlock/blob/master/设置.gif)<br>

验证<br>
![](https://github.com/csjlengxiang/Swift-GestureUnlock/blob/master/验证.gif)<br>

重新设置<br>
![](https://github.com/csjlengxiang/Swift-GestureUnlock/blob/master/重新设置.gif)<br>

