//
//  ViewController.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 27/7/21.
//

import Cocoa

import DSFAppKitBuilder

class ViewController: NSViewController {

	@IBOutlet weak var dslView: DSFAppKitBuilderView!

	lazy var primaryLayout = PrimaryDSL()
	lazy var secondaryLayout = SecondaryDSL()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		//dslView.builder = primaryLayout
		dslView.builder = secondaryLayout
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}
