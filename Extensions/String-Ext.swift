import Foundation

extension String {
    var localizedString: String {
        return NSLocalizedString(self, comment: "")
    }
}
