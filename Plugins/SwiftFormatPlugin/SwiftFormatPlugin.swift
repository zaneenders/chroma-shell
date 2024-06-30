import Foundation
import PackagePlugin
import RegexBuilder

@main
/// `swift package --allow-writing-to-package-directory format`
@available(macOS 13, *)
struct SwiftFormatPlugin: CommandPlugin {
    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) async throws {
        let swiftFormatTool = try context.tool(named: "swift-format")
        let configFile = context.package.directory
            .appending(".swift-format.json")
        // Package.swift files
        let packages = context.package.directory.appending(
            subpath: "Package.swift")
        var paths = [packages.string]
        // Plugin Files
        let plugins: Path = context.package.directory.appending(
            subpath: "Plugins")
        let plugin_paths = try! FileManager.default.subpathsOfDirectory(
            atPath: plugins.string)
        for p in plugin_paths {
            if p.contains(".swift") {
                paths.append("Plugins/" + p)
            }
        }

        var toFormat = Set<String>()

        for target in context.package.targets {
            toFormat.insert("\(target.directory)")
        }

        paths += Array(toFormat)

        let swiftFormatExec = URL(
            fileURLWithPath: swiftFormatTool.path.string)
        let swiftFormatArgs: [String] = [
            "--configuration", "\(configFile)",
            "--in-place",
            "--recursive",
            "--parallel",
        ]

        let process = try Process.run(
            swiftFormatExec, arguments: swiftFormatArgs + paths)
        for p in paths {
            print("formatting: \(p)")
        }
        process.waitUntilExit()
        if !(process.terminationReason == .exit
            && process.terminationStatus == 0)
        {
            fatalError(
                "\(process.terminationReason):\(process.terminationStatus)")
        }
    }
}

// Saving this to possibly remove the `.swift-format.json` file
// Note moved to
// Sources/SwiftFormat/API/Configuration.swift
/*
var config: Configuration {
    var config = Configuration()
    config.fileScopedDeclarationPrivacy.accessLevel = .private
    config.indentation = .spaces(4)
    config.indentConditionalCompilationBlocks = true
    config.indentSwitchCaseLabels = false
    config.lineBreakAroundMultilineExpressionChainComponents = false
    config.lineBreakBeforeControlFlowKeywords = false
    config.lineLength = 80
    config.maximumBlankLines = 1
    config.prioritizeKeepingFunctionOutputTogether = false
    config.respectsExistingLineBreaks = true
    config.rules["AllPublicDeclarationsHaveDocumentation"] = false
    config.rules["AlwaysUseLowerCamelCase"] = true
    config.rules["AmbiguousTrailingClosureOverload"] = true
    config.rules["BeginDocumentationCommentWithOneLineSummary"] = false
    config.rules["DoNotUseSemicolons"] = true
    config.rules["DontRepeatTypeInStaticProperties"] = true
    config.rules["FileScopedDeclarationPrivacy"] = true
    config.rules["FullyIndirectEnum"] = true
    config.rules["GroupNumericLiterals"] = true
    config.rules["IdentifiersMustBeASCII"] = true
    config.rules["NeverForceUnwrap"] = false
    config.rules["NeverUseForceTry"] = false
    config.rules["NeverUseImplicitlyUnwrappedOptionals"] = false
    config.rules["NoAccessLevelOnExtensionDeclaration"] = true
    config.rules["NoBlockComments"] = true
    config.rules["NoCasesWithOnlyFallthrough"] = true
    config.rules["NoEmptyTrailingClosureParentheses"] = true
    config.rules["NoLabelsInCasePatterns"] = true
    config.rules["NoLeadingUnderscores"] = false
    config.rules["NoParensAroundConditions"] = true
    config.rules["NoVoidReturnOnFunctionSignature"] = true
    config.rules["OneCasePerLine"] = true
    config.rules["OneVariableDeclarationPerLine"] = true
    config.rules["OnlyOneTrailingClosureArgument"] = true
    config.rules["OrderedImports"] = true
    config.rules["ReturnVoidInsteadOfEmptyTuple"] = true
    config.rules["UseEarlyExits"] = false
    config.rules["UseLetInEveryBoundCaseVariable"] = true
    config.rules["UseShorthandTypeNames"] = true
    config.rules["UseSingleLinePropertyGetter"] = true
    config.rules["UseSynthesizedInitializer"] = true
    config.rules["UseTripleSlashForDocumentationComments"] = true
    config.rules["UseWhereClausesInForLoops"] = false
    config.rules["ValidateDocumentationComments"] = false
    config.tabWidth = 4
    return config
}
*/
