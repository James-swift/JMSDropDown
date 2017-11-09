//
//  ViewController.swift
//  JMSDropDown
//
//  Created by James.xiao on 2017/11/9.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var chooseArticleButton: UIButton!
    @IBOutlet weak var amountButton: UIButton!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    // MARK: - DropDown's
    let chooseArticleDropDown   = JMSDropDown()
    let amountDropDown          = JMSDropDown()
    let rightBarDropDown        = JMSDropDown()
    
    lazy var dropDowns: [JMSDropDown] = {
        return [
            self.chooseArticleDropDown,
            self.amountDropDown,
            self.rightBarDropDown
        ]
    }()
    
    // MARK: - Actions
    @IBAction func chooseArticle(_ sender: AnyObject) {
        chooseArticleDropDown.show()
    }
    
    @IBAction func changeAmount(_ sender: AnyObject) {
        amountDropDown.show()
    }
    
    @IBAction func showBarButtonDropDown(_ sender: AnyObject) {
        rightBarDropDown.show()
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropDowns()
    }
    
    // MARK: - Setup
    func setupDropDowns() {
        setupChooseArticleDropDown()
        setupAmountDropDown()
        setupRightBarDropDown()
    }
    
    func setupChooseArticleDropDown() {
        chooseArticleDropDown.dismissMode = .onTap
        chooseArticleDropDown.direction   = .bottom
        chooseArticleDropDown.anchorView  = chooseArticleButton

        chooseArticleDropDown.bottomOffset = CGPoint(x: 0, y: chooseArticleButton.bounds.height)
        
        chooseArticleDropDown.dataSource = [
            "iPhone SE | Black | 64G",
            "Samsung S7",
            "Huawei P8 Lite Smartphone 4G",
            "Asus Zenfone Max 4G",
            "Apple Watwh | Sport Edition"
        ]
        
        chooseArticleDropDown.selectionAction = { [unowned self] (index, item) in
            self.chooseArticleButton.setTitle(item, for: .normal)
        }
        
        //        dropDown.cancelAction = { [unowned self] in
        //            self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //            self.actionButton.setTitle("Canceled", forState: .Normal)
        //        }
        
        //        dropDown.selectRowAtIndex(3)
    }
    
    func setupAmountDropDown() {
        amountDropDown.cellHeight = 60
        amountDropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        amountDropDown.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        //        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        amountDropDown.cornerRadius = 10
        amountDropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        amountDropDown.shadowOpacity = 0.9
        amountDropDown.shadowRadius = 25
        amountDropDown.animationduration = 0.25
        amountDropDown.textColor = .darkGray
        //        appearance.textFont = UIFont(name: "Georgia", size: 14)
        
        amountDropDown.cellNib = UINib(nibName: "MyCell", bundle: nil)
        amountDropDown.customCellConfiguration = { (index: Index, item: String, cell: JMSDropDownCell) -> Void in
            guard let cell = cell as? MyCell else { return }
            
            cell.suffixLabel.text = "Suffix \(index)"
        }
        
        amountDropDown.dismissMode = .automatic
        amountDropDown.direction   = .top
        amountDropDown.anchorView  = amountButton
        
        amountDropDown.topOffset = CGPoint(x: 0, y: amountButton.bounds.height)
        
        amountDropDown.dataSource = [
            "10 €",
            "20 €",
            "30 €",
            "40 €",
            "50 €",
            "60 €",
            "70 €",
            "80 €",
            "90 €",
            "100 €",
            "110 €",
            "120 €"
        ]
        
        amountDropDown.selectionAction = { [unowned self] (index, item) in
            self.amountButton.setTitle(item, for: .normal)
        }
    }
    
    func setupRightBarDropDown() {
        rightBarDropDown.bottomOffset   = CGPoint.init(x: -50, y: 0)
        rightBarDropDown.dismissMode    = .manual
        rightBarDropDown.anchorView     = rightBarButton
        
        rightBarDropDown.dataSource = [
            "Menu 1",
            "Menu 2",
            "Menu 3",
            "Menu 4"
        ]
    }


}

