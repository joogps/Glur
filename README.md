<h1> Glur
  <img align="right" alt="Project logo" src="../assets/Icon.png" width=128px>
</h1>

<p>
    <img src="https://img.shields.io/badge/iOS-15.0+-FF4D00.svg" />
    <img src="https://img.shields.io/badge/macOS-12.0+-FF4D00.svg" />
    <img src="https://img.shields.io/badge/watchOS-8.0+-FF4D00.svg" />
    <img src="https://img.shields.io/badge/tvOS-15.0+-FF4D00.svg" />
    <img src="https://img.shields.io/badge/visionOS-1.0+-FF4D00.svg" />
    <br>
    <img src="https://img.shields.io/badge/-SwiftUI-FF9F00.svg" />
    <a href="https://twitter.com/joogps">
        <img src="https://img.shields.io/badge/Contact-@joogps-lightgrey.svg?style=social&logo=twitter" alt="Twitter: @joogps" />
    </a>
</p>

A SwiftUI library that uses Metal to display efficient progressive blurs, just like the ones used by Apple.

## Installation
This repository is a Swift package, so just include it in your Xcode project and target under **File > Add package dependencies**. Then, `import Glur` to the Swift files where you'll be using it.

> [!NOTE]  
> While Glur is supported on older platforms, it will only utilize the Metal implementation of the blur effect on **iOS 17.0 and later, macOS 14.0 and later, watchOS 10.0 and later, and tvOS 17.0 and later**. Otherwise, it will present a worse, compatibility effect that should be tested by the developer before being used in production.

## Usage
You can add a glur effect with the following modifier:

```swift
.glur()
```

Here are all optional parameters:

```swift
.glur(radius: 8.0, // The full radius of the blur once it has interpolated
      offset: 0.3, // The offset until the blur starts being applied, relative to the size of the view
      interpolation: 0.4, // The interpolation until the blur reaches its full radius, relative to the size of the view
      direction: .down // The direction of the blur
)
```

> [!WARNING]  
> When being used in the iOS simulator, SwiftUI shader effects may not be displayed if the view exceeds 545 points in either dimension. Please note that, on a physical device, the effect should work as intented. 

## How it's done

This project makes use of Apple's new simplified [Shader API for SwiftUI](https://developer.apple.com/documentation/swiftui/shader). I first coded a Metal shader that produces a gaussian blur for the modified view with the correct gaussian weights distribution, efficiently. Then, I modified it to vary the blur radius over the vertical or horizontal axis given the offset and interpolation values.

> [!WARNING]
> Given that the shader is applied through Apple's own Shader API for SwiftUI, it is restricted by the limitations imposed by that API. This means that Glur **can only be applied to pure SwiftUI views**, excluding UIKit-backed views, such as `ScrollView`.

> [!TIP]
> If you want to learn how to write your first Metal shader with SwiftUI, check out [this tutorial](https://cindori.com/developer/swiftui-shaders-wave) that I wrote for the [Cindori](https://cindori.com) blog.

# Demo

You can run a demo of Glur in your device or simulator through the **GlurDemo** project in this repository.
