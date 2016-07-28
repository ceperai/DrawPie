//
//  PieView.swift
//  DrawPie
//
//  Created by Sergey Pestov on 27/07/16.
//  Copyright © 2016 Sergey Pestov. All rights reserved.
//

import UIKit

// Сделать view c кастомным layer
class PieView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func layerClass() -> AnyClass {
        return PieLayer.self
    }
    
//    var beginAngle: CGFloat = CGFloat(-M_PI_2) {
//        didSet {
//            pieLayer.beginAngle = beginAngle
//        }
//    }
//    var endAngle: CGFloat = CGFloat(-M_PI_2) {
//        didSet {
//            pieLayer.endAngle = endAngle
//        }
//    }
    var valueColor : CGColor = UIColor.redColor().CGColor {
        didSet {
            pieLayer.valueColor = valueColor
        }
    }
    
    func startAnimating(duration: NSTimeInterval) {
        let angle = CGFloat(-M_PI_2)
        pieLayer.beginAngle = angle
        pieLayer.endAngle = angle
        
        let a = CABasicAnimation(keyPath: "endAngle")
        a.fromValue = CGFloat(-M_PI_2)
        a.toValue = CGFloat( 3/2 * M_PI)
        a.duration = duration
        layer.addAnimation(a, forKey: "endAngle")
    }
    
    func stopAnimating() {
        
    }
    
    private func doInit() {
        opaque = false
//        pieLayer.beginAngle = beginAngle
//        pieLayer.endAngle = endAngle
        pieLayer.valueColor = valueColor
        setNeedsDisplay()
    }
    
    private var pieLayer: PieLayer { return layer as! PieLayer }
}

// у кастомного layer добавить пару свойств
class PieLayer: CALayer {
    @NSManaged var beginAngle : CGFloat
    @NSManaged var endAngle   : CGFloat
    @NSManaged var valueColor : CGColor
    
//    override func actionForKey(event: String) -> CAAction? {
//        if ["beginAngle", "endAngle"].contains(event) {
//            let action = CABasicAnimation()
//            action.fromValue = presentationLayer()?.valueForKey(event)
//            action.duration = animationDuration
//            return action
//        }
//        return super.actionForKey(event)
//    }
    override init() {
        super.init()
    }
    
    // Блин, эта штука вызывается каждый раз на каждую анимацию при копировании из modelLayer в presentationLayer.
    override init(layer: AnyObject) {
        super.init(layer: layer)
        
        if let layer = layer as? PieLayer {
            layer.beginAngle = beginAngle
            layer.endAngle = endAngle
            layer.valueColor = valueColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func needsDisplayForKey(key: String) -> Bool {
        if ["beginAngle", "endAngle"].contains(key) {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    override func drawInContext(ctx: CGContext) {
        guard beginAngle != endAngle else { return }
        
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = min(self.bounds.width / 2, self.bounds.height / 2)
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, center.x, center.y)
        CGContextAddArc(ctx, center.x, center.y, radius, beginAngle, endAngle, 0)
        CGContextClosePath(ctx)
        
        // Нарисовать путь
        CGContextSetFillColorWithColor(ctx, valueColor)
        CGContextSetStrokeColorWithColor(ctx, valueColor)
        CGContextSetLineWidth(ctx, 1)
        
        CGContextDrawPath(ctx, .FillStroke)
    }
}
