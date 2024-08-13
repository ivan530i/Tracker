import UIKit

final class StatisticViewController: UIViewController {
    
    var dayCount = ""
    let gradient = CAGradientLayer()
    
    private lazy var header: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized(text: "statistics")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = localized(text: "emptyStat")
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var emptyImg: UIImageView = {
        let img = UIImage(named: "EmptyStat")
        let imageView = UIImageView(image: img)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var readyView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return view
    }()
    
    private lazy var dayCountLabel: UILabel = {
        let label = UILabel()
        label.text = dayCount
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var finishedTrackers: UILabel = {
        let label = UILabel()
        label.text = localized(text: "finishedTrackers")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupHeader()
        setupNotification()
        updateStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    private func setupHeader() {
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatistics),
            name: .trackerDataUpdated,
            object: nil
        )
    }
    
    private func removeEmptyErrorView() {
        emptyImg.removeFromSuperview()
        emptyLabel.removeFromSuperview()
        
        readyView.removeFromSuperview()
    }
    
    @objc private func updateStatistics() {
        removeEmptyErrorView()
        
        let completedTrackersCount = CoreDataManager.shared.getCompletedTrackersCount()
        
        if (completedTrackersCount > 0) {
            dayCount = "\(completedTrackersCount)"
            dayCountLabel.text = dayCount
            setView()
        } else {
            setEmptyErrorView()
        }
    }
    
    private func setEmptyErrorView() {
        view.addSubview(emptyImg)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyImg.heightAnchor.constraint(equalToConstant: 80),
            emptyImg.widthAnchor.constraint(equalToConstant: 80),
            emptyImg.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyImg.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImg.bottomAnchor, constant: 8)
        ])
    }
    
    private func setView() {
        view.addSubview(readyView)
        readyView.addSubview(dayCountLabel)
        readyView.addSubview(finishedTrackers)
        NSLayoutConstraint.activate([
            readyView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            readyView.heightAnchor.constraint(equalToConstant: 90),
            readyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dayCountLabel.topAnchor.constraint(equalTo: readyView.topAnchor, constant: 12),
            dayCountLabel.trailingAnchor.constraint(equalTo: readyView.trailingAnchor, constant: -16),
            dayCountLabel.leadingAnchor.constraint(equalTo: readyView.leadingAnchor, constant: 16),
            
            finishedTrackers.topAnchor.constraint(equalTo: dayCountLabel.bottomAnchor, constant: 7),
            finishedTrackers.leadingAnchor.constraint(equalTo: readyView.leadingAnchor, constant: 16),
            finishedTrackers.trailingAnchor.constraint(equalTo: readyView.trailingAnchor, constant: -16)
        ])
    }
}
