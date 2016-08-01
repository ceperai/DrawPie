//
//  PieView.swift
//  DrawPie
//
//  Created by Sergey Pestov on 27/07/16.
//  Copyright © 2016 Sergey Pestov. All rights reserved.
//

import UIKit

/// Animate drawing pie with animating cancelation.
final class PieView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInit()
    }
    
    override class func layerClass() -> AnyClass {
        return PieLayer.self
    }
    
    /// Fill color of Pie
    var valueColor : UIColor = UIColor.redColor() {
        didSet {
            pieLayer.valueColor = valueColor.CGColor
        }
    }
    
    /// Start pie animation with predefined timeout.
    func startAnimating() {
        switch state {
        case .started, .finished:
            state = .started
        case .canceled:
            break
        }
    }
    
    /// Stop pie animation and start cancel animation with default timeout (0.25 s)
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
        pieLayer.valueColor = valueColor.CGColor
        setNeedsDisplay()
    }
    
    private func startTimeoutAnimation() {
        layer.removeAllAnimations()
        
        let a = CABasicAnimation(keyPath: "endAngle")
        a.fromValue = zeroAngle
        a.toValue = CGFloat( 3/2 * M_PI)
        a.duration = timeoutAnimationDuration
        a.delegate = self
        layer.addAnimation(a, forKey: "timeoutAnimation")
        
        pieLayer.endAngle = CGFloat( 3/2 * M_PI)
    }
    
    private func startCancelAnimation() {
        layer.removeAllAnimations()
        
        let a = CABasicAnimation(keyPath: "endAngle")
        a.fromValue = layer.presentationLayer()?.valueForKey("endAngle")
        a.toValue = zeroAngle
        a.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        a.delegate = self
        layer.addAnimation(a, forKey: "cancelAnimation")
        
        pieLayer.endAngle = zeroAngle
    }
    
    /// Full pie drawing animation duration. Should be set before `startAnimating`
    var timeoutAnimationDuration: NSTimeInterval = 4
    
    /// Block of code to be called with animation completed. `finished` parameter shows if
    /// pie animation was canceled.
    var completionBlock: ( (finished: Bool) -> Void )?
    
    /// Possible pie animation states.
    enum State { case started, canceled, finished }
    /// Pie current animation state.
    private (set) var state: State = .finished {
        didSet {
            switch state {
            case .started:
                startTimeoutAnimation()
            case .canceled:
                startCancelAnimation()
            case .finished:
                break
            }
        }
    }
    private let zeroAngle = CGFloat(-M_PI_2)
    
    private var pieLayer: PieLayer { return layer as! PieLayer }
}

private extension PieView {
    
    private func isTimeoutAnimation(anim: CAAnimation) -> Bool {
        // Check if it's timeout animation by comparing animation final value with zero.
        if let a = anim as? CABasicAnimation, value = a.toValue?.floatValue where value > 0 {
            return true
        }
        return false
    }
}

#if swift(>=2.3)
    
extension PieView: CAAnimationDelegate {
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if isTimeoutAnimation(anim) {
            if flag {
                completionBlock?(finished: true)
                state = .finished
            }
        } else {
            completionBlock?(finished: false)
            state = .finished
        }
    }
}
    
#else
    
extension PieView {
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if isTimeoutAnimation(anim) {
            if flag {
                completionBlock?(finished: true)
                state = .finished
            }
        } else {
            completionBlock?(finished: false)
            state = .finished
        }
    }
}
#endif

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
            layer.contentsScale = UIScreen.mainScreen().scale
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
        
        let lineWidth = 1 as CGFloat
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = min(self.bounds.midX, self.bounds.midY) - 2 * lineWidth
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, center.x, center.y)
        CGContextAddArc(ctx, center.x, center.y, radius, beginAngle, endAngle, 0)
        CGContextClosePath(ctx)
        
        // Нарисовать путь
        CGContextSetFillColorWithColor(ctx, valueColor)
        CGContextSetStrokeColorWithColor(ctx, valueColor)
        CGContextSetLineWidth(ctx, lineWidth)
        
        CGContextDrawPath(ctx, .FillStroke)
    }
}
