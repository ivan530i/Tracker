import Foundation
import CoreData

final class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    
    private override init () { }
    
    var trackersFromCoreData = [TrackerCD]()
    var categoriesFromCoreData = [TrackerCategoryCD]()
    var selectedCategory = ""
    
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
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var trackersFRC: NSFetchedResultsController<TrackerCD>?
    
    private func setupTrackerFRC(request: NSFetchRequest<TrackerCD>) {
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
        let predicate1 = NSPredicate(format: "schedule CONTAINS %@", weekDay)
        request.predicate = predicate1
        
        let sort = NSSortDescriptor(key: "category.header", ascending: true)
        request.sortDescriptors = [sort]
        
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
    
    func createNewTracker(newTracker: Tracker) {
        let request = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "header = %@", selectedCategory)
        
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
            
            newTask.category = category
            category.addToTrackers(newTask)
            
            save()
            print("✅ New tracker added successfully")
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
    
    func sendLastChosenCategoryToStore(categoryName: String) {
        self.selectedCategory = categoryName
    }
    
    func printAllTrackersInCoreData() {
        let fetchRequest = TrackerCD.fetchRequest()
        do {
            let allTrackers = try context.fetch(fetchRequest)
            allTrackers.forEach { tracker in
                guard let name = tracker.name,
                      let schedule = tracker.schedule else { return }
                print("Name \(name) - Schedule \(schedule)")
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
    
    func setTrackerPinned(id: UUID, pinned: Bool) {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(request).first {
                tracker.isPinned = pinned
                save()
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
    
    func deleteTracker(id: UUID) {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let tracker = try context.fetch(request).first {
                context.delete(tracker)
                save()
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
    
    func updateTracker(id: UUID, name: String, color: String, emoji: String, schedule: String) {
        let tracker = fetchTracker(by: id)
        tracker?.name = name
        tracker?.colorHex = color
        tracker?.emoji = emoji
        tracker?.schedule = schedule
        save()
    }
    
    func fetchTracker(by id: UUID) -> TrackerCD? {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try context.fetch(request).first
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
            for element in result {
                print("element.date \(String(describing: element.date)), element.id \(String(describing: element.id))")
            }
        } catch {
            print("🟥 \(error.localizedDescription)")
        }
    }
}

extension CoreDataManager: NSFetchedResultsControllerDelegate {
    
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
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(request)
            return result.first?.isPinned ?? false
        } catch {
            print("🟥 \(error.localizedDescription)")
            return false
        }
    }
}
