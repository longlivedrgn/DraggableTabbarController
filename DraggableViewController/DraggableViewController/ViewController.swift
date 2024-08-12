//
//  ViewController.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/12/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, RightDraggableVCDelegate {
    func viewControllerPannableDidDismissed() {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
    }

    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let previewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        view.addSubview(previewView)
        setupCamera()

        NSLayoutConstraint.activate([
              previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
              previewView.heightAnchor.constraint(equalToConstant: 300) // 높이를 300으로 설정
          ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        self.view.addGestureRecognizer(panGesture)
    }
    
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting device input: \(error)")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = previewView.bounds
        
        if let previewLayer = previewLayer {
            previewView.layer.addSublayer(previewLayer)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }
    
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let progress = -translation.x / view.bounds.width  // 부호를 변경
        
        switch gesture.state {
        case .began:
            print(translation.x)
            if translation.x <= 0 {  // 오른쪽에서 왼쪽으로 드래그할 때만 시작
                interactionController = UIPercentDrivenInteractiveTransition()
                presentPannableViewController()
            }
        case .changed:
            if let interactionController = interactionController {
                interactionController.update(max(0, min(1, progress)))
            }
        case .ended, .cancelled:
            guard let interactionController = interactionController else { return }
            if progress > 0.5 || gesture.velocity(in: view).x < -300 {
                interactionController.finish()
                DispatchQueue.main.async {
                    self.captureSession?.stopRunning()
                }
            } else {
                interactionController.cancel()
                print("cancel입니다아아~!!🥹")
            }
            self.interactionController = nil
            print("여기에유~!!~🙇‍♂️")
//            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                self?.captureSession?.stopRunning()
//            }
        default:
            break
        }
    }
    
    private func presentPannableViewController() {
        let rootVC = RightDraggableVC()
        rootVC.delegate = self
        let vc = UINavigationController(rootViewController: rootVC)
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        toVC.view.frame = finalFrame.offsetBy(dx: finalFrame.width, dy: 0)  // 시작 위치를 오른쪽으로 변경
        containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = finalFrame
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// ViewCon

