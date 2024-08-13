import UIKit
import AVFoundation

class ViewController: UIViewController, RightDraggableVCDelegate, LeftDraggableVCDelegate {
    
    func viewControllerPannableDidDismissed() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func leftViewControllerDidDismiss() {
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
            previewView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        self.view.addGestureRecognizer(panGesture)
    }
    
    private var isStartInTranslationZeroX = false
    
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
        super.viewWillAppear(animated)
        print("🚨🚨🚨🚨Home - viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🚨🚨🚨🚨Home -viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("🚨🚨🚨🚨Home - viewWillDisappear")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("🚨🚨🚨🚨Home - viewDidDisappear")
    }
    
    deinit {
        print("Home - Deinit🗑️🗑️🗑️")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let progress = abs(translation.x) / view.bounds.width
        
        switch gesture.state {
        case .began:
            if translation.x < 0 {  // 오른쪽에서 왼쪽으로 드래그
//                print("🏁 ⬅️ Drag begin \(translation.x)")
                interactionController = UIPercentDrivenInteractiveTransition()
                presentRightPannableViewController()
            } else if translation.x > 0 {  // 왼쪽에서 오른쪽으로 드래그
//                print("🏁 ➡️ Drag begin \(translation.x)")
                interactionController = UIPercentDrivenInteractiveTransition()
                presentLeftPannableViewController()
            } else {
                isStartInTranslationZeroX = true
            }
            
        case .changed:
            if isStartInTranslationZeroX == true {
                if translation.x < 0 {  // 오른쪽에서 왼쪽으로 드래그
                    interactionController = UIPercentDrivenInteractiveTransition()
                    presentRightPannableViewController()
                } else if translation.x > 0 {  // 왼쪽에서 오른쪽으로 드래그
                    interactionController = UIPercentDrivenInteractiveTransition()
                    presentLeftPannableViewController()
                }
                isStartInTranslationZeroX = false
            }
//            print("🏃🏻‍♂️Drag changed \(translation.x)")
            if let interactionController = interactionController {
                interactionController.update(progress)
            }
        case .ended, .cancelled:
//            print("✅ Drag ended")
            guard let interactionController = interactionController else { return }
//            if progress > 0.5 || abs(gesture.velocity(in: view).x) > 300 {
            if progress > 0.5 {
                interactionController.finish()
                DispatchQueue.main.async {
                    self.captureSession?.stopRunning()
                }
            } else {
                interactionController.cancel()
            }
            self.interactionController = nil
        default:
            break
        }
    }
    
    private func presentRightPannableViewController() {
        let rootVC = RightDraggableVC()
        rootVC.delegate = self
        let vc = UINavigationController(rootViewController: rootVC)
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.transitioningDelegate = self
        self.present(vc, animated: true)
    }
    
    private func presentLeftPannableViewController() {
        let rootVC = LeftDraggableVC()
        rootVC.delegate = self
        let vc = UINavigationController(rootViewController: rootVC)
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.transitioningDelegate = self
        self.present(vc, animated: true)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented.children.first is RightDraggableVC {
            return PresentRightAnimator()
        } else if presented.children.first is LeftDraggableVC {
            return PresentLeftAnimator()
        }
        return nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

class PresentRightAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        toVC.view.frame = finalFrame.offsetBy(dx: finalFrame.width, dy: 0)
        containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = finalFrame
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class PresentLeftAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        toVC.view.frame = finalFrame.offsetBy(dx: -finalFrame.width, dy: 0)
        containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = finalFrame
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
