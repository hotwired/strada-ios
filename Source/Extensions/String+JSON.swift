import Foundation

extension String {
    func jsonObject() -> Any? {
        guard let jsonData = self.data(using: .utf8) else {
            debugLog("Error converting JSON string to data. \nJSON string: \(self)")
            return nil
            
        }
        
        do {
            let object = try JSONSerialization.jsonObject(with: jsonData)
            return object
        } catch {
            debugLog("Error converting JSON data to object: \(error)")
            return nil
        }
    }
}
