//
//  ThumbsUpView.swift
//  secondAnimation
//
//  Created by 创客工场 on 2019/1/29.
//  Copyright © 2019 makeblock. All rights reserved.
//

import UIKit
import SnapKit
class ThumbsUpView: UIView {
    let backGroundView = UIView()
    let centerImage = UIImageView()
    let moveLabel = UILabel()
    let moveButton = UIButton()
    private var pointArray = [[CGPoint]]()
    private let startTag = 1
    private let backGroundViewScale: CGFloat = 280
    private let springViewScale: CGFloat = 22
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = UIColor.clear
    }
    override func layoutSubviews() {
        commonLayout()
    }
    override func draw(_ rect: CGRect) {
        commonSetUp()
        commonInit()
    }
    public func startAnimation() {
        startCenterAnimation()
        startBallsAnimtaion()
        mainViewLargen()
        moveButton.isHidden = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func commonSetUp() {
        backGroundView.backgroundColor = UIColor.white
        backGroundView.isHidden = true
        addSubview(backGroundView)
        backGroundView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.02)
            make.height.equalTo(backGroundView.snp.width).dividedBy(1.53)
        }
        centerImage.image = UIImage(named: "Group 8")
        centerImage.isHidden = true
        addSubview(centerImage)
        centerImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.snp.centerY).multipliedBy(1.05)
            make.width.equalToSuperview().multipliedBy(0.01)
            make.height.equalTo(centerImage.snp.width)
        }
        moveLabel.text = "恭喜你！搭建成功!"
        moveLabel.textAlignment = NSTextAlignment.center
        moveLabel.font = UIFont.systemFont(ofSize: frame.size.height * 0.08)
        moveLabel.isHidden = true
        addSubview(moveLabel)
        moveLabel.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(snp.centerY).multipliedBy(1.62)
            make.width.equalTo(snp.height).multipliedBy(0.8)
            make.height.equalTo(moveLabel.snp.width).dividedBy(7)
        }
        moveButton.isHidden = true
        moveButton.backgroundColor = UIColor(hex: "1DADFF")
        moveButton.setTitle("动起来", for: .normal)
        moveButton.titleLabel?.font = UIFont.systemFont(ofSize: frame.size.height * 0.1)
        addSubview(moveButton)
        moveButton.snp.makeConstraints { (make) in
             make.centerX.equalToSuperview()
             make.centerY.equalTo(snp.centerY).multipliedBy(1.78)
             make.width.equalTo(snp.height).multipliedBy(0.55)
             make.height.equalTo(moveButton.snp.width).dividedBy(3.1)
        }
        layoutIfNeeded()
        moveButton.layer.cornerRadius  = moveButton.frame.height * 0.5
    }
    private func mainViewLargen() {
        UIView.animate(withDuration: 0.2, animations: animScale)
    }
    private func animScale() {
        backGroundView.isHidden = false
        centerImage.isHidden = false
        backGroundView.transform = CGAffineTransform(scaleX: backGroundViewScale, y: backGroundViewScale)
        centerImage.transform = CGAffineTransform(scaleX: springViewScale, y: springViewScale)
        moveLabel.isHidden = false
        for index in 0..<BallAnimationInfos.balls.count {
            self.viewWithTag(index + 1)?.isHidden = false
        }
    }
    private func commonLayout() {
        moveButton.layer.cornerRadius = moveButton.frame.height * 0.5
        layer.cornerRadius = 14
        layer.masksToBounds = true
        layoutBalls()
    }
    private func commonInit() {
        for index in 0..<BallAnimationInfos.balls.count {
            let oneBall = UIView()
            oneBall.tag = index + 1
            oneBall.isHidden = true
            self.addSubview(oneBall)
        }
    }
    // 系统自动调用layoutSubviews，此时能准确获取父控件frame 给小球布局
    private func layoutBalls() {
        for index in 0..<BallAnimationInfos.balls.count {
            let ballInfo = BallAnimationInfos.balls[index]
            let ballFrame = CGRect(x: frame.width * ballInfo.rect.0,
                                   y: frame.height * ballInfo.rect.1,
                                   width: frame.width * ballInfo.rect.2,
                                   height: frame.width * ballInfo.rect.3)
            let tag = index + 1
            viewWithTag(tag)?.frame = ballFrame
            viewWithTag(tag)?.layer.cornerRadius = ballFrame.size.width * 0.5
            viewWithTag(tag)?.layer.masksToBounds = true
            viewWithTag(tag)?.backgroundColor = UIColor(hex: ballInfo.hexStr)
        }
    }
    private func handlePoints(_ points: [CGPoint]) -> [CGPoint] {
        var newArray = [CGPoint]()
        for index in 0..<points.count {
            newArray.append(CGPoint(x: points[index].x * frame.width, y: points[index].y * frame.height))
        }
        return newArray
    }
    private func startCenterAnimation() {
        let frame = self.centerImage.bounds
        let fromValue = NSValue(cgRect: CGRect(x: 50, y: 50, width: 0.25, height: 0.25))
        centerImage.layer.removeAllAnimations()
        let parameter = SpringParameter(path: "bounds",
                                        mass: 20,
                                        stiffness: 6000,
                                        damping: 200,
                                        fromValue: fromValue,
                                        toValue: NSValue(cgRect: frame))
        let springAni = BallMethod.springAnimationWithPath(para: parameter)
        springAni.delegate = self
        centerImage.layer.add(springAni, forKey: "bounds")
    }
    private func startBallsAnimtaion() {
        for index in 0..<BallAnimationInfos.balls.count {
            var  points = [(CGPoint)]()
            let ballInfo = BallAnimationInfos.balls[index]
            for index in 0..<ballInfo.points.count {
                let pointX = ballInfo.points[index].0 * frame.width
                let pointY = ballInfo.points[index].1 * frame.height
                let point = CGPoint(x: pointX, y: pointY)
                points.append(point)
            }
            pointArray.append(points)
        }
        let animationPara = KeyAnimationParameter(path: "position", repeatCount: 0, duration: 0.9)
        for index in 0..<pointArray.count {
            let parameter = KeyFrameParameter(keyFramePath: animationPara, ballPoint: pointArray[index])
            let animation = BallMethod.keyframeAnimationPath(parameter: parameter)
            self.viewWithTag(index + 1)?.layer.add(animation, forKey: nil)
        }
    }
    private func startButtonAnimation() {
        moveButton.isHidden = false
        let animationPara = KeyAnimationParameter(path: "position", repeatCount: 0, duration: 0.4)
        let parameter = KeyFrameParameter(keyFramePath: animationPara,
                                          ballPoint: handlePoints(BallAnimationInfos.btnPoints))
        let animation = BallMethod.keyframeAnimationPath(parameter: parameter)
        centerImage.layer.add(animation, forKey: nil)
    }
    private func startLabelAnimation() {
        let animationPara = KeyAnimationParameter(path: "position", repeatCount: 0, duration: 0.45)
        let parameter = KeyFrameParameter(keyFramePath: animationPara,
                                          ballPoint: handlePoints(BallAnimationInfos.labPoints))
        let animation = BallMethod.keyframeAnimationPath(parameter: parameter)
        moveLabel.layer.add(animation, forKey: nil)
    }
    private func resetFrame() {
        var frameCom = self.frame
        frameCom.size.height *= 1.08
        self.frame =  frameCom
    }
    
}

extension ThumbsUpView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        for index in startTag...BallAnimationInfos.balls.count {
            self.viewWithTag(index)?.isHidden = true
        }
        startButtonAnimation()
        startLabelAnimation()
        resetFrame()
    }
}
//uicolor 扩展
extension UIColor {
    var toHexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(
            format: "%02X%02X%02X",
            Int(red * 0xff),
            Int(green * 0xff),
            Int(blue * 0xff)
        )
    }
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = (rgbValue & 0xff0000) >> 16
        let green = (rgbValue & 0xff00) >> 8
        let blue = rgbValue & 0xff
        self.init(
            red: CGFloat(red) / 0xff,
            green: CGFloat(green) / 0xff,
            blue: CGFloat(blue) / 0xff, alpha: 1
        )
    }
}
