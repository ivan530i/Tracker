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
            return localized(text: self.rawValue)
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
                    return localized(text: "mon")
                case .Tuesday:
                    return localized(text: "tues")
                case .Wednesday:
                    return localized(text: "wed")
                case .Thursday:
                    return localized(text: "thurs")
                case .Friday:
                    return localized(text: "fri")
                case .Saturday:
                    return localized(text: "sat")
                case .Sunday:
                    return localized(text: "sun")
        }
    }
}
