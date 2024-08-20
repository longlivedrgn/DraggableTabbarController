//
//  ViewController.swift
//  DraggableViewController
//
//  Created by 김용재 on 8/19/24.
//

import UIKit

class ViewController: SwipeableTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [UINavigationController(rootViewController: FirstVC()), SecondVC(), UINavigationController(rootViewController: ThirdVC())]
        if let viewControllers {
            selectedViewController = viewControllers[1]
        }
        if let items = self.tabBar.items {
            items[0].title = "첫번째"
            items[1].title = "두번째"
            items[2].title = "세번째"
        }
        
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.overlap
        
        tabBar.barTintColor = .black
        tabBar.tintColor = .brown
        tabBar.isTranslucent = false
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Handle didSelect viewController method here
    }
}

class FirstVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tabBarController = self.tabBarController as? ViewController {
            tabBarController.isSwipeEnabled = true
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .green
        
        let button = UIButton(type: .system)
        button.setTitle("버튼", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼에 탭 이벤트 추가
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func buttonTapped() {
        let fourthVC = FourthVC()
        fourthVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(fourthVC, animated: true)
    }
}
import UIKit
import AVFoundation
import UIKit
import AVFoundation

class SecondVC: UIViewController {
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var previewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPreviewView()
        setupCamera()
    }
    
    private func setupUI() {
        view.backgroundColor = .red
        
        let button = UIButton(type: .system)
        button.setTitle("버튼", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPreviewView() {
        previewView = UIView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3)
        ])
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("카메라를 사용할 수 없습니다.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("카메라 입력을 설정하는 중 오류가 발생했습니다: \(error.localizedDescription)")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = previewView.bounds
        
        if let previewLayer = previewLayer {
            previewView.layer.addSublayer(previewLayer)
        }
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
    }
    
    @objc private func buttonTapped() {
        // 여기에 버튼이 탭되었을 때 수행할 동작을 추가하세요
    }
}

import UIKit

class ThirdVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        print("Deinit되었습니다")
    }
    
    private func setupUI() {
        view.backgroundColor = .blue
        
        let button = UIButton(type: .system)
        button.setTitle("버튼", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼에 탭 이벤트 추가
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tabBarController = self.tabBarController as? ViewController {
            tabBarController.isSwipeEnabled = true
        }
    }
    
    @objc private func buttonTapped() {
        let fourthVC = FourthVC()
        fourthVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(fourthVC, animated: true)
    }
}


class FourthVC: UIViewController {
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         if isMovingFromParent {
             tabBarController?.tabBar.isHidden = false
         }
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarController = self.tabBarController as? ViewController {
            tabBarController.isSwipeEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        title = "Fourth View"
        
        let label = UILabel()
        label.text = "This is the Fourth View"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
