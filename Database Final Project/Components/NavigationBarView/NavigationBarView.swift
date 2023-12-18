//
//  NavigationBarView.swift
//  Database Final Project
//  Created by 呂淳昇 on 2023/2/24.
//

import UIKit

@MainActor class NavigationBarView: UIView {

    // MARK: - IBOutlet
    
    /// 返回鍵 (只做 ImageView 功能)
    @IBOutlet weak var ivBack: UIImageView!
    /// 返回鍵 (只做 Button 功能)
    @IBOutlet weak var btnBack: UIButton!
    /// 返回鍵標題 (只做 Label 功能)
    @IBOutlet weak var lbBack: UILabel!
    @IBOutlet weak var lbBackLeadingConstraint: NSLayoutConstraint!
    /// 通常為 `搜尋密碼／記事`
    @IBOutlet weak var btnRight1: UIButton!
    /// 通常為 `新增密碼／記事`
    @IBOutlet weak var btnRight2: UIButton!
    
    // MARK: - Variables
    
    weak var delegate: NavigationBarViewDelegate?
        
    enum DisplayMode {
        
        /// 初始化流程、無右側按鈕畫面
        case noRightButtons
        
        /// 右側只有一個按鈕
        case onlyRight1
        
        /// 左右各一個按鈕
        case leftRight
        
        /// 主畫面－密碼
        case password
        
        /// 主畫面－記事
        case notes
    }
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        addXibView()
    }
    
    // view 在設計時想要看到畫面要用這個
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        addXibView()
    }
    
    // MARK: - UI Settings
    
    func setInit(backButtonIsHidden: Bool,
                 backButtonImage: UIImage?,
                 backButtonTitle: String,
                 displayMode: DisplayMode,
                 btnIcon1: SFSymbols = .magnifyingglass,
                 btnIcon2: SFSymbols = .plus) {
        if backButtonIsHidden == true {
            lbBackLeadingConstraint.constant = 10
        }
        
        setupBackButtonImage(isHidden: backButtonIsHidden, image: backButtonImage)
        setupBackButton()
        setupBackButtonLabel(title: backButtonTitle)
        setupRightButton(mode: displayMode,
                         btnIcon1: btnIcon1,
                         btnIcon2: btnIcon2)
    }
    
    private func setupBackButtonImage(isHidden: Bool, image: UIImage?) {
        ivBack.isHidden = isHidden
        ivBack.image = image
        ivBack.contentMode = .center
        ivBack.preferredSymbolConfiguration = .some(.init(weight: .medium))
    }
    
    private func setupBackButton() {
        btnBack.setTitle(nil, for: .normal)
    }
    
    private func setupBackButtonLabel(title: String) {
        lbBack.text = title
        lbBack.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    private func setupRightButton(mode: DisplayMode,
                                  btnIcon1: SFSymbols = .magnifyingglass,
                                  btnIcon2: SFSymbols = .plus) {
        
        // 搜尋密碼／記事
        btnRight1.setTitle(nil, for: .normal)
        btnRight1.tag = 0
        
        // 新增密碼／記事
        btnRight2.setTitle(nil, for: .normal)
        btnRight2.tag = 1
        
        switch mode {
        case .noRightButtons:
            btnRight1.isHidden = true
            btnRight2.isHidden = true
        case .password:
            btnRight1.setImage(UIImage(icon: btnIcon1), for: .normal)
            btnRight2.setImage(UIImage(icon: btnIcon2), for: .normal)
        case .notes:
            btnRight1.setImage(UIImage(icon: btnIcon1), for: .normal)
            btnRight2.setImage(UIImage(icon: btnIcon2), for: .normal)
        case .onlyRight1:
            btnRight1.isHidden = true
            btnRight2.setImage(UIImage(icon: btnIcon2), for: .normal)
        case .leftRight:
            btnRight1.isHidden = true
            btnRight2.setImage(UIImage(icon: btnIcon2), for: .normal)
        }
    }
    
    // MARK: - Function
    

    
    // MARK: - IBAction
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        delegate?.btnBackClicked()
    }
    
    @IBAction func btnRightClicked(_ sender: UIButton) {
        delegate?.btnRightClicked(index: sender.tag)
    }
}

// MARK: - Extensions

fileprivate extension NavigationBarView {
    // 加入畫面
    func addXibView() {
        guard let loadView = Bundle(for: NavigationBarView.self)
            .loadNibNamed("NavigationBarView", owner: self)?
            .first as? UIView else {
            return
        }
        addSubview(loadView)
        loadView.frame = bounds
    }
}

// MARK: - Protocol

@MainActor protocol NavigationBarViewDelegate: NSObjectProtocol {
    
    func btnBackClicked()
    
    func btnRightClicked(index: Int)
}
