
import XCTest
import MustacheCombine

@available(iOS 13.0, *)
final class StorageCombineTest: XCTestCase {

    @StorageCombine("\(#file)-\(#function)", mode: .memory(scope: .shared), expiration: .none)
    var storedObject: StoredObject?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.storedObject = nil
        XCTAssertNil(self.storedObject)
    }

    func testSimpleUserDefaults() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.storedObject)
        self.storedObject = stored
        
        XCTAssertEqual(self.storedObject, stored)
        
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

class StoredObject: Codable, Equatable {
    
    var id: UUID = UUID()

    static func == (lhs: StoredObject, rhs: StoredObject) -> Bool {
        return lhs.id == rhs.id
    }
    
}
