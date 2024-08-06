import UIKit

final class scheduleCell: UITableViewCell {
    
    weak var delegate: ScheduleCellDelegate?
    
    private var weekDay: Weekdays?
    
    private lazy var cellTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switchButton: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.addTarget(self, action: #selector(switchButtonTapped(_:)), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with weekDay: Weekdays, isLastCell: Bool, isSelected: Bool) {
        self.weekDay = weekDay
        cellTitleLabel.text = weekDay.rawValue
        separatorView.isHidden = isLastCell
        switchButton.isOn = isSelected
    }
    
    private func setupViews() {
        contentView.backgroundColor = .ypBackground
        contentView.addSubview(cellTitleLabel)
        contentView.addSubview(switchButton)
        contentView.addSubview(separatorView)
    }
    
    private func setupConstraints() {
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 75)
        contentViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            cellTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            cellTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellTitleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            switchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchButton.centerYAnchor.constraint(equalTo: cellTitleLabel.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc private func switchButtonTapped(_ sender: UISwitch) {
        guard let weekDay = weekDay else { return }
        delegate?.switchButtonClicked(to: sender.isOn, of: weekDay)
    }
}
