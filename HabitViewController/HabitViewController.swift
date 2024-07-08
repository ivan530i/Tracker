import UIKit

protocol HabitViewControllerDelegate: AnyObject {
    func createNewHabit(header: String, tracker: Tracker)
}

final class HabitViewController: UIViewController {
    
    weak var delegate: HabitViewControllerDelegate?
    weak var scheduleViewControllerDelegate: ScheduleViewControllerDelegate?
    
    var schedules: [Weekdays] = []
    var category: String = ""
    
    init(delegate: HabitViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var habit: [(name: String, pickedSettings: String)] = [
        (name: "Категория", pickedSettings: ""),
        (name: "Расписание", pickedSettings: "")
    ]
    
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Новая привычка"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        var textField = UITextField()
        textField.textColor = .ypBlack
        textField.backgroundColor = .ypBackground
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.leftViewMode = .always
        textField.leftView = leftView
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
    
    private var habitOrScheduleTableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.register(HabitOrEventSettingsCell.self, forCellReuseIdentifier: HabitOrEventSettingsCell.cellIdentifer)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
        button.tintColor = .ypWhite
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
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setViews()
        setUpConstraints()
        habitOrScheduleTableView.delegate = self
        habitOrScheduleTableView.dataSource = self
    }
    
    private func setViews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(restrictionLabel)
        view.addSubview(habitOrScheduleTableView)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            
            restrictionLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            restrictionLabel.leftAnchor.constraint(equalTo: textField.leftAnchor, constant: 28),
            restrictionLabel.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: -28),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            habitOrScheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            habitOrScheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            habitOrScheduleTableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            habitOrScheduleTableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func checkIfCorrect() {
        if let text = textField.text, !text.isEmpty || !schedules.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
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
        if textField.text!.count >= 38 {
            restrictionLabel.isHidden = false
        } else {
            restrictionLabel.isHidden = true
        }
        checkIfCorrect()
    }
    
    
    @objc private func cancelButtonIsClicked() {
        dismiss(animated: true)
        print("Отменить")
    }
    
    @objc private func createButtonClicked() {
        guard let trackerName = textField.text else { return }
        let newHabit = Tracker(id: UUID(), name: trackerName, color: .cSelection18, emoji: "❤️️️️️️️", schedule: schedules)
        self.delegate?.createNewHabit(header: category, tracker: newHabit)
        dismiss(animated: true)
        print("Создать")
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
            if indexPath.row == 0{
                let viewController = CategoryViewController()
                self.present(viewController, animated: true)
            } else if indexPath.row == 1 {
                let viewController = ScheduleViewController()
                viewController.delegate = self
                self.scheduleViewControllerDelegate?.didSelectDays(self.schedules)
                self.present(viewController, animated: true)
            }
            tableView.deselectRow(at: indexPath, animated: true)
            checkIfCorrect()
        }
    }

extension HabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habit.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventSettingsCell.cellIdentifer, for: indexPath) as? HabitOrEventSettingsCell else {
            assertionFailure("Не удалось выполнить приведение к HabitOrEventSettingsCell")
            return UITableViewCell()
        }
        cell.textLabel?.text = habit[indexPath.row].name
        cell.detailTextLabel?.text = habit[indexPath.row].pickedSettings
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
    }
}
