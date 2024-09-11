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

public struct SlogError: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "error")
    }
}

public struct SlogWarning: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        try createLogExpression(node: node, level: "warn")
    }
}


enum MacroExpansionError: Error {
    case missingArgument
}

@main
struct SlogPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SlogError.self,
        SlogWarning.self,
    ]
}
