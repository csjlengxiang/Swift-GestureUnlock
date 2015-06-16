//
//  Unlock.swift
//  Swift-GestureUnlock
//
//  Created by csj on 15/6/16.
//  Copyright (c) 2015年 csj. All rights reserved.
//

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
            return CircleState.red
        default:
            return UIColor.clearColor()
        }
    }
    static func rgba(r: Int, g: Int, b: Int, a: CGFloat)->UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
}

class Unlock: UIView {
    static let circleRadiusRadio: CGFloat = 0.6 //对于9宫格，圆相对九宫格的大小
    static let edgeMargin: CGFloat = 30.0
    
    // 默认,屏幕3/5位置，且与屏幕边框edgeMargin值
    static let frame = CGRect(
        x: Unlock.edgeMargin,
        y: UIScreen.mainScreen().bounds.size.height * 3 / 5 - (UIScreen.mainScreen().bounds.size.width - Unlock.edgeMargin * 2) / 2,
        width: UIScreen.mainScreen().bounds.size.width - Unlock.edgeMargin * 2,
        height: UIScreen.mainScreen().bounds.size.width - Unlock.edgeMargin * 2)
    var state: UnlockState = UnlockState.Error
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
                circle.state = CircleState.LSelected
                if self.touchedCircles.count > 0{
                    var preCircle = self.touchedCircles.lastObject as! Circle
                    preCircle.setAagle(circle)
                    preCircle.state = CircleState.Selected
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
        //线条转角样式
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        // 设置绘图的属性
        CGContextSetLineWidth(ctx, Circle.edgeWidth);
        // 线条颜色
        state.getColor().set()
        //渲染路径
        CGContextStrokePath(ctx);
    }
}
