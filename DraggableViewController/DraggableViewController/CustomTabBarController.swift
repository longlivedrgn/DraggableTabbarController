import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // View Controllers 설정
        let firstViewController = UIViewController()
        let secondViewController = ViewController()
        let thirdViewController = UIViewController()
        
        // Navigation Controller를 각 ViewController에 래핑
        let secondNavigationController = UINavigationController(rootViewController: secondViewController)

        // Tab Bar Items 설정
        firstViewController.tabBarItem = UITabBarItem(title: "First", image: UIImage(systemName: "1.circle"), tag: 0)
        secondViewController.tabBarItem = UITabBarItem(title: "Second", image: UIImage(systemName: "2.circle"), tag: 1)
        thirdViewController.tabBarItem = UITabBarItem(title: "Third", image: UIImage(systemName: "3.circle"), tag: 2)

        // Tab Bar Appearance 설정
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemGray
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray

        self.tabBar.standardAppearance = tabBarAppearance

        // iOS 15 이상에서는 scrollEdgeAppearance도 설정 필요
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = tabBarAppearance
        }

        // Tab Bar에 ViewControllers 추가
        self.viewControllers = [firstViewController, secondNavigationController, thirdViewController]

        // 델리게이트 설정
        self.delegate = self
        self.selectedIndex = 1
    }

    // 델리게이트 메서드: 특정 탭이 선택되었을 때 호출
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let index = viewControllers?.firstIndex(of: viewController) {
            print("Selected tab: \(index)")
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let viewControllers = viewControllers,
           let index = viewControllers.firstIndex(of: viewController),
           index == 2 { // Third 탭의 인덱스가 2
            guard let navigationController = selectedViewController as? UINavigationController,
                  let currentVC = navigationController.viewControllers.first as? ViewController else {
                return true
            }
            let rootVC = RightDraggableVC()
            rootVC.delegate = currentVC
            let vc = UINavigationController(rootViewController: rootVC)
            
            vc.modalPresentationStyle = .overCurrentContext
            
            navigationController.present(vc, animated: false)
            
            return false // Third 탭으로의 실제 전환을 막음
        }
        
        return true // 다른 탭들은 정상적으로 선택되도록 함
    }
}
