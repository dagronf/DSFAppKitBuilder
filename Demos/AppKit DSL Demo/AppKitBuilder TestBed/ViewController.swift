//
//  ViewController.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Cocoa
import DSFAppKitBuilder
import DSFToolbar
import DSFMenuBuilder
import DSFValueBinders

class ViewController: NSViewController {

	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var contentView: DSFAppKitBuilderView!

	var controller: ElementController?
	private let scalingMenuItem = ScalingMenuViewController()

	let viewItems = ViewItems()

	lazy var scaleMenu = createScaleFontMenu()
	lazy var customToolbar = createToolbar()

	let headlineFont: AKBFont = .title1.weight(.medium)
	let typeFont: AKBFont = .title1.weight(.medium).withSymbolicTraits(.monoSpace)
	let descriptionFont: AKBFont = .system

	private let selectedScaleIndex = ValueBinder(3)

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.tableView.delegate = self
		self.tableView.dataSource = self

		displayEmptyView()
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		customToolbar.attachedWindow = self.view.window
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
		self.contentView.element = Group(layoutType: .center) {
			Label(String.localized("No selection"))
				.dynamicFont(.system)
		}
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		self.controller = nil
		let which = self.tableView.selectedRow
		if which < 0 {
			self.displayEmptyView()
		}
		else {
			let newItem = self.viewItems.items[which]
			let newController = newItem.build()

			// Hold on to the controller so we can use ValueBinders etc.
			controller = newController

			let content: Element = {
				if newItem.showContentInScroll {
					return ScrollView(borderType: .noBorder, fitHorizontally: true) {
						newController.body
							.horizontalHuggingPriority(10)
							.padding(8)
					}
				}
				else {
					return newController.body
						.horizontalHuggingPriority(10)
						.padding(8)
				}
			}()

			contentView.element =
				VStack(spacing: 0, alignment: .leading) {
					VisualEffectView(effect: .init(material: .titlebar), padding: 8) {
						VStack(alignment: .leading) {
							HStack {
								Label(newItem.title)
									.dynamicFont(self.headlineFont)
									.applyStyle(Label.Styling.truncatingTail)
								Maybe(!newItem.type.isEmpty) {
									Label("(\(newItem.type))")
										.dynamicFont(self.typeFont)
										.applyStyle(Label.Styling.truncatingTail)
								}
							}
							Label(newItem.description)
								.isSelectable(true)
								.dynamicFont(self.descriptionFont)
								.applyStyle(Label.Styling.multiline)
						}
						.hugging(h: 10, v: 999)
					}

					HDivider()

					content
				}
		}
	}
}

extension ViewController {

	private func setScaleFraction(_ fraction: Double) {
		DynamicFontService.shared.scale(by: fraction)
	}

	private func createScaleFontMenu() -> DSFMenuBuilder.Menu {
		DSFMenuBuilder.Menu {
			MenuItem("25%")
				.onAction { [weak self] in self?.setScaleFraction(0.25) }
			MenuItem("50%")
				.onAction { [weak self] in self?.setScaleFraction(0.50) }
			MenuItem("75%")
				.onAction { [weak self] in self?.setScaleFraction(0.75) }
			MenuItem("100%")
				.onAction { [weak self] in self?.setScaleFraction(1.00) }
			MenuItem("125%")
				.onAction { [weak self] in self?.setScaleFraction(1.25) }
			MenuItem("150%")
				.onAction { [weak self] in self?.setScaleFraction(1.50) }
			MenuItem("200%")
				.onAction { [weak self] in self?.setScaleFraction(2.00) }
			MenuItem("300%")
				.onAction { [weak self] in self?.setScaleFraction(3.00) }
			MenuItem("400%")
				.onAction { [weak self] in self?.setScaleFraction(4.00) }
			Separator()
			ViewItem("scale", self.scalingMenuItem)
		}
	}

	private func createToolbar() -> DSFToolbar {
		DSFToolbar("Main Toolbar", allowsUserCustomization: true) {
			DSFToolbar.PopupMenu("font-scale", menu: self.scaleMenu.menu)
				.label("Scale")
				.legacySizes(minSize: NSSize(width: 72, height: 14))
				.bindSelectedIndex(self.selectedScaleIndex)
		}
	}
}

class ScalingMenuViewController: NSViewController {
	deinit { Swift.print("ScalingMenuViewController: deinit") }
	override func loadView() {
		let v = DSFAppKitBuilderView {
			VStack(alignment: .leading) {
				Label("Scaling").font(.systemSmall)
				Slider(DynamicFontService.shared.currentScale, range: 0.25 ... 4.0)
					.numberOfTickMarks(5)
					.controlSize(.small)
			}
			.stackPadding(NSEdgeInsets(top: 0, left: 16, bottom: 4, right: 16))
			.width(150)
		}
		self.view = v
	}
}
