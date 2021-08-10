# DSFAppKitBuilder

A SwiftUI-style DSL for generating AppKit user interfaces.

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

Sometimes I have to play in AppKit code and it always struck me how much boilerplate code was required to get relatively straight-forward views to display nicely - especially with autolayout! NSStackView makes life easier for sure but it still can lead to very verbose and difficult-to-read code.  Even moreso - as a reviewer it can be VERY difficult to understand the intent of programatically generated AppKit code.

So I decided to make a SwiftUI-style builder DSL for AppKit views.  It has certainly made round-trip times faster for the projects I have that use it (although not as swish as with SwiftUI and its previews)

## TL;DL - Show me something!

Here's an AppKit layout that is made a lot simpler with DSFAppKitBuilder

```
------------------------------------
|         |  Name                  |
|  image  |------------------------|
|         |  Description           |
------------------------------------
```

1. Image is fixed dimensions (42x42)
2. Name is font size 24, which truncates if the view gets too small horizontally
3. Description is font size 12, grey, and truncates if the view gets too small horizontally

```swift
class IdentityContainer: NSObject, DSFAppKitBuilderViewHandler {
   lazy var body: Element =
      HStack(spacing: 4) {
         ImageView()
            .image(NSImage(named: "apple_logo_orig")!)               // The image
            .size(width: 42, height: 42, priority: .required)        // fixed size
         VStack(spacing: 2, alignment: .leading) {
            Label("Apple Computer")                                  // The label with title 'Name'
               .font(NSFont.systemFont(ofSize: 24))                  // Font size 12
               .lineBreakMode(.byTruncatingTail)                     // Truncate line
               .horizontalPriorities(compressionResistance: 100)     // Allow the text field to compress
            Label("This is the description that can be quite long")  // The label with title 'Description'
               .font(NSFont.systemFont(ofSize: 12))                  // Font size 12
               .textColor(.placeholderTextColor)                     // Grey text
               .lineBreakMode(.byTruncatingTail)                     // Truncate line
               .horizontalPriorities(compressionResistance: 100)     // Allow the text field to compress
         }
      }
}
```

To display the builder content, assign the container to an instance of `DSFAppKitBuilderView`

```swift
class ViewController: NSViewController {
   @IBOutlet weak var mainView: DSFAppKitBuilderView!
   let identity = IdentityContainer()
   override func viewDidLoad() {
      super.viewDidLoad()
      mainView.builder = self.identity  // Set our builder as the view's builder
   }
}
```

And the result is...

<p align="center">
<img src="https://raw.githubusercontent.com/dagronf/dagronf.github.io/master/art/projects/DSFAppKitBuilder/s1.png" alt="Result image" width="310" />
</p>

You can find this demo in the `Demos/Simple AppKitBuilder Test` folder.

## Behaviours

### Modifiers

Modifiers allow you to change the default behaviour of an element.

```swift
Label("Name")
   .font(NSFont.systemFont(ofSize: 24))
   .lineBreakMode(.byTruncatingTail)
```

### Actions

You can supply action blocks for many of the element types.

```swift
Button(title: "Press Me!") { [weak self] _ in
  guard let `self` = self else { return }
  Swift.print("You pressed it!")
}
```

### Binders

You can use the binders on each element to bind to a keypath variable allowing two-way communications between the view and the controller.

Wrap all your view logic in its own object. Present the object to an instance of `DSFAppKitBuilderView` to display and manage the contents of your object.

```swift
class MyExcitingViewContainer: NSObject, DSFAppKitBuilderViewHandler {

   // Bind the user name and the display name to fields
   @objc dynamic var userName: String = ""
   @objc dynamic var displayName: String = ""
   	
   	// The body of the view
   lazy var body: Element =
      VStack {
         TextField()
            .placeholderText("User Name")
            .bindText(self, keyPath: \MyExcitingViewContainer.userName)
         TextField()
            .placeholderText("Display Name")
            .bindText(self, keyPath: \MyExcitingViewContainer.displayName)
      }
}
```

### Autolayout helpers

* Set the hugging and compression resistance on each element
* Set a fixed width and/or height for an element

```swift
TextField()
   .placeholderText("Noodles")
   .horizontalPriorities(hugging: 10)
```

### Controls

| Element Type       |  Description            |
|--------------------|-------------------------|
| `Box`              | An `NSBox` wrapper      |
| `Button`           | An `NSButton` wrapper   |
| `CheckBox`         | An `NSButton` wrapper configured to display as a checkbox |
| `ColorWell`        | An `NSColorWell` wrapper |
| `Divider`<br/>`HDivider/VDivider` | A divider element (a single line, either horizontal or vertical) |
| `EmptyView`        | A spacer view |
| `ImageView`        | An `NSImageView` wrapper |
| `Label`            | An `NSTextField` wrapper configured as a read-only label |
| `PopupButton`      | An `NSPopupButton` wrapper |
| `ProgressBar`      | An `NSProgressIndicator` wrapper |
| `RadioGroup`       | A grouped stack of buttons configured as a radio group |
| `ScrollView`       | An `NSScrollView` wrapper |
| `Segmented`        | An `NSSegmentedControl` wrapper |
| `Slider`           | An `NSSlider` wrapper |
| `SplitView`        | An `NSSplitView` wrapper |
| `Stack`<br/>`HStack/VStack` | An `NSStackView` wrapper (horizontal or vertical) |
| `Stepper`          | An `NSStepper` wrapper |
| `Switch`<br/>(10.15+) | An `NSSwitch` wrapper |
| `TabView`          | An `NSTabView` wrapper |
| `TextField`        | An `NSTextField` wrapper configured as an editable field |
| `View`             | A wrapper for an `NSView` instance |
| `VisualEffectView` | A wrapper for a `NSVisualEffectView` instance |
| `ZStack`           | Layer multiple Elements on top of each other |

## Integration

### Swift package manager

Add `https://github.com/dagronf/DSFAppKitBuilder` to your project.

## Documentation

The code is documented and will produce nice documentation for each element when run through [`jazzy`](https://github.com/realm/jazzy) or similar documentation generator tools.

## Known bugs

* `SplitView` needs to be a top-level object. They REALLY don't like playing in an autolayout container (eg. embedding a splitview inside a stackview)

### 0.3.0

* Add theme handling (dark mode detection)
* Add font modifier for Button
* Removed `addedToParentView` overridable function
* Changed public `nsView` to `view()`
* Simple logging

### 0.2.1

* Added `ZStack`

### 0.2.0

* Added `VisualEffectView`

### 0.1.0

* Initial release

## License

MIT. Use it and abuse it for anything you want, just attribute my work. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2021 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
