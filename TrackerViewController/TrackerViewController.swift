import UIKit

final class TrackerViewController: UIViewController, UICollectionViewDelegate {

    private lazy var noTrackersPlaceholder = CustomPlaceholder(labelText: "emptyTracker".localizedString, imageName: "mockImage")

    private lazy var searchNoTrackersPlaceholder = CustomPlaceholder(labelText: "emptySearch".localizedString, imageName: "nothingImg")

    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = false
        return search
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.calendar.firstWeekday = 2
        picker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .inline
        } else {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        picker.backgroundColor = .ypWhite
        picker.isHidden = true
        return picker
    }()

    private lazy var dateButton: UIButton = {
        let button = UIButton()
        let date = MainHelper.dateToString(date: Date())
        let titleColor = UIColor(hex: "1A1B22")
        button.setTitle(date, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.frame = CGRect(x: 0, y: 0, width: 77, height: 34)
        button.backgroundColor = UIColor(hex: "F0F0F0")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        return button
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
        collectionView.backgroundColor = .ypWhite
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("filters".localizedString, for: .normal)
        button.backgroundColor = .ypBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
        return button
    }()

    private let analyticsService = AnalyticsService()
    private let dataManager = CoreDataManager.shared

    private var currentDate = Date() {
        didSet {
            updateWeekDay()
        }
    }

    private var weekDay = ""

    private var isSearching = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDataManager()
        setupNotification()
        getTrackersFromCD()
        updateWeekDay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report("open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report("close", params: ["screen": "Main"])
    }

    @objc private func dateButtonTapped(_ sender: UIButton) {
        showDatePicker()
    }

    @objc private func buttonIsTapped() {
        let viewController = HabitOrEventViewController()
        present(viewController, animated: true)
        analyticsService.report("click", params: ["screen": "Main", "item": "add_tracker"])
    }
    
    @objc private func datePickerChanged(sender: UIPickerView) {
        currentDate = datePicker.date
        datePicker.isHidden.toggle()
        updateButtonDateLabel()
        showFilteredTrackers()
        reloadCollection()
    }

    @objc private func filterButtonClicked(_ sender: UIButton) {
        let viewModel = FilterViewModel()
        let viewController = UINavigationController(rootViewController: FilterViewController(delegate: self, viewModel: viewModel))
        viewModel.view = viewController
        present(viewController, animated: true)
        analyticsService.report("click", params: ["screen": "Main", "item": "filters"])
    }

    private func setupDataManager() {
        dataManager.delegate = self
    }

    private func updateWeekDay() {
        weekDay = MainHelper.getWeekdayFromCurrentDate(currentDate: currentDate)
    }

    private func showDatePicker() {
        datePicker.isHidden.toggle()
        !datePicker.isHidden ? hidePlaceholder() : showOrHidePlaceholder()
    }

    private func updateButtonDateLabel() {
        let dateForButton = MainHelper.dateToString(date: datePicker.date)
        dateButton.setTitle(dateForButton, for: .normal)
    }

    private func reloadCollection() {
        trackerCollectionView.reloadData()
    }
    
    private func getTrackersFromCD() {
        let weekDay = MainHelper.getWeekdayFromCurrentDate(currentDate: currentDate)
        dataManager.getdataFromCoreData(weekday: weekDay)
        showOrHidePlaceholder()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(closeFewVCAfterCreatingTracker),
            name: .returnToMainScreen,
            object: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubViews([trackerCollectionView, datePicker, filterButton])

        setupNavigationBar()

        setupConstraints()

        noTrackersPlaceholder.setupLayout(view)
        searchNoTrackersPlaceholder.setupLayout(view)
    }


    private func setupConstraints() {
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(greaterThanOrEqualToConstant: 325),

            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "trackerText".localizedString
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always

        let plusButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(Self.buttonIsTapped))
        plusButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = plusButton
        
        let rightButton = UIBarButtonItem(customView: dateButton)
        navigationItem.rightBarButtonItem = rightButton

        navigationItem.searchController = searchController
    }
}

extension TrackerViewController {
    
    private func showOrHidePlaceholder() {
        let isNoData = dataManager.isCoreDataEmpty()
        isNoData ? showPlaceholder() : hidePlaceholder()
    }
    
    private func showPlaceholder() {
        if isSearching {
            searchNoTrackersPlaceholder.isHidden = false
            noTrackersPlaceholder.isHidden = true
            trackerCollectionView.isHidden = true
        } else {
            noTrackersPlaceholder.isHidden = false
            trackerCollectionView.isHidden = true
            searchNoTrackersPlaceholder.isHidden = true
        }
    }
    
    private func hidePlaceholder() {
        noTrackersPlaceholder.isHidden = true
        searchNoTrackersPlaceholder.isHidden = true
        trackerCollectionView.isHidden = false
        reloadCollection()
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
        
        cell.setupCell(id: trackerId, name: tracker.name, color: tracker.colorHex, emoji: tracker.emoji, completedDays: dayCompleted, isEnabled: isEnabled, isCompleted: isCompleted, indexPath: indexPath, date: correctDate, isPinned: tracker.isPinned)

        cell.dataUpdated = {
            collectionView.reloadData()
        }

        cell.delegate = self

        return cell
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
        withReuseIdentifier: TrackerViewHeader.identifier, for: indexPath) as? TrackerViewHeader {
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
    func pinOrUnpinTracker(id: UUID) {
        let isPinned = dataManager.isTrackerPinned(id: id)
        if !isPinned {
            dataManager.moveTrackerToPinnedCategory(trackerID: id)
        } else {
            dataManager.moveTrackerBackToCategory(trackerID: id)
        }
        dataManager.toggleTrackerPin(id: id)
    }

    func editTracker(id: UUID) {
        let editingVC = EditingTrackerViewController()
        editingVC.trackerID = id
        let navVC = UINavigationController(rootViewController: editingVC)
        present(navVC, animated: true)
    }
    
    func deleteTracker(id: UUID) {
        self.showAlert(id: id)
    }

    private func showAlert(id: UUID) {
        let alert = UIAlertController(title: "Do you really want to delete the Tracker".localizedString, message: nil, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "delete".localizedString, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteTrackerAndRecords(id)
        }

        let cancelAction = UIAlertAction(title: "cancel".localizedString, style: .cancel)
        [deleteAction, cancelAction].forEach { alert.addAction($0)}
        self.present(alert, animated: true)
    }

    private func deleteTrackerAndRecords(_ id: UUID) {
        dataManager.deleteTracker(id: id)
        dataManager.deleteTrackerRecords(id: id)
        getTrackersFromCD()
        reloadCollection()
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

extension TrackerViewController {
    @objc func closeFewVCAfterCreatingTracker() {
        getTrackersFromCD()
        reloadCollection()
        NotificationCenter.default.post(name: .trackerDataUpdated, object: nil)
        dismiss(animated: true)
    }
}

extension TrackerViewController: FilterViewControllerProtocol {
    func showFilteredTrackers() {
        let filter = dataManager.getSelectedFilter()

        switch filter {
        case "allTrackers".localizedString: getAllTrackersForDate()
        case "todayTrackers".localizedString: getTodayTrackers()
        case "completed".localizedString: getCompletedTrackers()
        case "inComplete".localizedString: getInCompletedTrackers()
        default: print("Smth's going wrong!")
        }

        showOrHidePlaceholder()
    }

    private func getAllTrackersForDate() {
        dataManager.getdataFromCoreData(weekday: weekDay)
    }

    private func getTodayTrackers() {
        currentDate = Date()
        let date = MainHelper.dateToString(date: currentDate)
        dateButton.setTitle(date, for: .normal)
        getTrackersFromCD()
    }

    private func getCompletedTrackers() {
        let completedTrackersID = getCompletedTrackersID()
        dataManager.getCompletedTrackersWithID(completedTrackerId: completedTrackersID, weekDay: weekDay)
    }

    private func getInCompletedTrackers() {
        let completedTrackersID = getCompletedTrackersID()
        dataManager.getInCompleteTrackersWithID(completedTrackerId: completedTrackersID, weekDay: weekDay)
    }

    private func getCompletedTrackersID() -> [String] {
        let completedTrackers =
        dataManager.getAllTrackerRecordForDate(date: currentDate)
        let completedTrackersID = completedTrackers.compactMap { $0 }
        return completedTrackersID
    }
}

extension TrackerViewController: TrackerDataManagerDelegate {
    func dataManagerDidUpdateData(_ manager: CoreDataManager) {
        trackerCollectionView.reloadData()
    }
}

extension TrackerViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.lowercased(), !text.isEmpty {
            dataManager.filteredData(text: text)
            reloadCollection()
            isSearching = true
            showOrHidePlaceholder()
        } else {
            getTrackersFromCD()
            isSearching = false
        }
    }
}
