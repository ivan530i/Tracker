import UIKit

extension UIView {
    func addSubViews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}
