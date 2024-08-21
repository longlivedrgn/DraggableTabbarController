//
//  SwipeableTabBarController.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/19/24.
//

import UIKit

class SwipeableTabBarController: UITabBarController {
    
    var swipeAnimatedTransitioning: SwipeTransitioningProtocol? = SwipeTransitionAnimator(animationType: SwipeAnimationType.overlap)
    
    private var currentAnimatedTransitioningType: SwipeTransitioningProtocol?
    
    private var panGestureRecognizer: UIPanGestureRecognizer?

    var isSwipeEnabled = true {
        didSet { panGestureRecognizer?.isEnabled = isSwipeEnabled }
    }
    
    override var selectedIndex: Int {
        get { return super.selectedIndex }
        set {
            if transitionCoordinator != nil {
                swipeAnimatedTransitioning?.forceTransitionToFinish()
            }
            super.selectedIndex = newValue
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    private func setup() {
        currentAnimatedTransitioningType = swipeAnimatedTransitioning
        delegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanGestureRecognizerPan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        panGestureRecognizer = panGesture
    }
    
    @objc private func didPanGestureRecognizerPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended || sender.state == .cancelled {
            currentAnimatedTransitioningType = nil
        }
        
        if sender.state == .began || sender.state == .changed {
            guard transitionCoordinator == nil else { return }
            currentAnimatedTransitioningType = swipeAnimatedTransitioning
            beginInteractiveTransition(sender)
        }
    }
    
    ///
    private func beginInteractiveTransition(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // x가 0.0보다 크면서(오른쪽으로 panning 중!) 현재 Index가 0보다 크면 왼쪽 VC로 이동 OK
        if translation.x > 0.0 && selectedIndex > 0 {
            selectedIndex -= 1
            
            // x가 0.0보다 작고(왼쪽으로 panning 중!) 현재 index + 1이 되면! (내 오른쪽에 VC가 있다면)
        } else if translation.x < 0.0 && selectedIndex + 1 < viewControllers?.count ?? 0 {
            selectedIndex += 1
        } else {
            // 만약 사용자가 왼쪽 탭인데 왼쪽으로 스와이프를 하려고 한다면, 인식기를 껐다가 다시 킨다.(현재 잘못된 스와이프를 무시하고 다시 새로운 스와이프를 시작할 수 있게 해준다.
            if !translation.equalTo(CGPoint.zero) {
                sender.isEnabled = false
                sender.isEnabled = true
            }
        }

        transitionCoordinator?.animate(alongsideTransition: nil) { [unowned self] context in
            if context.isCancelled && sender.state == .changed {
                self.beginInteractiveTransition(sender)
            }
        }
    }

}

// MARK: - UIGestureRecognizerDelegate
extension SwipeableTabBarController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UITabBarControllerDelegate
extension SwipeableTabBarController: UITabBarControllerDelegate {
    
    /// 애니메이션의 '모양'을 정의 -> 애니메이션 자체를 정의
    /// - 탭 바 컨트롤러에서 탭 간 전환 애니메이션을 커스텀할 때 활용한다.
    /// - 전환 애니메이션의 시각적 효과를 결정한다. - 페이드/슬라이드/확대 축소 등
    /// - ex) 오른쪽에서 왼쪽으로 슬라이드 애니메이션
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        
        // 현재 Tab의 Index와 변경될 Tab의 Index를 가져온다.
        guard let fromVCIndex = tabBarController.viewControllers?.firstIndex(of: fromVC),
            let toVCIndex = tabBarController.viewControllers?.firstIndex(of: toVC) else {
                return nil
        }
        let edge: UIRectEdge = fromVCIndex > toVCIndex ? .right : .left

        currentAnimatedTransitioningType?.targetEdge = edge
        
        // Center에서 넘어갈 때만 overLap / 그 외에서는 push가 될 수 있도록 구현
        guard let controllersCount = tabBarController.viewControllers?.count else { return nil }
        let centerIndex = controllersCount / 2
        if fromVCIndex == centerIndex {
            currentAnimatedTransitioningType?.animationType = SwipeAnimationType.overlap
        } else {
            currentAnimatedTransitioningType?.animationType = SwipeAnimationType.push
        }
        return currentAnimatedTransitioningType
    }
    
    
    /// 애니메이션의 진행 방식을 정의 -> 애니메이션을 어떻게 정의할 지 결정한다.
    /// - 사용자의 상호작용에 따라 애니메이션의 진행을 제어한다.
    /// - ex) 오른쪽에서 왼쪽으로 슬라이드 애니메이션을 사용자가 얼마나 스와이프했지에따라 진행정도 설정하기
    
    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        guard let panGesture = panGestureRecognizer else { return nil }
        if panGesture.state == .began || panGesture.state == .changed {
            return SwipeInteractor(gestureRecognizer: panGesture, edge: currentAnimatedTransitioningType?.targetEdge ?? .right)
        } else {
            return nil
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return transitionCoordinator == nil
    }
}

