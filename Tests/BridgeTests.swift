import XCTest
import WebKit
@testable import Strada

@MainActor
class BridgeTests: XCTestCase {
    func testInitWithANewWebViewAutomaticallyLoadsIntoWebView() async {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)
        
        await Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
    }
    
    func testInitWithTheSameWebViewDoesNotLoadTwice() async {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)
        
        await Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
        
        await Bridge.initialize(webView)
        XCTAssertEqual(userContentController.userScripts.count, 1)
    }
    
    func testInitWithANewWebViewAutomaticallyLoadsIntoWebView() {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)

        let expectation = expectation(description: "Wait for completion.")
        Bridge.initialize(webView) {
            XCTAssertEqual(userContentController.userScripts.count, 1)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: .expectationTimeout)
    }
    
    func testInitWithTheSameWebViewDoesNotLoadTwice() {
        let webView = WKWebView()
        let userContentController = webView.configuration.userContentController
        XCTAssertTrue(userContentController.userScripts.isEmpty)

        let expectation1 = expectation(description: "Wait for completion.")
        Bridge.initialize(webView) {
            XCTAssertEqual(userContentController.userScripts.count, 1)
            expectation1.fulfill()
        }
        
        let expectation2 = expectation(description: "Wait for completion.")
        
        Bridge.initialize(webView) {
            XCTAssertEqual(userContentController.userScripts.count, 1)
            expectation2.fulfill()
        }

        wait(for: [expectation1, expectation2], timeout: .expectationTimeout)
    }

    /// NOTE: Each call to `webView.evaluateJavaScript(String)` will throw an error.
    /// We intentionally disregard any thrown errors (`try? await bridge...`)
    /// because we validate the evaluated JavaScript string ourselves.
    func testRegisterComponentCallsJavaScriptFunction() async throws {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        try? await bridge.register(component: "test")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.register(\"test\")")
    }
    
    func testRegisterComponentsCallsJavaScriptFunction() async throws {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        try? await bridge.register(components: ["one", "two"])
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.register([\"one\",\"two\"])")
    }
    
    func testUnregisterComponentCallsJavaScriptFunction() async throws {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        try? await bridge.unregister(component: "test")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.unregister(\"test\")")
    }
    
    func testSendCallsJavaScriptFunction() async throws {
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

        
        try? await bridge.reply(with: message)
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "window.nativeBridge.replyWith({\"component\":\"page\",\"event\":\"connect\",\"data\":{\"title\":\"Page-title\"},\"id\":\"1\"})")
    }
    
    func testEvaluateJavaScript() async throws {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        _ = try? await bridge.evaluate(javaScript: "test(1,2,3)")
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "test(1,2,3)")
    }
    
    func testEvaluateJavaScriptReturnsErrorForNoWebView() async throws {
        let bridge = Bridge(webView: WKWebView())
        bridge.webView = nil
        
        var didFailWithError: Error?
        do { _ = try await bridge.evaluate(function: "test", arguments: []) }
        catch { didFailWithError = error }

        let bridgeError = try XCTUnwrap(didFailWithError as? BridgeError)
        XCTAssertEqual(bridgeError, BridgeError.missingWebView)
    }
    
    func testEvaluateFunction() async throws {
        let webView = TestWebView()
        let bridge = Bridge(webView: webView)
        XCTAssertNil(webView.lastEvaluatedJavaScript)
        
        _ = try? await bridge.evaluate(function: "test", arguments: [1, 2, 3])
        XCTAssertEqual(webView.lastEvaluatedJavaScript, "test(1,2,3)")
    }
}

private final class TestWebView: WKWebView {
    var lastEvaluatedJavaScript: String?

    override func evaluateJavaScript(_ javaScriptString: String) async throws -> Any {
        lastEvaluatedJavaScript = javaScriptString
        return try await super.evaluateJavaScript(javaScriptString)
    }
}
