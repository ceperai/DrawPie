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
    let dt = dispatch_time(DISPATCH_TIME_NOW, Int64(ti * NSTimeInterval(NSEC_PER_SEC)))
   dispatch_after(dt, dispatch_get_main_queue(), block)
}

extension Int {
    var degrees: CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180
    }
}

final class ViewController: UIViewController {

    @IBAction func startorCancel(sender: AnyObject) {
        if pieView == nil {
            let pv = PieView( frame: .zero )
            pv.completionBlock = { [weak self] (_) in
                (sender as? UIButton)?.setTitle("Start animation", forState: .Normal)
                (sender as? UIButton)?.enabled = true
                self?.pieView?.removeFromSuperview()
                self?.pieView = nil
            }
            
            capieView.addSubview( pv )
            pv.translatesAutoresizingMaskIntoConstraints = false
            pv.constrainToSuperview()
            pieView = pv
        }
        if let pv = pieView {
            if pv.state == .started {
                pv.stopAnimating()
                (sender as? UIButton)?.enabled = false
            } else {
                pv.startAnimating()
                (sender as? UIButton)?.setTitle("Cancel animation", forState: .Normal)
            }
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var capieView: UIView!
    private var pieView: PieView?
}
