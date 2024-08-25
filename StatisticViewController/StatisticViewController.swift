import UIKit

final class StatisticViewController: UIViewController {

    private lazy var placeholder = CustomPlaceholder(labelText: "emptyStat".localizedString, imageName: "EmptyStat")
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypWhite
        return view
    }()
    
    private lazy var dayCountLabel: UILabel = {
        let label = UILabel()
        label.text = dayCount
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var finishedTrackers: UILabel = {
        let label = UILabel()
        label.text = "finishedTrackers".localizedString
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var gradientFrameView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.layer.insertSublayer(gradientLayer, at: 0)
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = Constants.gradientColors
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private var dayCount = ""
    private let dataManager = CoreDataManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()

        setupNotification()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientFrameView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }

    @objc private func updateStatistics() {
        let completedTrackersCount = dataManager.getCompletedTrackersCount()

        if completedTrackersCount > 0 {
            dayCount = "\(completedTrackersCount)"
            dayCountLabel.text = dayCount
            hidePlaceholder()
        } else {
            showPlaceholder()
        }
    }

    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "statistics".localizedString
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatistics),
            name: .trackerDataUpdated,
            object: nil
        )
    }
    
    private func showPlaceholder() {
        gradientFrameView.isHidden = true
        placeholder.isHidden = false
        placeholder.setupLayout(view)
    }

    private func hidePlaceholder() {
        gradientFrameView.isHidden = false
        placeholder.isHidden = true
    }

    private func setupUI() {
        view.backgroundColor = .ypWhite

        view.addSubViews([gradientFrameView])

        gradientFrameView.addSubViews([contentContainerView])
        contentContainerView.addSubViews([dayCountLabel, finishedTrackers])

        NSLayoutConstraint.activate([

            gradientFrameView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            gradientFrameView.heightAnchor.constraint(equalToConstant: 90),
            gradientFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gradientFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            contentContainerView.topAnchor.constraint(equalTo: gradientFrameView.topAnchor, constant: 1),
            contentContainerView.leadingAnchor.constraint(equalTo: gradientFrameView.leadingAnchor, constant: 1),
            contentContainerView.trailingAnchor.constraint(equalTo: gradientFrameView.trailingAnchor, constant: -1),
            contentContainerView.bottomAnchor.constraint(equalTo: gradientFrameView.bottomAnchor, constant: -1),

            dayCountLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 12),
            dayCountLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -16),
            dayCountLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),
            
            finishedTrackers.topAnchor.constraint(equalTo: dayCountLabel.bottomAnchor, constant: 7),
            finishedTrackers.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 16),
            finishedTrackers.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -16)
        ])
    }
}
