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

A SwiftUI library that uses Metal to display efficient progressive blurs, just like the ones used by Apple. Try it today [on the App Store](https://apps.apple.com/app/glur/id6478063257).

<img width="1280" alt="A comparison of Glur and a simple masked material" src="https://github.com/joogps/Glur/assets/41346220/1c748b09-a8e4-4782-a250-8563f106f298">

## Installation
This repository is a Swift package, so just include it in your Xcode project and target under **File > Add package dependencies**. Then, `import Glur` to the Swift files where you'll be using it.

> [!NOTE]  
> While Glur is supported on older platforms, it will only utilize the Metal implementation of the blur effect on **iOS 17.0 and later, macOS 14.0 and later, and tvOS 17.0 and later**. Otherwise, it will present a worse, compatibility effect that should be tested by the developer before being used in production.
> 
> **The Metal implementation is not available on watchOS**, and therefore the compatibility effect will be presented on this platform by default.

## Usage
You can add a glur effect with the following modifier:

```swift
.glur()
```

Here are all optional parameters:

```swift
.glur(radius: 8.0, // The total radius of the blur effect when fully applied.
      offset: 0.3, // The distance from the view's edge to where the effect begins, relative to the view's size.
      interpolation: 0.4, // The distance from the offset to where the effect is fully applied, relative to the view's size.
      direction: .down // The direction in which the effect is applied.
)
```

> [!WARNING]  
> When being used in the iOS simulator, SwiftUI shader effects may not be displayed if the view exceeds 545 points in either dimension. Please note that, on a physical device, the effect should work as intented. 

## How it's done

This project builds on a [proof of concept](https://twitter.com/joogps/status/1667240291869270032) developed in June of 2023, right after WWDC.

It makes use of Apple's new simplified [Shader API for SwiftUI](https://developer.apple.com/documentation/swiftui/shader). First, I coded a Metal shader that produced a gaussian blur for the modified view with the correct gaussian weights distribution, efficiently. Then, I modified it slightly to vary the blur radius over the vertical or horizontal axis given the offset, interpolation and direction values.

> [!WARNING]
> Given that the shader is applied through Apple's own Shader API for SwiftUI, it is restricted by the limitations imposed by that API. This means that Glur **can only be applied to pure SwiftUI views**, excluding UIKit-backed views, such as `ScrollView`.

> [!TIP]
> If you want to learn how to write your first Metal shader with SwiftUI, check out [this tutorial](https://cindori.com/developer/swiftui-shaders-wave) that I wrote for the [Cindori](https://cindori.com) blog.

# Demo

You can run a demo of Glur in your device or simulator through the **GlurDemo** project in this repository.
