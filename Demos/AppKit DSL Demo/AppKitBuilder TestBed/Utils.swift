//
//  Utils.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 6/2/2023.
//

import Foundation

extension NumberFormatter {
	convenience init(_ builder: (NumberFormatter) -> Void) {
		self.init()
		builder(self)
	}
}
