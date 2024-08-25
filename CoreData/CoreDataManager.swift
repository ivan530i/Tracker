import Foundation
import CoreData

protocol TrackerDataManagerDelegate: AnyObject {
    func dataManagerDidUpdateData(_ manager: CoreDataManager)
}

final class CoreDataManager: NSObject {
    static let shared = CoreDataManager()

    private override init () { }

    private var trackersFromCoreData = [TrackerCD]()
    private var categoriesFromCoreData = [TrackerCategoryCD]()

    var selectedCategory = ""
    var selectedFilter = "allTrackers".localizedString
    weak var delegate: TrackerDataManagerDelegate?

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("🔴 Unresolved error \(error), \(error.userInfo)")
            } else {
                print("✅ CoreData loaded successfully")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var trackersFRC: NSFetchedResultsController<TrackerCD>?

    func setupTrackerFRC(request: NSFetchRequest<TrackerCD>) {
        trackersFRC = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.header",
            cacheName: nil)

        trackersFRC?.delegate = self

        do {
            try trackersFRC?.performFetch()
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }

    func fetchTrackers() {
        let request = TrackerCD.fetchRequest()
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        setupTrackerFRC(request: request)
    }

    func getAllTrackersForWeekday(weekDay: String) {
        let request = TrackerCD.fetchRequest()

        let predicate = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        request.predicate = predicate

        let sortByPinned = NSSortDescriptor(key: "isPinned", ascending: false)
        request.sortDescriptors = [sortByPinned]

        setupTrackerFRC(request: request)
    }

    func isCoreDataEmpty() -> Bool {
        if let sections = trackersFRC?.sections, sections.count > 0 {
            return false
        } else {
            return true
        }
    }

    private func fetchCategories() {
        let request = TrackerCategoryCD.fetchRequest()
        let sort = NSSortDescriptor(key: "header", ascending: true)
        request.sortDescriptors = [sort]

        do {
            categoriesFromCoreData = try context.fetch(request)
            print("✅ Categories uploaded successfully")
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }

    func createNewCategory(newCategoryName: String) {
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.header = newCategoryName
        save()
        print("✅ New category created successfully")
        fetchCategories()
    }

    func createNewTracker(newTracker: Tracker, category: String? = nil) {
        let categoryToUse = category ?? selectedCategory

        let request = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "header = %@", categoryToUse)

        do {
            let result = try context.fetch(request)
            guard let category = result.first else {
                print("We don't have this category")
                return
            }

            let newTask = TrackerCD(context: context)
            newTask.id = newTracker.id
            newTask.colorHex = newTracker.color
            newTask.emoji = newTracker.emoji
            newTask.name = newTracker.name
            newTask.schedule = newTracker.schedule
            newTask.isPinned = newTracker.isPinned

            newTask.category = category
            category.addToTrackers(newTask)

            save()
            print("✅ New tracker created successfully")
            fetchTrackers()
        } catch {
            print("🔴 \(error.localizedDescription)")
        }
    }

    func getdataFromCoreData(weekday: String) {
        getAllTrackersForWeekday(weekDay: weekday)
    }

    func getCategoriesFromCoreData() -> [TrackerCategoryCD] {
        fetchCategories()
        return categoriesFromCoreData
    }

    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("🟥 Error saving context: \(error), \(error.userInfo)")
            }
        }
    }

    func setChosenCategory(categoryName: String) {
        self.selectedCategory = categoryName
    }

    func setChosenFilter(filterName: String) {
        self.selectedFilter = filterName
    }

    func getSelectedFilter() -> String {
        selectedFilter
    }

    func filteredData(text: String) {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS %@", text)
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]

        setupTrackerFRC(request: request)
    }

    func printAllTrackersInCoreData() {
        let fetchRequest = TrackerCD.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)

            if !allTrackers.isEmpty {
                allTrackers.forEach { tracker in
                    guard let name = tracker.name,
                          let _ = tracker.schedule else { return }
                    print("Name \(name) - isPinned \(tracker.isPinned)")
                }
            } else {
                print("No trackers in CoreData")
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }

    func toggleTrackerPin(id: UUID) {
        let tracker = fetchTracker(by: id)
        tracker?.isPinned.toggle()
        save()
        print("✅ Tracker marked as pinned / unpinned")
    }

    func deleteTracker(id: UUID) {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let tracker = try context.fetch(request).first {
                context.delete(tracker)
                save()
                print("✅ Tracker deleted successfully")
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }

    func deleteTrackerRecords(id: UUID) {
        let request = TrackerRecordCD.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCD.id), id as CVarArg)
        request.predicate = predicate

        do {
            let result = try context.fetch(request)
            for tracker in result {
                context.delete(tracker)
                save()
            }
            print("✅ All records for Tracker removed")
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }

    func updateTracker(id: UUID, name: String, color: String, emoji: String, schedule: String, category: String, initialCategory: String) {
        let trackerToUpdate = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)

        if isCategoryChanged(initialCategory, category) {
            changeTrackerCategory(trackerID: id, newCategoryName: category, oldCategoryName: initialCategory)
        } else {
            updateTrackerData(trackerToUpdate: trackerToUpdate)
        }
    }

    func changeTrackerCategory(trackerID: UUID, newCategoryName: String, oldCategoryName: String) {
        guard let tracker = fetchTracker(by: trackerID),
              let oldCategory = fetchCategory(by: oldCategoryName),
              let newCategory = fetchCategory(by: newCategoryName) else { print("123"); return }

        oldCategory.removeFromTrackers(tracker)
        newCategory.addToTrackers(tracker)
        save()
        print("✅ Tracker updated successfully")
    }


    func moveTrackerToPinnedCategory(trackerID: UUID) {
        if !isPinnedCategoryExist() {
            createNewCategory(newCategoryName: "Закрепленные")
        }
        print("isPinnedCategoryExist \(isPinnedCategoryExist())")

        guard let tracker = fetchTracker(by: trackerID),
              let pinnedCategory = fetchCategory(by: "Закрепленные") else { print("123"); return }

        tracker.initialCategory = tracker.category?.header
        pinnedCategory.addToTrackers(tracker)
        save()
        print("tracker.category?.header \(String(describing: tracker.category?.header))")
        print("tracker.initialCategory \(String(describing: tracker.initialCategory))")
        print("✅ Tracker pinned successfully")
    }

    func moveTrackerBackToCategory(trackerID: UUID) {

        guard let tracker = fetchTracker(by: trackerID),
              let initialCategoryName = tracker.initialCategory,
              let initialCategory = fetchCategory(by: initialCategoryName) else { print("123"); return }

        initialCategory.addToTrackers(tracker)
        save()
//        print("tracker.category?.header \(String(describing: tracker.category?.header))")
//        print("tracker.initialCategory \(String(describing: tracker.initialCategory))")
        print("✅ Tracker pinned successfully")
    }

    func isPinnedCategoryExist() -> Bool {
        return fetchCategory(by: "Закрепленные") != nil
    }

    func updateTrackerData(trackerToUpdate: Tracker) {
        guard let tracker = fetchTracker(by: trackerToUpdate.id) else { return }
        tracker.name = trackerToUpdate.name
        tracker.colorHex = trackerToUpdate.color
        tracker.emoji = trackerToUpdate.emoji
        tracker.schedule = trackerToUpdate.schedule
        save()
        print("✅ Tracker updated successfully")
    }

    func deleteTracker(trackerID: UUID) {
        guard let tracker = fetchTracker(by: trackerID) else { return }
        context.delete(tracker)
        save()
        print("✅ Tracker deleted from initial category successfully")
    }

    func isCategoryChanged(_ initialCategory: String, _ chosenCategory: String) -> Bool {
        return chosenCategory != initialCategory
    }


    func fetchTracker(by id: UUID) -> TrackerCD? {
        let fetchedObject = trackersFRC?.fetchedObjects
        let result = fetchedObject?.first(where: { $0.id == id })
        return result
    }

    func fetchCategory(by header: String) -> TrackerCategoryCD? {
        let request = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "header = %@", header)

        do {
            let result = try context.fetch(request)
            guard let category = result.first else {
                print("We don't have this category"); return nil }
            return category
        } catch {
            print("🟥 \(error.localizedDescription)")
            return nil
        }
    }
}

extension CoreDataManager {
    
    func addTrackerRecord(trackerRecordToAdd: TrackerRecord) {
        let newTrackerRecord = TrackerRecordCD(context: context)
        newTrackerRecord.id = trackerRecordToAdd.id
        newTrackerRecord.date = trackerRecordToAdd.date
        save()
        print("✅ New TrackerRecord created")
    }
    
    func countOfTrackerInRecords(trackerIDToCount: UUID) -> Int {
        let request = TrackerRecordCD.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(TrackerRecordCD.id),
                                    trackerIDToCount as CVarArg)
        request.predicate = predicate
        
        do {
            return try context.count(for: request)
        } catch {
            print("🟥 \(error.localizedDescription)")
            return 0
        }
    }
    
    func removeTrackerRecordForThisDay(trackerToRemove: TrackerRecord) {
        let request = TrackerRecordCD.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCD.id),
                                     trackerToRemove.id as CVarArg)
        let predicate2 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCD.date),
                                     trackerToRemove.date as CVarArg)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compoundPredicate
        
        do {
            let result = try context.fetch(request)
            if let trackerToDelete = result.first {
                context.delete(trackerToDelete)
                print("✅ Tracker Record removed")
                save()
            } else {
                print("🟥 We can't find the tracker")
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
    
    func isTrackerExistInTrackerRecord(trackerIdToCheck: UUID, date: Date) -> Bool {
        let request = TrackerRecordCD.fetchRequest()
        let predicate1 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCD.id),
                                     trackerIdToCheck.uuidString)
        let predicate2 = NSPredicate(format: "%K == %@",
                                     #keyPath(TrackerRecordCD.date),
                                     date as CVarArg)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compoundPredicate
        
        do {
            let result = try context.count(for: request)
            return result > 0
        } catch {
            print("🟥 \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteAllRecords() {
        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCD.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            print("✅ All TrackerRecords deleted successfully")
            save()
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
    
    func printAllTrackerRecords() {
        let request = TrackerRecordCD.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            if !result.isEmpty {
                for element in result {
                    print("element.date \(String(describing: element.date)), element.id \(String(describing: element.id))")
                }
            } else {
                print("No tracker records in CoreData")
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
}

extension CoreDataManager: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataManagerDidUpdateData(self)
    }
}

extension CoreDataManager {
    
    func getCompletedTrackersCount() -> Int {
        let request = TrackerRecordCD.fetchRequest()
        do {
            let completedTrackers = try context.count(for: request)
            return completedTrackers
        } catch {
            print("🟥 \(error.localizedDescription)")
            return 0
        }
    }
}

extension CoreDataManager {
    func isTrackerPinned(id: UUID) -> Bool {
        guard let tracker = fetchTracker(by: id) else { return false }
//        print("tracker?.isPinned \(tracker.isPinned)")
        return tracker.isPinned
    }
}
