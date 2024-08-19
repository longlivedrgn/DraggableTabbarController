//
//  SwipeAnimationTypeProtocol.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/19/24.
//


import UIKit

/// 화면 전환되는 애니메이션 타입

protocol SwipeAnimationable {
    func addTo(containerView: UIView, fromView: UIView, toView: UIView)
    func prepare(fromView from: UIView, toView to: UIView, direction: Bool)
    func animation(fromView from: UIView, toView to: UIView, direction: Bool)
}

/// Animation 타입
///
/// - overlap: 현재 탭은 가만히 있고, 새로운 탭이 위로 올라와서 감싸는 방법
/// - push:  애플의 default push 방법도 동일한 방법
enum SwipeAnimationType: SwipeAnimationable {
    case overlap // to가 from을 덮는 animation
    case push // from이 to를 덮는 animation
    
    /// View의 계층구조를 설정
    ///
    /// - Parameters:
    ///   - containerView: Animation을 실행한 tab view들을 가지고 있는 View
    ///   - fromView: 이전에 선택된 tab view
    ///   - toView: 새롭게 선택된 tab view
    public func addTo(containerView: UIView, fromView: UIView, toView: UIView) {
        switch self {
        case .push:
            containerView.insertSubview(toView, belowSubview: fromView)
        default:
            containerView.addSubview(toView)
        }
    }
    
    /// Animation이 실행되기 전에 View들의 위치를 셋업한다.
    ///
    /// - Parameters:
    ///   - from: 이전에 선택된 tab view
    ///   - to: 새롭게 선택된 tab view
    ///   - direction: animation이 시작되는 방향
    public func prepare(fromView from: UIView, toView to: UIView, direction: Bool) {
        let screenWidth = from.frame.size.width
        switch self {
        case .overlap:
            to.frame.origin.x = direction ? -screenWidth : screenWidth
        case .push:
            to.frame.origin.x = 0 // presenting될 view는 화면 그대로 유지
            from.frame.origin.x = 0
        }
    }

    /// 애니메이션이 실행되는 중간
    ///
    /// - Parameters:
    ///   - from: 이전에 선택된 tab view
    ///   - to: 새롭게 선택된 tab view
    ///   - direction: animation이 시작되는 방향
    public func animation(fromView from: UIView, toView to: UIView, direction: Bool) {
        let screenWidth = from.frame.size.width
        switch self {
        case .overlap:
            to.frame.origin.x = 0
        case .push:
            to.frame.origin.x = 0
            from.frame.origin.x = direction ? screenWidth : -screenWidth
        }
    }
}
