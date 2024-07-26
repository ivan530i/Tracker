import UIKit

extension Int {
    func days() -> String {
        var dayString: String
        switch self {
        case 1:
            dayString = "день"
        case 2...4:
            dayString = "дня"
        default:
            dayString = "дней"
        }
        return "\(self) \(dayString)"
    }
}

