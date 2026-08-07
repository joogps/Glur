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

A SwiftUI library that uses Metal to display efficient progressive blurs, just like the ones used by Apple. No **CIFilter**, and no **private APIs** used.

<img width="1280" alt="A comparison of Glur and a simple masked material" src="https://github.com/joogps/Glur/assets/41346220/1c748b09-a8e4-4782-a250-8563f106f298">

## Installation
This repository is a Swift package, so just include it in your Xcode project and target under **File > Add package dependencies**. Then, `import Glur` to the Swift files where you'll be using it.

The package vends two products, and you choose which ones your target links against:

| Product | What you get | Blurs | Private API |
| --- | --- | --- | --- |
| `Glur` | The `.glur()` modifier and `GlurMask` | The view it's applied to | None |
| `GlurBackdrop` | `GlurView` | The content behind it | Yes, on iOS/tvOS/visionOS only — see [Blurring the backdrop](#blurring-the-backdrop) |

`GlurBackdrop` depends on `Glur`, so masks are shared between them. Nothing in `GlurBackdrop` reaches your binary unless you add that product explicitly.

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
      direction: .down, // The direction in which the effect is applied.
      noise: 0.1, // The amount of noise that should be applied to the view.
      drawingGroup: true // Whether or not to pre-render the modified view with `drawingGroup()`.
)
```

### Masks

Where the effect lands is described by a `GlurMask`, a grayscale ramp in which an intensity of `0` leaves the view untouched and an intensity of `1` applies the full radius. The parameters above are shorthand for the default one, so these two are the same effect:

```swift
.glur(radius: 8.0, offset: 0.3, interpolation: 0.4, direction: .down)
.glur(radius: 8.0, mask: .linear(direction: .down, offset: 0.3, interpolation: 0.4))
```

Passing a mask directly opens up the shapes the shorthand can't spell:

```swift
.glur(radius: 8.0, mask: .radial(offset: 0.2, interpolation: 0.5)) // Sharp in the middle, blurred towards the corners
.glur(radius: 8.0, mask: .radial(offset: 0.2, interpolation: 0.5, spread: 2.5)) // The same, reaching much further out
.glur(radius: 8.0, mask: .linear(stops: [.init(intensity: 1.0, location: 0.0), // Blurred at both ends, sharp in the middle
                                         .init(intensity: 0.0, location: 0.5),
                                         .init(intensity: 1.0, location: 1.0)]))
```

`spread` is how far a radial mask reaches, as a multiple of the view's longest side. At `1.0` the ramp finishes at the far edge; larger values push it outwards, so the falloff is wider and gentler and the corners never reach the full radius.

#### Any view can be a mask

Every mask is a SwiftUI gradient underneath — `.linear` is a `LinearGradient`, `.radial` a `RadialGradient` — drawn into a square with `ImageRenderer` and stretched to fit. `.view()` hands that same pipeline something of your own, which covers everything the built-in ramps can't spell: angular, elliptical and mesh gradients, shapes, text, images.

```swift
.glur(radius: 8.0, mask: .view(AngularGradient(colors: [.black, .clear], center: .center)))
.glur(radius: 8.0, mask: .view(Text("blur").font(.system(size: 96, weight: .black))))
.glur(radius: 8.0, mask: .image(myCGImage)) // Or a bitmap you already have
```

Only **opacity** matters, whichever mask you use. It's flattened to white carrying that alpha, so colors are ignored and `.black` to `.clear` reads the same as `.white` to `.clear`.

> [!NOTE]
> The built-in gradients depend only on their own parameters, never on the size of the view, so they're drawn once and cached. A `.view()` mask can't be cached that way and is redrawn whenever the effect updates — prefer a built-in mask where one will do.

> [!WARNING]  
> When being used in the iOS simulator, SwiftUI shader effects may not be displayed if the view exceeds 545 points in either dimension. Please note that, on a physical device, the effect should work as intented. 

## Blurring the backdrop

The modifier blurs the view it's applied to, which means it can only reach views SwiftUI draws itself. `GlurView` is the other half: a transparent overlay that blurs whatever is rendered *behind* it, including `ScrollView` and other platform-backed content.

It ships as a **separate module**, so nothing below arrives in your binary unless you ask for it:

```swift
import GlurBackdrop

content
    .overlay(alignment: .top) {
        GlurView(radius: 12.0, offset: 0.0, interpolation: 1.0, direction: .up)
            .frame(height: 120)
    }
```

It takes the same masks as the modifier, so `GlurView(radius: 12.0, mask: .radial())` works too.

> [!NOTE]
> `GlurView` requires **iOS 16.0, macOS 13.0 or tvOS 16.0**. Masks are rasterized with `ImageRenderer`, which starts there. The `.glur()` modifier is unaffected, since its Metal path starts later still and its compatibility effect never rasterizes.

> [!WARNING]
> On **iOS, tvOS and visionOS** this reaches a **private API** — nothing public applies a varying blur to a backdrop on those platforms. The class is looked up by name at runtime and the names are held as code units, so no readable literal ends up in the binary, but that is obfuscation rather than a guarantee. This is why it lives in its own module. Weigh the App Store risk yourself before shipping it.
>
> On **macOS** no private API is involved: `CALayer.backgroundFilters` is supported there, and Core Image ships `CIMaskedVariableBlur`. On **watchOS** the view renders as empty space.

## How it's done

This project builds on a [proof of concept](https://twitter.com/joogps/status/1667240291869270032) developed in June of 2023, right after WWDC.

It makes use of Apple's new simplified [Shader API for SwiftUI](https://developer.apple.com/documentation/swiftui/shader). First, I coded a Metal shader that produced a gaussian blur for the modified view with the correct gaussian weights distribution, efficiently. Then, I modified it slightly to vary the blur radius over the vertical or horizontal axis given the offset, interpolation and direction values.

> [!NOTE]
> The shader runs through Apple's Shader API, which only reaches views SwiftUI draws itself. The `.glur()` modifier therefore **can't be applied to platform-backed views** such as `ScrollView`, `TextEditor` or `Map` — on those it silently does nothing.
>
> That's what [`GlurView`](#blurring-the-backdrop) is for: rather than blurring the view it's applied to, it blurs whatever is behind it, so you can lay one over a `ScrollView` instead of trying to apply the effect to it.

> [!TIP]
> If you want to learn how to write your first Metal shader with SwiftUI, check out [this tutorial](https://cindori.com/developer/swiftui-shaders-wave) that I wrote for the [Cindori](https://cindori.com) blog.

# Demo

You can run a demo of Glur in your device or simulator through the **GlurDemo** project in this repository.
