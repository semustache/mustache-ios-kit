
import XCTest
import MustacheCombine

@available(iOS 13.0, *)
final class StorageDefaultsTest: XCTestCase {
    
    @StorageCombine("memorySingletonNone", mode: .userDefaults(), expiration: .seconds(2))
    var defaultsSeconds: StoredObject?

    @StorageCombine("memorySharedNone", mode: .userDefaults(), expiration: .timestamp(.nowSafe))
    var defaultsDate: StoredObject?
    
    @StorageCombine("memorySharedNone", mode: .userDefaults(), expiration: .hourOfDay(2))
    var defaultsHour: StoredObject?
    
    @StorageCombine("memorySharedNone", mode: .userDefaults(), expiration: .dayOfWeek(2))
    var defaultsDay: StoredObject?
    
    @StorageCombine("memorySharedNone", mode: .userDefaults(), expiration: .none)
    var defaultsNone: StoredObject?
    
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.defaultsSeconds = nil
        self.defaultsDate = nil
        self.defaultsHour = nil
        self.defaultsDay = nil
        self.defaultsNone = nil        
    }
    
    func testDefaultsSeconds() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsSeconds)
        self.defaultsSeconds = stored
        XCTAssertEqual(self.defaultsSeconds, stored)
        
        sleep(6)
        
        XCTAssertNil(self.defaultsSeconds)
                
    }
    
    func testDefaultsHour() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsHour)
        self.defaultsHour = stored
        XCTAssertEqual(self.defaultsHour, stored)

    }
    
    func testDefaultsDay() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsDay)
        self.defaultsDay = stored
        XCTAssertEqual(self.defaultsDay, stored)
        
    }
    
    func testDefaultsDate() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsDate)
        self.defaultsDate = stored
        XCTAssertNil(self.defaultsDate)
        
    }
    
    func testDefaulsNone() throws {
        
        let stored = StoredObject()
        
        XCTAssertNil(self.defaultsNone)
        self.defaultsNone = stored
        XCTAssertEqual(self.defaultsNone, stored)
        self.defaultsNone = nil
        XCTAssertNil(self.defaultsNone)
    }

}
