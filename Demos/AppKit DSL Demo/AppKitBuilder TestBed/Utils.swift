//
//  Utils.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 6/2/2023.
//

import Foundation

extension NumberFormatter {
	/// A convenience initializer for creating a NumberFormatter and initializing it using a block
	///
	/// ```swift
	/// let percentFormatter = NumberFormatter {
	///    $0.numberStyle = .percent
	///    $0.maximumFractionDigits = 2
	/// }
	/// ```
	@inlinable convenience init(_ builder: (NumberFormatter) -> Void) {
		self.init()
		builder(self)
	}
}
