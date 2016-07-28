//
//  ViewController.swift
//  DrawPie
//
//  Created by Sergey Pestov on 25/04/16.
//  Copyright © 2016 Sergey Pestov. All rights reserved.
//

import UIKit

private extension UIView {
    
    func constrainToSuperview() {
        let h = NSLayoutConstraint.constraintsWithVisualFormat("H:|[self]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["self":self])
        self.superview!.addConstraints(h)
        
        let v = NSLayoutConstraint.constraintsWithVisualFormat("V:|[self]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["self":self])
        self.superview!.addConstraints(v)
    }
}

func dispatch_after(timeInterval ti: NSTimeInterval, _ block: () -> Void ) {
//DISPATCH_TIME_NOW +
    let dt = dispatch_time(DISPATCH_TIME_NOW, Int64(ti * NSTimeInterval(NSEC_PER_SEC)))
   dispatch_after(dt, dispatch_get_main_queue(), block)
}

extension Int {
    var degrees: CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderValueDidChange(sender: UISlider) {
        let label = view.viewWithTag(500) as! UILabel
        label.text = "\(sender.value * 1000)"
        
    }
    @IBAction func startorCancel(sender: AnyObject) {
        if pieView == nil {
            let pv = PieView( frame: .zero )
            
            capieView.addSubview( pv )
            pv.translatesAutoresizingMaskIntoConstraints = false
            pv.constrainToSuperview()
            pieView = pv
        }
        pieView?.startAnimating(2)

//        pv.beginAngle = -90.degrees
//        let a = CABasicAnimation()
//        a.fromValue = -90.degrees
//        a.toValue = 270.degrees
//        a.duration = 4
//        a.keyPath = "endAngle"
//        pv.layer.addAnimation(a, forKey: nil)
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var capieView: UIView!
    private var pieView: PieView?
}
