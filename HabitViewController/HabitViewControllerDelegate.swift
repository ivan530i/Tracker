import Foundation

protocol HabitViewControllerDelegate: AnyObject {
    func createNewHabit(header: String, tracker: Tracker)
}
