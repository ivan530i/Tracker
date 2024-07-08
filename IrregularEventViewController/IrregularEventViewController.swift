import UIKit

final class IrregularEventViewController: UIViewController {
    
    weak var delegate: TrackerCreateViewControllerDelegate?
    
    private var configure: [ConfigureModel] = [
        ConfigureModel(name: "Категория", pickedSettings: "")
    ]
    
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    private var categoryTableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.register(HabitOrEventSettingsCell.self, forCellReuseIdentifier: HabitOrEventSettingsCell.cellIdentifer)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    
    private var createButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var cancelButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.backgroundColor = .ypWhite
        button.tintColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var buttonStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setUpViews()
        setUpConstraints()
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }
    
    private func setUpViews() {
        view.addSubview(titleLabel)
        view.addSubview(textNameField)
        view.addSubview(restrictionLabel)
        view.addSubview(categoryTableView)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            
            textNameField.heightAnchor.constraint(equalToConstant: 75),
            textNameField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textNameField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textNameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            
            restrictionLabel.topAnchor.constraint(equalTo: textNameField.bottomAnchor, constant: 8),
            restrictionLabel.leftAnchor.constraint(equalTo: textNameField.leftAnchor, constant: 28),
            restrictionLabel.rightAnchor.constraint(equalTo: textNameField.rightAnchor, constant: -28),
            
            categoryTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTableView.topAnchor.constraint(equalTo: textNameField.bottomAnchor, constant: 24),
            categoryTableView.heightAnchor.constraint(equalToConstant: 75),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func checkIfCorrect() {
        if let text = textNameField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .ypBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .ypGray
        }
    }
    
    @objc func cancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
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
        checkIfCorrect()
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
        if indexPath.row == 0 {
            let viewController = CategoryViewController()
            self.present(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        checkIfCorrect()
    }
}

extension IrregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configure.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitOrEventSettingsCell.cellIdentifer, for: indexPath) as? HabitOrEventSettingsCell else {
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
