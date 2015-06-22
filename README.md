# Swift-GestureUnlock
swift版支付宝解锁仿造

写的时候源码参照：https://github.com/iosdeveloperpanc/PCGestureUnlock 写的,后来写着写着渐入佳境就按照自己思路来的  <br>

功能跟上述源码差不多，但是代码短很多很多，大概650行代码<br>

使用方法：
在viewLoad中初始化，GestureUnlockViewController，主要有3个托管，设置成功，验证结果，重设结果
    var psw: String!
    var nextView: GestureUnlockViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = rgba(13, g: 52, b: 89, a: 1)
        
        var btn = UIButton()
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

