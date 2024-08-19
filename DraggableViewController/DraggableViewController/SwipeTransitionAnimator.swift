//
//  SwipeTransitionAnimator.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/19/24.
//

import UIKit

/// Custom Transition을 도와주는 Animator 객체 - `UIViewControllerAnimatedTransitioning`  프로토콜을 채택한다.

final class SwipeTransitionAnimator: NSObject, SwipeTransitioningProtocol {
    
    var animationDuration: TimeInterval
    
    var targetEdge: UIRectEdge
    
    var animationType: SwipeAnimationable
    
    /// 뷰 애니메이션을 더욱 세밀하고 동적으로 제어할 수 있게 도와주는 객체 -`UIViewPropertyAnimator`이다.
    private var viewPropertyAnimator: UIViewAnimating?
    
    init(animationDuration: TimeInterval = 0.33,
         targetEdge: UIRectEdge = .right,
         animationType: SwipeAnimationable) {
        self.animationDuration = animationDuration
        self.targetEdge = targetEdge
        self.animationType = animationType
        super.init()
    }
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return (transitionContext?.isAnimated == true) ? animationDuration : 0
    }
    
    /// 원하는 애니메이션 실행
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    /// UIViewPropertyAnimator object를 활용해서 animation을 구현하고 싶을 경우, 해당 메소드를 inherit해서 활용한다.
    func interruptibleAnimator(using transitionContext: any UIViewControllerContextTransitioning) -> any UIViewImplicitlyAnimating {
        // 컨테이너 뷰 가져오기
        let containerView = transitionContext.containerView
        
        // 현재 보여진 View를 가져온다.
        let fromView = transitionContext.view(forKey: .from)!
        
        // 앞으로 보여질 View를 가져온다.
        let toView = transitionContext.view(forKey: .to)!
        let fromRight = targetEdge == .right
        
        animationType.addTo(containerView: containerView, fromView: fromView, toView: toView)
        animationType.prepare(fromView: fromView, toView: toView, direction: fromRight)
        
        let duration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
            self.animationType.animation(fromView: fromView, toView: toView, direction: fromRight)
        })
        
        // 애니메이션이 완료된 후에 특정 작업을 수행하고자 할 때 활용
        animator.addCompletion { [weak self] _ in
            // 애니메이션이 전환 완료되었음을 시스템에게 알림
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self?.viewPropertyAnimator = nil
        }
        viewPropertyAnimator = animator
        return animator
    }
    
    func forceTransitionToFinish() {
        guard let animator = viewPropertyAnimator else {
            return
        }
        
        /// 애니메이션 중지
        /// - true로 할당할 경우 -> state를 inactive로 설정하고, 현재 상태를 최종상태로 결정한다.
        /// - false로 할당할 경우 -> state를 stopped으로 옮긴다.
        animator.stopAnimation(false)
        
        if animator.state == .stopped {
            animator.finishAnimation(at: .end) // 애니메이션을 최종 상태로 이동시킨다.
        }
    }
}
