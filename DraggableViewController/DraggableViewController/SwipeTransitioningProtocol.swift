//
//  SwipeTransitioningProtocol.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/19/24.
//

import UIKit

protocol SwipeTransitioningProtocol: UIViewControllerAnimatedTransitioning {

    /// Animation transition 유지 시간
    var animationDuration: TimeInterval { get set }

    /// Animation이 시작되는 방향
    var targetEdge: UIRectEdge { get set }

    /// Animation type
    var animationType: SwipeAnimationable { get set }

    /// 현재 진행 중인 transition을 즉시 끝내버리는 메소드
    func forceTransitionToFinish()
}
