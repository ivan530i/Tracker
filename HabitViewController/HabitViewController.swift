import UIKit

final class HabitViewController: UIViewController {
    
    private var trackerId: UUID?
    private var isEditingMode = false
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .ypBlack
        textField.backgroundColor = .ypBackground
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var clearTextFieldButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "error_clear"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(clearTextFieldButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var habitOrScheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HabitOrEventSettingsCell.self, forCellReuseIdentifier: HabitOrEventSettingsCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private lazy var restrictionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.backgroundColor = .ypWhite
        button.tintColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelButtonIsClicked), for: .touchUpInside)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        return stackView
    }()
    
    private lazy var emojiCollection = CustomCollection(identifier: "emojiCell", collection: .emoji)
    private lazy var colorsCollection = CustomCollection(identifier: "colorsCell", collection: .colors)
    
    weak var delegate: HabitViewControllerDelegate?
    weak var scheduleViewControllerDelegate: ScheduleViewControllerDelegate?
    
    private var schedules: [Weekdays] = []
    private var selectedEmoji: String?
    private var selectedColor: String?
    private let rowHeight = CGFloat(75)
    
    private var selectedCategory = ""
    
    private lazy var habit: [(name: String, pickedSettings: String)] = [
        (name: "Категория", pickedSettings: ""),
        (name: "Расписание", pickedSettings: "")
    ]
    
    private let dataManager = CoreDataManager.shared
    
    init(delegate: HabitViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(trackerId: UUID?) {
        self.trackerId = trackerId
        self.isEditingMode = trackerId != nil
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setViews()
        setupCollectionsDataBinding()
        setupScrollView()
        
        if isEditingMode {
            loadTrackerData()
        }
    }
    
    private func loadTrackerData() {
        guard let trackerId = trackerId else { return }
        
        if let tracker = dataManager.fetchTracker(by: trackerId) {
            textField.text = tracker.name
            
            selectedColor = tracker.colorHex ?? ""
            selectedEmoji = tracker.emoji ?? ""
            
            habit[1].pickedSettings = tracker.schedule ?? ""
            
            if let category = tracker.category {
                selectedCategory = category.header ?? ""
            } else {
                selectedCategory = ""
            }
            checkIfCorrect()
        }
    }
    
    @objc private func clearTextFieldButtonClicked() {
        textField.text = ""
        clearTextFieldButton.isHidden = true
    }
    
    @objc private func textFieldChanged(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            clearTextFieldButton.isHidden = false
        } else {
            clearTextFieldButton.isHidden = true
        }
        if let text = textField.text, text.count >= 38 {
            restrictionLabel.isHidden = false
        } else {
            restrictionLabel.isHidden = true
        }
        checkIfCorrect()
    }
    
    @objc private func cancelButtonIsClicked() {
        returnToMainScreen()
    }
    
    @objc private func createButtonClicked() {
        if isEditingMode {
            updateTracker()
        } else {
            createNewTracker()
        }
        returnToMainScreen()
    }
    
    private func updateTracker() {
        guard let trackerId = trackerId,
              let name = textField.text,
              let color = selectedColor,
              let emoji = selectedEmoji else {
            print("Ошибка при обновлении трекера")
            return
        }
        
        dataManager.updateTracker(id: trackerId, name: name, color: color, emoji: emoji, schedule: habit[1].pickedSettings)
    }
    
    private func createNewTracker() {
        guard let name = textField.text,
              let color = selectedColor,
              let emoji = selectedEmoji else {
            print("Smth's going wrong here"); return }
        
        let newTask = Tracker(id: UUID(),
                              name: name,
                              color: color,
                              emoji: emoji,
                              schedule: habit[1].pickedSettings)
        
        dataManager.createNewTracker(newTracker: newTask)
    }
    
    private func updateCategoryFromCD() {
        selectedCategory = dataManager.selectedCategory
    }
    
    private func setupNavigationController() {
        if isEditingMode {
            title = "Редактировать привычку"
            createButton.setTitle("Сохранить", for: .normal)
        } else {
            title = "Новая привычка"
            createButton.setTitle("Создать", for: .normal)
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    private func setViews() {
        view.backgroundColor = .ypWhite
    }
    
    private func checkIfCorrect() {
        if areAllFieldsFilled() {
            print("YES")
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            print("NO")
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    private func areAllFieldsFilled() -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        
        return  (!selectedCategory.isEmpty &&
                 !schedules.isEmpty &&
                 selectedEmoji != nil &&
                 selectedColor != nil)
    }
    
    private func returnToMainScreen() {
        NotificationCenter.default.post(name: .returnToMainScreen, object: nil)
    }
}

extension HabitViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension HabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewModel = CategoryViewModel()
            let viewController = CategoryViewController(viewModel: viewModel)
            viewModel.view = viewController
            goToCategoryVC(viewController)
            
            viewModel.updateCategory = { [weak self] categoryName in
                guard let cell = tableView.cellForRow(at: indexPath) else { return }
                cell.detailTextLabel?.text = categoryName
                self?.selectedCategory = categoryName
            }
        } else {
            goToScheduleVC()
        }
        checkIfCorrect()
    }
    
    private func goToCategoryVC(_ viewController: UIViewController) {
        let navVC = UINavigationController(rootViewController: viewController)
        present(navVC, animated: true)
    }
    
    private func goToScheduleVC() {
        let viewController = ScheduleViewController()
        viewController.delegate = self
        self.scheduleViewControllerDelegate?.didSelectDays(self.schedules)
        self.present(viewController, animated: true)
    }
}

extension HabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habit.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventSettingsCell.identifier, for: indexPath) as? HabitOrEventSettingsCell else {
            assertionFailure("Не удалось выполнить приведение к HabitOrEventSettingsCell")
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = habit[indexPath.row].name
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = dataManager.selectedCategory
        } else {
            cell.detailTextLabel?.text = habit[indexPath.row].pickedSettings
        }
        
        cell.backgroundColor = .ypBackground
        return cell
    }
}

extension HabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [Weekdays]) {
        schedules = days
        let schedule = days.isEmpty ? "" : days.map { $0.shortDayName }.joined(separator: ", ")
        habit[1].pickedSettings = schedule
        habitOrScheduleTableView.reloadData()
        dismiss(animated: true)
        checkIfCorrect()
    }
}

extension HabitViewController {
    
    func setupContentStack() -> UIStackView {
        
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalCentering
        
        let textFieldViewStack = UIStackView()
        textFieldViewStack.axis = .vertical
        textFieldViewStack.spacing = 8
        [textField, restrictionLabel].forEach { textFieldViewStack.addArrangedSubview($0) }
        
        [textFieldViewStack, habitOrScheduleTableView, emojiCollection,
         colorsCollection, buttonStackView].forEach { contentStackView.addArrangedSubview($0) }
        
        var tableViewHeight: CGFloat {
            rowHeight * CGFloat(habit.count)
        }
        
        NSLayoutConstraint.activate([
            textFieldViewStack.heightAnchor.constraint(equalToConstant: 75),
            
            habitOrScheduleTableView.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            habitOrScheduleTableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            
            emojiCollection.topAnchor.constraint(equalTo: habitOrScheduleTableView.bottomAnchor),
            
            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 8),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return contentStackView
    }
    
    func setupScrollView() {
        
        let screenScrollView = UIScrollView()
        
        view.addSubViews([screenScrollView])
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let contentView = UIView()
        
        screenScrollView.addSubViews([contentView])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor)
        ])
        
        let contentStackView = setupContentStack()
        
        contentView.addSubViews([contentStackView])
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
}

extension HabitViewController {
    
    func setupCollectionsDataBinding() {
        emojiCollection.didSelectItem = { [weak self] selectedEmoji in
            self?.selectedEmoji = selectedEmoji
            self?.checkIfCorrect()
        }
        colorsCollection.didSelectItem = { [weak self] selectedColor in
            self?.selectedColor = selectedColor
            self?.checkIfCorrect()
        }
    }
}
