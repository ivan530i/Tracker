import Foundation

enum Weekdays: String, CaseIterable {
    case Monday = "monday"
    case Tuesday = "tuesday"
    case Wednesday = "wednesday"
    case Thursday = "thursday"
    case Friday = "friday"
    case Saturday = "saturday"
    case Sunday = "sunday"
    
    var localizedFullDayName: String {
            return self.rawValue.localizedString
        }
    
    var calendarDayNumber: Int {
        switch self {
        case .Sunday: return 1
        case .Monday: return 2
        case .Tuesday: return 3
        case .Wednesday: return 4
        case .Thursday: return 5
        case .Friday: return 6
        case .Saturday: return 7
        }
    }
    
    var shortDayName: String {
        switch self {
        case .Monday:
                    return "mon".localizedString
                case .Tuesday:
                    return "tues".localizedString
                case .Wednesday:
                    return "wed".localizedString
                case .Thursday:
                    return "thurs".localizedString
                case .Friday:
                    return "fri".localizedString
                case .Saturday:
                    return "sat".localizedString
                case .Sunday:
                    return  "sun".localizedString
        }
    }
}
