# Quick Start Guide

This outlines everything you need to initially configure in your [`turbo-ios`](https://github.com/hotwired/turbo-ios) app to integrate `strada-ios`. Everything in this guide only needs to be done once in your app.

_NOTE: You can find the code in this guide fully implemented in the `turbo-ios` [demo app](https://github.com/hotwired/turbo-ios/tree/main/Demo)._

## Create an array of registered bridge components

For now, create an empty (global) list of registered component factories, so we have a reference. You'll need to populate this list with each bridge component that your app supports.

**`BridgeComponent+App.swift`:**
```swift
extension BridgeComponent {
    static var allTypes: [BridgeComponent.Type] {
        [
            // Add registered components here later
        ]
    }
}
```

## Initialize the WKWebView instance

For Strada to work properly across your web and native app, you'll need to make sure each `Turbo.Session` `WKWebView` instance is initialized with the following:
- An updated user agent string that includes the supported bridge components. Strada provides a utility function that builds the substring for you.
- Initialize the `WKWebView` with the `Bridge` class, so Strada can internally manage the `WKWebView` through the app's lifecycle.

The place to update the `WKWebView` user agent string is where your `WKWebViewConfiguration` is configured:

**`WKWebViewConfiguration+App.swift`**
```swift
extension WKWebViewConfiguration {
    static var appConfiguration: WKWebViewConfiguration {
        let stradaSubstring = Strada.userAgentSubstring(for: BridgeComponent.allTypes)
        let userAgent = "Turbo Native iOS \(stradaSubstring)"

        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = userAgent

        return configuration
    }
}
```

The place to initialize the `Bridge` is where each `TurboSession` and `WKWebView` instance is created in your app:

**`SceneController.swift`:**
```swift
Bridge.initialize(webView)
```

## Implement the `BridgeDestination` protocol
You'll need to add the `BridgeDestination` protocol for you each `VisitableViewController` in your app:

**`TurboWebViewController.swift`:**
```swift
final class TurboWebViewController: VisitableViewController, BridgeDestination {
    // ...
}
```

## Delegate to the `BridgeDelegate` class
You'll need to delegate the `VisitableViewController` lifecycle events to the `BridgeDelegate` class:

**`TurboWebViewController.swift`:**
```swift
final class TurboWebViewController: VisitableViewController, BridgeDestination {

    private lazy var bridgeDelegate: BridgeDelegate = {
        BridgeDelegate(location: visitableURL.absoluteString,
                       destination: self,
                       componentTypes: BridgeComponent.allTypes)
    }()

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bridgeDelegate.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bridgeDelegate.onViewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bridgeDelegate.onViewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bridgeDelegate.onViewWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bridgeDelegate.onViewDidDisappear()
    }

    // MARK: Visitable

    override func visitableDidActivateWebView(_ webView: WKWebView) {
        bridgeDelegate.webViewDidBecomeActive(webView)
    }

    override func visitableDidDeactivateWebView() {
        bridgeDelegate.webViewDidBecomeDeactivated()
    }
}
```

## Build your first `BridgeComponent`

You're now down with the initial setup. See the [Build Components](BUILD-COMPONENTS.md) page to build your first bridge component.
