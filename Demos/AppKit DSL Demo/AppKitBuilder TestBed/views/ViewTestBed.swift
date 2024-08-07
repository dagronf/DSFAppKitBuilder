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
	var type: String { get }
	var description: String { get }
	var showContentInScroll: Bool { get }
	func build() -> ElementController
}

extension ViewTestBed {
	var showContentInScroll: Bool { true }
}

public class ViewItems {
	let items: [ViewTestBed] = [
		ListBuilder(),
		ComboButtonBuilder(),
		DisclosureViewBuilder(),
		FontBuilder(),
		DatePickerBuilder(),
		ButtonBuilder(),
		GridBuilder(),
		FormBuilder(),
		OneOfBuilder(),
		ToggleBuilder(),
		ColorWellBuilder(),
		PathBuilder(),
		CheckboxBuilder(),
		SearchFieldBuilder(),
		DynamicElementBuilder(),
		VisualEffectBuilder(),
		TokenFieldBuilder(),
		PlainTextViewBuilder(),
		TextFieldBuilder(),
		FlowLayoutBuilder(),
		PopoverSheetBuilder(),
		ZoomableScrollviewBuilder(),
		PanelStyleBuilder(),
		ViewControllerDemoBuilder(),
		BindingsExampleBuilder(),
		LevelIndicatorBuilder(),
		PagerBuilder()
	].sorted { a, b in a.title < b.title }
}
