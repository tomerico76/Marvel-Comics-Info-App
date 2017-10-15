//
//  ToastLabel.swift
//  ToastProject
//
//  Created by tomer on 19/07/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

extension String{
    func toast(){
        Toast.toast(with: self)
    }
}

extension UIView{
    func toast(with text : String){
        Toast.toast(with: text, on: self)
    }
}

class Toast: UILabel {
    
    class func toast(with text : String,
                     on view : UIView? = nil,
                     fadeInDuration : TimeInterval = 1,
                     fadeOutDuration : TimeInterval = 5,
                     relativeVerticalPosition : CGFloat = 0.95)
    {
        
        let superView : UIView
        if let view = view{
            superView = view
        }else{
            superView = UIApplication.shared.delegate!.window!!
        }
        let label = Toast(frame: CGRect(x: 0, y: 0, width: superView.bounds.width * 0.8, height: superView.bounds.height * 0.1))
        
        label.text = text
        
        label.frame = CGRect(x: 0, y: 0, width: superView.bounds.width * 0.8,
                             height: label.textRect(forBounds: CGRect(x: 0, y: 0,
                                                                      width: superView.bounds.width * 0.8,
                                                                      height: superView.bounds.height),
                                                    limitedToNumberOfLines: label.numberOfLines).height + (label.font.lineHeight / 2))
        label.center = CGPoint(x: superView.bounds.width * 0.5, y: superView.bounds.height * relativeVerticalPosition - (label.frame.height / 2))
        
        
        superView.addSubview(label)
       
        UIView.animate(withDuration: fadeInDuration, animations: {label.alpha = 1}, completion: { _ in
            UIView.animate(withDuration: fadeOutDuration, animations: {label.alpha = 0}, completion: { _ in label.removeFromSuperview()})
        })
    }

    //from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        self.font = UIFont.boldSystemFont(ofSize: 16)
        self.textColor = .white
        self.numberOfLines = 0
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 10
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        layer.masksToBounds = true
        textAlignment = .center
        self.alpha = 0
    }
}
