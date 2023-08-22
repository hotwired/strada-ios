import Foundation
import XCTest
@testable import Strada

final class ComposerComponent: BridgeComponent {
    static override var name: String { "composer" }
    
    override func onReceive(message: Message) {
        guard let event = InboundEvent(rawValue: message.event) else {
            return
        }
        
        switch event {
        case .connect:
            break
        }
    }
    
    func selectSender(emailAddress: String) {
        guard let message = receivedMessage(for: InboundEvent.connect.rawValue),
              let data: MessageData = message.data() else {
            return
        }
        
        guard let sender = data.senders.first(where: { $0.email == emailAddress }) else {
            return
        }
        
        let newMessage = message.replacing(event: OutboundEvent.selectSender.rawValue,
                                           data: SelectSenderMessageData(selectedIndex: sender.index))
        reply(with: newMessage)
    }
    
    func selectedSender() -> String? {
        guard let message = receivedMessage(for: InboundEvent.connect.rawValue),
              let data: MessageData = message.data() else {
            return nil
        }
        
        guard let selected = data.senders.first(where: { $0.selected }) else {
            return nil
        }
        
        return selected.email
    }
}

// MARK: Events

extension ComposerComponent {
    private enum InboundEvent: String {
        case connect
    }
    
    private enum OutboundEvent: String {
        case selectSender = "select-sender"
    }
}

// MARK: Message data

extension ComposerComponent {
    private struct MessageData: Decodable {
        let senders: [Sender]
    }
    
    private struct Sender: Decodable {
        let email: String
        let index: Int
        let selected: Bool
    }
    
    private struct SelectSenderMessageData: Encodable {
        let selectedIndex: Int
    }
}

