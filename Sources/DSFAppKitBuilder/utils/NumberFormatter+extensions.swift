//
//  File.swift
//  
//
//  Created by Darren Ford on 14/2/2023.
//

import Foundation

extension NumberFormatter {
	convenience init(_ block: (NumberFormatter) -> Void) {
		self.init()
		block(self)
	}
}
