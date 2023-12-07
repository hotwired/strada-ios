import XCTest
import WebKit
@testable import Strada

class BridgeTests: XCTestCase {
    func testInitWithANewWebViewAutomaticallyLoadsIntoWebView() {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)
        
        Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
    }
    
    func testInitWithTheSameWebViewDoesNotLoadTwice() {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)
        
        Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
        
        Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
    }
    
    @MainActor
    func testRegisterComponentCallsJavaScriptFunction() async {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        await bridge.register(component: "test")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.register(\"test\")")
    }
    
    @MainActor
    func testRegisterComponentsCallsJavaScriptFunction() async {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        await bridge.register(components: ["one", "two"])
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.register([\"one\",\"two\"])")
    }
    
    @MainActor
    func testUnregisterComponentCallsJavaScriptFunction() async {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        await bridge.unregister(component: "test")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.unregister(\"test\")")
    }
    
    @MainActor
    func testSendCallsJavaScriptFunction() async {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        let data = """
        {"title":"Page-title"}
        """
        let metadata = Message.Metadata(url: "https://37signals.com")
        let message = Message(id: "1",
                              component: "page",
                              event: "connect",
                              metadata: metadata,
                              jsonData: data)

        
        await bridge.reply(with: message)
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.replyWith({\"component\":\"page\",\"event\":\"connect\",\"data\":{\"title\":\"Page-title\"},\"id\":\"1\"})")
    }
    
    @MainActor
    func testEvaluateJavaScript() async {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        await bridge.evaluate(javaScript: "test(1,2,3)")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "test(1,2,3)")
    }
    
    @MainActor
    func testEvaluateJavaScriptReturnsErrorForNoWebView() async {
        let bridge = Bridge(webView: WKWebView())
        bridge.webView = nil
        
        let result = await bridge.evaluate(function: "test", arguments: [])
        XCTAssertEqual(result.error! as! BridgeError, BridgeError.missingWebView)
    }
    
    @MainActor
    func testEvaluateFunction() async {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        await _ = bridge.evaluate(function: "test", arguments: [1, 2, 3])
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "test(1,2,3)")
    }
}

private final class TestWebView: WKWebView {
    var lastEvaluatedJavaScript: String?
    
    override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        lastEvaluatedJavaScript = javaScriptString
        super.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
}
