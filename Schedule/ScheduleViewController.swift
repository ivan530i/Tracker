import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [Weekdays])
}

protocol ScheduleCellDelegate: AnyObject {
    func switchButtonClicked(to isSelected: Bool, of weekDay: Weekdays)
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private var selectedWeekDays: Set<Weekdays> = []
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(scheduleCell.self, forCellReuseIdentifier: scheduleCell.cellIdentifier)
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupView()
        setupConstraints()
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
    }
    
    private func setupView() {
        view.addSubview(scheduleTableView)
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
            var constraints = [NSLayoutConstraint]()
            
            constraints.append(scheduleTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30))
            constraints.append(scheduleTableView.heightAnchor.constraint(equalToConstant: 525))
            constraints.append(scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
            constraints.append(scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
            
            constraints.append(titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
            constraints.append(titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38))
            constraints.append(titleLabel.heightAnchor.constraint(equalToConstant: 22))
            
            constraints.append(doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
            constraints.append(doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
            constraints.append(doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
            constraints.append(doneButton.heightAnchor.constraint(equalToConstant: 60))
            
            NSLayoutConstraint.activate(constraints)
        }
    
    @objc private func doneButtonTapped() {
        let weekDays = Array(selectedWeekDays)
                delegate?.didSelectDays(weekDays)
                self.dismiss(animated: true)
    }
}

extension ScheduleViewController: ScheduleCellDelegate {
    func switchButtonClicked(to isSelected: Bool, of weekDay: Weekdays) {
        if isSelected {
            selectedWeekDays.insert(weekDay)
        } else {
            selectedWeekDays.remove(weekDay)
        }
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekdays.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: scheduleCell.cellIdentifier, for: indexPath) as? scheduleCell else {
            fatalError("Не удалось найти ячейку ScheduleCell")
        }
        cell.delegate = self
        cell.selectionStyle = .none
        let weekDay = Weekdays.allCases[indexPath.row]
        cell.configureCell(
            with: weekDay,
            isLastCell: indexPath.row == 6,
            isSelected: selectedWeekDays.contains(weekDay)
        )
        return cell
    }
}
