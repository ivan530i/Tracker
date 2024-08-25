import UIKit

extension EditingTrackerViewController {
    
    func setupScrollView() {
        
        let screenScrollView = UIScrollView()
        let contentView = UIView()
        
        view.addSubViews([screenScrollView])
        screenScrollView.addSubViews([contentView])
        contentView.addSubViews([contentStackView])
        
        NSLayoutConstraint.activate([
            screenScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            screenScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            screenScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            screenScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: screenScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: screenScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: screenScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: screenScrollView.widthAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    func setupContentStack() {
        
        let textFieldViewStack: UIStackView = .init(.vertical, .fill, .fill, 10, [trackerNameTextField, exceedLabel])
        
        saveButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let buttonsStack: UIStackView = .init(.horizontal, .fillEqually, .fill, 8, [cancelButton, saveButton])
        
        [contentStackView, counterLabel, tableView, emojiCollection, colorsCollection, buttonsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [counterLabel, textFieldViewStack, tableView, emojiCollection, colorsCollection, buttonsStack].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
            
            counterLabel.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            counterLabel.heightAnchor.constraint(equalToConstant: 75),
            
            textFieldViewStack.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40),
            textFieldViewStack.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textFieldViewStack.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: 222),
            
            colorsCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor),
            colorsCollection.heightAnchor.constraint(equalToConstant: 222),
            
            buttonsStack.topAnchor.constraint(equalTo: colorsCollection.bottomAnchor, constant: 16),
            buttonsStack.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor)
        ])
    }
}
