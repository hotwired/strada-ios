import Foundation

/// A `Message` is the structure sent back and forth over the bridge
/// to enable communication between native and web apps
public struct Message: Equatable {
    /// A unique identifier for this message. When you reply to the web with
    /// a message, this identifier is used to find its previously sent message.
    public let id: String
    
    /// The component the message is sent from (e.g. - "form", "page", etc)
    public let component: String
    
    /// The event that this message is about: "submit", "display", "send"
    public let event: String
    
    /// The metadata associated with the message, which includes its url.
    public let metadata: Metadata?
    
    /// Data, represented in a json object string, to send along with the message.
    /// For a "page" component, this might be `{"title": "Page Title"}`.
    public let jsonData: String
    
    init(id: String,
         component: String,
         event: String,
         metadata: Metadata?,
         jsonData: String) {
        self.id = id
        self.component = component
        self.event = event
        self.metadata = metadata
        self.jsonData = jsonData
    }
    
    /// Replaces the existing `Message`'s data with passed-in data and event.
    /// - Parameters:
    ///   - updatedEvent: The updated event of this message. If omitted, the existing event is used.
    ///   - updatedData: The updated data of this message. If omitted, the existing data is used.
    /// - Returns: A new `Message` with the provided data.
    public func replacing(event updatedEvent: String? = nil,
                          jsonData updatedData: String? = nil) -> Message {
        Message(id: id,
                component: component,
                event: updatedEvent ?? event,
                metadata: metadata,
                jsonData: updatedData ?? jsonData)
    }
    
    public func replacing<T: Encodable>(event updatedEvent: String? = nil,
                                        jsonEncodableData encodable: T? = nil) -> Message {
        
        let data: String?
        if let encodable,
           let jsonData = try? JsonDataDecoder.appEncoder.encode(encodable) {
            data = String(data: jsonData, encoding: .utf8)
        } else {
            data = nil
        }
        
        return Message(id: id,
                       component: component,
                       event: updatedEvent ?? event,
                       metadata: metadata,
                       jsonData: data ?? jsonData)
    }
}

extension Message {
    public struct Metadata: Equatable {
        public let url: String
    }
}

extension Message {
    public func decodedJsonData<T: Decodable>() -> T? {
        guard let data = jsonData.data(using: .utf8) else {
            debugLog("Error converting json string to data: \(jsonData)")
            return nil
        }
        
        do {
            let decoder = JsonDataDecoder.appDecoder
            return try decoder.decode(T.self, from: data)
        } catch {
            debugLog("Error decoding json: \(jsonData) -> \(error)")
            return nil
        }
    }
}
