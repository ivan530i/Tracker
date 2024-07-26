import Foundation
import CoreData

@objc(TrackerRecordCD)
public class TrackerRecordCD: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCD> {
        return NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
    }
    
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var tracker: TrackerCD?
    
}
