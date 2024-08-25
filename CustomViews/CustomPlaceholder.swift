import UIKit

final class CustomPlaceholder: UIStackView {
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(labelText: String = "categoryPlaceHolder".localizedString, imageName: String = "stubIMG") {
        super.init(frame: .zero)
        self.placeholderLabel.text = labelText
        self.placeholderImageView.image = UIImage(named: imageName)
        setupPlaceholder()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlaceholder()  {
        let emptyScreenStack = UIStackView(.vertical, .fill, .center, 8, [placeholderImageView, placeholderLabel])
        
        addSubViews([emptyScreenStack])
        
        NSLayoutConstraint.activate([
            emptyScreenStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func setupLayout(_ view: UIView) {
        view.addSubViews([self])
        
        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
