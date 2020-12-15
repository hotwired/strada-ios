# Strada iOS

Strada is a light-weight library that provides a bridge for bi-directional, async communication between a native iOS/[Android](https://github.com/hotwired/strada-android) app and a [web app](https://github.com/hotwired/strada-web) embedded in a web view. The bridge allows sending/receiving messages with a standard format.

## Installation
Strada iOS can be installed via Carthage:

```
github "hotwired/strada-ios" ~> 1.0.0
```

or via Swift Package Manager, either in a Package.swift or through Xcode:

```
.package(url: "https://github.com/hotwired/strada-ios", from: "1.0.0")
```

## Usage
The primary object you interact with in Strada is the `Bridge`. You create a `Bridge` with an existing `WKWebView` from your app and set your object as the delegate:

```swift
let bridge = Bridge(webView: webView, delegate: self)
```

Upon initialization, Strada automatically injects a bundled JavaScript file into the web view as a user script and sets up everything needed for communication with the web app.

### Receiving Messages
You receive messages from the web app through the bridge's delegate:

```swift
extension YourObject: BridgeDelegate {
  func bridgeDidInitialize() {
    // Configure your supported components
    bridge.register(components: ["nav-bar", "toast", "menu"])
  }

  func bridgeDidReceiveMessage(_ message: Message) {
    // Inspect message and perform related actions
  }
}
```

### Sending Messages
You send over the bridge by creating a `Message` and calling `send`:

```swift
bridge.send(message)
```

In most case though, you'll be replying to an existing message, in which you can use the convenience `reply` method:

```swift
let message: Message = // a message received earlier through delegate
bridge.reply(to: message, with: data)
```