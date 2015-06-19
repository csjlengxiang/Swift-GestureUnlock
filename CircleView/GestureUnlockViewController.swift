import UIKit

enum GestureUnlockState {
    case Set, Verify, Reset
}
class GestureUnlockViewController: UIViewController {
    // mark = 初始化都在这里...统一管理
    var state: GestureUnlockState! {
        didSet{
            stateInit()
        }
    }
    var tpsw: NSString!
    var unlock: Unlock!
    var rightBtn: UIBarButtonItem!
    var unlockInfo: UnlockInfo!
    var unlockLabel: UnlockLabel!
    var wrongCnt = 0
    
    var setSuc: ((NSString)->Void)?
    var verifyResult:((Bool)->Void)?
    var resetResult:((Bool)->Void)?
    
    func rgba(r: Int, g: Int, b: Int, a: CGFloat)->UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = rgba(13, g: 52, b: 89, a: 1)
        prepare()
        stateInit()
    }
    
    func stateInit(){
        switch self.state! {
        case GestureUnlockState.Set:
            tpsw = nil
            unlock?.processClear()
            navigationItem.rightBarButtonItem = nil
            unlockInfo?.psw = nil
            unlockInfo?.hidden = false
            unlockLabel?.showNormalMsg("绘制解锁图案")
            navigationItem.title? = "设置手势密码"
            return
        case GestureUnlockState.Verify:
            unlock?.processClear()
            navigationItem.rightBarButtonItem = nil
            unlockInfo?.hidden = true
            unlockLabel?.showNormalMsg("请输入手势密码")
            wrongCnt = 0
            navigationItem.title? = "验证手势密码"
            //self.navigationController?.navigationBarHidden = true
            return
        case GestureUnlockState.Reset:
            unlock?.processClear()
            navigationItem.rightBarButtonItem = nil
            unlockInfo?.hidden = true
            unlockLabel?.showNormalMsg("请输入原手势密码")
            wrongCnt = 0
            navigationItem.title? = "重设手势密码"
            return
        }
        
    }
}
// mark - view prepare
extension GestureUnlockViewController{
    func prepare(){
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
        
        rightBtn = UIBarButtonItem(title: "重设", style: UIBarButtonItemStyle.Done, target: self, action: "reset:")
        
        unlockInfo = UnlockInfo(frame: nil)
        self.view.addSubview(unlockInfo)
        
        unlockLabel = UnlockLabel(frame: nil)
        self.view.addSubview(unlockLabel)
        
        
    }
}
// mark - process
extension GestureUnlockViewController{
    func processSet(psw: NSString){
        if tpsw == nil {
            tpsw = psw
            unlock.processRight()
            unlockInfo.psw = psw
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
    func processVerify(psw: NSString){
        if tpsw == psw{
            println("验证成功")
            verifyResult?(true)
            unlock.processRight()
            navigationController?.popViewControllerAnimated(true)
        } else {
            wrongCount()
            unlockLabel.showWarnMsgAndShake("输入错误，您还有\(5-wrongCnt)输入机会")
            unlock.processWrong()
        }
    }
    func processReset(psw: NSString){
        if tpsw == psw {
            println("重置成功")
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
            println("错误超过5次，验证失败")
            resetResult?(false)
            navigationController?.popViewControllerAnimated(true)
        }
    }
}