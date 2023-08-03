import Foundation

public protocol BridgeComponent: AnyObject {
    static var name: String { get }
    var delegate: BridgeDelegate? { get set }
    
    init(destination: BridgeDestination)
    func handle(message: Message)
    
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewDidAppear()
    func onViewWillDisappear()
    func onViewDidDisappear()
}

public extension BridgeComponent {
    func send(message: Message) {
        guard let bridge = delegate?.bridge else {
            debugLog("bridgeMessageFailedToSend: bridge is not available")
            return
        }
        
        bridge.send(message)
    }
    
    func onViewDidLoad() {}
    func onViewWillAppear() {}
    func onViewDidAppear() {}
    func onViewWillDisappear() {}
    func onViewDidDisappear() {}
}
