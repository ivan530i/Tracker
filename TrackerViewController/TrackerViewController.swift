import UIKit

final class TrackerViewController: UIViewController, UICollectionViewDelegate {
    
    private var categories: [TrackerCategory] = [TrackerCategory(header: "Домашний вайб", trackersArray: [Tracker(id: UUID(), name: "Поливать растения", color: .cSelection18, emoji: "❤️️️️️️️", schedule: [.Friday, .Monday])]), TrackerCategory(header: "Радостные мелочи" , trackersArray: [Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .cSelection2, emoji: "😻", schedule: [.Friday, .Monday]), Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: .cSelection1, emoji: "🌺", schedule: [.Friday, .Monday]), Tracker(id: UUID(), name: "Свидания в апреле", color: .cSelection14, emoji: "❤️️️️️️️", schedule: [.Friday, .Monday])])]
    
    private var completedTrackers: [TrackerRecord] = []
    private var visibleTrackers: [TrackerCategory] = []
    
    var currentDate: Date = Date()
    
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
        return collectionView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        view.backgroundColor = .ypWhite
        setupViews()
        navBarItem()
        setupConstraints()
        reloadData()
        updateViewController()
    }
    
    private func updateViewController() {
        if !visibleTrackers.isEmpty {
            mockLabel.isHidden = true
            mockImageView.isHidden = true
            nothingFoundImageView.isHidden = true
            nothingFoundLabel.isHidden = true
            trackerCollectionView.isHidden = false
        } else {
            trackerCollectionView.isHidden = true
            mockLabel.isHidden = false
            mockImageView.isHidden = false
        }
    }
    
    private func reloadPlaceholder() {
        if !categories.isEmpty && visibleTrackers.isEmpty {
            nothingFoundImageView.isHidden = false
            nothingFoundLabel.isHidden = false
            mockLabel.isHidden = true
            mockImageView.isHidden = true
        } else {
            nothingFoundImageView.isHidden = true
            nothingFoundLabel.isHidden = true
        }
    }
    
    private func setupViews() {
        view.addSubview(trackerCollectionView)
        view.addSubview(mockImageView)
        view.addSubview(mockLabel)
        view.addSubview(searchBar)
        view.addSubview(nothingFoundImageView)
        view.addSubview(nothingFoundLabel)
        nothingFoundImageView.isHidden = true
        nothingFoundLabel.isHidden = true
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
            
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            nothingFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nothingFoundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            nothingFoundLabel.centerXAnchor.constraint(equalTo: nothingFoundImageView.centerXAnchor),
            nothingFoundLabel.topAnchor.constraint(equalTo: nothingFoundImageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func navBarItem() {
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
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentDate)
        let filterText = (searchBar.text ?? "").lowercased()
        visibleTrackers = categories.compactMap { category in
            let trackers = category.trackersArray.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.contains { weekDay in
                    weekDay.calendarDayNumber == filterWeekday
                }
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                header: category.header,
                trackersArray: trackers)
        }
        trackerCollectionView.reloadData()
        updateViewController()
    }
    
    private func reloadVisibleCategoriesSearch() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentDate)
        let filterText = (searchBar.text ?? "").lowercased()
        
        visibleTrackers = categories.flatMap { category -> [TrackerCategory] in
            let trackers = category.trackersArray.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.contains { weekDay in
                    weekDay.calendarDayNumber == filterWeekday
                }
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return []
            }
            return [TrackerCategory(header: category.header, trackersArray: trackers)]
        }
        
        trackerCollectionView.reloadData()
        reloadPlaceholder()
    }
    
    private func reloadData() {
        reloadVisibleCategories()
    }
    
    @objc private func buttonIsTapped() {
        let viewController = HabitOrEventViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    @objc private func datePickerChanged() {
        nothingFoundImageView.isHidden = true
        nothingFoundLabel.isHidden = true
        currentDate = datePicker.date
        reloadVisibleCategories()
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleTrackers[section].trackersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCell.identifier, for: indexPath) as? TrackerViewCell else { return UICollectionViewCell()}
        let tracker = visibleTrackers[indexPath.section].trackersArray[indexPath.row]
        let dayCompleted = completedTrackers.filter { $0.id == tracker.id}.count
        let isCompleted = completedTrackers.contains { record in
            record.id == tracker.id && record.date.onlyDate == datePicker.date.onlyDate }
        let isEnabled = datePicker.date <= Date() || Date().onlyDate == datePicker.date.onlyDate
        cell.setupCell(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, completedDays: dayCompleted, isEnabled: isEnabled , isCompleted: isCompleted , indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerViewHeader.identifier,
            for: indexPath
        ) as? TrackerViewHeader {
            cell.topLabel.font = .boldSystemFont(ofSize: 19)
            cell.topLabel.text = visibleTrackers[indexPath.section].header
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
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 11, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionInsets = UIEdgeInsets(top: 16, left: 28, bottom: 12, right: 28)
        return CGSize(width: collectionView.bounds.width - sectionInsets.left - sectionInsets.right, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension TrackerViewController: CreateTypeTrackerDelegate {
    func plusTracker(tracker: Tracker, category: String, from: HabitOrEventViewController) {
        var updatedCategory: TrackerCategory?
        var index: Int?
        
        for i in 0..<categories.count {
            if categories[i].header == category {
                updatedCategory = categories[i]
                index = i
            }
        }
        
        if updatedCategory == nil {
            categories.append(TrackerCategory(header: category, trackersArray: [tracker]))
        } else {
            let newTrackersArray = (updatedCategory?.trackersArray ?? []) + [tracker]
            let sortedTrackersArray = newTrackersArray.sorted { $0.name < $1.name }
            let newCategory = TrackerCategory(header: category, trackersArray: sortedTrackersArray)
            categories.remove(at: index ?? 0)
            categories.insert(newCategory, at: index ?? 0)
        }
        
        visibleTrackers = categories
        reloadVisibleCategories()
        trackerCollectionView.reloadData()
    }
}

extension TrackerViewController: UITextFieldDelegate {
    func returnTextField(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategoriesSearch()
        return true
    }
}

extension Date {
    var onlyDate: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
