import Foundation
import CoreData

@objc(TrackerCategoryCD)
public class TrackerCategoryCD: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCD> {
        return NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
    }
    
    @NSManaged public var header: String?
    @NSManaged public var trackers: NSSet?
    
}

extension TrackerCategoryCD {
    
    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerCD)
    
    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerCD)
    
    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)
    
    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)
    
}

extension TrackerCategoryCD : Identifiable {
    
}
