import UIKit

class Circle: UIView {
    var state: CircleState = CircleState.Normal {
        didSet{
            setNeedsDisplay()
        }
    }
    var angle: CGFloat = 0
    var row: Int
    var col: Int

    init (row: Int, col: Int, frame: CGRect){
        self.row = row
        self.col = col
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// mark - 设置angle
extension Circle{
    func setAagle(nextCircle: Circle){
        var lhs = nextCircle.col - col
        var rhs = nextCircle.row - row
        angle = atan2(CGFloat(lhs), CGFloat(rhs)) + CGFloat(M_PI_2)
    }
}
// mark - 画图形
extension Circle{
    override func drawRect(rect: CGRect) {
        var ctx = UIGraphicsGetCurrentContext()
        transformCtx(ctx, rect: rect)
        drawOutCircle(ctx, rect: rect)
        drawInCircle(ctx, rect: rect)
        drawTrangle(ctx, rect: rect)
    }
    // 中心旋转
    func transformCtx(ctx: CGContextRef, rect: CGRect){
        let len = rect.width / 2
        CGContextTranslateCTM(ctx, len, len)
        CGContextRotateCTM(ctx, angle)
        CGContextTranslateCTM(ctx, -len, -len)
    }
    // 绘制外圆
    func drawOutCircle(ctx: CGContextRef, rect: CGRect){
        let len = rect.width
        let edgeWidth = len * CommonConfig.Circle.edgeWidthRadio
        // 注意ios绘制的线是，内外以path为分割各一半，于是edgeWidth要取一半...可以调大edgeWidth试下
        var circleRect = CGRect(x: edgeWidth / 2, y: edgeWidth / 2, width: len - edgeWidth, height: len - edgeWidth)
        var path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, circleRect)
        CGContextAddPath(ctx, path)
        CGContextSetLineWidth(ctx, edgeWidth)
        state.getOutColor().set()
        CGContextStrokePath(ctx)
    }
    // 绘制内圆，且实心
    func drawInCircle(ctx: CGContextRef, rect: CGRect){
        var path = CGPathCreateMutable()
        var len = rect.width * CommonConfig.Circle.inRadio / 2
        var start = rect.width / 2 - len
        var circleRect = CGRect(x: start, y: start, width: len * 2, height: len * 2)
        CGPathAddEllipseInRect(path, nil, circleRect)
        CGContextAddPath(ctx, path)
        state.getInColor().set()
        CGContextFillPath(ctx)
    }
    // 绘制三角形
    func drawTrangle(ctx: CGContextRef, rect: CGRect){
        var path = CGPathCreateMutable()
        var len = rect.size.width / 2 * CommonConfig.Circle.trLenRadio
        var startX = rect.size.width / 2
        var startY = rect.size.width / 2 * (1.0 - CommonConfig.Circle.trPosRadio)
        CGPathMoveToPoint(path, nil, startX, startY);
        CGPathAddLineToPoint(path, nil, startX - len/2, startY + len/2);
        CGPathAddLineToPoint(path, nil, startX + len/2, startY + len/2);
        CGContextAddPath(ctx, path);
        state.getTrColor().set()
        CGContextFillPath(ctx);
    }
}