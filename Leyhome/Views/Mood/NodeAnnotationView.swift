//
//  NodeAnnotationView.swift
//  Leyhome - 地脉归途
//
//  心绪标注 - MKAnnotation 子类与自定义 MKAnnotationView
//
//  Created on 2026/01/29.
//

import SwiftUI
import UIKit
import MapKit

// MARK: - MoodAnnotation

/// 心绪标注 - 包装 MoodRecord 用于地图展示
class MoodAnnotation: NSObject, MKAnnotation {
    let moodRecord: MoodRecord

    dynamic var coordinate: CLLocationCoordinate2D

    var title: String? {
        moodRecord.moodType.displayName
    }

    var subtitle: String? {
        moodRecord.note
    }

    init(moodRecord: MoodRecord) {
        self.moodRecord = moodRecord
        self.coordinate = moodRecord.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        super.init()
    }
}

// MARK: - MoodAnnotationUIView

/// 心绪标注视图 - 涟漪圆 + 图标
class MoodAnnotationUIView: MKAnnotationView {
    static let reuseID = "MoodAnnotation"

    private let circleSize: CGFloat = 40
    private let rippleSize: CGFloat = 56

    private let iconView = UIImageView()
    private let circleLayer = CAShapeLayer()
    private let rippleLayer = CAShapeLayer()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        frame = CGRect(x: 0, y: 0, width: rippleSize, height: rippleSize)
        centerOffset = CGPoint(x: 0, y: -rippleSize / 2)
        canShowCallout = false

        // 涟漪圆
        let ripplePath = UIBezierPath(ovalIn: bounds)
        rippleLayer.path = ripplePath.cgPath
        rippleLayer.fillColor = UIColor.clear.cgColor
        rippleLayer.strokeColor = UIColor.systemBlue.cgColor
        rippleLayer.lineWidth = 1.5
        rippleLayer.opacity = 0.4
        layer.addSublayer(rippleLayer)

        // 主圆
        let circleFrame = CGRect(
            x: (rippleSize - circleSize) / 2,
            y: (rippleSize - circleSize) / 2,
            width: circleSize,
            height: circleSize
        )
        let circlePath = UIBezierPath(ovalIn: circleFrame)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.systemBlue.cgColor
        layer.addSublayer(circleLayer)

        // 图标
        iconView.contentMode = .center
        iconView.tintColor = .white
        iconView.frame = circleFrame
        addSubview(iconView)
    }

    func configure(with moodRecord: MoodRecord) {
        let moodColor = UIColor(moodRecord.moodType.color)

        // 更新颜色
        circleLayer.fillColor = moodColor.cgColor
        rippleLayer.strokeColor = moodColor.cgColor

        // 更新图标
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iconView.image = UIImage(systemName: moodRecord.moodType.icon, withConfiguration: config)

        // 涟漪动画
        startRippleAnimation()
    }

    private func startRippleAnimation() {
        rippleLayer.removeAllAnimations()

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.85
        scaleAnim.toValue = 1.15

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 0.6
        opacityAnim.toValue = 0.1

        let group = CAAnimationGroup()
        group.animations = [scaleAnim, opacityAnim]
        group.duration = 2.0
        group.repeatCount = .infinity
        group.autoreverses = true
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        rippleLayer.add(group, forKey: "ripple")
    }
}
