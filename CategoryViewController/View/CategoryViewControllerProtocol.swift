import UIKit

protocol CategoryViewControllerProtocol: AnyObject {
    func showScreen(_ screen: UINavigationController)
    func showPlaceholder()
    func hidePlaceholder()
}
