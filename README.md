# DSFAppKitBuilder

A SwiftUI-style DSL for AppKit UI.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFAppKitBuilder" />
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" /></a>
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
</p>

## Why?

I have a few apps that need to play nicely pre 10.15. Even in 10.15, SwiftUI can be a bit buggy.

Sometimes I have to play in AppKit code and it always struck me how much boilerplate code was required to get relatively straight-forward views to display nicely - especially with autolayout! NSStackView makes life easier for sure but it still can lead to very verbose and difficul-to-read code.

### With DSFAppKitBuilder

```swift
lazy var layout =
   VStack {
      HStack(spacing: 8) {
         ImageView(NSImage(named: "filter-icon")!)
            .scaling(.scaleProportionallyUpOrDown)
            .size(width: 36, height: 36)
         VStack(spacing: 0, alignment: .leading) {
            Label("Mount Everest")
               .font(NSFont.systemFont(ofSize: 18))
            Label("Mount Everest is really really tall")
         }
         .contentHugging(h: .defaultLow)
      }
   }
```

### Features

* Bindable values (using KeyPaths)
* 
