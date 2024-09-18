import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private func createLogExpression(node: some FreestandingMacroExpansionSyntax, level: String) throws -> ExprSyntax {
    guard let argument = node.argumentList.first?.expression else {
        throw MacroExpansionError.missingArgument
    }
    let logMessage = "symlog.\(level)(\"\\(#function): \\(#line): \\(String(describing: \(argument)))\")"
    return ExprSyntax(stringLiteral: logMessage)
}

public struct ALogError: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "error")
    }
}

public struct ALogWarning: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "warning")
    }
}

public struct ALogChange: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "change")
    }
}

public struct ALogNotice: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "notice")
    }
}

public struct ALogInfo: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "info")
    }
}

public struct ALogValue: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "value")
    }
}

public struct ALogLog: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "log")
    }
}

public struct ALogAppear: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "appear")
    }
}

public struct ALogEntry: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "entry")
    }
}

/// System log levels

public struct SLogFault: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "fault")
    }
}

public struct SLogCritical: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "critical")
    }
}

public struct SLogError: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "error")
    }
}

public struct SLogWarning: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "warning")
    }
}

public struct SLogNotice: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "notice")
    }
}

public struct SLogInfo: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "info")
    }
}

enum MacroExpansionError: Error {
    case missingArgument
}

@main
struct SLogPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ALogError.self,
        ALogWarning.self,
        ALogChange.self,
        ALogNotice.self,
        ALogInfo.self,
        ALogValue.self,
        ALogLog.self,
        ALogAppear.self,
        ALogEntry.self,
        SLogFault.self,
        SLogCritical.self,
        SLogError.self,
        SLogWarning.self,
        SLogNotice.self,
        SLogInfo.self
        
    ]
}
