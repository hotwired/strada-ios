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
    open class var name: String {
        fatalError("BridgeComponent subclass must provide a unique 'name'")
    }
    
    public unowned let delegate: BridgeDelegate
    
    required public init(destination: BridgeDestination, delegate: BridgeDelegate) {
        self.delegate = delegate
    }
    
    open func onReceive(message: Message) {
        fatalError("BridgeComponent subclass must handle incoming messages")
    }
    
    public func reply(with message: Message) {
        guard let bridge = delegate.bridge else {
            debugLog("bridgeMessageFailedToReply: bridge is not available")
            return
        }
        
        bridge.reply(with: message)
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
