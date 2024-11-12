//
//  SymLog.swift
//
//  Created by Dave Carlton on 2/26/24.
//

import OSLog

/// A protocol that defines the requirements for a log category.
///
/// This protocol is used to create custom logging categories that can be used with the SymLog system.
/// It requires conforming types to be `CaseIterable` and `RawRepresentable` with a `String` raw value.
///
/// Conforming types must also provide a static `subsystem` property that returns a `String`.
///
/// - Note: This protocol is typically implemented by an enum to represent different logging categories.
public protocol LogCategory: CaseIterable, RawRepresentable where RawValue == String {
    /// The subsystem identifier for the log category.
    ///
    /// This property should return a string that identifies the subsystem or module
    /// to which this log category belongs.
    static var subsystem: String { get }
    /// The raw string value representing the log category.
    ///
    /// This property should return a unique string identifier for the log category.
    /// It's typically used for serialization or when a string representation of the category is needed.
    static var rawValue: String { get }

    /// The log identifier for the category.
    ///
    /// This property should return a string that uniquely identifies the log category.
    /// It's often used in logging systems to categorize or filter log messages.
    /// The log identifier for the category.
    ///
    /// This static property should return a string that uniquely identifies the log category.
    /// It's often used in logging systems to categorize or filter log messages.
    static var logidentifier: String { get }

    /// The raw string value of the log category.
    ///
    /// This instance property returns the string representation of the log category.
    /// It's typically used for serialization or when a string representation of the category is needed.
    var rawValue: String { get }

    /// Creates a log category instance from a string representation.
    ///
    /// - Parameter string: The string to convert into a log category.
    /// - Returns: An instance of the log category if the string matches a valid category, or nil if no match is found.
    static func from(string: String) -> Self?
}

/// Represents different levels of logging severity.
///
/// This enum defines various log levels that can be used to categorize log messages
/// based on their importance or severity. It also provides a mapping to corresponding
/// `OSLogType` values for integration with Apple's unified logging system.
///
/// - Note: The cases are ordered from least severe to most severe.
public enum LogLevel: String {
    /// General-purpose logging.
    case log
    /// Fine-grained information for debugging.
    case trace
    /// Debugging information.
    case debug
    /// General information about system operation.
    case info
    /// Information that may require attention.
    case notice
    /// Warning conditions.
    case warning
    /// Error conditions.
    case error
    /// Critical conditions that require immediate attention.
    case critical
    /// System is unusable.
    case fault

    /// Converts the `LogLevel` to the corresponding `OSLogType`.
    ///
    /// This property maps the custom log levels to Apple's `OSLogType` for
    /// compatibility with the system logging framework.
    ///
    /// - Returns: The corresponding `OSLogType` for the current log level.
    var osLogType: OSLogType {
        switch self {
        case .log, .trace, .debug: return .debug
        case .info, .notice: return .info
        case .warning: return .default
        case .error, .critical, .fault: return .error
        }
    }
}

/// Extends `OSLog` to include a `logColor` enum for color-coded logging.
extension OSLog {
    /// Represents various colors that can be used for log messages.
    ///
    /// This enum provides a set of predefined colors that can be used to visually
    /// distinguish different types of log messages, enhancing readability and
    /// allowing for quick identification of message categories or severity levels.
    enum logColor {
        /// Red color for log messages.
        case red
        /// Orange color for log messages.
        case orange
        /// Yellow color for log messages.
        case yellow
        /// Green color for log messages.
        case green
        /// Blue color for log messages.
        case blue
        /// Violet color for log messages.
        case violet
        /// Brown color for log messages.
        case brown
        /// White color for log messages.
        case white
        /// Black color for log messages.
        case black
        /// No specific color for log messages (default).
        case none
    }
}

/// A property wrapper that provides a convenient way to log messages with specific categories, colors, and log levels.
///
/// This struct encapsulates the logging functionality, allowing for easy integration of structured logging
/// into Swift properties. It works with a generic `Category` type that conforms to `LogCategory`.
///
/// - Parameters:
///   - symLog: The `SymLog` instance responsible for actual logging.
///   - color: The color to be used for the log message.
///   - level: The severity level of the log message.
///   - category: The category of the log message.
@propertyWrapper
public struct Logging<Category: LogCategory> {
    let symLog: SymLog<Category>
    let color: OSLog.logColor
    let level: LogLevel
    let category: Category

    /// The wrapped value is a closure that takes a string message and logs it.
    ///
    /// - Returns: A closure that accepts a string message and performs the logging operation.
    public var wrappedValue: (String) -> Void {
        { message in
            symLog.log(category: category, message: message, color: color, logLevel: level)
        }
    }
}

/// A wrapper struct that provides dynamic member lookup for logging with specific log levels and colors.
///
/// This struct allows for a more flexible and intuitive way of creating log messages
/// with different categories, colors, and log levels.
///
/// - Parameters:
///   - symLog: The `SymLog` instance responsible for actual logging.
///   - color: The color to be used for the log messages.
///   - level: The severity level of the log messages.
@dynamicMemberLookup
public struct LogLevelWrapper<Category: LogCategory> {
    let symLog: SymLog<Category>
    let color: OSLog.logColor
    let level: LogLevel

    /// Provides dynamic access to logging functions for different categories.
    ///
    /// - Parameter member: A string representing the category name.
    /// - Returns: A closure that takes a string message and logs it with the specified category, color, and log level.
    /// - Precondition: The `member` string must be a valid category name.
    public subscript(dynamicMember member: String) -> (String) -> Void {
        guard let category = Category.from(string: member) else {
            fatalError("Invalid category: \(member)")
        }
        return Logging<Category>(symLog: symLog, color: color, level: level, category: category).wrappedValue
    }
}

/// A generic logging class that provides customizable logging functionality.
///
/// `SymLog` allows for logging messages with different categories, colors, and log levels.
/// It uses emojis to visually represent the subsystem and category of each log message.
///
/// - Note: This class is generic over `Category`, which must conform to `LogCategory`.
public class SymLog<Category: LogCategory> {
    private var logger: Logger
    private let subsystemColor: OSLog.logColor
    private let subsystem: String

    /// Initializes a new `SymLog` instance.
    ///
    /// - Parameters:
    ///   - category: A string representing the logging category.
    ///   - subsystemColor: The color associated with the subsystem.
    init(category: String, subsystemColor: OSLog.logColor) {
        subsystem = Bundle.main.bundleIdentifier ?? "my.default.app"
        logger = Logger(subsystem: subsystem, category: category)
        self.subsystemColor = subsystemColor
    }

    /// Logs a message with the specified category, color, and log level.
    ///
    /// - Parameters:
    ///   - category: The category of the log message.
    ///   - message: The message to be logged.
    ///   - color: The color associated with the log message.
    ///   - logLevel: The severity level of the log message.
    func log(category: Category, message: String, color: OSLog.logColor, logLevel: LogLevel) {
        let formattedMessage = format(message: "\(message)", subsystemColor: subsystemColor, categoryColor: color)
        switch logLevel {
        case .log:
            logger.log("\(formattedMessage)")
        case .trace:
            logger.trace("\(formattedMessage)")
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .notice:
            logger.notice("\(formattedMessage)")
        case .warning:
            logger.warning("\(formattedMessage)")
        case .error:
            logger.error("\(formattedMessage)")
        case .critical:
            logger.critical("\(formattedMessage)")
        case .fault:
            logger.fault("\(formattedMessage)")
        }
    }

    /// Formats the log message with emojis representing the subsystem and category colors.
    ///
    /// - Parameters:
    ///   - message: The original log message.
    ///   - subsystemColor: The color associated with the subsystem.
    ///   - categoryColor: The color associated with the category.
    /// - Returns: A formatted string with color emojis prepended to the message.
private func format(message: String, subsystemColor: OSLog.logColor, categoryColor: OSLog.logColor) -> String {
    let subsystemEmoji = emoji(for: subsystemColor)
    let categoryEmoji = emoji(for: categoryColor)
    let callStackSymbols = Thread.callStackSymbols
    if callStackSymbols.count > 1 {
        let callingFunctionSymbol = callStackSymbols[3]
        let symbol = callingFunctionSymbol.split(separator: " ").first ?? ""
        return "\(symbol)•\(subsystemEmoji) \(categoryEmoji) \(message)"
    }
    return "\(subsystemEmoji) \(categoryEmoji) \(message)"
}
    /// Returns an emoji representation for a given color.
    ///
    /// - Parameter color: The color for which to return an emoji.
    /// - Returns: A string containing the emoji representation of the color.
    private func emoji(for color: OSLog.logColor) -> String {
        switch color {
        case .red: return "\u{1F7E5}"
        case .orange: return "\u{1F7E7}"
        case .yellow: return "\u{1F7E8}"
        case .green: return "\u{1F7E9}"
        case .blue: return "\u{1F7E6}"
        case .violet: return "\u{1F7EA}"
        case .brown: return "\u{1F7EB}"
        case .white: return "\u{2B1C}"
        case .black: return "\u{1F7F0}"
        case .none: return "\u{25A0}"
        }
    }
}

/// Extension to SymLog that provides convenient properties for different log levels.
/// Each property returns a LogLevelWrapper with a specific color and log level.
extension SymLog {
    /// Log with black color and .log level
    public var log: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .black, level: .log) }
    /// Log with brown color and .trace level
    public var trace: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .brown, level: .trace) }
    /// Log with violet color and .debug level
    public var debug: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .violet, level: .debug) }
    /// Log with blue color and .info level
    public var info: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .blue, level: .info) }
    /// Log with green color and .notice level
    public var notice: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .green, level: .notice) }
    /// Log with yellow color and .warning level
    public var warning: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .yellow, level: .warning) }
    /// Log with orange color and .error level
    public var error: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .orange, level: .error) }
    /// Log with red color and .fault level
    public var fault: LogLevelWrapper<Category> { LogLevelWrapper(symLog: self, color: .red, level: .fault) }
}

/// A factory struct for creating CLogger instances with predefined categories and colors.
///
/// This struct allows you to create CLogger instances with a set of predefined categories
/// and their associated colors. It provides a convenient way to ensure consistency
/// across multiple loggers in an application.
public struct CLoggerFactory<Category: LogCategory> {
    /// A dictionary mapping category names to their associated colors.
    let categories: [String: OSLog.logColor]

    /// Initializes a new CLoggerFactory with the given categories and colors.
    ///
    /// - Parameter categories: A dictionary mapping category names to their associated colors.
    init(categories: [String: OSLog.logColor]) {
        self.categories = categories
    }

    /// Creates and returns a new CLogger instance with the predefined categories and colors.
    ///
    /// - Returns: A new CLogger instance configured with the factory's categories and colors.
    public func createLogger() -> CLogger<Category> {
        CLogger<Category>(categories: categories)
    }
}

/// A generic logger struct that provides dynamic logging capabilities for different categories.
///
/// `CLogger` uses the `SymLog` system internally and allows for easy logging with predefined
/// categories and colors. It supports dynamic member lookup for convenient category-based logging.
///
/// - Generic parameter Category: A type conforming to `LogCategory` protocol, used to define logging categories.
public struct CLogger<Category: LogCategory> {
    private let symLog: SymLog<Category>
    private let categories: [String: OSLog.logColor]

    init(categories: [String: OSLog.logColor]) {
        symLog = SymLog<Category>(category: Category.logidentifier, subsystemColor: .black)
        self.categories = categories
    }

    public subscript(dynamicMember member: String) -> (String) -> Void {
        guard let color = categories[member] else {
            fatalError("Invalid category: \(member)")
        }
        guard let category = Category.from(string: member) else {
            fatalError("Invalid category: \(member)")
        }
        return { message in
            self.symLog.log(category: category, message: message, color: color, logLevel: .info)
        }
    }
}

/// Represents the context for logging operations.
///
/// This class encapsulates the necessary information for configuring a logger,
/// including the log identifier, subsystem, and subsystem color.
class LoggerContext {
    public let logid: String
    public let subsystem: String
    public let subsystemColor: OSLog.logColor

    /// Initializes a new LoggerContext instance.
    ///
    /// - Parameters:
    ///   - logid: A unique identifier for the log.
    ///   - subsystem: The subsystem associated with the log.
    ///   - subsystemColor: The color associated with the subsystem for visual distinction in logs.
    public init(logid: String, subsystem: String, subsystemColor: OSLog.logColor) {
        self.logid = logid
        self.subsystem = subsystem
        self.subsystemColor = subsystemColor
    }
}

/// A type-erased log category that conforms to the LogCategory protocol.
///
/// This struct allows for dynamic creation of log categories at runtime,
/// providing flexibility when the exact categories are not known at compile time.
public struct AnyLogCategory: LogCategory {
    public static let subsystem: String = ""
    public static let logidentifier: String = ""
    public static let rawValue: String = "AnyLogCategory"
    public let rawValue: String

    /// Initializes a new AnyLogCategory instance.
    ///
    /// - Parameter rawValue: The string representation of the log category.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates an AnyLogCategory instance from a string, if possible.
    ///
    /// - Parameter string: The string to convert to an AnyLogCategory.
    /// - Returns: An AnyLogCategory instance if the conversion is successful, nil otherwise.
    public static func from(string: String) -> AnyLogCategory? {
        AnyLogCategory(rawValue: string)
    }

    /// Returns an empty array as this won't be used in the current implementation.
    public static var allCases: [AnyLogCategory] {
        [] // This won't be used in our implementation
    }
}

/// LoggerWrapper: A class that provides a convenient interface for category-based logging.
///
/// This class wraps a SymLog instance and allows for dynamic category-based logging.
/// It uses the @dynamicMemberLookup attribute to enable a more intuitive syntax for logging.
///
/// Usage:
/// ```
/// let logger = LoggerWrapper(context: myContext, categories: myCategories)
/// logger.networkCategory("Network request started")
/// logger.uiCategory("Button tapped")
/// ```
///
/// The class is structured as follows:
///
/// 1. Properties:
///    - context: Stores the logging context information.
///    - categories: A dictionary mapping category names to their associated colors.
///    - symLog: The underlying SymLog instance used for actual logging.
///
/// 2. Initializer:
///    - Takes a LoggerContext and a dictionary of categories with their colors.
///    - Sets up the internal properties and initializes the SymLog instance.
///
/// 3. Dynamic Member Lookup:
///    - Implemented through the subscript method.
///    - Allows for dynamic access to logging categories as if they were methods.
///
/// 4. Logging Mechanism:
///    - The subscript method returns a closure that performs the actual logging.
///    - It retrieves the color for the category (or uses .none if not found).
///    - Logs the message using symLog.log() with the specified category, message, color, and a default log level of .info.
///
/// This design provides a user-friendly interface for category-based logging while encapsulating
/// the complexity of the underlying logging system.
@dynamicMemberLookup
public class LoggerWrapper {
    private let context: LoggerContext
    private let categories: [String: OSLog.logColor]
    private let symLog: SymLog<AnyLogCategory>

    init(context: LoggerContext, categories: [String: OSLog.logColor]) {
        self.context = context
        self.categories = categories
        self.symLog = SymLog<AnyLogCategory>(category: context.logid, subsystemColor: context.subsystemColor)
    }

    /// Subscript that enables dynamic category-based logging.
    ///
    /// - Parameter member: The category name as a String.
    /// - Returns: A closure that takes a String message and logs it with the specified category.
    public subscript(dynamicMember member: String) -> (String) -> Void {
        return { message in
            let color = self.categories[member] ?? .none
            self.symLog.log(category: AnyLogCategory(rawValue: member), message: message, color: color, logLevel: .info)
        }
    }
}

/// Creates and returns a new LoggerWrapper instance.
///
/// - Parameters:
///   - logid: A unique identifier for the logger.
///   - subsystem: The subsystem name for the logger.
///   - subsystemColor: The color associated with the subsystem.
///   - categories: A dictionary mapping category names to their associated colors.
///
/// - Returns: A configured LoggerWrapper instance.
///
/// This function serves as a factory method for creating LoggerWrapper instances with specific
/// configurations. It encapsulates the creation process, making it easier to set up loggers
/// with consistent settings across the application.
func createLogger(_ logid: String, subsystem: String, subsystemColor: OSLog.logColor, categories: [String: OSLog.logColor]) -> LoggerWrapper {
    let context = LoggerContext(logid: logid, subsystem: subsystem, subsystemColor: subsystemColor)
    return LoggerWrapper(context: context, categories: categories)
}

// Example of how to define categories
/// Defines an enumeration of log categories for the application.
///
/// This enum conforms to `String`, `LogCategory`, and `CaseIterable` protocols.
/// It provides various categories for different parts of the application logging system.
enum AppLogCategory: String, LogCategory, CaseIterable {
    /// The subsystem identifier for logging.
    static let subsystem = logid

    /// The log identifier for the application.
    static let logidentifier = "app"

    /// Defines various log categories as enum cases.
    /// Each case represents a different area or aspect of the application for logging purposes.
    case entry
    case network
    case ui
    case database
    case auth
    case general
    case performance
    case security
    case analytics
    case thirdPartyServices
    case fileSystem

    /// Provides a static raw value for the enum.
    static var rawValue: String {
        "AppLogCategory"
    }

    /// Attempts to find an `AppLogCategory` case that matches the given string.
    ///
    /// - Parameter string: The string to match against the raw values of `AppLogCategory` cases.
    /// - Returns: The matching `AppLogCategory` case, or `nil` if no match is found.
    ///
    /// This static method performs the following steps:
    /// 1. Iterates through all cases of `AppLogCategory` using `allCases`.
    /// 2. Uses `first` to find the first case whose `rawValue` matches the input string.
    /// 3. Returns the matching case if found, or `nil` otherwise.
    static func from(string: String) -> AppLogCategory? {
        let it = Self.allCases.first { $0.rawValue == string }
        return it
    }
}

#if EXAMPLE
    public let logid = "appexpose"

    enum CExampleCategory: String, LogCategory {
        static let subsystem = logid
        static let logidentifier = "example"

        case changed, loaded, saved, error

        static var rawValue: String { "CExampleCategory" }

        static func from(string: String) -> CExampleCategory? {
            return Self.allCases.first { $0.rawValue == string }
        }
    }

    let clogger = createLogger("example", subsystem: logid, subsystemColor: .blue, categories: [
        "changed": .orange,
        "loaded": .green,
        "saved": .blue,
        "error": .red,
    ])

    // ... (rest of the example code remains the same)

    let networkLogger = SymLog<AppLogCategory>(subsystem: "com.example.myapp", category: "network", subsystemColor: .violet)
    let uiLogger = SymLog<AppLogCategory>(subsystem: "com.example.myapp", category: "ui", subsystemColor: .green)

    func cloggerExample() {
        clogger.changed("Change: New job title")
        clogger.loaded("Job view loaded successfully")
        clogger.saved("Job saved with warnings")
        clogger.error("Failed to load job data")
    }

    func symlogExample1() {
        // Usage examples:
        networkLogger.info.network("Connected to server")
        networkLogger.error.what("Failed to send data")
    }

    func symlogExample2() {
        // Usage examples:
        uiLogger.debug.userInterface("View did load")
        uiLogger.warning.userInterface("Low memory warning received")
    }
#endif
