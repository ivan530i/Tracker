import UIKit

final class TrackerViewController: UIViewController, UICollectionViewDelegate {
    
    var selectedFilters: String = ""
    
    private lazy var mockImageView : UIImageView = {
        let image = UIImage(named: "mockImage")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var mockLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "Что будем отслеживать?"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nothingFoundImageView: UIImageView = {
        let image = UIImage(named: "nothingImg")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var nothingFoundLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var searchBar: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.backgroundColor = .clear
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .black
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.clipsToBounds = true
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 9
        layout.headerReferenceSize = .init(width: view.frame.size.width, height: 35)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            TrackerViewCell.self,
            forCellWithReuseIdentifier: TrackerViewCell.identifier
        )
        collectionView.register(
            TrackerViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerViewHeader.identifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
       let button = UIButton()
        button.setTitle(localized(text: "filters"), for: .normal)
        button.backgroundColor = .ypBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private let dataManager = CoreDataManager.shared
    
    private var completedTrackers: [TrackerRecord] = []
    private var visibleTrackers: [TrackerCategory] = []
    private var currentDate: Date = Date()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNotification()
        getTrackersFromCD()
    }
    
    @objc private func buttonIsTapped() {
        let viewController = HabitOrEventViewController()
        present(viewController, animated: true)
    }
    
    @objc private func datePickerChanged(sender: UIPickerView) {
        currentDate = datePicker.date
        getTrackersFromCD()
        reloadCollection()
    }
    
    @objc private func filterButtonClicked(_ sender: UIButton) {
        let viewController = UINavigationController(rootViewController: FilterViewController(delegate: self))
        present(viewController, animated: true)
    }
    
    private func reloadCollection() {
        trackerCollectionView.reloadData()
    }
    
    private func getTrackersFromCD() {
        let weekDay = MainHelper.getWeekdayFromCurrentDate(currentDate: currentDate)
        dataManager.getdataFromCoreData(weekday: weekDay)
        showOrHidePlaceholder()
        
        dataManager.printAllTrackerRecords()
        dataManager.printAllTrackersInCoreData()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(closeFewVCAfterCreatingTracker),
            name: .returnToMainScreen,
            object: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubViews([trackerCollectionView, mockImageView, mockLabel, searchBar, nothingFoundImageView, nothingFoundLabel, filterButton])
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mockImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mockImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            mockLabel.centerXAnchor.constraint(equalTo: mockImageView.centerXAnchor),
            mockLabel.topAnchor.constraint(equalTo: mockImageView.bottomAnchor, constant: 8),
            
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            nothingFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingFoundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            nothingFoundLabel.centerXAnchor.constraint(equalTo: nothingFoundImageView.centerXAnchor),
            nothingFoundLabel.topAnchor.constraint(equalTo: nothingFoundImageView.bottomAnchor, constant: 8),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        
        let plusButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(Self.buttonIsTapped))
        plusButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = plusButton
        
        let rightButton = UIBarButtonItem(customView: datePicker)
        self.navigationItem.rightBarButtonItem = rightButton
    }
}

extension TrackerViewController {
    
    private func showOrHidePlaceholder() {
        let isNoData = dataManager.isCoreDataEmpty()
        isNoData ? showPlaceholder() : hidePlaceholder()
    }
    
    private func showPlaceholder() {
        trackerCollectionView.isHidden = true
        mockLabel.isHidden = false
        mockImageView.isHidden = false
    }
    
    private func hidePlaceholder() {
        mockLabel.isHidden = true
        mockImageView.isHidden = true
        nothingFoundImageView.isHidden = true
        nothingFoundLabel.isHidden = true
        trackerCollectionView.isHidden = false
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataManager.trackersFRC?.sections?.count ?? 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataManager.trackersFRC?.sections?[section].numberOfObjects ?? 99
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.identifier, for: indexPath) as? TrackerViewCell,
              let tracker = dataManager.trackersFRC?.object(at: indexPath),
              let trackerId = tracker.id else { return UICollectionViewCell()}
        
        let dayCompleted = dataManager.countOfTrackerInRecords(trackerIDToCount: trackerId)
        let correctDate = MainHelper.dateToShortDate(date: currentDate)
        let isCompleted = dataManager.isTrackerExistInTrackerRecord(trackerIdToCheck: trackerId, date: correctDate)
        let isEnabled = datePicker.date <= Date()
        
        cell.setupCell(id: trackerId, name: tracker.name, color: tracker.colorHex, emoji: tracker.emoji, completedDays: dayCompleted, isEnabled: isEnabled, isCompleted: isCompleted, indexPath: indexPath, date: correctDate)
        
        cell.dataUpdated = {
            collectionView.reloadData()
        }
        
        return cell
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if let cell = collectionView.dequeueReusableSupplementaryView( ofKind: kind,
                                                                       withReuseIdentifier: TrackerViewHeader.identifier, for: indexPath
        ) as? TrackerViewHeader {
            if let headers = dataManager.trackersFRC?.sections {
                cell.topLabel.text = headers[indexPath.section].name
            }
            return cell
        } else {
            return UICollectionReusableView()
        }
    }
}

extension TrackerViewController: TrackerViewCellDelegate {
    func trackerCompleted(id: UUID, indexPath: IndexPath) {
        if let index = completedTrackers.firstIndex(where: { tracker in
            tracker.id == id && tracker.date.onlyDate == datePicker.date.onlyDate
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(id: id, date: datePicker.date))
        }
        trackerCollectionView.reloadItems(at: [indexPath])
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 9
        let availableWidth = collectionView.frame.width - padding
        let width = availableWidth / 2
        return CGSize(width: width, height: 148)
    }
}

extension TrackerViewController: UITextFieldDelegate {
    func returnTextField(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Date {
    var onlyDate: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}

extension TrackerViewController {
    @objc func closeFewVCAfterCreatingTracker() {
        getTrackersFromCD()
        reloadCollection()
        dismiss(animated: true)
    }
}

extension TrackerViewController: FilterViewControllerProtocol {
    func filterSetting(_ setting: Int) {

    }
}
