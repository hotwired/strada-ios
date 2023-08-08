import XCTest
@testable import Strada

class MessageTests: XCTestCase {
    func testReplacingWithNewEventAndData() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let newEvent = "disconnect"
        let newData = "{}"
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let newMessage = message.replacing(event: newEvent, jsonData: newData)
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, newEvent)
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, newData)
    }
    
    func testReplacingByChangingDataWithoutChangingEvent() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        let newData = """
        {"title":"Page-title""}
        """
        let newMessage = message.replacing(jsonData: newData)
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, "connect")
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, newData)
    }
    
    func testReplacingByChangingEventWithoutChangingData() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        let newEvent = "disconnect"
        let newMessage = message.replacing(event: newEvent)
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, newEvent)
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, jsonData)
    }
    
    func testReplacingWithoutChangingEventAndData() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let newMessage = message.replacing()
        
        XCTAssertEqual(newMessage.id, "1")
        XCTAssertEqual(newMessage.component, "page")
        XCTAssertEqual(newMessage.event, "connect")
        XCTAssertEqual(newMessage.metadata, metadata)
        XCTAssertEqual(newMessage.jsonData, jsonData)
    }
    
    func test_decodingWithDefaultDecoder() {
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle", "actionName": "go"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let pageData = MessageData(title: "Page-title",
                                   subtitle: "Page-subtitle",
                                   actionName: "go")
        
        let decodedMessageData: MessageData? = message.decodedJsonData()
        
        XCTAssertEqual(decodedMessageData, pageData)
    }
    
    func test_decodingWithCustomDecoder() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        JsonDataDecoder.appDecoder = decoder
        
        let metadata = Message.Metadata(url: "https://37signals.com")
        let jsonData = """
        {"title":"Page-title","subtitle":"Page-subtitle", "action_name": "go"}
        """
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: jsonData)
        
        let pageData = MessageData(title: "Page-title",
                                   subtitle: "Page-subtitle",
                                   actionName: "go")
        
        let decodedMessageData: MessageData? = message.decodedJsonData()
        
        XCTAssertEqual(decodedMessageData, pageData)
    }
}
