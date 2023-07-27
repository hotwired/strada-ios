import Foundation
import WebKit

public protocol BridgeDestination: AnyObject {
    func bridgeWebViewIsReady() -> Bool
    var supportedComponents: [BridgeComponent.Type] { get }
}

public final class BridgeDelegate {
    public let location: String
    public let destination: BridgeDestination
    weak var bridge: Bridgable?
    
    public init(location: String,
                destination: BridgeDestination) {
        self.location = location
        self.destination = destination
    }
    //
    //    func onColdBootPageCompleted() {
    //        bridge?.load()
    //    }
    //
    //    func onColdBootPageStarted() {
    //        bridge?.reset()
    //    }
    //
    //    func onWebViewAttached(_ webView: WKWebView) {
    //        bridge = Bridge.getBridgeFor(webView)
    //        bridge?.delegate = self
    //
    //        if bridge != nil {
    //            if shouldReloadBridge() {
    //                bridge?.load()
    //            }
    //        } else {
    //            logEvent("bridgeNotInitializedForWebView", location)
    //        }
    //    }
    //
    //    func onWebViewDetached() {
    //        bridge?.delegate = nil
    //        bridge = nil
    //    }
    //
    func bridgeDidInitialize() {
        let componentNames = destination.supportedComponents.map { $0.name }
        bridge?.register(components: componentNames)
    }
    
    @discardableResult
    func bridgeDidReceiveMessage(_ message: Message) -> Bool {
        guard destinationIsActive,
              location == message.metadata?.url else {
            debugLog("bridgeDidIgnoreMessage: \(message)")
            return false
        }
        
        debugLog("bridgeDidReceiveMessage: \(message)")
        getOrCreateComponent(name: message.component)?.handle(message: message)
        
        return true
    }
    
    // MARK: - Destination lifecycle
    
    public func onStart() {
        debugLog("bridgeDestinationDidStart: \(location)")
        destinationIsActive = true
        activeComponents.forEach { $0.onStart() }
    }
    
    public func onStop() {
        activeComponents.forEach { $0.onStop() }
        destinationIsActive = false
        debugLog("bridgeDestinationDidStop: \(location)")
    }
    
    public func onDestroy() {
        destinationIsActive = false
        debugLog("bridgeDestinationDidDestroy: \(location)")
    }
    
    // MARK: Retrieve component(s) by type
    
    func component<C: BridgeComponent>() -> C? {
        return activeComponents.compactMap { $0 as? C }.first
    }
    
    func forEachComponent<C: BridgeComponent>(action: (C) -> Void) {
        activeComponents.compactMap { $0 as? C }.forEach { action($0) }
    }
    
    // MARK: Private
    
    private var initializedComponents: [String: BridgeComponent] = [:]
    private var destinationIsActive = false
    
    private var activeComponents: [BridgeComponent] {
        return initializedComponents.values.filter { _ in destinationIsActive }
    }
    
    private func getOrCreateComponent(name: String) -> BridgeComponent? {
        if let component = initializedComponents[name] {
            return component
        }
        
        guard let componentType = destination.supportedComponents.first(where: { $0.name == name }) else {
            return nil
        }
        
        let component = componentType.init()
        component.delegate = self
        
        initializedComponents[name] = component
        
        return component
    }
}

