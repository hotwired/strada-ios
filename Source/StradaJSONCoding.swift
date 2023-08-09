import Foundation

/// A utility for managing custom JSON encoders for the library.
///
/// The `StradaJSONEncoder` enum provides a static property `appEncoder`
/// that allows users to set a custom JSON encoder for the library.
/// The custom encoder can be useful when you need to apply specific
/// encoding strategies.
public enum StradaJSONEncoder {
    public static var appEncoder: JSONEncoder = JSONEncoder()
}

/// A utility for managing custom JSON decoders for the library.
///
/// The `StradaJSONDecoder` enum provides a static property `appDecoder`
/// that allows users to set a custom JSON decoder for the library.
/// The custom decoder can be useful when you need to apply specific
/// decoding strategies.
public enum StradaJSONDecoder {
    public static var appDecoder: JSONDecoder = JSONDecoder()
}
