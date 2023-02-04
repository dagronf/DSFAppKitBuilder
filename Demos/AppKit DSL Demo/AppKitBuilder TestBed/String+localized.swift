import Foundation

extension String {
	/// Returns a localized version of the string designated by the specified key and residing in the specified table.
	/// - Parameter key: The key for a string in the table identified by tableName.
	/// - Parameter tableName: The receiver’s string table to search. If tableName is `nil` or is an empty string, the method attempts to use the table in `Localizable.strings`.
	/// - Parameter bundle: The bundle of the string table.
	/// - Parameter value: The value to return if key is nil or if a localized string for key can’t be found in the table.
	/// - Parameter comment: The comment to place above the key-value pair in the strings file. This parameter provides the translator with some context about the localized string’s presentation to the user.
	/// - Returns: A localized version of the string designated by key in table tableName, or `value` if failed.
	@inlinable static func localized(_ key: String, table tableName: String? = nil, bundle: Bundle = .main, value: String = "", comment: String? = nil) -> String {
		NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment ?? key)
	}

	/// Returns a localized version of this string residing in the specified table.
	/// - Parameter tableName: The receiver’s string table to search. If tableName is `nil` or is an empty string, the method attempts to use the table in `Localizable.strings`.
	/// - Parameter bundle: The bundle of the string table.
	/// - Parameter value: The value to return if key is nil or if a localized string for key can’t be found in the table.
	/// - Parameter comment: The comment to place above the key-value pair in the strings file. This parameter provides the translator with some context about the localized string’s presentation to the user.
	/// - Returns: A localized version of the string designated by key in table tableName, or `value` if failed.
	@inlinable func localized(table tableName: String? = nil, bundle: Bundle = .main, value: String = "", comment: String? = nil) -> String {
		NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment ?? self)
	}
}
