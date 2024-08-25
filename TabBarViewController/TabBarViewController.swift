import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        self.viewControllers = [createTrackerView(), createStatisticView()]
    }
    
    private func createTrackerView() -> UINavigationController {
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "trackerText".localizedString,
            image: UIImage(named: "tracker"),
            tag: 0
        )
        return UINavigationController(rootViewController: trackerViewController)
    }
    
    private func createStatisticView() -> UINavigationController {
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "statisticsText".localizedString,
            image: UIImage(named: "statistics"),
            tag: 1
        )
        return UINavigationController(rootViewController: statisticViewController)
    }
    
    private func setupTabBar() {
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor(named: "tabBarBorder")?.cgColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTabBarBorderColor()
    }

    private func updateTabBarBorderColor() {
        tabBar.layer.borderColor = UIColor(named: "tabBarBorder")?.cgColor
    }
}
