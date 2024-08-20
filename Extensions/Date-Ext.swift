import Foundation

extension Date {
    var onlyDate: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
