@freestanding(expression)
public macro alogerr(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogError")

@freestanding(expression)
public macro alogwarn(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogWarning")

@freestanding(expression)
public macro alogchange(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogChange")

@freestanding(expression)
public macro alogmotice(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogNotice")

@freestanding(expression)
public macro aloginfo(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogInfo")

@freestanding(expression)
public macro alogvalue(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogValue")

@freestanding(expression)
public macro aloglog(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogLog")

@freestanding(expression)
public macro alogappear(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogAppear")

@freestanding(expression)
public macro alogentry(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogEntry")

@freestanding(expression)
public macro alogverbose(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "ALogVerbose")

@freestanding(expression)
public macro slogtrace(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogTrace")

@freestanding(expression)
public macro slog(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogLog")

@freestanding(expression)
public macro slogdebug(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogDebug")

@freestanding(expression)
public macro sloginfo(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogInfo")

@freestanding(expression)
public macro slognotice(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogNotice")

@freestanding(expression)
public macro slogwarning(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogWarning")

@freestanding(expression)
public macro slogerror(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogError")

@freestanding(expression)
public macro slogcritical(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogCritical")

@freestanding(expression)
public macro slogfault(_ message: String) = #externalMacro(module: "SLogMacroPlugin", type: "SLogFault")



