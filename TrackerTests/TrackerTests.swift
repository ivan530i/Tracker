import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testExample() throws {
        
    }
    
    func testPerfomanceExample() throws {
        measure {
        }
    }
    
    func testViewController() {
        let viewController = TrackerViewController()
        
        assertSnapshot(matching: viewController, as: .image)
    }
}
