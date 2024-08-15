import UIKit

final class OnboardingVC: UIPageViewController {
    
    private lazy var pages = [UIViewController]()
    
    private lazy var pageController: UIPageControl = {
        let pageVC = UIPageControl()
        pageVC.translatesAutoresizingMaskIntoConstraints = false
        pageVC.currentPageIndicatorTintColor = .black
        pageVC.pageIndicatorTintColor = .gray
        pageVC.numberOfPages = pages.count
        pageVC.currentPage = initialPage
        pageVC.addTarget(self, action: #selector(pageControllerTapped), for: .valueChanged)
        return pageVC
    }()
    
    private let initialPage = 0
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
        setupLayout()
    }
    
    @objc private func pageControllerTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true)
    }
    
    private func setupPageVC() {
        let firstScreen = OnboardingCustomVC(image: "blue", labelText: localized(text: "onboardingOne"))
        let secondScreen = OnboardingCustomVC(image: "red", labelText: localized(text: "onboardingTwo"))
        
        pages.append(firstScreen)
        pages.append(secondScreen)
        
        setViewControllers([pages[initialPage]], direction: .forward, animated: true)
    }
    
    private func setupLayout() {
        view.addSubview(pageController)
        NSLayoutConstraint.activate([
            pageController.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageController.heightAnchor.constraint(equalToConstant: 18),
            pageController.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168)
        ])
    }
}

extension OnboardingVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex == 0 {
            return pages.last
        } else {
            return pages[currentIndex - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        
        if currentIndex == pages.count - 1 {
            return pages.first
        } else {
            return pages[currentIndex + 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let visibleViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleViewController) {
            pageController.currentPage = index
        }
    }
}
