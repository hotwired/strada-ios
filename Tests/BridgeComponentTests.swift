import Foundation
import XCTest
import WebKit
@testable import Strada

class BridgeComponentTest: XCTestCase {
    private var delegate: BridgeDelegate!
    private var bridge: BridgeSpy!
    private var destination: AppBridgeDestination!
    private var component: BridgeComponentSpy!
    private let message = Message(id: "1",
                                  component: BridgeComponentSpy.name,
                                  event: "connect",
                                  metadata: .init(url: "https://37signals.com"),
                                  jsonData: "{\"title\":\"Page-title\",\"subtitle\":\"Page-subtitle\"}")
    
    override func setUp() async throws {
        destination = AppBridgeDestination()
        delegate = BridgeDelegate(location: "https://37signals.com",
                                  destination: destination,
                                  componentTypes: [BridgeComponentSpy.self])
        
        bridge = BridgeSpy()
        bridge.delegate = delegate
        delegate.bridge = bridge
        delegate.onViewDidLoad()
        
        delegate.bridgeDidReceiveMessage(message)
        component = delegate.component()
    }
    
    // MARK: didReceive(:) and caching
    
    func test_didReceiveCallsOnReceive() {
        XCTAssertTrue(component.onReceiveMessageWasCalled)
        XCTAssertEqual(component.onReceiveMessageArg, message)
    }
    
    func test_didReceiveCachesTheMessage() {
        let cachedMessage = component.receivedMessage(for: "connect")
        XCTAssertEqual(cachedMessage, message)
    }
    
    func test_didReceiveCachesOnlyTheLastMessage() {
        let newJsonData = "{\"title\":\"Page-title\"}"
        let newMessage = message.replacing(jsonData: newJsonData)
        
        delegate.bridgeDidReceiveMessage(newMessage)
        
        let cachedMessage = component.receivedMessage(for: "connect")
        XCTAssertEqual(cachedMessage, newMessage)
    }
    
    func test_retrievingNonCachedMessageForEvent() {
        let cachedMessage = component.receivedMessage(for: "disconnect")
        XCTAssertNil(cachedMessage)
    }
    
    // MARK: reply(to:)
    
    func test_replyToReceivedMessageSucceeds() {
        let success = component.reply(to: "connect")
        
        XCTAssertTrue(success)
        XCTAssertTrue(bridge.replyWithMessageWasCalled)
        XCTAssertEqual(bridge.replyWithMessageArg, message)
    }
    
    func test_replyToReceivedMessageWithACodableObjectSucceeds() {
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")
        let newJsonData = "{\"title\":\"hey\",\"subtitle\":\"\",\"actionName\":\"tap\"}"
        let newMessage = message.replacing(jsonData: newJsonData)
        
        let success = component.reply(to: "connect", with: messageData)
        
        XCTAssertTrue(success)
        XCTAssertTrue(bridge.replyWithMessageWasCalled)
        XCTAssertEqual(bridge.replyWithMessageArg, newMessage)
    }
    
    func test_replyToMessageNotReceivedWithACodableObjectIgnoresTheReply() {
        let messageData = MessageData(title: "hey", subtitle: "", actionName: "tap")
        
        let success = component.reply(to: "disconnect", with: messageData)
        
        XCTAssertFalse(success)
        XCTAssertFalse(bridge.replyWithMessageWasCalled)
        XCTAssertNil(bridge.replyWithMessageArg)
    }
    
    func test_replyToMessageNotReceivedIgnoresTheReply() {
        let success = component.reply(to: "disconnect")
        
        XCTAssertFalse(success)
        XCTAssertFalse(bridge.replyWithMessageWasCalled)
        XCTAssertNil(bridge.replyWithMessageArg)
    }
    
    func test_replyToMessageNotReceivedWithJsonDataIgnoresTheReply() {
        let success = component.reply(to: "disconnect", with: "{\"title\":\"Page-title\"}")
        
        XCTAssertFalse(success)
        XCTAssertFalse(bridge.replyWithMessageWasCalled)
        XCTAssertNil(bridge.replyWithMessageArg)
    }
    
    func test_replyToFailsWhenBridgeNotSet() {
        delegate.bridge = nil
        
        let success = component.reply(to: "disconnect")
        
        XCTAssertFalse(success)
        XCTAssertFalse(bridge.replyWithMessageWasCalled)
        XCTAssertNil(bridge.replyWithMessageArg)
    }
    
    // MARK: reply(with:)
   
    func test_replyWithSucceedsWhenBridgeIsSet() {
        let newJsonData = "{\"title\":\"Page-title\"}"
        let newMessage = message.replacing(jsonData: newJsonData)
        
        let success = component.reply(with: newMessage)
        
        XCTAssertTrue(success)
        XCTAssertTrue(bridge.replyWithMessageWasCalled)
        XCTAssertEqual(bridge.replyWithMessageArg, newMessage)
    }
    
    func test_replyWithFailsWhenBridgeNotSet() {
        delegate.bridge = nil
        
        let newJsonData = "{\"title\":\"Page-title\"}"
        let newMessage = message.replacing(jsonData: newJsonData)
        
        let success = component.reply(with: newMessage)
        
        XCTAssertFalse(success)
        XCTAssertFalse(bridge.replyWithMessageWasCalled)
        XCTAssertNil(bridge.replyWithMessageArg)
    }
}
