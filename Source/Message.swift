import Foundation

public typealias MessageData = [String: AnyHashable]

/// A `Message` is the structure sent back and forth over the bridge
/// to enable communication between native and web apps
public struct Message: Equatable {
    /// A unique identifier for this message. You can reply to messages by sending
    /// the same message back, or creating a new message with the same id
    public let id: String
    
    /// The component the message is sent from (e.g. - "form", "page", etc)
    public let component: String
    
    /// The event that this message is about: "submit", "display", "send"
    public let event: String
    
    /// The metadata associated with the message, which includes its url.
    public let metadata: Metadata?
    
    /// Any data to send along with the message, for a "page" component, this might be the ["title": "Page Title"]
    public let data: MessageData
    
    public init(id: String,
                component: String,
                event: String,
                metadata: Metadata?,
                data: MessageData) {
        self.id = id
        self.component = component
        self.event = event
        self.metadata = metadata
        self.data = data
    }
    
    /// Returns a new Message, replacing the existing data with passed-in data and event
    /// If event is omitted, the existing event is used
    public func replacing(event updatedEvent: String? = nil,
                          data updatedData: MessageData) -> Message {
        Message(id: id,
                component: component,
                event: updatedEvent ?? event,
                metadata: metadata,
                data: updatedData)
    }
}

public struct Metadata: Equatable {
    public let url: String
}
