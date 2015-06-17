import UIKit

enum UnlockState{
    case Normal, Error
    static let blue = UnlockState.rgba(34, g: 178, b: 246, a: 1.0)
    static let red = UnlockState.rgba(254, g: 82, b: 92, a: 1.0)
    func getColor()->UIColor {
        switch self {
        case .Normal:
            return UnlockState.blue
        case .Error:
            return UnlockState.red
        default:
            return UIColor.clearColor()
        }
    }
    static func rgba(r: Int, g: Int, b: Int, a: CGFloat)->UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
}
class Unlock: UIView {
    static let circleRadiusRadio: CGFloat = 0.66 //对于9宫格，圆相对九宫格的大小
    static let edgeMarginRadio: CGFloat = 0.08 //相对于屏幕宽度的，九宫相对于屏幕边缘的距离
    static let edgeWidthRadio: CGFloat = 0.0038 //相对于frame的宽度
    
    // 默认,屏幕3/5位置，且与屏幕边框edgeMargin = UIScreen.mainScreen().bounds.size.width * edgeMarginRadio值
    static let frame = CGRect(
        x: UIScreen.mainScreen().bounds.size.width * Unlock.edgeMarginRadio,
        y: UIScreen.mainScreen().bounds.size.height * 3 / 5 - (UIScreen.mainScreen().bounds.size.width - UIScreen.mainScreen().bounds.size.width * Unlock.edgeMarginRadio * 2) / 2,
        width: UIScreen.mainScreen().bounds.size.width - UIScreen.mainScreen().bounds.size.width * Unlock.edgeMarginRadio * 2,
        height: UIScreen.mainScreen().bounds.size.width - UIScreen.mainScreen().bounds.size.width * Unlock.edgeMarginRadio * 2)
    
    var state: UnlockState = UnlockState.Normal{
        didSet{
            self.setNeedsDisplay()
        }
    }
    var circles: NSMutableArray = []
    var touchedCircles: NSMutableArray = []
    var curPoint: CGPoint = CGPointZero
    
    override init(frame: CGRect? = nil){
        var nframe = frame ?? Unlock.frame
        super.init(frame: nframe)
        perpare(nframe)
        backgroundColor = UIColor.clearColor()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
// mark - 初始化时布局下9个圈圈，无需layoutSubviews
extension Unlock{
    func perpare(rect: CGRect){
        var circleRadius = rect.size.width / 3.0 * Unlock.circleRadiusRadio
        var circleMargin = rect.size.width / 3.0 - circleRadius
        for row in 0..<3{
            for col in 0..<3{
                var x = CGFloat(row) * (circleMargin + circleRadius) + circleMargin / 2.0
                var y = CGFloat(col) * (circleMargin + circleRadius) + circleMargin / 2.0
                var circle = Circle()
                circle.frame = CGRect(x: x, y: y, width: circleRadius, height: circleRadius)
                circle.row = row
                circle.col = col
                addSubview(circle)
                circles.addObject(circle)
            }
        }
    }
}
// mark - touch 绘图
extension Unlock{
    override func drawRect(rect: CGRect) {
        var ctx = UIGraphicsGetCurrentContext()
        // 裁剪时候要用到
        CGContextAddRect(ctx, rect)
        circles.enumerateObjectsUsingBlock{
            (_circle, _, _) in
            var circle = _circle as! Circle
            CGContextAddEllipseInRect(ctx, circle.frame); // 确定"剪裁"的形状
        }
        CGContextEOClip(ctx)
        // 裁剪代码
        var first = true
        touchedCircles.enumerateObjectsUsingBlock{
            (_circle, _, _) in
            var circle = _circle as! Circle
            if first {
                CGContextMoveToPoint(ctx, circle.center.x, circle.center.y)
                first = false
            } else {
                CGContextAddLineToPoint(ctx, circle.center.x, circle.center.y)
            }
        }
        if touchedCircles.count > 0 && curPoint != CGPointZero {
            CGContextAddLineToPoint(ctx, curPoint.x, curPoint.y)
        }
        //线条转角样式,只有线粗的时候第一个有点用，第二个是转角但是转角其实被掩盖了，暂且留着
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        // 设置绘图的属性
        CGContextSetLineWidth(ctx, Unlock.edgeWidthRadio * rect.size.width)
        // 线条颜色
        state.getColor().set()
        //渲染路径
        CGContextStrokePath(ctx);
    }
}
// mark - touch 触摸过程
extension Unlock{
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // mark - 清空
        var point = (touches.first as! UITouch).locationInView(self)
        curPoint = point
        self.circles.enumerateObjectsUsingBlock{
            (_circle, _, _) in
            var circle = _circle as! Circle
            if CGRectContainsPoint(circle.frame, point) { //应当判断点是否在圆内，但是这个只是个矩形，暂且如此
                circle.state = CircleState.LSelected
                self.touchedCircles.addObject(circle)
            }
        }
        self.setNeedsDisplay()
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var point = (touches.first as! UITouch).locationInView(self)
        curPoint = point
        self.circles.enumerateObjectsUsingBlock{
            (_circle, _, _) in
            var circle = _circle as! Circle
            // 包含在某圆内，但是不在已选中的内
            if CGRectContainsPoint(circle.frame, point) && !self.touchedCircles.containsObject(circle) { //应当判断点是否在圆内，但是这个只是个矩形，暂且如此
                if self.touchedCircles.count > 0{
                    // 设置方向
                    var preCircle = self.touchedCircles.lastObject as! Circle
                    preCircle.setAagle(circle)
                    preCircle.state = CircleState.Selected
                    // 处理跳的情况，判断只适用于一跳的情况，当然九宫格只有一跳
                    var lhs = abs(preCircle.col - circle.col)
                    var rhs = abs(preCircle.row - circle.row)
                    if (lhs + rhs) % 2 == 0 && (lhs == 2 || rhs == 2) {
                        var midRow = (preCircle.row + circle.row) / 2
                        var midCol = (preCircle.col + circle.col) / 2
                        var midCircle = self.circles[midRow * 3 + midCol] as! Circle
                        if !self.touchedCircles.containsObject(midCircle) { //注意是没有选过的
                            midCircle.setAagle(circle)
                            midCircle.state = CircleState.Selected
                            self.touchedCircles.addObject(midCircle)
                        }
                    }
                }
                circle.state = CircleState.LSelected
                self.touchedCircles.addObject(circle)
            }
        }
        self.setNeedsDisplay()
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        curPoint = CGPointZero
        self.setNeedsDisplay()
        returnResult()
    }
}
// mark - check手势
extension Unlock{
    func returnResult(){
        var ret = ""
        self.touchedCircles.enumerateObjectsUsingBlock{
            (_circle, _, _) in
            var circle = _circle as! Circle
            var idx = circle.row * 3 + circle.col
            ret += "\(idx)"
        }
        println(ret)
        // delegate 交给将结果委托到上级业务函数，若要消失调用processRight，爆红再消失调用processWrong
    }
    func processWrong(displayTime: UInt64 = 600){
        turnError()
        turnNormalAndDisappear(displayTime)
    }
    func processRight(displayTime: UInt64 = 600){
        turnNormalAndDisappear(displayTime)
    }
    func turnError(){
        state = UnlockState.Error // 变线的颜色
        touchedCircles.enumerateObjectsUsingBlock{
            (_circle, _, _) in
            var circle = _circle as! Circle
            switch circle.state{
            case .Selected:
                circle.state = .Error
                return
            case .LSelected:
                circle.state = .LError
                return
            default:
                return
            }
        }
    }
    func turnNormalAndDisappear(displayTime: UInt64){
        var time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(displayTime * NSEC_PER_MSEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            println("手势消失")
            self.touchedCircles.enumerateObjectsUsingBlock{
                (_circle, _, _) in
                var circle = _circle as! Circle
                circle.state = CircleState.Normal
            }
            self.touchedCircles.removeAllObjects()
            self.state = UnlockState.Normal
        }
    }
}
