//
//  Unlock.swift
//  Swift-GestureUnlock
//
//  Created by csj on 15/6/16.
//  Copyright (c) 2015年 csj. All rights reserved.
//

import UIKit

class Unlock: UIView {
    static let circleRadiusRadio: CGFloat = 0.6 //对于9宫格，圆相对九宫格的大小
    static let edgeMargin: CGFloat = 30.0
    
    // 默认,屏幕3/5位置，且与屏幕边框edgeMargin值
    static let frame = CGRect(
        x: Unlock.edgeMargin,
        y: UIScreen.mainScreen().bounds.size.height * 3 / 5 - (UIScreen.mainScreen().bounds.size.width - Unlock.edgeMargin * 2) / 2,
        width: UIScreen.mainScreen().bounds.size.width - Unlock.edgeMargin * 2,
        height: UIScreen.mainScreen().bounds.size.width - Unlock.edgeMargin * 2)
    
    var circles: NSMutableArray = []
    var touchedCircles: NSMutableArray = []
    var curPoint: CGPoint = CGPointZero
    
    override init(frame: CGRect? = nil){
        var nframe = frame ?? Unlock.frame
        super.init(frame: nframe)
        perpare(nframe)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
// mark - 布局下9个圈圈
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
// mark - touch 
extension Unlock{
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // mark - 清空
        var point = (touches.first as! UITouch).locationInView(self)
        self.circles.enumerateObjectsUsingBlock{
            (_circle, _, _) in
            var circle = _circle as! Circle
            if CGRectContainsPoint(circle.frame, point) { //应当判断点是否在圆内，但是这个只是个矩形，暂且如此
                circle.state = CircleState.LSelected
                self.touchedCircles.addObject(circle)
            }
        }
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var point = (touches.first as! UITouch).locationInView(self)
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
    }
}
