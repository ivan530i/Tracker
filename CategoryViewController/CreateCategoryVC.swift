import UIKit

final class CreateCategoryVC: UIViewController {
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(buttonIsTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var trackerTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.backgroundColor = .ypBackground
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        applyConstraints()
        view.backgroundColor = .ypWhite
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
            
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            
            trackerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            trackerTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureView() {
        view.addSubview(headerLabel)
        view.addSubview(trackerTextField)
        view.addSubview(confirmButton)
    }
    
    @objc private func buttonIsTapped() {
        self.dismiss(animated: true)
    }
}

extension CreateCategoryVC: UITextFieldDelegate {
    func returnTextField(for textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
