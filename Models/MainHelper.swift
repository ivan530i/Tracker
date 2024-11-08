import UIKit

struct MainHelper {
    
    static func getWeekdayFromCurrentDate(currentDate: Date) -> String {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.weekday], from: currentDate)
        let weekDay = dateComponents.weekday
        let weekDayString = dayNumberToDayString(weekDayNumber: weekDay)
        return weekDayString
    }
    
    static private func dayNumberToDayString(weekDayNumber: Int?) -> String {
        guard let weekDayNumber = weekDayNumber else { return "" }
                
                let weekDay: [Int: String] = [
                    1: "sun".localizedString,
                    2: "mon".localizedString,
                    3: "tues".localizedString,
                    4: "wed".localizedString,
                    5: "thurs".localizedString,
                    6: "fri".localizedString,
                    7: "sat".localizedString
                ]
                
                guard let result = weekDay[weekDayNumber] else { return "" }
                return result
    }
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let dateToString = formatter.string(from: date)
        return dateToString
    }
    
    static func dateToShortDate(date: Date) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        let dateToString = formatter.string(from: date)
        guard let shortDate = formatter.date(from: dateToString) else { return Date()}
        return shortDate
    }
    
    static func stringToDate(string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let stringToDate = formatter.date(from: string)
        return stringToDate
    }
    
    static let arrayOfEmoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                               "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                               "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    static let arrayOfColors = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
                                "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
                                "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
}
