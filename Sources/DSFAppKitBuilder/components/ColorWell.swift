//
//  ColorWell.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AppKit.NSColorWell
import DSFValueBinders

/// A color well
///
/// Note that in later macOS versions (10.15+?) NSColorWell provides an intrinsic control size.
/// If you're targeting earlier versions you will need to provide a size to the control for it to appear.
///
/// Usage:
///
/// ```swift
/// ColorWell(showsAlpha: true)
///    .size(width: 60, height: 40)
///    .onChange { [weak self] color in
///       // Do something with 'color'
/// }
/// ```
public class ColorWell: Control {
	/// Constants that specify the appearance and interaction modes for a color well.
	public enum Style {
		/// The default style for color wells.
		case `default`
		/// A style that adds minimal adornments to the color well (available macOS 13)
		case minimal
		/// A style that supports a color picker popover for fast interactions, and adds a dedicated button to display the color panel. (available macOS 13)
		case expanded
	}

	/// Create a ColorWell
	/// - Parameters:
	///   - style: (macOS 13+) The style for the color well, ignored before macOS 13
	///   - showsAlpha: true if the color well should allow setting the opacity of the returned color
	///   - isBordered: true if the color well has a border
	///   - color: The initial color
	public init(
		style: Style = .default,
		showsAlpha: Bool = false,
		isBordered: Bool = true,
		color: NSColor? = nil
	) {
		if #available(macOS 13, *) {
			self.colorWell = {
				switch style {
				case .`default`: return AlphaCompatibleColorWell(style: .default)
				case .minimal: return AlphaCompatibleColorWell(style: .minimal)
				case .expanded: return AlphaCompatibleColorWell(style: .expanded)
				}
			}()
		}
		else {
			self.colorWell = AlphaCompatibleColorWell()
		}

		super.init()
		self.colorWell.showsAlpha = showsAlpha
		self.colorWell.isBordered = isBordered

		// Capture changes
		self.colorWell.target = self
		self.colorWell.action = #selector(colorChanged(_:))

		if let c = color {
			self.colorWell.color = c
		}
	}

	deinit {
		self.colorBinder?.deregister(self)
	}

	// Privates
	private let colorWell: AlphaCompatibleColorWell
	public override func view() -> NSView { return self.colorWell }

	private var colorBinder: ValueBinder<NSColor>?
	private var actionCallback: ((NSColor) -> Void)? = nil

	@objc private func colorChanged(_ sender: Any) {
		let newColor = self.colorWell.color
		self.actionCallback?(newColor)

		// Tell the binder to update
		self.colorBinder?.wrappedValue = newColor
	}
}

// MARK: - Action callbacks

public extension ColorWell {
	/// Set a callback block for when the color changes
	func onChange(_ block: @escaping (NSColor) -> Void) -> Self {
		self.actionCallback = block
		return self
	}
}

// MARK: - Bindings

public extension ColorWell {
	/// Bind the color
	func bindColor(_ colorBinder: ValueBinder<NSColor>) -> Self {
		self.colorBinder = colorBinder
		colorBinder.register { [weak self] newValue in
			self?.colorWell.color = newValue
		}
		return self
	}
}

// MARK: - Custom Colorwell

internal class AlphaCompatibleColorWell: NSColorWell {
	var showsAlpha: Bool = false

// Workaround for NSColorWell.Style only available on Xcode 14+

#if swift(>=5.7)
	@available(macOS 13.0, *)
	init(style: ColorWell.Style) {
		super.init(frame: .zero)
		self.colorWellStyle = {
			switch style {
			case .`default`: return NSColorWell.Style.default
			case .minimal: return NSColorWell.Style.minimal
			case .expanded: return NSColorWell.Style.expanded
			}
		}()
	}
#else
	init(style: ColorWell.Style) {
		super.init(frame: .zero)
	}
#endif

	init() {
		super.init(frame: .zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func activate(_ exclusive: Bool) {
		NSColorPanel.shared.showsAlpha = self.showsAlpha
		super.activate(exclusive)
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ColorWellPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			Group(layoutType: .center) {
				Grid(columnSpacing: 16) {
					GridRow(rowAlignment: .firstBaseline) {
						Label("Style").font(.title2)
						Label("Bordered").font(.title2)
						Label("No border").font(.title2)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".default").font(.monospaced.size(14))
						ColorWell(style: .default, showsAlpha: true, isBordered: true, color: NSColor.controlAccentColor)
						ColorWell(style: .default, showsAlpha: true, isBordered: false, color: NSColor.controlAccentColor)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".minimal").font(.monospaced.size(14))
						ColorWell(style: .minimal, showsAlpha: true, isBordered: true, color: NSColor.controlAccentColor)
						ColorWell(style: .minimal, showsAlpha: true, isBordered: false, color: NSColor.controlAccentColor)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".expanded").font(.monospaced.size(14))
						ColorWell(style: .expanded, showsAlpha: true, isBordered: true, color: NSColor.controlAccentColor)
						ColorWell(style: .expanded, showsAlpha: true, isBordered: false, color: NSColor.controlAccentColor)
					}
				}
				.columnFormatting(xPlacement: .center, atColumn: 1)
				.columnFormatting(xPlacement: .center, atColumn: 2)
			}
			.SwiftUIPreview()
		}
	}
}
#endif
