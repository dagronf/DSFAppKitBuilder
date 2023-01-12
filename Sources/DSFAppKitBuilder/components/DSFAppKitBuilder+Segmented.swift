//
//  DSFAppKitBuilder+Segmented.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import AppKit.NSSegmentedControl
import DSFValueBinders

// MARK: - Segmented control

/// Wrapper for NSSegmentedControl
///
/// Usage:
///
/// ```swift
/// Segmented(trackingMode: .selectAny) {
///    Segment("One")
///    Segment("Two")
///    Segment("Three")
/// }
/// .bindSelectedSegments(self.selectedSegments)
/// .width(200)
/// .toolTip("Which one")
/// ```
public class Segmented: Control {
	/// Create a segmented control
	/// - Parameters:
	///   - segmentStyle: The style for the segments
	///   - trackingMode: The tracking mode (eg. selectAny, selectOne)
	///   - builder: The resultBuilder to generate the segment items
	public convenience init(
		segmentStyle: NSSegmentedControl.Style? = nil,
		trackingMode: NSSegmentedControl.SwitchTracking? = nil,
		@SegmentBuilder builder: () -> [Segment]
	) {
		self.init(
			segmentStyle: segmentStyle,
			trackingMode: trackingMode,
			content: builder()
		)
	}

	deinit {
		self.selectedSegmentsBinder?.deregister(self)
		self.segmentedEnabledBinder?.deregister(self)
	}

	// The currently selected segments
	var selectedSegments: NSSet {
		let selected = (0 ..< self.segmented.segmentCount).filter { index in
			self.segmented.isSelected(forSegment: index)
		}
		return NSSet(array: selected)
	}

	// Privates
	public override func view() -> NSView { return self.segmented }
	private let segmented = NSSegmentedControl()
	private let content: [Segment]

	private var actionCallback: ((NSSet) -> Void)?

	private var selectedSegmentsBinder: ValueBinder<NSSet>?
	private var segmentedEnabledBinder: ValueBinder<NSSet>?

	init(
		segmentStyle: NSSegmentedControl.Style? = nil,
		trackingMode: NSSegmentedControl.SwitchTracking? = nil,
		content: [Segment]
	) {
		self.content = content
		super.init()

		self.segmented.target = self
		self.segmented.action = #selector(segmentChanged(_:))

		if let s = segmentStyle { self.segmented.segmentStyle = s }
		if let t = trackingMode { self.segmented.trackingMode = t }

		self.segmented.segmentCount = content.count

		(0 ..< content.count).forEach { index in
			if let l = content[index].title {
				self.segmented.setLabel(l, forSegment: index)
			}
			if let i = content[index].textAlignment {
				if #available(macOS 10.13, *) {
					self.segmented.setAlignment(i, forSegment: index)
				} else {
					// Fallback on earlier versions
				}
			}
			if let i = content[index].image {
				self.segmented.setImage(i, forSegment: index)
			}
			if let i = content[index].imageScaling {
				self.segmented.setImageScaling(i, forSegment: index)
			}
			if let i = content[index].toolTip {
				if #available(macOS 10.13, *) {
					self.segmented.setToolTip(i, forSegment: index)
				}
			}
		}
	}
}

// MARK: - Modifiers

public extension Segmented {
	/// Select exactly one segment
	func selectSegment(_ index: Int) -> Self {
		self.selectSegments(from: NSSet(array: [index]))
		return self
	}
}

// MARK: - Actions

public extension Segmented {
	/// Set a callback block for when the selection changes
	func onChange(_ block: @escaping (NSSet) -> Void) -> Self {
		self.actionCallback = block
		return self
	}

	@objc private func segmentChanged(_: Any) {
		self.actionCallback?(self.selectedSegments)

		// Tell the binder to update
		self.selectedSegmentsBinder?.wrappedValue = self.selectedSegments
	}
}

// MARK: - Bindings

public extension Segmented {
	/// Bind enabled state for each segment
	func bindEnabledSegments(_ enabledSegmentsBinder: ValueBinder<NSSet>) -> Self {
		self.segmentedEnabledBinder = enabledSegmentsBinder
		enabledSegmentsBinder.register { [weak self] newValue in
			self?.enableSegments(from: newValue)
		}
		return self
	}

	/// Bind the selected segments
	func bindSelectedSegments(_ selectedSegmentsBinder: ValueBinder<NSSet>) -> Self {
		self.selectedSegmentsBinder = selectedSegmentsBinder
		selectedSegmentsBinder.register { [weak self] newValue in
			self?.selectSegments(from: newValue)
		}
		return self
	}
}

// MARK: - Segment

/// A segment within a segmented control
public class Segment {
	let title: String?
	let textAlignment: NSTextAlignment?
	let image: NSImage?
	let imageScaling: NSImageScaling?
	let toolTip: String?

	/// Create a segment for a segmented control
	/// - Parameters:
	///   - title: The title to use for the segment
	///   - textAlignment: The title's alignment
	///   - image: The segment's image
	///   - imageScaling: How to scale the segment's image
	///   - toolTip: The tooltip for the segment
	public init(
		_ title: String? = nil,
		textAlignment: NSTextAlignment? = nil,
		image: NSImage? = nil,
		imageScaling: NSImageScaling? = nil,
		toolTip: String? = nil
	) {
		self.title = title
		self.textAlignment = textAlignment
		self.image = image
		self.imageScaling = imageScaling
		self.toolTip = toolTip
	}
}

// MARK: - Result Builder for Segments

#if swift(<5.4)
@_functionBuilder
public enum SegmentBuilder {
	static func buildBlock() -> [Segment] { [] }
}
#else
@resultBuilder
public enum SegmentBuilder {
	static func buildBlock() -> [Segment] { [] }
}
#endif

/// A resultBuilder to build menus
public extension SegmentBuilder {
	static func buildBlock(_ settings: Segment...) -> [Segment] {
		settings
	}
}

// MARK: - Private

private extension Segmented {
	func selectSegments(from nsSet: NSSet) {
		(0 ..< self.segmented.segmentCount).forEach { index in
			let value = nsSet.contains(index)
			self.segmented.setSelected(value, forSegment: index)
		}
	}

	func enableSegments(from nsSet: NSSet) {
		(0 ..< self.segmented.segmentCount).forEach { index in
			let value = nsSet.contains(index)
			self.segmented.setEnabled(value, forSegment: index)
		}
	}
}
