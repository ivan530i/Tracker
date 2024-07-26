import Foundation
import CoreData

@objc(TrackerCD)
public class TrackerCD: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCD> {
        return NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
    }
    
    @NSManaged public var colorHex: String?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: String?
    @NSManaged public var category: TrackerCategoryCD?
    @NSManaged public var record: TrackerRecordCD?
    
}

extension TrackerCD : Identifiable {
    
}

