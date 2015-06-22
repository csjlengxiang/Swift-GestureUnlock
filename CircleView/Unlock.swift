import UIKit

class Unlock: UIView {    
    var state: UnlockState = UnlockState.Normal{
        didSet{
            setNeedsDisplay()
        }
    }
    var circles = [Circle]()
    var touchedCircles = [Circle]()
    var curPoint: CGPoint = CGPointZero
    var result: ((String)->Void)?
    
    override init(frame: CGRect? = nil){
        var nframe = frame ?? CommonConfig.Unlock.frame
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
    private func perpare(rect: CGRect){
        var circleRadius = rect.size.width / 3.0 * CommonConfig.Unlock.circleRadiusRadio
        var circleMargin = rect.size.width / 3.0 - circleRadius
        for row in 0..<3{
            for col in 0..<3{
                var x = CGFloat(row) * (circleMargin + circleRadius) + circleMargin / 2.0
                var y = CGFloat(col) * (circleMargin + circleRadius) + circleMargin / 2.0
                var frame = CGRect(x: x, y: y, width: circleRadius, height: circleRadius)
                var circle = Circle(row: row, col: col, frame: frame)
                addSubview(circle)
                circles.append(circle)
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
        for circle in circles {
            CGContextAddEllipseInRect(ctx, circle.frame); // 确定"剪裁"的形状
        }
        CGContextEOClip(ctx)
        // 裁剪代码
        var first = true
        for circle in touchedCircles {
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
        CGContextSetLineWidth(ctx, CommonConfig.Unlock.edgeWidthRadio * rect.size.width)
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
        for circle in circles {
            if CGRectContainsPoint(circle.frame, point) { //应当判断点是否在圆内，但是这个只是个矩形，暂且如此
                circle.state = CircleState.LSelected
                touchedCircles.append(circle)
            }
        }
        setNeedsDisplay()
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var point = (touches.first as! UITouch).locationInView(self)
        curPoint = point
        for circle in circles {
            // 包含在某圆内，但是不在已选中的内
            if CGRectContainsPoint(circle.frame, point) && !contains(touchedCircles, circle) { //应当判断点是否在圆内，但是这个只是个矩形，暂且如此
                if touchedCircles.count > 0{
                    // 设置方向
                    var preCircle = touchedCircles.last!
                    preCircle.setAagle(circle)
                    preCircle.state = CircleState.Selected
                    // 处理跳的情况，判断只适用于一跳的情况，当然九宫格只有一跳
                    var lhs = abs(preCircle.col - circle.col)
                    var rhs = abs(preCircle.row - circle.row)
                    if (lhs + rhs) % 2 == 0 && (lhs == 2 || rhs == 2) {
                        var midRow = (preCircle.row + circle.row) / 2
                        var midCol = (preCircle.col + circle.col) / 2
                        var midCircle = circles[midRow * 3 + midCol]
                        if !contains(touchedCircles, midCircle) { //注意是没有选过的
                            println(circle)
                            midCircle.setAagle(circle)
                            midCircle.state = CircleState.Selected
                            touchedCircles.append(midCircle)
                        }
                    }
                }
                circle.state = CircleState.LSelected
                touchedCircles.append(circle)
            }
        }
        setNeedsDisplay()
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        curPoint = CGPointZero
        self.setNeedsDisplay()
        var ret = ""
        for circle in touchedCircles {
            var idx = circle.row * 3 + circle.col
            ret += "\(idx)"
        }
        println(ret)
        result?(ret)
    }
}
// mark - 对外可操作
extension Unlock{
    func processWrong(displayTime: UInt64 = 600){
        state = UnlockState.Error // 变线的颜色
        for circle in touchedCircles {
            switch circle.state {
            case .Selected:
                circle.state = .Error
            case .LSelected:
                circle.state = .LError
            default:
                break
            }
        }
        processRight(displayTime: displayTime)
    }
    func processRight(displayTime: UInt64 = 600){
        var time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(displayTime * NSEC_PER_MSEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.processClear()
        }
    }
    func processClear(){
        for circle in touchedCircles {
            circle.state = CircleState.Normal
        }
        touchedCircles.removeAll(keepCapacity: false)
        state = UnlockState.Normal
    }
}
