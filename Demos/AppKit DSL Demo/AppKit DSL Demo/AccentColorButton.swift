//
//  AccentColorButton.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 22/8/2022.
//

import Foundation
import AppKit

import DSFAppearanceManager

@IBDesignable
class AccentColorButton: NSButton {

	@IBInspectable var fillColor: NSColor = .systemGray {
		didSet {
			self.circle.fillColor = self.fillColor.cgColor
		}
	}
	let circle = CAShapeLayer()

	let selectedCircle = CAShapeLayer()

	override var intrinsicContentSize: NSSize {
		switch controlSize {
		case .large: return NSSize(width: 16, height: 16)
		case .regular: return NSSize(width: 14, height: 14)
		case .small: return NSSize(width: 12, height: 12)
		case .mini: return NSSize(width: 9, height: 9)
		@unknown default:
			fatalError()
		}
	}

	override var wantsDefaultClipping: Bool { false }

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}


	func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.isBordered = false
		self.stringValue = ""
		self.imagePosition = .imageOnly
		self.wantsLayer = true
		self.layer!.addSublayer(circle)

		self.circle.shadowColor = NSColor.shadowColor.cgColor
		self.circle.shadowOffset = CGSize(width: 0.5, height: 1)
		self.circle.shadowOpacity = 0.6
		self.circle.shadowRadius = 2
		self.circle.masksToBounds = false
		self.layer!.masksToBounds = false

		self.selectedCircle.fillColor = .white
		self.selectedCircle.strokeColor = .black.copy(alpha: 0.3)
		self.selectedCircle.lineWidth = 0.5
		self.selectedCircle.zPosition = 10
		self.selectedCircle.shadowColor = NSColor.shadowColor.cgColor
		self.selectedCircle.shadowOffset = CGSize(width: 0.5, height: 1)
		self.selectedCircle.shadowOpacity = 0.4
		self.selectedCircle.shadowRadius = 1
		self.selectedCircle.masksToBounds = false
		self.layer!.masksToBounds = false
		self.layer!.addSublayer(selectedCircle)

		self.setButtonType(.onOff)
	}

	@IBAction func doSomething(_ sender: Any) {

	}

	override var wantsUpdateLayer: Bool { true }

	override func updateLayer() {
		super.updateLayer()
		circle.frame = self.bounds
		circle.path = CGPath(ellipseIn: self.bounds, transform: nil)

		selectedCircle.frame = self.bounds

		let inset: CGFloat = {
			switch self.controlSize {
			case .large: return 5
			case .regular: return 4
			case .small: return 3.5
			case .mini: return 2.5
			@unknown default:
				fatalError()
			}
		}()

		selectedCircle.path = CGPath(ellipseIn: self.bounds.insetBy(dx: inset, dy: inset), transform: nil)

		if DSFAppearanceCache.shared.reduceMotion {
			CATransaction.setDisableActions(true)
		}
		selectedCircle.isHidden = self.state != .on
	}
}

