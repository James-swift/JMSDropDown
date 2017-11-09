//
//  UIView+Extension.swift
//  JMSDropDown
//
//  Created by James.xiao on 2017/11/9.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

internal extension UIView {
    
    func addConstraints(format: String, options: NSLayoutFormatOptions = [], metrics: [String: AnyObject]? = nil, views: [String: UIView]) {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views))
    }
    
    func addUniversalConstraints(format: String, options: NSLayoutFormatOptions = [], metrics: [String: AnyObject]? = nil, views: [String: UIView]) {
        addConstraints(format: "H:\(format)", options: options, metrics: metrics, views: views)
        addConstraints(format: "V:\(format)", options: options, metrics: metrics, views: views)
    }
    
}

internal extension UIView {
    
    var windowFrame: CGRect? {
        return superview?.convert(frame, to: nil)
    }
    
}

internal extension UIWindow {
    
    static func visibleWindow() -> UIWindow? {
        var currentWindow = UIApplication.shared.keyWindow
        
        if currentWindow == nil {
            let frontToBackWindows = Array(UIApplication.shared.windows.reversed())
            
            for window in frontToBackWindows {
                if window.windowLevel == UIWindowLevelNormal {
                    currentWindow = window
                    break
                }
            }
        }
        
        return currentWindow
    }
    
}

