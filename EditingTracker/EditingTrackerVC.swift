import UIKit

final class EditingTrackerViewController: UIViewController {
    
    lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.textAlignment = .left
        textField.layer.cornerRadius = 10
        textField.backgroundColor = .ypBackground
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.delegate = self
        return textField
    }()
    
    lazy var cancelButton: UIButton = {
        let button = setupButtons(title: "cancel".localizedString)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.setTitleColor(UIColor.ypRed, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButton = setupButtons(title: "save".localizedString)
    
    lazy var exceedLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    }()
    
    lazy var contentStackView: UIStackView = .init(.vertical, .equalCentering, .fill, 0, [])
    
    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let colorsCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let tableView = UITableView()
    let rowHeight = CGFloat(75)
    
    private let dataManager = CoreDataManager.shared
    private var trackerRecord = 0
    
    var tableViewRows = ["category".localizedString, "schedule".localizedString]
    
    var tracker: TrackerCD? = nil
    var chosenCategory = ""
    var schedule = ""
    var selectedEmoji = ""
    var selectedColor = ""
    var trackerName = ""
    var initialTrackerCategory = ""
    
    var emojiIndexPath: IndexPath? {
        guard let emoji = tracker?.emoji,
              let emojiIndex = MainHelper.arrayOfEmoji.firstIndex(of: emoji) else { print("Oops"); return nil}
        return IndexPath(row: emojiIndex, section: 0)
    }
    
    var colorIndexPath: IndexPath? {
        guard let color = tracker?.colorHex,
              let colorIndex = MainHelper.arrayOfColors.firstIndex(of: color) else { print("Oops"); return nil}
        return IndexPath(row: colorIndex, section: 0)
    }
    
    var trackerID = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        uploadTrackerFromCD()
        fillAllFieldsWithTrackerData()
        
        addTapGestureToHideKeyboard()
        
        isCreateButtonEnable()
    }
    
    @objc private func clearTextButtonTapped(_ sender: UIButton) {
        trackerNameTextField.text = ""
        isCreateButtonEnable()
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        dataManager.updateTracker(id: trackerID, name: trackerName, color: selectedColor, emoji: selectedEmoji, schedule: schedule, category: chosenCategory, initialCategory: initialTrackerCategory)
        dismiss(animated: true)
    }
    
    private func uploadTrackerFromCD() {
        tracker = dataManager.fetchTracker(by: trackerID)
        trackerRecord = dataManager.countOfTrackerInRecords(trackerIDToCount: trackerID)
    }
    
    private func fillAllFieldsWithTrackerData() {
        let daysCompleted = String.localizedStringWithFormat("numberOfDays".localizedString, trackerRecord)
        counterLabel.text = daysCompleted
        
        guard let tracker,
              let categoryName = tracker.category?.header,
              let name = tracker.name,
              let trackerSchedule = tracker.schedule,
              let emoji = tracker.emoji,
              let color = tracker.colorHex else { return }
        trackerNameTextField.text = name
        trackerName = name
        initialTrackerCategory = categoryName
        chosenCategory = categoryName
        schedule = trackerSchedule
        selectedEmoji = emoji
        selectedColor = color
    }
    
    private func areAllFieldsFilled() -> Bool {
        guard let text = trackerNameTextField.text, !text.isEmpty else { return false }
        
        return  (!chosenCategory.isEmpty &&
                 !schedule.isEmpty &&
                 !selectedEmoji.isEmpty &&
                 !selectedColor.isEmpty)
    }
    
    private func setupTextField() {
        let rightPaddingView = UIView()
        
        let clearTextFieldButton: UIButton = UIButton(type: .custom)
        let configuration = UIImage.SymbolConfiguration(pointSize: 17)
        let imageColor = UIColor.ypGray
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(imageColor)
        clearTextFieldButton.setImage(image, for: .normal)
        clearTextFieldButton.addTarget(self, action: #selector(clearTextButtonTapped), for: .touchUpInside)
        
        
        let clearTextStack: UIStackView = .init(.horizontal, .fill, .fill, 0, [clearTextFieldButton, rightPaddingView])
        clearTextStack.translatesAutoresizingMaskIntoConstraints = false
        clearTextStack.widthAnchor.constraint(equalToConstant: 28).isActive = true
        
        trackerNameTextField.rightView = clearTextStack
        trackerNameTextField.rightViewMode = .whileEditing
    }
    
    func isCreateButtonEnable() {
        let isOn = areAllFieldsFilled()
        saveButton.isEnabled = isOn
        saveButton.backgroundColor = isOn ? .ypBlack : .ypGray
    }
    
    private func setupUI() {
        self.title = "Editing the tracker".localizedString
        view.backgroundColor = .ypWhite
        
        setupTextField()
        setupContentStack()
        setupScrollView()
        setupTableView()
        setupEmojiCollectionView()
        setupColorsCollectionView()
    }
    
    private func setupButtons(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }
    
    func showLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = false
    }
    
    func hideLabelExceedTextFieldLimit() {
        exceedLabel.isHidden = true
    }
}
