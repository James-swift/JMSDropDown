//
//  JMSDropDown+Appearance.swift
//  JMSDropDown
//
//  Created by James.xiao on 2017/11/9.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

extension JMSDropDown {

    public class func setupDefaultAppearance() {
        let appearance = JMSDropDown.appearance()
        
        appearance.cellHeight                   = Constants.UI.RowHeight
        appearance.backgroundColor              = Constants.UI.BackgroundColor
        appearance.selectionBackgroundColor     = Constants.UI.SelectionBackgroundColor
        appearance.separatorColor               = Constants.UI.SeparatorColor
        appearance.cornerRadius                 = Constants.UI.CornerRadius
        appearance.shadowColor                  = Constants.UI.Shadow.Color
        appearance.shadowOffset                 = Constants.UI.Shadow.Offset
        appearance.shadowOpacity                = Constants.UI.Shadow.Opacity
        appearance.shadowRadius                 = Constants.UI.Shadow.Radius
        appearance.animationduration            = Constants.Animation.Duration
        appearance.textColor                    = Constants.UI.TextColor
        appearance.textFont                     = Constants.UI.TextFont
    }
    
}
