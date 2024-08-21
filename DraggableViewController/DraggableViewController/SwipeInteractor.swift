//
//  SwipeInteractor.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/19/24.
//

import UIKit

final class SwipeInteractor: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Private
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private var gestureRecognizer: UIPanGestureRecognizer
    private var edge: UIRectEdge
    private var initialLocationInContainerView: CGPoint = CGPoint()
    private var initialTranslationInContainerView: CGPoint = CGPoint()
    
    private let xVelocityForComplete: CGFloat = 200.0
    private let xVelocityForCancel: CGFloat = 30.0
    
    init(gestureRecognizer: UIPanGestureRecognizer, edge: UIRectEdge) {
        self.gestureRecognizer = gestureRecognizer
        self.edge = edge
        super.init()
        
        gestureRecognizer.addTarget(self, action: #selector(didGestureRecognizeUpdate(_:)))
    }

    deinit {
        gestureRecognizer.removeTarget(self, action: #selector(didGestureRecognizeUpdate(_:)))
    }
    
    /// 전환 시작 메서드
    /// - 전환이 시작될 때 필요한 정보를 저장한다.
    /// - 해당 메소드는 화면 전환이 시작될 때 호출이된다
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        initialLocationInContainerView = gestureRecognizer.location(in: transitionContext.containerView)
        initialTranslationInContainerView = gestureRecognizer.translation(in: transitionContext.containerView)
        
        super.startInteractiveTransition(transitionContext)
    }

    /// 진행률 계산 메서드
    /// -  스와이프한 거리를 화면 너비로 나눠 진행률을 계산한다.
    private func percentForGesture(_ gesture: UIPanGestureRecognizer) -> CGFloat {
        let transitionContainerView = transitionContext?.containerView
        
        let translationInContainerView = gesture.translation(in: transitionContainerView)
        
        // 만약 panGesture를 시작한 방향과 진행 중 panGesture 방향이 다르다면 -1.0을 return한다.
        if translationInContainerView.x > 0.0 && initialTranslationInContainerView.x < 0.0 ||
            translationInContainerView.x < 0.0 && initialTranslationInContainerView.x > 0.0 {
            return -1.0
        }
        
        // 스와이프한 percentage를 계산한다.
        return abs(translationInContainerView.x) / (transitionContainerView?.bounds ?? CGRect()).width
    }
    
    /// 제스처 업데이트 처리 메소드
    /// - 제스처 상태에 따라 전환을 진행, 취소, 완료를 한다.
    /// - 스와이프 속도와 진행률을 기준으로 전환 완료 여부를 결정한다.
    @objc private func didGestureRecognizeUpdate(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            break
            
        case .changed:
            update(percentForGesture(gestureRecognizer))

        case .ended:
            let transitionContainerView = transitionContext?.containerView
            let velocityInContainerView = gestureRecognizer.velocity(in: transitionContainerView)
            let shouldComplete: Bool

            switch edge {
            case .left:
                shouldComplete = (percentForGesture(gestureRecognizer) >= 0.4 && velocityInContainerView.x < xVelocityForCancel) || velocityInContainerView.x < -xVelocityForComplete || (percentForGesture(gestureRecognizer) >= 0.7 && velocityInContainerView.x < -xVelocityForComplete)
            case .right:
                shouldComplete = (percentForGesture(gestureRecognizer) >= 0.4 && velocityInContainerView.x > -xVelocityForCancel) || velocityInContainerView.x > xVelocityForComplete || (percentForGesture(gestureRecognizer) >= 0.7 && velocityInContainerView.x > xVelocityForComplete)
            default:
                fatalError("\(edge) is unsupported.")
            }

            if shouldComplete {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
        }
    }
}
