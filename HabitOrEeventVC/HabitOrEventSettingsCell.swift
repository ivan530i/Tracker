import UIKit

final class HabitOrEventSettingsCell: UITableViewCell {
    
    private lazy var chevronImg: UIImageView = {
        return UIImageView(image: UIImage(named: "chevron"))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        self.detailTextLabel?.textColor = .ypGray
        setUpConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setUpConstraints() {
        let heightCell = contentView.heightAnchor.constraint(equalToConstant: 75)
        heightCell.priority = .defaultHigh
        contentView.addSubview(chevronImg)
        chevronImg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightCell,
            chevronImg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            chevronImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configureCell(model: ConfigureModel) {
        self.textLabel?.text = model.name
        self.detailTextLabel?.text = model.pickedSettings
    }
}
