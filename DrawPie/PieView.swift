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
    
    var valueColor : CGColor = UIColor.redColor().CGColor {
        didSet {
            pieLayer.valueColor = valueColor
        }
    }
    
    /// Начать анимацию таймаута.
    func startAnimating() {
        switch state {
        case .started, .finished:
            state = .started
        case .canceled:
            break
        }
    }
    
    /// Прекратить анимацию таймаута и начать анимацию отмены.
    func stopAnimating() {
        switch state {
        case .started:
            state = .canceled
        case .canceled, .finished:
            break
        }
    }
    
    private func doInit() {
        opaque = false
        pieLayer.beginAngle = zeroAngle
        pieLayer.endAngle   = zeroAngle
        pieLayer.valueColor = valueColor
        setNeedsDisplay()
    }
    
    private func startTimeoutAnimation() {
        layer.removeAnimationForKey("endAngle")
        
        let a = CABasicAnimation(keyPath: "endAngle")
        a.fromValue = zeroAngle
        a.toValue = CGFloat( 3/2 * M_PI)
        a.duration = timeoutAnimationDuration
        a.delegate = self
        layer.addAnimation(a, forKey: "endAngle")
    }
    
    private func startCancelAnimation() {
        layer.removeAnimationForKey("endAngle")
        
        let a = CABasicAnimation(keyPath: "endAngle")
        a.fromValue = layer.presentationLayer()?.valueForKey("endAngle")
        a.toValue = zeroAngle
        a.duration = cancelAnimationDuration
        a.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        layer.addAnimation(a, forKey: "endAngle")
    }
    
    /// Время анимации таймаута.
    var timeoutAnimationDuration: NSTimeInterval = 4
    /// Время анимации отмены таймаута.
    var cancelAnimationDuration: NSTimeInterval = 0.3
    
    /// Состояние анимации.
    enum State { case started, canceled, finished }
    /// Текущее состояние анимации.
    private (set) var state: State = .finished {
        didSet {
            switch state {
            case .started:
                startTimeoutAnimation()
            case .canceled:
                startCancelAnimation()
                state = .finished
            case .finished:
                break
            }
        }
    }
    private let zeroAngle = CGFloat(-M_PI_2)
    
    private var pieLayer: PieLayer { return layer as! PieLayer }
}

extension PieView {
    
//    override func animationDidStart(anim: CAAnimation) {
//        state = .started
//    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        state = flag ? .finished : .canceled
    }
}

// у кастомного layer добавить пару свойств
class PieLayer: CALayer {
    @NSManaged var beginAngle : CGFloat
    @NSManaged var endAngle   : CGFloat
    @NSManaged var valueColor : CGColor
    
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
