//
//  DSFAppKitBuilder+Segmented.swift
//
//  Created by Darren Ford on 27/7/21
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

// MARK: - Segment

public class Segment {
	let title: String?
	let textAlignment: NSTextAlignment?
	let image: NSImage?
	let imageScaling: NSImageScaling?
	let toolTip: String?

	public init(_ title: String? = nil,
					_ textAlignment: NSTextAlignment? = nil,
					_ image: NSImage? = nil,
					_ imageScaling: NSImageScaling? = nil,
					toolTip: String? = nil)
	{
		self.title = title
		self.textAlignment = textAlignment
		self.image = image
		self.imageScaling = imageScaling
		self.toolTip = toolTip
	}
}

#if swift(<5.3)
@_functionBuilder
public struct SegmentBuilder {
	static func buildBlock() -> [Segment] { [] }
}
#else
@resultBuilder
public struct SegmentBuilder {
	static func buildBlock() -> [Segment] { [] }
}
#endif

/// A resultBuilder to build menus
public extension SegmentBuilder {
	static func buildBlock(_ settings: Segment...) -> [Segment] {
		settings
	}
}

// MARK: - Segmented control

public class Segmented: Control {
	public override var nsView: NSView { return self.segmented }
	let segmented = NSSegmentedControl()
	let content: [Segment]

	internal init(tag: Int? = nil,
					  segmentStyle: NSSegmentedControl.Style? = nil,
					  trackingMode: NSSegmentedControl.SwitchTracking? = nil,
					  content: [Segment]) {
		self.content = content
		super.init(tag: tag)

		if let s = segmentStyle { self.segmented.segmentStyle = s }
		if let t = trackingMode { self.segmented.trackingMode = t }

		self.segmented.segmentCount = content.count

		(0 ..< content.count).forEach { index in
			if let l = content[index].title {
				self.segmented.setLabel(l, forSegment: index)
			}
			if let i = content[index].textAlignment {
				self.segmented.setAlignment(i, forSegment: index)
			}
			if let i = content[index].image {
				self.segmented.setImage(i, forSegment: index)
			}
			if let i = content[index].imageScaling {
				self.segmented.setImageScaling(i, forSegment: index)
			}
			if let i = content[index].toolTip {
				self.segmented.setToolTip(i, forSegment: index)
			}
		}
	}

	public convenience init(
		tag: Int? = nil,
		segmentStyle: NSSegmentedControl.Style? = nil,
		trackingMode: NSSegmentedControl.SwitchTracking? = nil,
		@SegmentBuilder builder: () -> [Segment])
	{
		self.init(tag: tag, segmentStyle: segmentStyle, trackingMode: trackingMode, content: builder())
	}

	/// Select exactly one segment
	public func selectSegment(_ index: Int) -> Self {
		self.selectSegments(from: NSSet(array: [index]))
		return self
	}

	/// Bind the selected segments to a keypath
	public func bindSelectedSegments<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSSet>) -> Self {
		self.valueBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.selectSegments(from: newValue)
		})
		self.valueBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	private func selectSegments(from nsSet: NSSet) {
		(0 ..< self.segmented.segmentCount).forEach { index in
			let value = nsSet.contains(index)
			self.segmented.setSelected(value, forSegment: index)
		}
	}

	/// Bind enabled state for each segment to a key path
	public func bindEnabledSegments<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSSet>) -> Self {
		self.segmentedEnabledBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.enableSegments(from: newValue)
		})
		self.segmentedEnabledBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	private func enableSegments(from nsSet: NSSet) {
		(0 ..< self.segmented.segmentCount).forEach { index in
			let value = nsSet.contains(index)
			self.segmented.setEnabled(value, forSegment: index)
		}
	}

	/// Set a callback block for when the selection changes
	public func onChange(_ block: @escaping (NSSet) -> Void) -> Self {
		self.actionCallback = block
		self.segmented.target = self
		self.segmented.action = #selector(segmentChanged(_:))
		return self
	}

	@objc private func segmentChanged(_ sender: Any) {
		self.actionCallback?(self.selectedSegments)
	}

	// The currently selected segments
	var selectedSegments: NSSet {
		let selected = (0 ..< self.segmented.segmentCount).filter { index in
			self.segmented.isSelected(forSegment: index)
		}
		return NSSet(array: selected)
	}

	// Privates
	private var actionCallback: ((NSSet) -> Void)? = nil

	private lazy var valueBinder = Bindable<NSSet>()
	private lazy var segmentedEnabledBinder = Bindable<NSSet>()
}