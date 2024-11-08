import UIKit

protocol TrackerViewCellDelegate: AnyObject {
    func pinOrUnpinTracker(id: UUID)
    func editTracker(id: UUID)
    func deleteTracker(id: UUID)
}

final class TrackerViewCell: UICollectionViewCell {
    
    private lazy var trackerView: UIView = {
        var view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(contextMenuInteraction)
        return view
    }()
    
    private lazy var textOnTrackerLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 14
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var dayWithButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayLabel: UILabel = {
        var label = UILabel()
        label.textColor = .ypBlack
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
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var pinImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.isHidden = true
        return imageView
    }()

    static let identifier = "trackerCell"

    weak var delegate: TrackerViewCellDelegate?

    private let analyticsService = AnalyticsService()
    private let dataManager = CoreDataManager.shared
    
    private let buttonPlus = UIImage(named: "PlusButton")
    private let doneButton = UIImage(named: "ButtonDone")
    private var indexPath: IndexPath?
    private var isCompleted: Bool = false
    private var date = Date()
    
    var trackerId = UUID()
    var dataUpdated: ( () -> Void )?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func plusButtonTapped() {
        if isCompleted {
            let trackerRecordToRemove = TrackerRecord(id: trackerId, date: date)
            dataManager.removeTrackerRecordForThisDay(trackerToRemove: trackerRecordToRemove)
            dataUpdated?()
        } else {
            let trackerRecordToAdd = TrackerRecord(id: trackerId, date: date)
            dataManager.addTrackerRecord(trackerRecordToAdd: trackerRecordToAdd)
            dataUpdated?()
        }
        analyticsService.report("click", params: ["screen": "Main", "item": "track"])
    }

    func setupCell(id: UUID, name: String?, color: String?, emoji: String?, completedDays: Int, isEnabled: Bool, isCompleted: Bool, indexPath: IndexPath, date: Date, isPinned: Bool) {
        guard let color else { return }
        let cellColor = UIColor(hex: color)
        let daysCompleted = String.localizedStringWithFormat("numberOfDays".localizedString, completedDays)

        trackerId = id
        textOnTrackerLabel.text = name
        trackerView.backgroundColor = cellColor
        emojiLabel.text = emoji
        dayLabel.text = daysCompleted
        plusButton.backgroundColor = cellColor
        plusButton.setImage(isCompleted ? doneButton : buttonPlus, for: .normal)
        plusButton.alpha = isCompleted ? 0.3 : 1
        plusButton.isEnabled = isEnabled
        pinImage.isHidden = !isPinned

        self.indexPath = indexPath
        self.isCompleted = isCompleted
        self.date = date
    }

    private func setViews() {
        contentView.addSubview(trackerView)
        contentView.addSubview(dayWithButtonView)
        trackerView.addSubview(emojiLabel)
        trackerView.addSubview(textOnTrackerLabel)
        trackerView.addSubViews([pinImage])
        dayWithButtonView.addSubview(dayLabel)
        dayWithButtonView.addSubview(plusButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 28),
            emojiLabel.widthAnchor.constraint(equalToConstant: 28),
            
            textOnTrackerLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            textOnTrackerLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            textOnTrackerLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            textOnTrackerLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),

            pinImage.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 18),
            pinImage.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),

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
    
    private func isPinned() -> Bool {
        return CoreDataManager.shared.isTrackerPinned(id: trackerId)
    }
}

extension TrackerViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let trackerId = self.trackerId

        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pinActionTitle = self.isPinned() ? NSLocalizedString("unpin", comment: "Unpin tracker") : NSLocalizedString("pin", comment: "Pin tracker")
            
            let pinAction = UIAction(title: pinActionTitle) { [weak self] _ in
                self?.delegate?.pinOrUnpinTracker(id: trackerId)
            }
            
            let editAction = UIAction(title: NSLocalizedString("edit", comment: "Edit tracker")) { [weak self] _ in
                self?.delegate?.editTracker(id: trackerId)
                self?.analyticsService.report("editTrackerButtonTapped", params: ["event": "click", "screen": "Main", "item": "edit"])
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("delete", comment: "Delete tracker"), attributes: .destructive) { [weak self] _ in
                self?.delegate?.deleteTracker(id: trackerId)
                self?.analyticsService.report("deleteTrackerButtonTapped", params: ["event": "click", "screen": "Main", "item": "delete"])
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }

        return configuration
    }
}
