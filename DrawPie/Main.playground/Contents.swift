//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

class PieCAView: UIView {
    
    override class func layerClass() -> AnyClass { return CAShapeLayer.self }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initControls()
    }
    
    func initControls() {
        let l = layer as! CAShapeLayer
        l.fillColor = UIColor.blueColor().CGColor
    }
    
    func animate() {
        let startPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addArcWithCenter(CGPoint(x: bounds.midX, y: bounds.midY), radius: min(bounds.midX, bounds.midY), startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(-M_PI_2) + 2 * CGFloat(0) * CGFloat(M_PI) / 100, clockwise: true)
        
        let pathe = UIBezierPath()
        pathe.moveToPoint(startPoint)
        pathe.addArcWithCenter(CGPoint(x: bounds.midX, y: bounds.midY), radius: min(bounds.midX, bounds.midY), startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(-M_PI_2) + 2 * CGFloat(100) * CGFloat(M_PI) / 100, clockwise: true)
        
        let animation = CAKeyframeAnimation(keyPath: "path")
        animation.duration = 4.0
        animation.values = [path.CGPath, pathe.CGPath]
        
        let l = layer as! CAShapeLayer
        l.strokeStart = 0
        l.strokeEnd = 0.5
        l.addAnimation(animation, forKey: nil)
        
    }
}

let b = UIView(frame: CGRect(x:0, y:0, width: 200, height: 200))
b.backgroundColor = .whiteColor()
let v = PieCAView(frame: CGRect(x:0, y:0, width: 100, height: 100))
b.addSubview(v)
v.animate()
let bb = b








