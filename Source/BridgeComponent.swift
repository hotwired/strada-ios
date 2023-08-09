import Foundation

protocol BridgingComponent: AnyObject {
    static var name: String { get }
    var delegate: BridgeDelegate { get }
    
    init(destination: BridgeDestination,
         delegate: BridgeDelegate)
    
    func onReceive(message: Message)
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewDidAppear()
    func onViewWillDisappear()
    func onViewDidDisappear()
}

open class BridgeComponent: BridgingComponent {
    /// A unique name representing the `BridgeComponent` type.
    ///
    /// Subclasses must provide their own implementation of this property.
    ///
    /// - Note: This property is used for identifying the component.
    open class var name: String {
        fatalError("BridgeComponent subclass must provide a unique 'name'")
    }
    
    public unowned let delegate: BridgeDelegate
    
    required public init(destination: BridgeDestination, delegate: BridgeDelegate) {
        self.delegate = delegate
    }
    
    @discardableResult
    /// Replies to the web with a received message, optionally replacing its `event` or `jsonData`.
    ///
    /// - Parameter message: The message to be replied with.
    /// - Returns: `true` if the reply was successful, `false` if the bridge is not available.
    public func reply(with message: Message) -> Bool {
        guard let bridge = delegate.bridge else {
            debugLog("bridgeMessageFailedToReply: bridge is not available")
            return false
        }
        
        bridge.reply(with: message)
        return true
    }
    
    @discardableResult
    /// Replies to the web with the last received message for a given `event` with its original `jsonData`.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameter event: The `event` for which a reply should be sent.
    /// - Returns: `true` if the reply was successful, `false` if the event message was not received.
    public func reply(to event: String) -> Bool {
        guard let message = receivedMessage(for: event) else {
            debugLog("bridgeMessageFailedToReply: message for event \(event) was not received")
            return false
        }
        
        return reply(with: message)
    }
    
    
    @discardableResult
    /// Replies to the web with the last received message for a given `event`, replacing its `jsonData`.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameters:
    ///   - event: The `event` for which a reply should be sent.
    ///   - jsonData: The `jsonData` to be included in the reply message.
    /// - Returns: `true` if the reply was successful, `false` if the event message was not received.
    public func reply(to event: String, jsonData: String) -> Bool {
        guard let message = receivedMessage(for: event) else {
            debugLog("bridgeMessageFailedToReply: message for event \(event) was not received")
            return false
        }
        
        let messageReply = message.replacing(jsonData: jsonData)
        
        return reply(with: messageReply)
    }
    
    @discardableResult
    /// Replies to the web with the last received message for a given `event`, replacing its `jsonData`
    /// with the provided `Encodable` object.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameters:
    ///   - event: The `event` for which a reply should be sent.
    ///   - encodable: An instance conforming to `Encodable` to be included as `jsonData` in the reply message.
    /// - Returns: `true` if the reply was successful, `false` if the event message was not received.
    public func reply<T: Encodable>(to event: String, encodable: T) -> Bool {
        guard let message = receivedMessage(for: event) else {
            debugLog("bridgeMessageFailedToReply: message for event \(event) was not received")
            return false
        }
        
        let messageReply = message.replacing(encodedDataObject: encodable)
        
        return reply(with: messageReply)
    }
    
    /// Returns the last received message for a given `event`, if available.
    /// - Parameter event: The event name.
    /// - Returns: The last received message, or nil.
    public func receivedMessage(for event: String) -> Message? {
        return receivedMessages[event]
    }
    
    /// Called when a message is received from the web bridge.
    /// Handle the message for its `event` type for the custom component's behavior.
    /// - Parameter message: The `message` received from the web bridge.
    open func onReceive(message: Message) {
        fatalError("BridgeComponent subclass must handle incoming messages")
    }
    
    /// Called when the component's destination view is loaded into memory
    /// (and is active) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewDidLoad() {}
    
    /// Called when the component's destination view is about to be added to a view hierarchy
    /// (and is active) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewWillAppear() {}
    
    /// Called when the component's destination view was added to a view hierarchy
    /// (and is active) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewDidAppear() {}
    
    /// Called when the component's destination view is about to be removed from a view hierarchy
    /// (and is inactive) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewWillDisappear() {}
    
    /// Called when the component's destination view was removed from a view hierarchy
    /// (and is inactive) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewDidDisappear() {}
    
    // MARK: Internal
    
    func didReceive(message: Message) {
        receivedMessages[message.event] = message
        onReceive(message: message)
    }
    
    func viewDidLoad() {
        onViewDidLoad()
    }
    
    func viewWillAppear() {
        onViewWillAppear()
    }
    
    func viewDidAppear() {
        onViewDidAppear()
    }
    
    func viewWillDisappear() {
        onViewWillDisappear()
    }
    
    func viewDidDisappear() {
        onViewDidDisappear()
    }
    
    // MARK: Private
    
    private var receivedMessages = [String: Message]()
}
