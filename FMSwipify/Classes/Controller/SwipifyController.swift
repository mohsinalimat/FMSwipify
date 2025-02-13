//
//  SwipifyController.swift
//  FMSwipify
//
//  Created by Franck-Stephane Ndame Mpouli on 12/09/2019.
//

import UIKit

public enum CellSource {
    case nib, code
}

public enum SelectorType {
    case bar, bubble
}

public struct Config {
    
    public var sectionsTitle: [String]
    public var sectionTitleFont: UIFont
    public var sectionsIcon: [UIImage]
    public var sectionIconSize: CGSize
    
    public var sectionsBackgroundColor: UIColor
    public var sectionsSelectedColor: UIColor
    public var sectionsUnselectedColor: UIColor
    public var sectionsSelectorColor: UIColor
    public var sectionSelectorType: SelectorType
    
    public var placeholderImage: UIImage
    public var placeholderAttributes: NSAttributedString
    
    public var innerColletionBackground: UIColor
    public var innerMinInteritemSpacing: CGFloat
    public var innerMinLineSpacing: CGFloat
    
    @available(iOS 8.2, *)
    public init(
        sectionsTitle: [String] = [],
                sectionTitleFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular) ,
                sectionsIcon: [UIImage] = [],
                sectionIconSize: CGSize = .init(width: 30, height: 30),
                
                sectionsBackgroundColor: UIColor = .white,
                sectionsSelectedColor: UIColor = .black,
                sectionsUnselectedColor: UIColor = .lightGray,
                sectionsSelectorColor: UIColor = .black,
                
                sectionSelectorType: SelectorType = .bar,
                placeholderImage: UIImage = UIImage(),
                placeholderAttributes: NSAttributedString = NSAttributedString(),
                
                innerColletionBackground: UIColor = UIColor.green,
                innerMinInteritemSpacing: CGFloat = 0,
                innerMinLineSpacing: CGFloat = 0
    )
    {
        
        self.sectionsTitle = sectionsTitle
        self.sectionTitleFont = sectionTitleFont
        self.sectionsIcon = sectionsIcon
        self.sectionIconSize = sectionIconSize
        
        self.sectionsBackgroundColor = sectionsBackgroundColor
        self.sectionsSelectedColor = sectionsSelectedColor
        self.sectionsUnselectedColor = sectionsUnselectedColor
        self.sectionsSelectorColor = sectionsSelectorColor
        self.sectionSelectorType = sectionSelectorType
        
        self.placeholderImage = placeholderImage
        self.placeholderAttributes = placeholderAttributes
        
        self.innerColletionBackground = innerColletionBackground
        self.innerMinInteritemSpacing = innerMinInteritemSpacing
        self.innerMinLineSpacing = innerMinLineSpacing
        
    }
}



private let reuseidentifier = "contentCell"

@available(iOS 8.2, *)
open class SwipifyController<T: SwipifyBaseCell<Y>, Y>: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SectionBarDelegate, SwipifyCellDelegate {
    
    lazy open var sectionBar: SectionBar = {
        let sb = SectionBar()
        sb.delegate = self
        return sb
    }()
    
    open var cellSource: CellSource { return .nib }
    open var cellSize: CGSize { return .zero }
    
    public let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        return cv
    }()
    

    open var data: [[Y]] {return [[Y]]()}
    
    // MARK: - TODO
    private var config = Config()
    
    public func setConfig(_ config: Config) {
        self.config = config
        pathConfig()
    }
    
    open var sectionDefaultTopConstraint: NSLayoutConstraint?
    
    

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    private func pathConfig() {
        view.addSubview(sectionBar)
        view.addSubview(collectionView)
        sectionBar.titles = config.sectionsTitle
        sectionBar.titleFont = config.sectionTitleFont
        sectionBar.icons = config.sectionsIcon
        sectionBar.iconSize = config.sectionIconSize
        sectionBar.bgColor = config.sectionsBackgroundColor
        sectionBar.selectedColor = config.sectionsSelectedColor
        sectionBar.unselectedColor = config.sectionsUnselectedColor
        sectionBar.selectorColor = config.sectionsSelectorColor
        sectionBar.bar.backgroundColor = config.sectionsSelectorColor
        sectionBar.dataCount = data.count
        sectionBar.setupSelectedIndex()
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SwipifyCell<Y, T>.self, forCellWithReuseIdentifier: reuseidentifier)
        
        if #available(iOS 11.0, *) {
            // iPhone X+
            sectionBar.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 50))
            sectionDefaultTopConstraint = sectionBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
            sectionDefaultTopConstraint?.isActive = true
        } else {
            // no Notch
            if #available(iOS 9.0, *) {
                sectionBar.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 50))
                 sectionDefaultTopConstraint = sectionBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
                 sectionDefaultTopConstraint?.isActive = true
            }
        }
        if #available(iOS 9.0, *) {
            collectionView.anchor(superView: view, top: sectionBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        }
        
        sectionBar.selectorType = config.sectionSelectorType
    }
    
    
    
    //MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseidentifier, for: indexPath) as!
            SwipifyCell<Y, T>
        cell.items = data[indexPath.item]
        cell.cellSource = cellSource
        cell.cellSize = cellSize
        cell.section = indexPath.item
        cell.delegate = self
        cell.placeholderImage = config.placeholderImage
        cell.placeholderAttributes = config.placeholderAttributes
        cell.innerCollectionView.backgroundColor = config.innerColletionBackground
        cell.innerMinInteritemSpacing = config.innerMinInteritemSpacing
        cell.innerMinLineSpacing = config.innerMinLineSpacing

        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    //MARK: - SectionBarDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    // Delegate to scroll when user scroll's the menuBar
    open func didSelectMenuOptionAt(indexPath: IndexPath) {
        scrollTo(menuIndex: indexPath.item)
    }
    
    // Scroll to the top of the collection view when you swipe the menuBar
    private func scrollTo(menuIndex index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        switch config.sectionsTitle.count {
        case 0: sectionBar.iconScrollTo(indexPath)
        case 1...4: sectionBar.scrollTo(indexPath)
        default: sectionBar.dynamicScrollTo(indexPath)
        }
        
        sectionBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        if #available(iOS 10.0, *) {
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()
        }
        
//        SlideController is a simple and flexible UI component fully written in Swift. Built using power of generic types, it is a nice alternative to UIPageViewController.
        
        
        
    }
    
    //MARK:- SwiftifyCell Delegate
    open func didSelectItemAt(section: Int, item: Int) {
        // Your implementation
    }
    
}


