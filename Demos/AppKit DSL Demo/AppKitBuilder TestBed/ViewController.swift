//
//  ViewController.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Cocoa
import DSFAppKitBuilder

class ViewController: NSViewController {

	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var contentView: DSFAppKitBuilderView!

	let viewItems = ViewItems()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.tableView.delegate = self
		self.tableView.dataSource = self

		displayEmptyView()
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in tableView: NSTableView) -> Int {
		viewItems.items.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let c = NSTextField(labelWithString: viewItems.items[row].title)
		c.translatesAutoresizingMaskIntoConstraints = false
		return c
	}

	func displayEmptyView() {
		self.contentView.element = Group(layoutType: .center) { Label("No selection") }
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		let which = self.tableView.selectedRow
		if which < 0 {
			self.displayEmptyView()
		}
		else {
			let v = self.viewItems.items[which]
			contentView.element = ScrollView {
				v.build()
					.padding(8)
			}
		}
	}
}
