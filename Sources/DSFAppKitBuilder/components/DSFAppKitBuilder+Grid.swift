//
//  DSFAppKitBuilder+Grid.swift
//
//  Created by Darren Ford on 31/8/21
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

import AppKit.NSView

/// A wrapper for NSGridView. Only available in macOS 10.12 and above
///
/// Usage:
///
/// ```swift
/// Grid {
///    GridRow(bottomPadding: 5) {
///       Label("Braille Translation:")
///       PopupButton {
///          MenuItem(title: "English (Unified)")
///          MenuItem(title: "United States")
///       }
///    }
///    GridRow {
///       Grid.EmptyCell()
///       CheckBox("Show Contracted Braille")
///    }
///    GridRow(bottomPadding: 5) {
///       Grid.EmptyCell()
///       CheckBox("Show Eight Dot Braille")
///    }
/// }
/// ```
@available(macOS 10.12, *)
public class Grid: Element {
	/// An empty cell element for grid cells that contain no element content
	public static func EmptyCell() -> Element {
		return Grid.EmptyCellInstance
	}

	/// Create a Grid
	/// - Parameter builder: The builder for the rows for the grid
	public init(@GridRowBuilder builder: () -> [GridRow]) {
		self.rows = builder()
		super.init()

		self.rows.enumerated().forEach { row in
			let currentRowCells = row.1.rowCells
			let rowCellViews = currentRowCells.map { $0.view() }
			self.gridView.addRow(with: rowCellViews)
			let rowItem = self.gridView.row(at: row.0)
			rowItem.topPadding = row.1.topPadding
			rowItem.bottomPadding = row.1.bottomPadding
			rowItem.rowAlignment = row.1.rowAlignment

			// Merge the cells that were specified
			row.1.mergedCells.forEach { range in
				rowItem.mergeCells(in: NSRange(range))
			}
		}
	}

	deinit {
		self.hiddenRowsBinder?.deregister(self)
	}

	// Private
	override public func view() -> NSView { return self.gridView }
	override public func childElements() -> [Element] {
		return self.rows
			.map { $0.rowCells }
			.reduce([]) { partialResult, elements in
				partialResult + elements
			}
	}

	private let gridView = NSGridView()
	private var hiddenRowsBinder: ValueBinder<NSSet>?
	private var hiddenColumnsBinder: ValueBinder<NSSet>?
	private var rows: [GridRow] = []

	// Empty View placeholder
	private static let EmptyCellInstance = EmptyCellObject()
	private class EmptyCellObject: Element {
		override public func view() -> NSView {
			return NSGridCell.emptyContentView
		}
	}
}

@available(macOS 10.12, *)
public extension Grid {
	// Columns

	/// Set the formatting for an entire column
	/// - Parameters:
	///   - xPlacement: The xPlacement
	///   - leadingPadding: The padding to apply to the leading side of the column
	///   - trailingPadding: The padding to apply to the trailing side of the column
	///   - col: The column to apply the formatting to
	/// - Returns: self
	func columnFormatting(
		xPlacement: NSGridCell.Placement? = nil,
		leadingPadding: CGFloat? = nil,
		trailingPadding: CGFloat? = nil,
		atColumn col: Int
	) -> Self {
		let column = self.gridView.column(at: col)
		if let x = xPlacement {
			column.xPlacement = x
		}
		if let t = leadingPadding {
			column.leadingPadding = t
		}
		if let b = trailingPadding {
			column.trailingPadding = b
		}
		return self
	}

	/// Merge the specified cell indexes in 'row'
	func mergeRowCells(_ columnIndexes: ClosedRange<Int>, inRowIndex row: Int) -> Self {
		self.gridView.row(at: row).mergeCells(in: NSRange(columnIndexes))
		return self
	}

	/// Merge the specified row indexes in 'column'
	func mergeColumnCells(_ rowIndexes: ClosedRange<Int>, inColumnIndex column: Int) -> Self {
		self.gridView.column(at: column).mergeCells(in: NSRange(rowIndexes))
		return self
	}
}

// MARK: - Cell Options

@available(macOS 10.12, *)
public extension Grid {
	/// Format a cell within the grid
	/// - Parameters:
	///   - xPlacement: Set the xPlacement for the cell
	///   - yPlacement: Set the yPlacement for the cell
	///   - rowAlignment: The cell alignment
	///   - row: The row of the cell to modify
	///   - column: The column of the cell to modify
	func cellFormatting(
		xPlacement: NSGridCell.Placement = .inherited,
		yPlacement: NSGridCell.Placement = .inherited,
		rowAlignment: NSGridRow.Alignment = .inherited,
		atRowIndex row: Int,
		columnIndex column: Int
	) -> Self {
		let cell = self.gridView.cell(atColumnIndex: column, rowIndex: row)
		cell.xPlacement = xPlacement
		cell.yPlacement = yPlacement
		cell.rowAlignment = rowAlignment
		return self
	}

	/// Add custom constraints to a cell
	/// - Parameters:
	///   - row: the cell's row
	///   - column: the cell's column
	///   - constraintBuilder: A block which returns an array of constraints to add
	/// - Returns: self
	func addingCellContraints(
		atRowIndex row: Int,
		columnIndex column: Int,
		_ constraintBuilder: () -> [NSLayoutConstraint]
	) -> Self {
		let cell = self.gridView.cell(atColumnIndex: column, rowIndex: row)
		let additionalConstraints = constraintBuilder()
		if additionalConstraints.count > 0 {
			cell.customPlacementConstraints.append(contentsOf: additionalConstraints)
		}
		return self
	}
}

// MARK: - Bindings

@available(macOS 10.12, *)
public extension Grid {
	/// A binding for hiding or showing rows within the grid
	func bindHiddenRows(_ hiddenRowsBinder: ValueBinder<NSSet>) -> Self {
		self.hiddenRowsBinder = hiddenRowsBinder
		hiddenRowsBinder.register(self) { [weak self] newValue in
			guard let `self` = self else { return }
			(0 ..< self.gridView.numberOfRows).forEach { rowIndex in
				self.gridView.row(at: rowIndex).isHidden = newValue.contains(rowIndex)
			}
		}
		return self
	}

	/// A binding for hiding or showing columns within the grid
	func bindHiddenColumns(_ hiddenColumnsBinder: ValueBinder<NSSet>) -> Self {
		self.hiddenColumnsBinder = hiddenColumnsBinder
		hiddenColumnsBinder.register(self) { [weak self] newValue in
			guard let `self` = self else { return }
			(0 ..< self.gridView.numberOfColumns).forEach { colIndex in
				self.gridView.column(at: colIndex).isHidden = newValue.contains(colIndex)
			}
		}
		return self
	}
}

// MARK: - Grid Content Priorities

@available(macOS 10.12, *)
public extension Grid {
	/// Set the content hugging priorites for the grid
	func contentHuggingPriority(
		h: NSLayoutConstraint.Priority? = nil,
		v: NSLayoutConstraint.Priority? = nil
	) -> Self {
		if let h = h {
			self.view().setContentHuggingPriority(h, for: .horizontal)
		}
		if let v = v {
			self.view().setContentHuggingPriority(v, for: .vertical)
		}
		return self
	}

	/// Set the content hugging priorites for the grid
	func contentHuggingPriority(h: Float? = nil, v: Float? = nil) -> Self {
		return self.contentHuggingPriority(
			h: NSLayoutConstraint.Priority.ValueOrNil(h),
			v: NSLayoutConstraint.Priority.ValueOrNil(v)
		)
	}
}

// MARK: - Grid Row

/// A row for the grid
@available(macOS 10.12, *)
public class GridRow {
	/// Create a new row for the grid
	/// - Parameters:
	///   - topPadding: Extra padding for the top of the row
	///   - bottomPadding: Extra padding for the bottom of the row
	///   - rowAlignment: The vertical alignment of items in the row. Defaults to .inherited
	///   - builder: The builder for the row elements
	public init(
		topPadding: CGFloat = 0,
		bottomPadding: CGFloat = 0,
		rowAlignment: NSGridRow.Alignment = .inherited,
		mergeCells: [ClosedRange<Int>] = [],
		@ElementBuilder builder: () -> [Element]
	) {
		self.rowCells = builder()
		self.topPadding = topPadding
		self.bottomPadding = bottomPadding
		self.rowAlignment = rowAlignment
		self.mergedCells = mergeCells
	}

	deinit {
		Logger.Debug("Element [\(type(of: self))] deinit")
	}

	fileprivate let topPadding: CGFloat
	fileprivate let bottomPadding: CGFloat
	fileprivate let rowAlignment: NSGridRow.Alignment
	fileprivate let mergedCells: [ClosedRange<Int>]
	fileprivate let rowCells: [Element]
}

// MARK: - Result Builder for Grid Rows

#if swift(<5.3)
@available(macOS 10.12, *)
@_functionBuilder
public enum GridRowBuilder {
	static func buildBlock() -> [GridRow] { [] }
}
#else
@available(macOS 10.12, *)
@resultBuilder
public enum GridRowBuilder {
	static func buildBlock() -> [GridRow] { [] }
}
#endif

@available(macOS 10.12, *)
public extension GridRowBuilder {
	static func buildBlock(_ settings: GridRow...) -> [GridRow] {
		settings
	}
}
