//
//  JMSDropDown.swift
//  JMSDropDown
//
//  Created by James.xiao on 2017/11/9.
//  Copyright © 2017年 James.xiao. All rights reserved.
//

import UIKit

public typealias Index = Int
public typealias Closure = () -> Void
public typealias SelectionClosure = (Index, String) -> Void
public typealias ConfigurationClosure = (Index, String) -> String
public typealias CellConfigurationClosure = (Index, String, JMSDropDownCell) -> Void
private typealias ComputeLayoutTuple = (x: CGFloat, y: CGFloat, width: CGFloat, offscreenHeight: CGFloat)
public typealias ContainerConstraint = (xConstraint: NSLayoutConstraint, yConstraint: NSLayoutConstraint, widthConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint)

@objc
public protocol JMSAnchorView: class {
    
    var plainView: UIView { get }
    
}

extension UIView: JMSAnchorView {
    
    public var plainView: UIView {
        return self
    }
    
}

extension UIBarButtonItem: JMSAnchorView {
    
    public var plainView: UIView {
        return value(forKey: "view") as! UIView
    }
    
}

public final class JMSDropDown: UIView {

    /// 下拉列表关闭模式
    public enum DismissMode {
        
        /// 触摸下拉列表以外的区域关闭
        case onTap
        
        /// 当要显示其他的下拉列表时才会被关闭
        case automatic
        
        /// 不能被用户关闭
        case manual
        
    }
    
    /// 从`anchorView`中显示的方向
    public enum Direction {
        
        /// 显示在`anchorView`上方或者下方，取决于空间是否足够
        case any
        
        /// 显示在`anchorView`视图上方或者当空间不够时不会显示
        case top
        
        /// 显示在`anchorView`视图下方或者当空间不够时不会显示
        case bottom
        
    }
    
    // MARK: - Properties
    public static weak var VisibleDropDown: JMSDropDown?

    // MARK: - UI
    fileprivate let dismissableView = UIView()
    fileprivate let tableViewContainer = UIView()
    fileprivate let tableView = UITableView()
    fileprivate var templateCell: JMSDropDownCell!
    
    /// 下拉的视图将显示在上面
    public weak var anchorView: JMSAnchorView? {
        didSet { setNeedsUpdateConstraints() }
    }
    
    /// 下拉列表显示的方向
    public var direction = Direction.any
    
    /// 当下拉列表显示在`anchorView`上面的时候，下拉列表相对于`anchorView`的偏移值
    public var topOffset: CGPoint = .zero {
        didSet { setNeedsUpdateConstraints() }
    }
    
    /// 当下拉列表显示在`anchorView`下面的时候，下拉列表相对于`anchorView`的偏移值
    public var bottomOffset: CGPoint = .zero {
        didSet { setNeedsUpdateConstraints() }
    }
    
    /// 下拉列表宽度
    public var width: CGFloat? {
        didSet { setNeedsUpdateConstraints() }
    }
    
    // MARK: Constraints
    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate var widthConstraint: NSLayoutConstraint!
    fileprivate var xConstraint: NSLayoutConstraint!
    fileprivate var yConstraint: NSLayoutConstraint!
    
    /**
     更新tableViewContainer约束
     */
    public var blkUpdTabContainerConstraint: ((_ constraint: ContainerConstraint)->())?
    
    /**
     更新下拉列表约束
     */
    public var blkUpdConstraint: ((_ dropDown: JMSDropDown)->())?
    
    // MARK: Appearance
    @objc public dynamic var cellHeight = Constants.UI.RowHeight {
        willSet { tableView.rowHeight = newValue }
        didSet { reloadAllComponents() }
    }
    
    @objc fileprivate dynamic var tableViewBackgroundColor = Constants.UI.BackgroundColor {
        willSet { tableView.backgroundColor = newValue }
    }
    
    public override var backgroundColor: UIColor? {
        get { return tableViewBackgroundColor }
        set { tableViewBackgroundColor = newValue! }
    }
    
    /**
     cell选中状态下的背景颜色
     
     改变selectionBackgroundColor属性会自动刷新下拉列表
     */
    @objc public dynamic var selectionBackgroundColor = Constants.UI.SelectionBackgroundColor {
        didSet {
            reloadAllComponents()
        }
    }
    
    /**
     cell之间分隔线条颜色
     
     改变separatorColor属性会自动刷新下拉列表
     */
    @objc public dynamic var separatorColor = Constants.UI.SeparatorColor {
        willSet { tableView.separatorColor = newValue }
        didSet { reloadAllComponents() }
    }
    
    /**
     下拉列表圆角
     
     改变cornerRadius属性会自动刷新下拉列表
     */
    @objc public dynamic var cornerRadius = Constants.UI.CornerRadius {
        willSet {
            tableViewContainer.layer.cornerRadius = newValue
            tableView.layer.cornerRadius = newValue
        }
        didSet { reloadAllComponents() }
    }
    
    /**
     下拉列表阴影颜色
     
     改变shadowColor属性会自动刷新下拉列表
     */
    @objc public dynamic var shadowColor = Constants.UI.Shadow.Color {
        willSet { tableViewContainer.layer.shadowColor = newValue.cgColor }
        didSet { reloadAllComponents() }
    }
    
    /**
     下拉列表阴影偏移值
     
     改变shadowOffset属性会自动刷新下拉列表
     */
    @objc public dynamic var shadowOffset = Constants.UI.Shadow.Offset {
        willSet { tableViewContainer.layer.shadowOffset = newValue }
        didSet { reloadAllComponents() }
    }
    
    /**
     下拉列表阴影透明度
     
     改变shadowOpacity属性会自动刷新下拉列表
     */
    @objc public dynamic var shadowOpacity = Constants.UI.Shadow.Opacity {
        willSet { tableViewContainer.layer.shadowOpacity = newValue }
        didSet { reloadAllComponents() }
    }
    
    /**
     下拉列表阴影半径
     
     改变shadowOpacity属性会自动刷新下拉列表
     */
    @objc public dynamic var shadowRadius = Constants.UI.Shadow.Radius {
        willSet { tableViewContainer.layer.shadowRadius = newValue }
        didSet { reloadAllComponents() }
    }
    
    /**
     显示/隐藏动画的时长
     */
    @objc public dynamic var animationduration = Constants.Animation.Duration
    
    /**
     动画显示类型，全局改变
     */
    public static var animationEntranceOptions = Constants.Animation.EntranceOptions
    
    /**
     动画隐藏类型，全局改变
     */
    public static var animationExitOptions = Constants.Animation.ExitOptions
    
    /**
     动画显示类型，改变当前对象
     */
    public var animationEntranceOptions: UIViewAnimationOptions = JMSDropDown.animationEntranceOptions
    
    /**
     动画隐藏类型，改变当前对象
     */
    public var animationExitOptions: UIViewAnimationOptions = JMSDropDown.animationExitOptions
    
    /**
     当下拉列表出现时，tableView向下缩放
     */
    public var downScaleTransform = Constants.Animation.DownScaleTransform {
        willSet { tableViewContainer.transform = newValue }
    }
    
    /**
     下拉列表cell中的文本颜色
     
     改变textColor属性会自动刷新下拉列表
     */
    @objc public dynamic var textColor = Constants.UI.TextColor {
        didSet { reloadAllComponents() }
    }
    
    /**
     下拉列表cell中的文本字体大小
     
     改变textColor属性会自动刷新下拉列表
     */
    @objc public dynamic var textFont = Constants.UI.TextFont {
        didSet { reloadAllComponents() }
    }
    
    /**
     下拉列表cell对应的nib
     
     改变cellNib属性会自动刷新下拉列表
     */
    public var cellNib = UINib(nibName: "JMSDropDownCell", bundle: Bundle(for: JMSDropDownCell.self)) {
        didSet {
            tableView.register(cellNib, forCellReuseIdentifier: Constants.ReusableIdentifier.DropDownCell)
            templateCell = nil
            reloadAllComponents()
        }
    }
    
    // MARK: Content
    
    /**
     下拉列表数据源
     
     改变dataSource属性会自动刷新下拉列表
     */
    public var dataSource = [String]() {
        didSet {
            deselectRow(at: selectedRowIndex)
            reloadAllComponents()
        }
    }
    
    /**
     下拉列表本地化数据源（国际化）
     
     改变localizationKeysDataSource属性会自动刷新下拉列表
     */
    public var localizationKeysDataSource = [String]() {
        didSet {
            dataSource = localizationKeysDataSource.map { NSLocalizedString($0, comment: "") }
        }
    }
    
    /// 选中行下标
    fileprivate var selectedRowIndex: Index?
    
    /**
     处理cell中的文本
     
     默认的文本值是`dataSource`中的值
     改变cellConfiguration属性会自动刷新下拉列表
     */
    public var cellConfiguration: ConfigurationClosure? {
        didSet { reloadAllComponents() }
    }
    
    /**
     自定义cell配置`customCellConfiguration`
     
     改变customCellConfiguration属性会自动刷新下拉列表
     */
    public var customCellConfiguration: CellConfigurationClosure? {
        didSet { reloadAllComponents() }
    }
    
    /// 选中cell触发动作
    public var selectionAction: SelectionClosure?
    
    /// 下拉列表将要显示触发动作
    public var willShowAction: Closure?
    
    /// 下拉列表取消或隐藏触发动作
    public var cancelAction: Closure?
    
    /// 下拉列表关闭模式，默认是`OnTap`
    public var dismissMode = DismissMode.onTap {
        willSet {
            if newValue == .onTap {
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissableViewTapped))
                dismissableView.addGestureRecognizer(gestureRecognizer)
            } else if let gestureRecognizer = dismissableView.gestureRecognizers?.first {
                dismissableView.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }
    
    fileprivate var minHeight: CGFloat {
        return tableView.rowHeight
    }
    
    fileprivate var didSetupConstraints = false
    
    // MARK: - Init's
    deinit {
        stopListeningToNotifications()
    }
    
    /**
     创建一个新的实例
     
     在调用`show()`方法之前不要忘记设置`dataSource`,
     `anchorView`和`selectionAction`属性
     */
    public convenience init() {
        self.init(frame: .zero)
    }
    
    /**
     创建一个新的实例
     
     - parameter anchorView:        下拉的视图将显示在上面
     - parameter selectionAction:   选中cell触发动作
     - parameter dataSource:        数据源
     - parameter topOffset:         当下拉列表显示在`anchorView`上面的时候，下拉列表相对于`anchorView`的偏移值
     - parameter bottomOffset:      当下拉列表显示在`anchorView`下面的时候，下拉列表相对于`anchorView`的偏移值
     - parameter cellConfiguration: 处理cell中的文本
     - parameter cancelAction:      下拉列表取消或隐藏触发动作
     
     - returns: 一个下拉列表实例
     */
    public convenience init(anchorView: JMSAnchorView, selectionAction: SelectionClosure? = nil, dataSource: [String] = [], topOffset: CGPoint? = nil, bottomOffset: CGPoint? = nil, cellConfiguration: ConfigurationClosure? = nil, cancelAction: Closure? = nil) {
        self.init(frame: .zero)
        
        self.anchorView = anchorView
        self.selectionAction = selectionAction
        self.dataSource = dataSource
        self.topOffset = topOffset ?? .zero
        self.bottomOffset = bottomOffset ?? .zero
        self.cellConfiguration = cellConfiguration
        self.cancelAction = cancelAction
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
}

// MARK: - Setup
private extension JMSDropDown {
    
    func setup() {
        tableView.register(cellNib, forCellReuseIdentifier: Constants.ReusableIdentifier.DropDownCell)
        
        DispatchQueue.main.async {
            //HACK: If not done in dispatch_async on main queue `setupUI` will have no effect
            self.updateConstraintsIfNeeded()
            self.setupUI()
        }
        
        dismissMode = .onTap
        
        tableView.delegate = self
        tableView.dataSource = self
        
        startListeningToKeyboard()
        
        accessibilityIdentifier = "drop_down"
    }
    
    func setupUI() {
        super.backgroundColor = .clear
        
        tableViewContainer.layer.masksToBounds  = false
        tableViewContainer.layer.cornerRadius   = cornerRadius
        tableViewContainer.layer.shadowColor    = shadowColor.cgColor
        tableViewContainer.layer.shadowOffset   = shadowOffset
        tableViewContainer.layer.shadowOpacity  = shadowOpacity
        tableViewContainer.layer.shadowRadius   = shadowRadius
        
        tableView.rowHeight                     = cellHeight
        tableView.backgroundColor               = tableViewBackgroundColor
        tableView.separatorColor                = separatorColor
        tableView.layer.cornerRadius            = cornerRadius
        tableView.layer.masksToBounds           = true
        
        setHiddentState()
        isHidden = true
    }
    
}

// MARK: - UI
extension JMSDropDown {
    
    public override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        
        didSetupConstraints = true
        
        let layout = computeLayout()
        
        if !layout.canBeDisplayed {
            super.updateConstraints()
            hide()
            
            return
        }
        
        xConstraint.constant = layout.x
        yConstraint.constant = layout.y
        widthConstraint.constant = layout.width
        heightConstraint.constant = layout.visibleHeight
        
        self.blkUpdTabContainerConstraint?((xConstraint: xConstraint, yConstraint: yConstraint, widthConstraint: widthConstraint, heightConstraint: heightConstraint))

        tableView.isScrollEnabled = layout.offscreenHeight > 0
        
        DispatchQueue.main.async { [unowned self] in
            self.tableView.flashScrollIndicators()
        }
        
        super.updateConstraints()
    }
    
    fileprivate func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Dismissable view
        addSubview(dismissableView)
        dismissableView.translatesAutoresizingMaskIntoConstraints = false
        
        addUniversalConstraints(format: "|[dismissableView]|", views: ["dismissableView": dismissableView])
        
        
        // Table view container
        addSubview(tableViewContainer)
        tableViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        xConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 0)
        addConstraint(xConstraint)
        
        yConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0)
        addConstraint(yConstraint)
        
        widthConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 0)
        tableViewContainer.addConstraint(widthConstraint)
        
        heightConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 0)
        tableViewContainer.addConstraint(heightConstraint)
        
        // Table view
        tableViewContainer.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewContainer.addUniversalConstraints(format: "|[tableView]|", views: ["tableView": tableView])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        setNeedsUpdateConstraints()
        
        let shadowPath = UIBezierPath(roundedRect: tableViewContainer.bounds, cornerRadius: Constants.UI.CornerRadius)
        tableViewContainer.layer.shadowPath = shadowPath.cgPath
    }
    
    fileprivate func computeLayout() -> (x: CGFloat, y: CGFloat, width: CGFloat, offscreenHeight: CGFloat, visibleHeight: CGFloat, canBeDisplayed: Bool, Direction: Direction) {
        var layout: ComputeLayoutTuple = (0, 0, 0, 0)
        var direction = self.direction
        
        guard let window = UIWindow.visibleWindow() else { return (0, 0, 0, 0, 0, false, direction) }
        
        barButtonItemCondition: if let anchorView = anchorView as? UIBarButtonItem {
            let isRightBarButtonItem = anchorView.plainView.frame.minX > window.frame.midX
            
            guard isRightBarButtonItem else { break barButtonItemCondition }
            
            let width = self.width ?? fittingWidth()
            let anchorViewWidth = anchorView.plainView.frame.width
            let x = -(width - anchorViewWidth)
            
            bottomOffset = CGPoint(x: x, y: 0)
        }
        
        if anchorView == nil {
            layout = computeLayoutBottomDisplay(window: window)
            direction = .any
        } else {
            switch direction {
            case .any:
                layout = computeLayoutBottomDisplay(window: window)
                direction = .bottom
                
                if layout.offscreenHeight > 0 {
                    let topLayout = computeLayoutForTopDisplay(window: window)
                    
                    if topLayout.offscreenHeight < layout.offscreenHeight {
                        layout = topLayout
                        direction = .top
                    }
                }
            case .bottom:
                layout = computeLayoutBottomDisplay(window: window)
                direction = .bottom
            case .top:
                layout = computeLayoutForTopDisplay(window: window)
                direction = .top
            }
        }
        
        constraintWidthToFittingSizeIfNecessary(layout: &layout)
        constraintWidthToBoundsIfNecessary(layout: &layout, in: window)
        
        let visibleHeight = tableHeight - layout.offscreenHeight
        let canBeDisplayed = visibleHeight >= minHeight
        
        return (layout.x, layout.y, layout.width, layout.offscreenHeight, visibleHeight, canBeDisplayed, direction)
    }
    
    fileprivate func computeLayoutBottomDisplay(window: UIWindow) -> ComputeLayoutTuple {
        var offscreenHeight: CGFloat = 0
        
        let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - bottomOffset.x
        
        let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? window.frame.midX - (width / 2)
        let anchorViewY = anchorView?.plainView.windowFrame?.minY ?? window.frame.midY - (tableHeight / 2)
        
        let x = anchorViewX + bottomOffset.x
        let y = anchorViewY + bottomOffset.y
        
        let maxY = y + tableHeight
        let windowMaxY = window.bounds.maxY - Constants.UI.HeightPadding
        
        let keyboardListener = KeyboardListener.sharedInstance
        let keyboardMinY = keyboardListener.keyboardFrame.minY - Constants.UI.HeightPadding
        
        if keyboardListener.isVisible && maxY > keyboardMinY {
            offscreenHeight = abs(maxY - keyboardMinY)
        } else if maxY > windowMaxY {
            offscreenHeight = abs(maxY - windowMaxY)
        }
        
        return (x, y, width, offscreenHeight)
    }
    
    fileprivate func computeLayoutForTopDisplay(window: UIWindow) -> ComputeLayoutTuple {
        var offscreenHeight: CGFloat = 0
        
        let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? 0
        let anchorViewMaxY = anchorView?.plainView.windowFrame?.maxY ?? 0
        
        let x = anchorViewX + topOffset.x
        var y = (anchorViewMaxY + topOffset.y) - tableHeight
        
        let windowY = window.bounds.minY + Constants.UI.HeightPadding
        
        if y < windowY {
            offscreenHeight = abs(y - windowY)
            y = windowY
        }
        
        let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - topOffset.x
        
        return (x, y, width, offscreenHeight)
    }
    
    fileprivate func fittingWidth() -> CGFloat {
        if templateCell == nil {
            templateCell = cellNib.instantiate(withOwner: nil, options: nil)[0] as! JMSDropDownCell
        }
        
        var maxWidth: CGFloat = 0
        
        for index in 0..<dataSource.count {
            configureCell(templateCell, at: index)
            templateCell.bounds.size.height = cellHeight
            let width = templateCell.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width
            
            if width > maxWidth {
                maxWidth = width
            }
        }
        
        return maxWidth
    }
    
    fileprivate func constraintWidthToBoundsIfNecessary(layout: inout ComputeLayoutTuple, in window: UIWindow) {
        let windowMaxX = window.bounds.maxX
        let maxX = layout.x + layout.width
        
        if maxX > windowMaxX {
            let delta = maxX - windowMaxX
            let newOrigin = layout.x - delta
            
            if newOrigin > 0 {
                layout.x = newOrigin
            } else {
                layout.x = 0
                layout.width += newOrigin
            }
        }
    }
    
    fileprivate func constraintWidthToFittingSizeIfNecessary(layout: inout ComputeLayoutTuple) {
        guard width == nil else { return }
        
        if layout.width < fittingWidth() {
            layout.width = fittingWidth()
        }
    }
    
}

// MARK: - Actions
extension JMSDropDown {
    
    /// 显示下拉列表，供OC调用
    ///
    /// - Returns NSDictionary
    @objc(show)
    public func objc_show() -> NSDictionary {
        let (canBeDisplayed, offScreenHeight) = show()
        
        var info = [AnyHashable: Any]()
        info["canBeDisplayed"] = canBeDisplayed
        if let offScreenHeight = offScreenHeight {
            info["offScreenHeight"] = offScreenHeight
        }
        
        return NSDictionary(dictionary: info)
    }
    
    /// 显示下拉列表
    ///
    /// - Returns 元组
    @discardableResult
    public func show() -> (canBeDisplayed: Bool, offscreenHeight: CGFloat?) {
        if self == JMSDropDown.VisibleDropDown {
            return (true, 0)
        }
        
        if let visibleDropDown = JMSDropDown.VisibleDropDown {
            visibleDropDown.cancel()
        }
        
        willShowAction?()
        
        JMSDropDown.VisibleDropDown = self
        
        setNeedsUpdateConstraints()
        
        let visibleWindow = UIWindow.visibleWindow()
        visibleWindow?.addSubview(self)
        visibleWindow?.bringSubview(toFront: self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if self.blkUpdConstraint != nil {
            self.blkUpdConstraint?(self)
        }else {
            visibleWindow?.addUniversalConstraints(format: "|[dropDown]|", views: ["dropDown": self])
        }
        
        let layout = computeLayout()
        
        if !layout.canBeDisplayed {
            hide()
            return (layout.canBeDisplayed, layout.offscreenHeight)
        }
        
        isHidden = false
        tableViewContainer.transform = downScaleTransform
        
        UIView.animate(
            withDuration: animationduration,
            delay: 0,
            options: animationEntranceOptions,
            animations: { [unowned self] in
                self.setShowedState()
            },
            completion: nil)
        
        selectRow(at: selectedRowIndex)
        
        return (layout.canBeDisplayed, layout.offscreenHeight)
    }
    
    /// 隐藏下拉列表
    ///
    /// - Returns Void
    public func hide() {
        if self == JMSDropDown.VisibleDropDown {
            JMSDropDown.VisibleDropDown = nil
        }
        
        if isHidden {
            return
        }
        
        UIView.animate(
            withDuration: animationduration,
            delay: 0,
            options: animationExitOptions,
            animations: { [unowned self] in
                self.setHiddentState()
            },
            completion: { [unowned self] finished in
                self.isHidden = true
                self.removeFromSuperview()
        })
    }
    
    fileprivate func cancel() {
        hide()
        cancelAction?()
    }
    
    fileprivate func setHiddentState() {
        alpha = 0
    }
    
    fileprivate func setShowedState() {
        alpha = 1
        tableViewContainer.transform = CGAffineTransform.identity
    }
    
}

// MARK: - UITableView
extension JMSDropDown {
    
    /// 刷新所有组件
    ///
    /// - Returns Void
    public func reloadAllComponents() {
        tableView.reloadData()
        setNeedsUpdateConstraints()
    }
    
    /// 选中某一行
    ///
    /// - Parameters:
    ///     - parameter index: 下标
    /// - Returns Void
    public func selectRow(at index: Index?) {
        if let index = index {
            tableView.selectRow(
                at: IndexPath(row: index, section: 0),
                animated: false,
                scrollPosition: .middle)
        } else {
            deselectRow(at: selectedRowIndex)
        }
        
        selectedRowIndex = index
    }
    
    public func deselectRow(at index: Index?) {
        selectedRowIndex = nil
        
        guard let index = index
            , index >= 0
            else { return }
        
        tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
    }
    
    /// 返回选中下标
    public var indexForSelectedRow: Index? {
        return (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
    }
    
    /// 返回选中项
    public var selectedItem: String? {
        guard let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row else { return nil }
        
        return dataSource[row]
    }
    
    /// 返回显示所有cell所需要的table高度
    fileprivate var tableHeight: CGFloat {
        return tableView.rowHeight * CGFloat(dataSource.count)
    }
    
}

// MARK: - UITableViewDataSource - UITableViewDelegate
extension JMSDropDown: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReusableIdentifier.DropDownCell, for: indexPath) as! JMSDropDownCell
        let index = (indexPath as NSIndexPath).row
        
        configureCell(cell, at: index)
        
        return cell
    }
    
    fileprivate func configureCell(_ cell: JMSDropDownCell, at index: Int) {
        if index >= 0 && index < localizationKeysDataSource.count {
            cell.accessibilityIdentifier = localizationKeysDataSource[index]
        }
        
        cell.optionLabel.textColor = textColor
        cell.optionLabel.font = textFont
        cell.selectedBackgroundColor = selectionBackgroundColor
        
        if let cellConfiguration = cellConfiguration {
            cell.optionLabel.text = cellConfiguration(index, dataSource[index])
        } else {
            cell.optionLabel.text = dataSource[index]
        }
        
        customCellConfiguration?(index, dataSource[index], cell)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.isSelected = (indexPath as NSIndexPath).row == selectedRowIndex
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = (indexPath as NSIndexPath).row
        selectionAction?(selectedRowIndex!, dataSource[selectedRowIndex!])
        
        if let _ = anchorView as? UIBarButtonItem {
            deselectRow(at: selectedRowIndex)
        }
        
        hide()
    }
    
}

// MARK: - Auto dismiss
extension JMSDropDown {
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if dismissMode == .automatic && view === dismissableView {
            cancel()
            return nil
        } else {
            return view
        }
    }
    
    @objc
    fileprivate func dismissableViewTapped() {
        cancel()
    }
    
}

// MARK: - Keyboard events
extension JMSDropDown {
    
    public static func startListeningToKeyboard() {
        KeyboardListener.sharedInstance.startListeningToKeyboard()
    }
    
    fileprivate func startListeningToKeyboard() {
        KeyboardListener.sharedInstance.startListeningToKeyboard()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardUpdate),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardUpdate),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    fileprivate func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    fileprivate func keyboardUpdate() {
        self.setNeedsUpdateConstraints()
    }
    
}
