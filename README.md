# DSFAppKitBuilder

A SwiftUI-style DSL for generating AppKit user interfaces.

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFAppKitBuilder" />
    <img src="https://img.shields.io/badge/macOS-10.11+-red" />
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

This library provides a custom view controller `DSFAppKitBuilderViewController` which you can inherit from
when building your own custom views.

```swift
class IdentityViewController: DSFAppKitBuilderViewController {
   // Build the view's body
   override var viewBody: Element {
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
}
```

And the result is...

<p align="center">
<img src="https://raw.githubusercontent.com/dagronf/dagronf.github.io/master/art/projects/DSFAppKitBuilder/s1.png" alt="Result image" width="310" />
</p>

You can find this demo in the `Demos/Simple AppKitBuilder Test` folder.

## Generating your view

There are a number of methods for building and managing your view

### DSFAppKitBuilderViewController

The `DSFAppKitBuilderViewController` is a custom NSViewController derived class which automatically
handles building and displaying your view.

Just override `var viewBody: Element { ... }` in your subclass and you're ready to go!

### DSFAppKitBuilderViewHandler protocol

The `DSFAppKitBuilderViewHandler` is a little lower level, allowing you to contain your view components
within composable objects.

```swift
class AppKitLayoutDemoContainer: NSObject, DSFAppKitBuilderViewHandler {
   lazy var body: Element =
      HStack(spacing: 4) {
         ImageView()
            .image(NSImage(named: "apple_logo_orig")!)           // The image
            .size(width: 42, height: 42, priority: .required)    // fixed size
         VStack(spacing: 2, alignment: .leading) {
            Label("Apple Computer")                              // The label with title 'Name'
               .font(NSFont.systemFont(ofSize: 24))              // Font size 12
               .lineBreakMode(.byTruncatingTail)                 // Truncate line
               .horizontalPriorities(compressionResistance: 100) // Allow the text field to compress
            Label(identityDescription)                           // The description label
               .font(NSFont.systemFont(ofSize: 12))              // Font size 12
               .textColor(.placeholderTextColor)                 // Grey text
               .lineBreakMode(lineBreakMode)                     // Line break mode
               .horizontalPriorities(compressionResistance: 250) // Allow the text field to wrap
         }
         .edgeInsets(6)
      }
      .edgeInsets(8)
      .border(width: 0.75, color: .textColor)
      .backgroundColor(.quaternaryLabelColor)
      .cornerRadius(4)
}
```

To display the builder content, assign the container to an instance of `DSFAppKitBuilderView`

```swift
class ViewController: NSViewController {
   @IBOutlet weak var mainView: DSFAppKitBuilderView!
   let identityContainer = AppKitLayoutDemoContainer()
   override func viewDidLoad() {
      super.viewDidLoad()
      mainView.builder = self.identityContainer  // Set our builder as the view's builder
   }
}
```

### Composing your own element types

If you find that you use a particular grouping of elements over and over, you can create your own `Element` subclass which provides your custom layout as its own .

For example, in a form you may use the label:textfield pattern multiple times.

```
-------------------------------------
|      Label | Text Field           |
-------------------------------------
|      Label | Text Field           |
-------------------------------------
|      Label | Text Field           |
-------------------------------------
```

Create a 'LabelTextPair' `Element` subclass that passes in the label text and a string ValueBinding…

```swift
/// An 'element' class which is a containerized eleement
class LabelTextFieldPair: Element {
   let label: String
   let textValueBinder: ValueBinder<String>
   init(label: String, value: ValueBinder<String>) {
      self.label = label
      self.textValueBinder = value
   }

   // Override the view() call of the `Element` base class to provide the element's body
   override func view() -> NSView { return self.body.view() }

   lazy var body: Element =
      HStack(distribution: .fillProportionally) {
         Label(self.label)
            .font(NSFont.boldSystemFont(ofSize: NSFont.systemFontSize))
            .alignment(.right)
            .width(150)
         TextField()
            .bindText(updateOnEndEditingOnly: true, self.textValueBinder)
            .horizontalPriorities(hugging: 10, compressionResistance: 10)
      }
}
```

Then use it in your code as you would a built-in element type!

```swift
let nameBinder = ValueBinder<String>("")
let usernameBinder = ValueBinder<String>("")
let nicknameBinder = ValueBinder<String>("")

VStack {
   LabelTextFieldPair(label: "Name", value: self.nameBinder)
   LabelTextFieldPair(label: "Username", value: self.usernameBinder)
   LabelTextFieldPair(label: "Nickname", value: self.nicknameBinder)
}
```

### Basic read-only view

You can see this in action in the 'Simple AppKitBuilder Test' demo.

## Behaviours

### Modifiers

Modifiers allow you to change the default behaviour of an element.

**Note:** Unlike SwiftUI modifiers, these modifiers return the original modified object, NOT a copy.

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

#### ValueBinder

A ValueBinder is a shared value container that allows a value to be shared amongst objects, and be notified if and when the value changes.
This is similar to the `@Binding` object in SwiftUI.

You will need to import `DSFValueBinders` to use a ValueBinder within your own code (it will be available to you via `DSFAppKitBuilder`)

```swift
import DSFAppKitBuilder
import DSFValueBinders
```

You can use the binders on an element to bind to a variable creating a two-way communication between element(s) and the controller.

For example, the following code holds the `userName` and `displayName` as member properties in a container class.

* If the code changes `userName` (eg. `userName.wrappedValue = "fish"`) the UI will automatically update with the new value
* If the user changes the value within the `TextField` on-screen, the ValueBinder will automatically reflect the changes

```swift
class MyExcitingViewContainer: NSObject, DSFAppKitBuilderViewHandler {

   // Bind the user name and the display name to fields
   let userName = ValueBinder<String>("")
   let displayName = ValueBinder<String>("")
   	
   // The body of the view
   lazy var body: Element =
      VStack {
         TextField()
            .placeholderText("User Name")
            .bindText(self.userName)
         TextField()
            .placeholderText("Display Name")
            .bindText(self.displayName)
      }
}
```

#### ElementBinder

Some elements (like Popovers) require additional information from the view hierarchy.  For example, a `Popover` needs to be told where to locate itself when it is displayed

This is where `ElementBinder` comes in. Similar to `ValueBinder`, the `ElementBinder` allows you to keep a reference to an element for later use.

```swift
class MyController: NSObject, DSFAppKitBuilderViewHandler {
   let popoverLocator = ElementBinder()
   
   lazy var popover: Popover = Popover {
      Label("This is the content of the popup")
   }

   lazy var body: Element =
      Button("Show Popup") { [weak self] _ in
         guard 
            let `self` = self,
            let element = self.popoverLocator.element 
         else {
            return 
         }
         self.popover.show(
            relativeTo: element.bounds,
            of: element,
            preferredEdge: .maxY
         )
      }
      .bindElement(self.popoverLocator)  // Store a reference to the button for later use
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
| `ComboBox`         | An `NSComboBox` wrapper |
| `DatePicker`         | An `NSDatePicker` wrapper |
| `Divider`<br/>`HDivider/VDivider` | A divider element (a single line, either horizontal or vertical) |
| `EmptyView`        | A spacer view |
| `Grid`             | An `NSGridView` wrapper |
| `Group`            | A element that contains another element |
| `ImageView`        | An `NSImageView` wrapper |
| `Label`            | An `NSTextField` wrapper configured as a read-only label |
| `PathControl`      | An `NSPathControl` wrapper |
| `Popover`          | An `NSPopover` wrapper, uses `DSFMenuBuilder` to generate content |
| `PopupButton`      | An `NSPopupButton` wrapper |
| `ProgressBar`      | An `NSProgressIndicator` wrapper |
| `RadioGroup`       | A grouped stack of buttons configured as a radio group |
| `ScrollView`       | An `NSScrollView` wrapper |
| `SecureTextField`  | An `NSSecureTextField` wrapper |
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
| `Window`           | An `NSWindow` wrapper |
| `ZStack`           | Layer multiple Elements on top of each other |

## Avoiding Retain Cycles

Any time a block is provided to either a `ValueBinder` or an `Element`, if the block captures `self` it is important to make sure that you capture `self` either `weak` or `unowned`.

```swift
let resetEnabled = ValueBinder<Bool>(false)

/// The following binder captures self, which will mean that the element that it is bound to will leak
lazy var badTextBinder = ValueBinder("The initial value") { newValue in
	self.resetEnabled.wrappedValue = !newValue.isEmpty
}

/// The following binder captures self weakly, which means that self is no longer in a retain cycle
lazy var goodTextBinder = ValueBinder("The initial value") { [weak self] newValue in
	self?.resetEnabled.wrappedValue = !newValue.isEmpty
}

...

TextField()
  .bindText(self.badTextBinder)    // <- Text field will leak as self is captured in a retain cycle
```

If you believe you have a leak, you can set `DSFAppKitBuilder.ShowDebuggingOutput = true` to report element deinit calls in the debugger output pane.

## Integration

### Swift package manager

Add `https://github.com/dagronf/DSFAppKitBuilder` to your project.

## Documentation

The code is documented and will produce nice documentation for each element when run through [`jazzy`](https://github.com/realm/jazzy) or similar documentation generator tools.

### Using swift doc
`> swift doc generate  --module-name DSFAppKitBuilder --output docs .`

### Using jazzy
`> jazzy`

## Known bugs

* `SplitView` needs to be a top-level object. They REALLY don't like playing in an autolayout container (eg. embedding a splitview inside a stackview)

### 6.1.0

* Added `DSFAppKitBuilderViewController`.
* Fixed some demo issues.

### 6.0.0

* Changed to use DSFMenuBuilder

### 5.1.0

* Added `NSGridView` support

### 5.0.0

* Some work on windows/sheets and popovers

### 4.3.0

* Added preliminary `NSWindow` support
* Added preliminary `NSPopover` support

### 4.2.1

* Added wraps and truncating support for `Label`

### 4.2.0

* Added support back to 10.11

### 4.1.0

* Added secure text field
* Cleanup the destruction of bindings

### 4.0.2

* Automatically call ValueBinder() callback (if specified) to set initial values.

### 4.0.1

* Fixed bug where slider value binding wasn't updating

### 4.0.0

**BREAKING**

* Moved to using `ValueBinder` instead of `@objc dynamic var` to allow passing bindable dynamic values through to child elements.

### 3.0.1

* Added `PathControl`

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
