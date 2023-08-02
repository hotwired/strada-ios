import Foundation

extension Dictionary where Key == String, Value == AnyHashable {
    func jsonData() -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            debugLog("The provided object is not a valid JSON object. \(self)")
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self)
            return data
        } catch {
            debugLog("Error converting JSON object to data: \(error)")
            return nil
        }
    }
}
