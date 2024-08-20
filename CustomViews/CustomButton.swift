import UIKit

final class CustomButton: UIButton {
    
    init(target: Any, action: Selector) {
        super.init(frame: .zero)
        setTitle("addCategory".localizedString, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        tintColor = .ypWhite
        backgroundColor = .ypBlack
        layer.cornerRadius = 16
        addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
}
