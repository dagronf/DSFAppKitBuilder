//
//  ViewTestBed.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 3/2/2023.
//

import Foundation
import DSFAppKitBuilder

protocol ViewTestBed {
	var title: String { get }
	func build() -> Element
}

public class ViewItems {

	let items: [ViewTestBed] = [
		DisclosureViewBuilder(),
		FontBuilder(),
		DatePickerBuilder(),
		ButtonBuilder(),
	].sorted { a, b in a.title < b.title }

}
