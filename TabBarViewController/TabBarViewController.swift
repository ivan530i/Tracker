import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        self.viewControllers = [createTrackerView(), createStatisticView()]
    }
    
    func createTrackerView() -> UINavigationController {
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: localized(text: "trackerText"),
            image: UIImage(named: "tracker"),
            tag: 0
        )
        return UINavigationController(rootViewController: trackerViewController)
    }
    
    func createStatisticView() -> UINavigationController {
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: localized(text: "statisticsText"),
            image: UIImage(named: "statistics"),
            tag: 1
        )
        return UINavigationController(rootViewController: statisticViewController)
    }
    
    func setupTabBar() {
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.gray.cgColor
    }
}
