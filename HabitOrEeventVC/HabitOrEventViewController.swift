import UIKit

protocol CreateTypeTrackerDelegate: AnyObject {
    func plusTracker(tracker: Tracker, category: String, from: HabitOrEventViewController)
}

final class HabitOrEventViewController: UIViewController {
    
    weak var delegate: CreateTypeTrackerDelegate?
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private  var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private  var eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypWhite
        button.setTitle("Нерегулярные события", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private  var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupAllViews()
    }
    
    private func setupAllViews() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(eventButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func habitControllerCliked() {
        let viewController = HabitViewController(delegate: self)
        present(UINavigationController(rootViewController: viewController), animated:  true)
                print("Привычка")
    }
}

extension HabitOrEventViewController: HabitViewControllerDelegate {
    func createNewHabit(header: String, tracker: Tracker) {
        dismiss(animated: true)
        delegate?.plusTracker(tracker: tracker, category: "habit", from: self)
    }
}
