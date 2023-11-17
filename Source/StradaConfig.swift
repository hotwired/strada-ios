import Foundation

public struct StradaConfig {
    
    public static var shared: StradaConfig = StradaConfig()
    
    public static func userAgentSubstring(for componentTypes: [BridgeComponent.Type]) -> String {
        let components = componentTypes.map { $0.name }.joined(separator: " ")
        return "bridge-components: [\(components)]"
    }
    
    /// Allows users to set a custom JSON encoder for the library.
    /// The custom encoder can be useful when you need to apply specific
    /// encoding strategies.
    public var jsonEncoder: JSONEncoder = JSONEncoder()
    
    /// Allows users to set a custom JSON decoder for the library.
    /// The custom decoder can be useful when you need to apply specific
    /// decoding strategies.
    public var jsonDecoder: JSONDecoder = JSONDecoder()
    
    public var debugLoggingEnabled = false {
        didSet {
            StradaLogger.debugLoggingEnabled = debugLoggingEnabled
        }
    }
    
    private init() {
        
    }
}
