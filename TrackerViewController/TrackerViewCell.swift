import UIKit

protocol TrackerViewCellDelegate: AnyObject {
    func trackerCompleted(id: UUID, indexPath: IndexPath)
}

final class TrackerViewCell: UICollectionViewCell {
    
    weak var delegate: TrackerViewCellDelegate?
    
    private let buttonPlus = UIImage(named: "PlusButton")
    private let doneButton = UIImage(named: "ButtonDone")
    private var indexPath: IndexPath?
    private var trackerId: UUID? = nil
    private var isCompleted: Bool = false
    
    static let identifier = "trackerCell"
    
    private lazy var trackerView: UIView = {
        var view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var textOnTrackerLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 14
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .ypBackground
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var dayWithButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var dayLabel: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.imageEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        button.tintColor = .ypWhite
        button.backgroundColor = trackerView.backgroundColor
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setViews() {
        contentView.addSubview(trackerView)
        contentView.addSubview(dayWithButtonView)
        trackerView.addSubview(emojiLabel)
        trackerView.addSubview(textOnTrackerLabel)
        dayWithButtonView.addSubview(dayLabel)
        dayWithButtonView.addSubview(plusButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            trackerView.widthAnchor.constraint(equalToConstant: 167),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 28),
            emojiLabel.widthAnchor.constraint(equalToConstant: 28),
            
            textOnTrackerLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            textOnTrackerLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            textOnTrackerLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            textOnTrackerLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            
            dayWithButtonView.topAnchor.constraint(equalTo: trackerView.bottomAnchor),
            dayWithButtonView.widthAnchor.constraint(equalToConstant: 167),
            dayWithButtonView.heightAnchor.constraint(equalToConstant: 58),
            dayLabel.topAnchor.constraint(equalTo: dayWithButtonView.topAnchor, constant: 8),
            dayLabel.leadingAnchor.constraint(equalTo: dayWithButtonView.leadingAnchor, constant: 12),
            dayLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            dayLabel.bottomAnchor.constraint(equalTo: dayWithButtonView.bottomAnchor, constant: -16),
            
            plusButton.topAnchor.constraint(equalTo: dayWithButtonView.topAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: dayWithButtonView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    func setupCell(id: UUID, name: String, color: UIColor, emoji: String, completedDays: Int, isEnabled: Bool, isCompleted: Bool, indexPath: IndexPath) {
        self.trackerId = id
        self.textOnTrackerLabel.text = name
        self.trackerView.backgroundColor = color
        self.emojiLabel.text = emoji
        self.dayLabel.text = "\(completedDays.days())"
        self.plusButton.backgroundColor = color
        self.plusButton.tintColor = .white
        self.plusButton.setImage(isCompleted ? doneButton : buttonPlus, for: .normal)
        self.plusButton.alpha = isCompleted ? 0.3 : 1
        self.indexPath = indexPath
        self.isCompleted = isCompleted
    }
    
    @objc private func plusButtonTapped() {
        guard let id = trackerId, let indexPath = indexPath else { return }
        delegate?.trackerCompleted(id: id, indexPath: indexPath)
    }
}

extension Int {
    func days() -> String {
        var dayString: String
        switch self {
        case 1:
            dayString = "день"
        case 2...4:
            dayString = "дня"
        default:
            dayString = "дней"
        }
        return "\(self) \(dayString)"
    }
}
