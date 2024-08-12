//
//  RightDraggableVC.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/12/24.
//


import UIKit

protocol RightDraggableVCDelegate: AnyObject {
    func viewControllerPannableDidDismissed()
}

class RightDraggableVC: UIViewController {
    private var originalPosition: CGPoint?
    
    weak var delegate: RightDraggableVCDelegate?
    
    private lazy var pushButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Push 새로운 뷰", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(pushToSecond), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.view.addSubview(self.pushButton)
        self.view.addGestureRecognizer(panGestureRecognizer)
        // 루트 뷰 컨트롤러 설정
        NSLayoutConstraint.activate([
            pushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pushButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pushButton.widthAnchor.constraint(equalToConstant: 200),
            pushButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func pushToSecond() {
        self.navigationController?.pushViewController(NewViewController(), animated: true)
    }
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            self.originalPosition = view.center
        case .changed:
            let translation = panGesture.translation(in: view)
            if translation.x > 0 {
                self.view.frame.origin = CGPoint(x: translation.x, y: 0)
            }
            self.delegate?.viewControllerPannableDidDismissed()
            
        case .ended:
            guard let originalPosition = self.originalPosition else { return }
            let velocity = panGesture.velocity(in: view)
            guard velocity.x >= 1500 else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = originalPosition
                })
                return
            }
            
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.view.frame.origin = CGPoint(
                        x: self.view.frame.size.width,
                        y: self.view.frame.origin.y
                    )
                },
                completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            )
        default:
            return
        }
    }
}


class NewViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "이것은 푸시된 새로운 뷰입니다"
        label.textAlignment = .center
        
        view.addSubview(label)
        view.backgroundColor = .darkGray
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
}


