import Foundation

extension CoreDataManager {

    func getAllTrackerRecordForDate(date: Date) -> [String?] {
        let shortDate = MainHelper.dateToShortDate(date: date)
        let request = TrackerRecordCD.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCD.date),
                                    shortDate as CVarArg)
        request.predicate = predicate
        request.propertiesToFetch = ["id"]

        var result = [String?]()
        do {
            let data = try context.fetch(request)
            for tracker in data {
                result.append(tracker.id?.uuidString)
            }
            return result
        } catch {
            print("\(error.localizedDescription) 🟥")
            return ["Ooops"]
        }
    }

    func getCompletedTrackersWithID(completedTrackerId: [String], weekDay: String) {
        let predicate1 = NSPredicate(format: "id IN %@", completedTrackerId)
        let predicate2 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        let sort = NSSortDescriptor(key: "category.header", ascending: true)

        updateFRC(predicate: compoundPredicate, sort: sort)
    }

    func getInCompletedTrackersWithID(completedTrackerId: [String]) {
        let predicate = NSPredicate(format: "NOT (id IN %@)", completedTrackerId)
        updateFRC(predicate: predicate)
    }


    private func updateFRC(predicate: NSPredicate, sort: NSSortDescriptor = NSSortDescriptor(key: "category.header", ascending: true)) {
        guard let trackersFRC else { print("🟥 NSFetchedResultsController is nil")
            return }

        trackersFRC.fetchRequest.predicate = predicate
        trackersFRC.fetchRequest.sortDescriptors = [sort]

        do {
            try trackersFRC.performFetch()
        } catch {
            print("🟥 \(error.localizedDescription)")
        }

    }

}
