import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // View Controllers 설정
        let firstViewController = UIViewController()
        let secondViewController = ViewController()
        let thirdViewController = UIViewController()
        
        // Navigation Controller를 각 ViewController에 래핑
        let firstNavigationController = UINavigationController(rootViewController: firstViewController)
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
        self.viewControllers = [firstNavigationController, secondNavigationController, thirdViewController]

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
}
