import UIKit

final class IrregularEventViewController: UIViewController {
    
    private lazy var textNameField: UITextField = {
        var textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var categoryTableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.register(HabitOrEventSettingsCell.self, forCellReuseIdentifier: HabitOrEventSettingsCell.identifier)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.estimatedRowHeight = rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
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
    
    private lazy var createButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.backgroundColor = .ypWhite
        button.tintColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        var stackView = UIStackView(.horizontal, .fillEqually, .fill, 8, [cancelButton, createButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var restrictionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiCollection = CustomCollection(identifier: "emojiCell", collection: .emoji)
    private lazy var colorsCollection = CustomCollection(identifier: "colorsCell", collection: .colors)
    
    private var configure: [ConfigureModel] = [
        ConfigureModel(name: "Категория", pickedSettings: "")
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: String?
    private var selectedCategory = ""
    
    private let rowHeight = CGFloat(75)
    
    private let dataManager = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionsDataBinding()
    }
    
    @objc func cancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonClicked() {
        createNewTracker()
        returnToMainScreen()
    }
    
    private func createNewTracker() {
        guard let name = textNameField.text,
              let color = selectedColor,
              let emoji = selectedEmoji else {
            print("Smth's going wrong here"); return }
        
        let newTask = Tracker(id: UUID(),
                              name: name,
                              color: color,
                              emoji: emoji,
                              schedule: "Пн, Вт, Ср, Чт, Пт, Сб, Вс")
        
        dataManager.createNewTracker(newTracker: newTask)
    }
    
    private func returnToMainScreen() {
        NotificationCenter.default.post(name: .returnToMainScreen, object: nil)
    }
    
    @objc private func clearTextFieldButtonClicked() {
        textNameField.text = ""
        clearTextFieldButton.isHidden = true
    }
    
    @objc private func textFieldDidChange() {
        if let text = textNameField.text, !text.isEmpty {
            clearTextFieldButton.isHidden = false
        } else {
            clearTextFieldButton.isHidden = true
        }
        if textNameField.text!.count >= 38 {
            restrictionLabel.isHidden = false
        } else {
            restrictionLabel.isHidden = true
        }
        makeCreateButtonEnable()
    }
    
    private func setupNavigationController() {
        title = "Новое нерегулярное событие"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        setupNavigationController()
        setupScrollView()
    }
    
    private func setupScrollView() {
        
        let screenScrollView = UIScrollView()
        
        view.addSubViews([screenScrollView])
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
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
    
    private func setupContentStack() -> UIStackView {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalCentering
        
        let textFieldViewStack = UIStackView()
        textFieldViewStack.axis = .vertical
        textFieldViewStack.spacing = 8
        [textNameField, restrictionLabel].forEach { textFieldViewStack.addArrangedSubview($0) }
        
        [textFieldViewStack, categoryTableView, emojiCollection,
         colorsCollection, buttonStackView].forEach { contentStackView.addArrangedSubview($0) }
        
        var tableViewHeight: CGFloat {
            rowHeight * CGFloat(configure.count)
        }
        
        NSLayoutConstraint.activate([
            textFieldViewStack.heightAnchor.constraint(equalToConstant: 75),
            
            categoryTableView.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            categoryTableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            
            emojiCollection.topAnchor.constraint(equalTo: categoryTableView.bottomAnchor),
            
            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 8),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return contentStackView
    }
    
    private func makeCreateButtonEnable() {
        if areAllFieldsFilled() {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    private func areAllFieldsFilled() -> Bool {
        guard let text = textNameField.text, !text.isEmpty else { return false }
        
        return  (!selectedCategory.isEmpty &&
                 selectedEmoji != nil &&
                 selectedColor != nil)
    }
}

extension IrregularEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension IrregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = CategoryViewModel()
        let viewController = CategoryViewController(viewModel: viewModel)
        viewModel.view = viewController
        
        viewModel.updateCategory = { [weak self] categoryName in
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            cell.detailTextLabel?.text = categoryName
            self?.selectedCategory = categoryName
        }
        
        goToCategoryVC(viewController)
    }
    
    private func goToCategoryVC(_ viewController: UIViewController) {
        let navVC = UINavigationController(rootViewController: viewController)
        present(navVC, animated: true)
    }
}

extension IrregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configure.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventSettingsCell.identifier, for: indexPath) as? HabitOrEventSettingsCell else {
            assertionFailure("Не удалось выполнить приведение к HabitOrEventSettingsCell")
            return UITableViewCell()
        }
        let setting = configure[indexPath.row]
        cell.configureCell(model: setting)
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        return cell
    }
}

extension IrregularEventViewController {
    
    func setupCollectionsDataBinding() {
        emojiCollection.didSelectItem = { [weak self] selectedEmoji in
            self?.selectedEmoji = selectedEmoji
            self?.makeCreateButtonEnable()
        }
        colorsCollection.didSelectItem = { [weak self] selectedColor in
            self?.selectedColor = selectedColor
            self?.makeCreateButtonEnable()
        }
    }
}
