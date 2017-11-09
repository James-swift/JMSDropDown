//
//  Constants.swift
//  JMSDropDown
//
//  Created by James.xiao on 2017/11/9.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

internal struct Constants {
    
    internal struct KeyPath {
        
        static let Frame = "frame"
        
    }
    
    internal struct ReusableIdentifier {
        
        static let DropDownCell = "JMSDropDownCell"
        
    }
    
    internal struct UI {
        
        static let TextColor = UIColor.black
        static let TextFont = UIFont.systemFont(ofSize: 15)
        static let BackgroundColor = UIColor(white: 0.94, alpha: 1)
        static let SelectionBackgroundColor = UIColor(white: 0.89, alpha: 1)
        static let SeparatorColor = UIColor.clear
        static let CornerRadius: CGFloat = 2
        static let RowHeight: CGFloat = 44
        static let HeightPadding: CGFloat = 20
        
        struct Shadow {
            
            static let Color = UIColor.darkGray
            static let Offset = CGSize.zero
            static let Opacity: Float = 0.4
            static let Radius: CGFloat = 8
            
        }
        
    }
    
    internal struct Animation {
        
        static let Duration = 0.15
        static let EntranceOptions: UIViewAnimationOptions = [.allowUserInteraction, .curveEaseOut]
        static let ExitOptions: UIViewAnimationOptions = [.allowUserInteraction, .curveEaseIn]
        static let DownScaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
    }
    
}
