@freestanding(expression)
public macro slogerr(_ message: String) = #externalMacro(module: "SlogMacroMacros", type: "SlogError")
@freestanding(expression)
public macro slogwarn(_ message: String) = #externalMacro(module: "SlogMacroMacros", type: "SlogWarning")
