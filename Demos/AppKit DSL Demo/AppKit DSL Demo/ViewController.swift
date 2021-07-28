//
//  ViewController.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 27/7/21.
//

import Cocoa

import DSFAppKitBuilder

class ViewController: NSViewController {

	@IBOutlet weak var demo1View: DSFAppKitBuilderView!
	@IBOutlet weak var demo2View: DSFAppKitBuilderView!
	@IBOutlet weak var demo3View: DSFAppKitBuilderView!
	@IBOutlet weak var demo4View: DSFAppKitBuilderView!

	let primaryLayout = PrimaryDSL()
	let secondaryLayout = SecondaryDSL()
	let scrollTest = ScrollerTestDSL()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		demo1View.builder = primaryLayout
		demo2View.builder = secondaryLayout
		demo3View.builder = scrollTest
		//demo4View.builder = ....
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}
