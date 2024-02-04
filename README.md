<h1> Glur
  <img align="right" alt="Project logo" src="../assets/icon-small.png" width=74px>
</h1>

<p>
    <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" />
    <img src="https://img.shields.io/badge/-SwiftUI-red.svg" />
    <a href="https://twitter.com/joogps">
        <img src="https://img.shields.io/badge/Contact-@joogps-lightgrey.svg?style=social&logo=twitter" alt="Twitter: @joogps" />
    </a>
</p>

A SwiftUI library that uses Metal to display efficient progressive blurs, just like the ones used by Apple.

## Installation
This repository is a Swift package, so all you gotta do is paste the repository link and include it in your project under **File > Add packages**. Then, just add `import SlideOverCard` to the files where this package will be referenced and you're good to go!

If your app runs on iOS 13, you might find a problem with keyboard responsiveness in your layout. That's caused by a SwiftUI limitation, unfortunately, since the [`ignoresSafeArea`](https://developer.apple.com/documentation/swiftui/text/ignoressafearea(_:edges:)) modifier was only introduced for the SwiftUI framework in the iOS 14 update.

## Usage
You can add a card to your app in two different ways. The first one is by adding a `.slideOverCard()` modifier, which works similarly to a `.sheet()`:
```swift
.slideOverCard(isPresented: $isPresented) {
  // Here goes your awesome content
}
```

# Example

The SwiftUI code for a demo view can be found [here](https://github.com/joogps/SlideOverCard/blob/f6cb0e2bac67555fd74cdadf3e6ca542538f0c23/Sources/SlideOverCard/SlideOverCard.swift#L128). It's an Xcode preview, and you can experience it right within the package, under **Swift Package Dependencies**, in your project.
