import Foundation

protocol BridgingComponent: AnyObject {
    static var name: String { get }
    var delegate: BridgeDelegate { get }
    
    init(destination: BridgeDestination,
         delegate: BridgeDelegate)
    
    func handle(message: Message)
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewDidAppear()
    func onViewWillDisappear()
    func onViewDidDisappear()
}

open class BridgeComponent: BridgingComponent {
    class var name: String {
        fatalError("BridgeComponent subclass must provide a unique 'name'")
    }
    
    unowned var delegate: BridgeDelegate
    
    required public init(destination: BridgeDestination, delegate: BridgeDelegate) {
        self.delegate = delegate
    }
    
    public func handle(message: Message) {
        fatalError("BridgeComponent subclass must handle incoming messages")
    }
    
    public func onViewDidLoad() {}
    public func onViewWillAppear() {}
    public func onViewDidAppear() {}
    public func onViewWillDisappear() {}
    public func onViewDidDisappear() {}
}

extension BridgingComponent {
    func send(message: Message) {
        guard let bridge = delegate.bridge else {
            debugLog("bridgeMessageFailedToSend: bridge is not available")
            return
        }
        
        bridge.send(message)
    }
}
