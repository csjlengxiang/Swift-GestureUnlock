import UIKit

class GestureUnlockViewController: UIViewController {
    // mark = 初始化都在这里...统一管理
    var state: GestureUnlockState! {
        didSet{
            stateInit()
        }
    }
    var tpsw: String!
    var unlock: Unlock!
    var rightBtn: UIBarButtonItem!
    var unlockInfo: UnlockInfo!
    var unlockLabel: UnlockLabel!
    var wrongCnt = 0
    
    var setSuc: ((String)->Void)?
    var verifyResult:((Bool)->Void)?
    var resetResult:((Bool)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = CommonConfig.GestureUnlockViewController.backgroundColor
        prepare()
        stateInit()
    }
    
    func stateInit(){
        switch self.state! {
        case GestureUnlockState.Set:
            tpsw = nil
            unlock?.processClear()
            navigationItem.rightBarButtonItem = nil
            unlockInfo?.state = .Normal
            unlockInfo?.hidden = false
            unlockLabel?.showNormalMsg("绘制解锁图案")
            navigationItem.title = "设置手势密码"
            
        case GestureUnlockState.Verify:
            unlock?.processClear()
            navigationItem.rightBarButtonItem = nil
            unlockInfo?.hidden = true
            unlockLabel?.showNormalMsg("请输入手势密码")
            wrongCnt = 0
            navigationItem.title = "验证手势密码"
            //self.navigationController?.navigationBarHidden = true
            
        case GestureUnlockState.Reset:
            unlock?.processClear()
            navigationItem.rightBarButtonItem = nil
            unlockInfo?.hidden = true
            unlockLabel?.showNormalMsg("请输入原手势密码")
            wrongCnt = 0
            navigationItem.title = "重设手势密码"
        }
        
    }
}
// mark - view prepare
extension GestureUnlockViewController{
    func prepare(){
        unlock = Unlock()
        unlock.result = {
            psw in
            if psw.characters.count < 4{
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
        
        rightBtn = UIBarButtonItem(title: "重设", style: UIBarButtonItemStyle.Done, target: self, action: "reset:")
        
        unlockInfo = UnlockInfo()
        self.view.addSubview(unlockInfo)
        
        unlockLabel = UnlockLabel()
        self.view.addSubview(unlockLabel)
    }
}
// mark - process
extension GestureUnlockViewController{
    func processSet(psw: String){
        if tpsw == nil {
            tpsw = psw
            unlock.processRight()
            unlockInfo.state = UnlockInfoState.Selected(psw)
            unlockLabel.showWarnMsg("再次绘制解锁图案")
        } else if tpsw == psw {
            setSuc!(psw)
            navigationController?.popViewControllerAnimated(true)
        } else {
            self.navigationItem.rightBarButtonItem = self.rightBtn
            unlockLabel.showWarnMsgAndShake("与上次绘制不一致，请重新绘制")
            unlock.processWrong()
        }
    }
    func processVerify(psw: String){
        if tpsw == psw{
            print("验证成功")
            verifyResult?(true)
            unlock.processRight()
            navigationController?.popViewControllerAnimated(true)
        } else {
            wrongCount()
            unlockLabel.showWarnMsgAndShake("输入错误，您还有\(5-wrongCnt)输入机会")
            unlock.processWrong()
        }
    }
    func processReset(psw: String){
        if tpsw == psw {
            print("重置成功")
            resetResult?(true)
            state = GestureUnlockState.Set
            unlockLabel.showNormalMsg("重新绘制解锁图案")
        } else {
            wrongCount()
            unlockLabel.showWarnMsgAndShake("输入错误，您还有\(5-wrongCnt)输入机会")
            unlock.processWrong()
        }
    }
    func reset(sender: AnyObject?){
        self.state = GestureUnlockState.Set
    }
    func wrongCount(){
        wrongCnt++
        if wrongCnt >= 5 {
            print("错误超过5次，验证失败")
            resetResult?(false)
            navigationController?.popViewControllerAnimated(true)
        }
    }
}