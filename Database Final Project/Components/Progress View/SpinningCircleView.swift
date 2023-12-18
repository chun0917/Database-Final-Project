//
//  SpinningCircleView.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/20.
//

import UIKit

class SpinningCircleView: UIView {
    
    let spinningCircle = CAShapeLayer()
    
    /// 轉圈的顏色
    var circleColor: UIColor = .systemTeal {
        didSet {
            self.spinningCircle.strokeColor = circleColor.cgColor
        }
    }
    
    /// 轉圈的寬度
    var circleLineWidth: CGFloat = 15 {
        didSet {
            self.spinningCircle.lineWidth = circleLineWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    init(frame: CGRect, color: UIColor, lineWidth: CGFloat) {
        super.init(frame: frame)
        self.circleColor = color
        self.circleLineWidth = lineWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        
        let rect = self.bounds
        let circularPath = UIBezierPath(ovalIn: rect)
        
        spinningCircle.path = circularPath.cgPath
        spinningCircle.fillColor = UIColor.clear.cgColor // 中間圓的顏色，設 UIColor.clear.cgColor 就看不到了
        spinningCircle.strokeColor = circleColor.cgColor // 外圈圓的顏色，根據 circleColor 來給值
        spinningCircle.lineWidth = circleLineWidth // 外圈圓的寬度，根據 circleLineWidth 來給值
        spinningCircle.strokeEnd = 0.25
        spinningCircle.lineCap = .round
        
        self.layer.addSublayer(spinningCircle)
    }
    
    /// 開始轉圈動畫
    func startAnimation() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, delay: 0, options: .curveLinear) {
                self.transform = CGAffineTransform(rotationAngle: .pi)
            } completion: { completed in
                UIView.animate(withDuration: 1, delay: 0, options: .curveLinear) {
                    self.transform = CGAffineTransform(rotationAngle: 0)
                } completion: { completed in
                    self.startAnimation()
                }
            }
        }
    }
    
    /// 停止轉圈動畫
    /// - Parameters:
    ///   - finish: 動畫停止後要做的事情
    func stopAnimation(finish: @escaping() -> Void) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0) {
                self.transform = CGAffineTransform(rotationAngle: .infinity)
            } completion: { completed in
                print("移除動畫完成")
                self.removeFromSuperview()
                self.layer.speed = 0
                finish()
            }
        }
    }
}

// MARK: - 參考來源

/*
 // Custom Activity Indicator
 https://youtu.be/22pF5za8MOw
 
 // UIView.animate 將動畫停止
 https://stackoverflow.com/questions/13991465/stop-an-auto-reverse-infinite-repeat-uiview-animation-with-a-bool-completion
 
 */
