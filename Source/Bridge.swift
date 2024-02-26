import Foundation
import WebKit

public enum BridgeError: Error {
    case missingWebView
}

protocol Bridgable: AnyObject {
    var delegate: BridgeDelegate? { get set }
    var webView: WKWebView? { get }

    func register(component: String) async throws
    func register(components: [String]) async throws
    func unregister(component: String) async throws
    func reply(with message: Message) async throws
}

/// `Bridge` is the object for configuring a web view and
/// the channel for sending/receiving messages
public final class Bridge: Bridgable {
    typealias CompletionHandler = (_ result: Any?, _ error: Error?) -> Void

    weak var delegate: BridgeDelegate?
    weak var webView: WKWebView?

    public static func initialize(_ webView: WKWebView) {
        if getBridgeFor(webView) == nil {
            initialize(Bridge(webView: webView))
        }
    }

    init(webView: WKWebView) {
        self.webView = webView
        loadIntoWebView()
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: scriptHandlerName)
    }

    // MARK: - Internal API

    /// Register a single component
    /// - Parameter component: Name of a component to register support for
    func register(component: String) async throws {
        try await callBridgeFunction(.register, arguments: [component])
    }

    /// Register multiple components
    /// - Parameter components: Array of component names to register
    func register(components: [String]) async throws {
        try await callBridgeFunction(.register, arguments: [components])
    }

    /// Unregister support for a single component
    /// - Parameter component: Component name
    func unregister(component: String) async throws {
        try await callBridgeFunction(.unregister, arguments: [component])
    }

    /// Send a message through the bridge to the web application
    /// - Parameter message: Message to send
    func reply(with message: Message) async throws {
        logger.debug("bridgeWillReplyWithMessage: \(String(describing: message))")
        let internalMessage = InternalMessage(from: message)
        try await callBridgeFunction(.replyWith, arguments: [internalMessage.toJSON()])
    }

//    /// Convenience method to reply to a previously received message. Data will be replaced,
//    /// while id, component, and event will remain the same
//    /// - Parameter message: Message to reply to
//    /// - Parameter data: Data to send with reply
//    public func reply(to message: Message, with data: MessageData) {
//        let replyMessage = message.replacing(data: data)
//        callBridgeFunction("send", arguments: [replyMessage.toJSON()])
//    }
    @MainActor
    @discardableResult
    func evaluate(javaScript: String) async throws -> Any? {
        guard let webView = webView else {
            throw BridgeError.missingWebView
        }

        do {
            return try await webView.evaluateJavaScript(javaScript)
        } catch {
            logger.error("Error evaluating JavaScript: \(error)")
            throw error
        }
    }

    /// Evaluates a JavaScript function with optional arguments by encoding the arguments
    /// Function should not include the parens
    /// Usage: evaluate(function: "console.log", arguments: ["test"])
    func evaluate(function: String, arguments: [Any] = []) async throws -> Any? {
        try await evaluate(javaScript: JavaScript(functionName: function, arguments: arguments).toString())
    }

    static func initialize(_ bridge: Bridge) {
        instances.append(bridge)
        instances.removeAll { $0.webView == nil }
    }

    static func getBridgeFor(_ webView: WKWebView) -> Bridge? {
        return instances.first { $0.webView == webView }
    }

    // MARK: Private

    private static var instances: [Bridge] = []
    /// This needs to match whatever the JavaScript file uses
    private let bridgeGlobal = "window.nativeBridge"

    /// The webkit.messageHandlers name
    private let scriptHandlerName = "strada"

    private func callBridgeFunction(_ function: JavaScriptBridgeFunction, arguments: [Any]) async throws {
        let js = JavaScript(object: bridgeGlobal, functionName: function.rawValue, arguments: arguments)
        try await evaluate(javaScript: js)
    }

    // MARK: - Configuration

    /// Configure the bridge in the provided web view
    private func loadIntoWebView() {
        guard let configuration = webView?.configuration else { return }

        // Install user script and message handlers in web view
        if let userScript = makeUserScript() {
            configuration.userContentController.addUserScript(userScript)
        }

        let scriptMessageHandler = ScriptMessageHandler(delegate: self)
        configuration.userContentController.add(scriptMessageHandler, name: scriptHandlerName)
    }

    private func makeUserScript() -> WKUserScript? {
        guard
            let path = PathLoader().pathFor(name: "strada", fileType: "js")
        else {
            return nil
        }

        do {
            let source = try String(contentsOfFile: path)
            return WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        } catch {
            assertionFailure("Could not open strada.js: \(error)")
            return nil
        }
    }

    // MARK: - JavaScript Evaluation

    @discardableResult
    private func evaluate(javaScript: JavaScript) async throws -> Any? {
        do {
            return try await evaluate(javaScript: javaScript.toString())
        } catch {
            logger.error("Error evaluating JavaScript: \(String(describing: javaScript)), error: \(error)")
            throw error
        }
    }

    private enum JavaScriptBridgeFunction: String {
        case register
        case unregister
        case replyWith
    }
}

extension Bridge: ScriptMessageHandlerDelegate {
    @MainActor
    func scriptMessageHandlerDidReceiveMessage(_ scriptMessage: WKScriptMessage) async throws {
        if let event = scriptMessage.body as? String, event == "ready" {
            try await delegate?.bridgeDidInitialize()
            return
        }

        if let message = InternalMessage(scriptMessage: scriptMessage) {
            delegate?.bridgeDidReceiveMessage(message.toMessage())
            return
        }

        logger.warning("Unhandled message received: \(String(describing: scriptMessage.body))")
    }
}
