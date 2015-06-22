import UIKit

class UnlockInfo: UIView {
    var state: UnlockInfoState = .Normal{
        didSet{
            setNeedsDisplay()
        }
    }
    override init(frame: CGRect? = nil){
        var nframe = frame ?? CommonConfig.UnlockInfo.frame
        super.init(frame: nframe)
        backgroundColor = UIColor.clearColor()
    }
    override func drawRect(rect: CGRect) {
        var ctx = UIGraphicsGetCurrentContext()
        var circleRadius = rect.size.width / 3.0 * CommonConfig.UnlockInfo.circleRadiusRadio
        var circleMargin = rect.size.width / 3.0 - circleRadius
        for row in 0..<3{
            for col in 0..<3{
                var x = CGFloat(row) * (circleMargin + circleRadius) + circleMargin / 2.0
                var y = CGFloat(col) * (circleMargin + circleRadius) + circleMargin / 2.0
                var nframe = CGRect(x: x, y: y, width: circleRadius, height: circleRadius)
                switch state {
                case .Normal:
                    drawOutCircle(ctx, rect: nframe)
                case .Selected(let psw):
                    if contain(psw, num: row * 3 + col) {
                        drawInCircle(ctx, rect: nframe)
                    } else {
                        drawOutCircle(ctx, rect: nframe)
                    }
                }
            }
        }
    }
    func drawOutCircle(ctx: CGContextRef, rect: CGRect){
        let len = rect.width
        let edgeWidth = len * CommonConfig.UnlockInfo.edgeWidthRadio
        // 注意ios绘制的线是，内外以path为分割各一半，于是edgeWidth要取一半...可以调大edgeWidth试下
        var circleRect = CGRect(
            x: rect.origin.x + edgeWidth / 2,
            y: rect.origin.y + edgeWidth / 2,
            width: len - edgeWidth,
            height: len - edgeWidth)
        var path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, circleRect)
        CGContextAddPath(ctx, path)
        CGContextSetLineWidth(ctx, edgeWidth)
        state.getColor().set()
        CGContextStrokePath(ctx)
    }
    // 绘制内圆，且实心
    func drawInCircle(ctx: CGContextRef, rect: CGRect){
        var path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, rect)
        CGContextAddPath(ctx, path)
        state.getColor().set()
        CGContextFillPath(ctx)
    }
    func contain(psw: NSString, num: Int)->Bool{
        var str = "\(num)"
        var range = psw.rangeOfString(str)
        return range.length > 0
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
