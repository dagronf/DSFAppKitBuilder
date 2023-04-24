//
//  PathBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 4/2/2023.
//

import Foundation
import AppKit

import DSFAppearanceManager
import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders

public class PathBuilder: ViewTestBed {
	var title: String { String.localized("Path Control") }
	var type: String { "PathControl" }
	var description: String { String.localized("An Element that presents an NSPathControl") }
	func build() -> ElementController {
		PathBuilderController()
	}
}

extension ValueBinder where ValueType == URL {
	func filePath() -> ValueBinder<String> {
		self.transform { url in
			url.path
		}
	}
}

class PathBuilderController: ElementController {
	deinit {
		Swift.print("PathBuilderController: deinit")
	}

	fileprivate func __getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths.first!
	}

	private lazy var urlPath: ValueBinder<URL> = {
		ValueBinder(__getDocumentsDirectory())
	}()

	struct LabelStyling: DSFAppKitBuilder.LabelStyle {
		@inlinable func apply(_ labelElement: DSFAppKitBuilder.Label) -> DSFAppKitBuilder.Label {
			labelElement
				.font(.subheadline).textColor(.secondaryLabelColor)
				.truncatesLastVisibleLine(true)
				.allowsDefaultTighteningForTruncation(true)
				.lineBreakMode(.byTruncatingHead)
				.horizontalCompressionResistancePriority(.defaultLow)
		}
	}

	// Style structure
	struct RowHeaderStyle: DSFAppKitBuilder.LabelStyle {
		@inlinable func apply(_ labelElement: DSFAppKitBuilder.Label) -> DSFAppKitBuilder.Label {
			labelElement
				.font(.headline.weight(.heavy))
		}
	}

	private func selectFile() {
		let openPanel = NSOpenPanel()
		openPanel.directoryURL = self.urlPath.wrappedValue
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = true
		openPanel.begin { [weak self] (result) -> Void in
			guard let `self` = self else { return }
			if result == NSApplication.ModalResponse.OK,
				let url = openPanel.url {
				self.urlPath.wrappedValue = url
			}
		}
	}


	lazy var body: Element = {
		VStack(alignment: .leading) {
			Grid {
				GridRow(rowAlignment: .lastBaseline) {
					Label("Home:")
						.applyStyle(RowHeaderStyle())
					PathControl(url: FileManager.default.homeDirectoryForCurrentUser)
						.horizontalCompressionResistancePriority(.defaultLow)
						.onClickPathComponent { item in
							let alert = NSAlert()
							alert.messageText = "User clicked component '\(item.title)'"
							alert.runModal()
						}
				}
				GridRow(rowAlignment: .lastBaseline) {
					Label("Documents:")
						.applyStyle(RowHeaderStyle())
					PathControl(url: __getDocumentsDirectory())
						.horizontalCompressionResistancePriority(.defaultLow)
				}
				GridRow(rowAlignment: .lastBaseline) {
					Label("(disabled):")
						.applyStyle(RowHeaderStyle())
					PathControl(url: __getDocumentsDirectory())
						.horizontalCompressionResistancePriority(.defaultLow)
						.isEnabled(false)
				}
				GridRow(rowAlignment: .lastBaseline) {
					Label("Temporary:")
						.applyStyle(RowHeaderStyle())
					PathControl(url: FileManager.default.temporaryDirectory)
						.horizontalCompressionResistancePriority(.defaultLow)
				}

				GridRow(rowAlignment: .firstBaseline) {
					Label("Choose:")
						.applyStyle(RowHeaderStyle())
					VStack(alignment: .leading) {
						HStack(spacing: 2) {
							Button(title: "…", bezelStyle: .roundRect) { [weak self] _ in
								self?.selectFile()
							}
							PathControl(url: FileManager.default.temporaryDirectory)
								.bindURL(urlPath)
								.horizontalCompressionResistancePriority(.defaultLow)
						}
						HStack {
							Button(title: ">", bezelStyle: .circular) { [weak self] _ in
								if let d = self?.urlPath.wrappedValue {
									NSWorkspace.shared.selectFile(d.path, inFileViewerRootedAtPath: "/")
								}
							}
							.controlSize(.small)
							Label("")
								.bindLabel(urlPath.filePath())
								.applyStyle(LabelStyling())
						}
					}
				}
			}
			.columnFormatting(xPlacement: .trailing, atColumn: 0)
			EmptyView()
		}
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct PathBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				PathBuilder().build().body
				DSFAppKitBuilder.EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
