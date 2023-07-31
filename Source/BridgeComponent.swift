import Foundation

public protocol BridgeComponent: AnyObject {
    static var name: String { get }
    var delegate: BridgeDelegate? { get set }
    
    init()
    func handle(message: Message)
    
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewWillDisappear()
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
    func onViewWillDisappear() {}
}
