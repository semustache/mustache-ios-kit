
import XCTest
import MustacheCombine

@available(iOS 13.0, *)
final class StorageMemoryTest: XCTestCase {
    
    @StorageCombine("memorySingletonNone", mode: .memory(scope: .singleton), expiration: .none)
    var memorySingletonNone: StoredObject?

    @StorageCombine("memorySharedNone", mode: .memory(scope: .shared), expiration: .none)
    var memorySharedNone: StoredObject?
    
    @StorageCombine("memorySharedNone", mode: .memory(scope: .shared), expiration: .none)
    var memorySharedNone2: StoredObject?
    
    @StorageCombine("memorySharedNone", mode: .memory(scope: .unique), expiration: .none)
    var memoryUniqueNone: StoredObject?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.memorySharedNone = nil
        XCTAssertNil(self.memorySharedNone)
    }
    
    func testMemorySingletonNone1() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.memorySingletonNone)
        self.memorySingletonNone = stored
        XCTAssertEqual(self.memorySingletonNone, stored)
                
    }

    func testMemorySingletonNone2() throws {
        
        XCTAssertNotNil(self.memorySingletonNone)
        
    }

    func testMemorySharedNone() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.memorySharedNone)
        self.memorySharedNone = stored
        
        XCTAssertEqual(self.memorySharedNone, stored)
        XCTAssertEqual(self.memorySharedNone2, stored)
        
    }
    
    func testMemoryUniqueNone() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.memoryUniqueNone)
        self.memoryUniqueNone = stored
        
        XCTAssertEqual(self.memoryUniqueNone, stored)
        
    }

}

