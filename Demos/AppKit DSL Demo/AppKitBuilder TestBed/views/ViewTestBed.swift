//
//  ViewTestBed.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 3/2/2023.
//

import Foundation
import DSFAppKitBuilder

protocol ElementController {
	var body: Element { get }
}

protocol ViewTestBed {
	var title: String { get }
	func build() -> ElementController
}

public class ViewItems {
	let items: [ViewTestBed] = [
		ComboButtonBuilder(),
		DisclosureViewBuilder(),
		FontBuilder(),
		DatePickerBuilder(),
		ButtonBuilder(),
		GridBuilder(),
		OneOfBuilder(),
	].sorted { a, b in a.title < b.title }
}
