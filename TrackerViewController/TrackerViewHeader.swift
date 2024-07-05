import UIKit

final class TrackerViewHeader: UICollectionReusableView {
    
    static let identifier = "trackerHeader"
    
    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        addSubview(topLabel)
        NSLayoutConstraint.activate([
            topLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            topLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            topLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }
}
