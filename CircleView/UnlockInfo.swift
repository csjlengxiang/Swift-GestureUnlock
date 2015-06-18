//
//  UnlockInfo.swift
//  Swift-GestureUnlock
//
//  Created by csj on 15/6/18.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import UIKit

class UnlockInfo: UIView {
    static let circleRadiusRadio: CGFloat = 0.76 //对于9宫格，圆相对九宫格的大小
    static let edgeMarginRadio: CGFloat = 0.445 //相对于屏幕宽度的，九宫相对于屏幕边缘的距离
    static let edgeWidthRadio: CGFloat = 0.13 //相对于frame的宽度
    
    // 默认,屏幕3/5位置，且与屏幕边框edgeMargin = UIScreen.mainScreen().bounds.size.width * edgeMarginRadio值
    static let frame = CGRect(
        x: UIScreen.mainScreen().bounds.size.width * UnlockInfo.edgeMarginRadio,
        y: UIScreen.mainScreen().bounds.size.height * 1.2 / 5 - (UIScreen.mainScreen().bounds.size.width - UIScreen.mainScreen().bounds.size.width * UnlockInfo.edgeMarginRadio * 2) / 2,
        width: UIScreen.mainScreen().bounds.size.width - UIScreen.mainScreen().bounds.size.width * UnlockInfo.edgeMarginRadio * 2,
        height: UIScreen.mainScreen().bounds.size.width - UIScreen.mainScreen().bounds.size.width * UnlockInfo.edgeMarginRadio * 2)
    
    var psw: NSString?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    override init(frame: CGRect? = nil){
        var nframe = frame ?? UnlockInfo.frame
        super.init(frame: nframe)
        backgroundColor = UIColor.clearColor()
    }
    override func drawRect(rect: CGRect) {
        var ctx = UIGraphicsGetCurrentContext()
        var circleRadius = rect.size.width / 3.0 * UnlockInfo.circleRadiusRadio
        var circleMargin = rect.size.width / 3.0 - circleRadius
        for row in 0..<3{
            for col in 0..<3{
                var x = CGFloat(row) * (circleMargin + circleRadius) + circleMargin / 2.0
                var y = CGFloat(col) * (circleMargin + circleRadius) + circleMargin / 2.0
                var nframe = CGRect(x: x, y: y, width: circleRadius, height: circleRadius)
                
                if (psw != nil) && contain(psw!, num: row * 3 + col) {
                    drawInCircle(ctx, rect: nframe)
                }
                else {
                    drawOutCircle(ctx, rect: nframe)
                }
            }
        }
    }
    func contain(psw: NSString, num: Int)->Bool{
        var str = "\(num)"
        var range = psw.rangeOfString(str)
        return range.length > 0
    }
    func drawOutCircle(ctx: CGContextRef, rect: CGRect){
        let len = rect.width
        let edgeWidth = len * UnlockInfo.edgeWidthRadio
        // 注意ios绘制的线是，内外以path为分割各一半，于是edgeWidth要取一半...可以调大edgeWidth试下
        var circleRect = CGRect(
            x: rect.origin.x + edgeWidth / 2,
            y: rect.origin.y + edgeWidth / 2,
            width: len - edgeWidth,
            height: len - edgeWidth)
        println(rect)
        println(circleRect)
        var path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, circleRect)
        CGContextAddPath(ctx, path)
        CGContextSetLineWidth(ctx, edgeWidth)
        CircleState.white.set()
        CGContextStrokePath(ctx)
    }
    // 绘制内圆，且实心
    func drawInCircle(ctx: CGContextRef, rect: CGRect){
        var path = CGPathCreateMutable()
        CGPathAddEllipseInRect(path, nil, rect)
        CGContextAddPath(ctx, path)
        CircleState.blue.set()
        CGContextFillPath(ctx)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
