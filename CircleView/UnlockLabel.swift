import UIKit

extension CALayer{
    func shake(){
        let kfa = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        kfa.values = [-5,0,5,0,-5,0,5,0]
        
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
    static let fontSizeRadio: CGFloat = 0.04
    static let normalColor: UIColor = CommonConfig.white
    static let warnColor: UIColor = CommonConfig.red

    convenience init() {
        self.init(frame: UnlockLabel.frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textColor = CommonConfig.white
        let fontSize = UIScreen.mainScreen().bounds.size.width * UnlockLabel.fontSizeRadio
        self.font = UIFont.systemFontOfSize(fontSize)
        self.textAlignment = NSTextAlignment.Center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func showNormalMsg(msg: String){
        self.text = msg
        self.textColor = UnlockLabel.normalColor
    }
    func showWarnMsg(msg: String){
        self.text = msg
        self.textColor = UnlockLabel.warnColor
    }
    func showWarnMsgAndShake(msg: String){
        self.text = msg
        self.textColor = UnlockLabel.warnColor
        self.layer.shake()
    }
}
