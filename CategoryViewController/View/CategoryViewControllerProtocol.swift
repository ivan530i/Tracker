import UIKit

protocol CategoryViewControllerProtocol: AnyObject {
    func showScreen(_ screen: UINavigationController)
    func isPlaceholderShown(_ : Bool)
}
